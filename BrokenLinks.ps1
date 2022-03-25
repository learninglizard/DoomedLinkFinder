# How to use:
# Run in PowerShell ISE
# Browse to your exported *.imscc file
# The file BrokenLinks.txt inside your %USERPROFILE%/Downloads folder will have all the links that failed to export
# All links are grouped together under the page they are located in above them
# If an html file name has no href= links under it, then that means that page has no broken links
# import .NET 4.5 compression utilities so we can work with zip files in memory
    Add-Type -AssemblyName System.IO.Compression;
    Add-Type -AssemblyName System.IO.Compression.FileSystem;
Clear-Host

# USER must configure!!
# Set the Canvas Server courses URL
Set-Variable CanvasServerURL -Option ReadOnly -Value https://example.university.edu/ -Force
# Builds the link regexp for finding broken links
$RegExpStringPattern = "href=`"" + $CanvasServerURL + "courses.*?`""
# Selects the folder in the *imscc file that stores the pages for your course
$CanvasPagesFolder = ".*\wiki_content\.*"

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
"##################################################################" | Out-File $env:USERPROFILE\Downloads\BrokenLinks.txt -Append
Get-Date | Out-File $env:USERPROFILE\Downloads\BrokenLinks.txt -Append
"##################################################################" | Out-File $env:USERPROFILE\Downloads\BrokenLinks.txt -Append

$zip = [IO.Compression.ZipFile]::OpenRead($FileBrowser.FileName)
    # Returns an object (FailedExportedLinks) with all the broken links
    $zip.Entries |
        # The file will be everything in the web_resources folder
        Where-Object { $_.FullName -match $CanvasPagesFolder } |
        ForEach-Object { "`n" + $_.FullName.Substring(13) | Out-File $env:USERPROFILE\Downloads\BrokenLinks.txt -Append
        # Create a stream reader to read the memory contents as UTF8 text
        $fileReader = [System.IO.StreamReader]::new($_.Open(), [Text.Encoding]::Utf8)
        # Read the lines of each file in wiki_content until there are no more lines to read
        [string[]]$lines = while($null -ne ($line = $fileReader.ReadLine())){ $line }
        $lines | Select-String -Pattern $RegExpStringPattern -AllMatches | %{$_.Matches} |
        %{$_.Value} | Out-File $env:USERPROFILE\Downloads\BrokenLinks.txt -Append
        }

$scriptRuntime.Stop()
Write-Output ("The script has completed!", "" ,
    ("Script completed in " + $scriptRuntime.Elapsed.Minutes +
    " minutes and " + $scriptRuntime.Elapsed.Seconds + " seconds.",
    "`n`n I've appended the links (each run is separted with the date and time) `n which failed to export properly to the file located in: `n`n", $env:USERPROFILE+"\Downloads\"+"BrokenLinks.txt"))