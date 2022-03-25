# DoomedLinkFinder
Canvas LMS hardlink finder for exported courses (*imscc files)<br>
How to use:<br>
1.)  Copy and paste code into PowerShell <b>ISE</b><br>
2.)  <b>IMPORTANT!!  SET CANVAS SERVER URL (the default is <i>https://example.university.edu/</i>) inside the code to your Canvas Server</b><br>
3.)  Browse to your exported *.imscc file<br>
4.)  The file BrokenLinks.txt inside your %USERPROFILE%/Downloads folder will have all the links that failed to export<br>
5.)  All links are grouped together under the page they are located in above them<br>
6.)  If an html file name has no href= links under it, then that means that page has no broken links<br>
<br>
<b>Note:</b>  The script simply appends each report to the same BrokenLinks.txt file in your Downloads folder.  Each run is separated by a data/time stamp header.  If you desire a clean BrokenLinks.txt with only one run, simply delete it, rename it, or move it and run the script again.
