# DoomedLinkFinder
Canvas LMS hardlink finder for exported courses (*imscc files)<br>
How to use:<br>
1.)  Copy and paste code into PowerShell <b>ISE</b><br>
2.)  <b>IMPORTANT!!  SET CANVAS SERVER URL (the default is <i>https://example.university.edu/</i>) inside the code to your Canvas Server</b><br>
3.)  Browse to your exported *.imscc file<br>
4.)  The *.txt file inside your %USERPROFILE%/Downloads folder will have all the links that failed to export<br>
5.)  The *.csv tile inside your %USERPROFILE%/Downloads folder will have a table of the files and hashes.<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(You can use these to idenfity duplicate files even if they have different paths or file names.)<br>
6.)  All links are grouped together under the page they are located in above them<br>
7.)  If an html file name has no href= links under it, then that means that page has no broken links<br>
8.)  In addition, a list of all files that the script couldn't find used in a link are listed as Orphaned files<br><br>
