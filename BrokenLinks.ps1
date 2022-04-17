# How to use:
# Run in PowerShell ISE
# Browse to your exported *.imscc file
# The report file will appear inside your %USERPROFILE%/Downloads folder
# All links are grouped together under the page they are located in above them
# If an html file name has no href= links under it, then that means that page has no broken links
# Orphaned files are files located in web_resources folder that don't seem to be linked anywhere in the course
# import .NET 4.5 compression utilities so we can work with zip files in memory
    Add-Type -AssemblyName System.IO.Compression;
    Add-Type -AssemblyName System.IO.Compression.FileSystem;
    Add-Type -AssemblyName System.Windows.Forms;
    Add-Type -AssemblyName System.Web;
Clear-Host

# USER must check / configure!!
# Set the Canvas Server courses URL
Set-Variable CanvasServerURL -Option ReadOnly -Value https://example.univeristy.edu/ -Force
Set-Variable CanvasRootVar -Option ReadOnly -Value %24IMS-CC-FILEBASE%24/ -Force
Set-Variable ReportPath -Option ReadOnly -Value "$env:USERPROFILE\Downloads\Doomed Links and Orphaned Files.txt" -Force
# Filters for all .html files in the common cartridge file
Set-Variable Filter -Option ReadOnly -Value "*.html" -Force
# Files directory
Set-Variable FileDirectory -Option ReadOnly -Value ".*\web_resources\.*" -Force
# Builds the link regexp for finding broken links
$HardLinkRegExpStringPattern = "href=`"" + $CanvasServerURL + "courses.*?`""
# RegEx for all html links (href="")
$HREFRegExpStringPattern = "href=`"" + "*?`""

Write-Output "`nYour canvas server URL is set to: " $CanvasServerURL
Write-Output "`nIf this is incorrect, please configure in the top of the script`n`n"

# Crappy File Browsing Dialog
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
$FileBrowser.filter = "Canvas Export Files (*.imscc)| *.imscc"
$FileBrowser.InitialDirectory = $env:USERPROFILE+'\Downloads'
$result = $FileBrowser.ShowDialog()
    if ($result -eq "Cancel")
        {
            Write-Output ("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
            "File browsing cancelled. Exiting.",
            "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX`n")
            return
    }
$FileBrowser.FileName
# Er body likes progress bars and metrics
$scriptRuntime = [System.Diagnostics.Stopwatch]::StartNew()
# Generate a header banner for each run of the script that will appear in the output file
"`n`n##################################################################`n" | Out-File $ReportPath -Append
Get-Date | Out-File $ReportPath -Append
"##################################################################" | Out-File $ReportPath -Append

# Open zip file
$zip = [IO.Compression.ZipFile]::OpenRead($FileBrowser.FileName)

# Improperly exported links section
$zip.Entries |
        Where-Object { $_.FullName -like $Filter } |
        ForEach-Object { "`n" + $_.FullName.Substring(13) | Out-File $ReportPath -Append
        # Create a stream reader to read the memory contents as UTF8 text
        $fileReader = [System.IO.StreamReader]::new($_.Open(), [Text.Encoding]::Utf8)
        # Read the lines of each file until there are no more lines to read
        [string[]]$lines = while($null -ne ($line = $fileReader.ReadLine())){ $line }
        # If any links match the regex, write them to the list of broken links
        $lines | Select-String -Pattern $HardLinkRegExpStringPattern -AllMatches | %{$_.Matches} |
        %{$_.Value} | Out-File $ReportPath -Append
        }

# Orphaned Files section
"`n##################################################################`n" +
"        Orphaned Files in the `"Files`" / `"web_resources`" directory`n" +
"##################################################################`n" |
Out-File $ReportPath -Append

# Encode all file names in the web_resources folder to percent encoding so that we can partial match
$URLEncodedFileNames = $zip.Entries | Where-Object {$_.FullName -match $FileDirectory} |
ForEach-Object {[System.Web.HTTPUtility]::UrlEncode($_.Name)}
    
# Collect all file links that meet the filter critera in the common cartridge file
$AllFileLinks = $zip.Entries |
    Where-Object { $_.FullName -like $Filter } |
    ForEach-Object { 
    # Create a stream reader to read the memory contents as UTF8 text
    $fileReader = [System.IO.StreamReader]::new($_.Open(), [Text.Encoding]::Utf8)
    # Read the lines of each file until there are no more lines to read
    [string[]]$lines = while($null -ne ($line = $fileReader.ReadLine())){ $line }
    $lines | Select-String -Pattern $HREFRegExpStringPattern -AllMatches |
    %{$_.Matches} | %{$_.Value}
    }

# Check and see if each file is linked at least once in course
    # Build a special regex for the array
    [regex]$Match_regex = ‘(‘ + (($AllFileLinks |foreach {[regex]::escape($_)}) –join “|”) + ‘)’
    # Generate array of files which can't be found in the links in the course
    $URLEncodedFileNames -notmatch $Match_regex |
    ForEach-Object {[System.Web.HTTPUtility]::UrlDecode($_)} |
    Out-File $ReportPath -Append

$scriptRuntime.Stop()
Write-Output ("The script has completed!", "" ,
    ("Script completed in " + $scriptRuntime.Elapsed.Minutes +
    " minutes and " + $scriptRuntime.Elapsed.Seconds + " seconds.",
    "`n`n I've appended the links (each run is separted with the date and time) `n which failed to export properly to the file located in: `n`n", $ReportPath))