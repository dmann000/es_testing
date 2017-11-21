$mydocs = [Environment]::GetFolderPath("MyDocuments")
# this run works!
$data = import-csv ($mydocs + "\Github\es_testing\cleanup.csv") | Sort-Object -Property "Date/Time" -unique

# $inputCsv | Export-Csv "$input-temp.csv" -NoTypeInformation