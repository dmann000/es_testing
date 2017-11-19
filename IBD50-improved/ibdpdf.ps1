#location of pdftotext program (download xpdfbin for windows
$pdftotext = "C:\Program Files\xpdfbin-win-3.04\bin64\pdftotext.exe"
# path within GitHub directory for sharing if needed
$path = [environment]::getfolderpath("mydocuments") + "\Github\PDF\"
cd $path

# get list of items in path - grab the name of each file
$list = (get-childitem -Filter *.pdf).Name

# set count to 0 for counting
$count = 0
foreach ($pdf in $list){
$count = $count + 1 #increase count
write-host "$count Converting $pdf"
$text = $pdf.Split(".")[0]+".txt" #convert the .pdf extention to .txt
if (Test-Path $path\text\$text){
    write-host $text already exists
    }Else{
        & 'C:\Program Files\xpdfbin-win-3.04\bin64\pdftotext.exe' -raw $path\$pdf $path\text\$text # run conversion from pdf to txt using the "raw" format
}
}
write-host "Converted $count pdf files to text"