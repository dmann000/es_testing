$mydocs = [Environment]::GetFolderPath("MyDocuments")
# this run works!
$data = import-csv ($mydocs + "\Github\es_testing\cleanup\cleanup.csv") # | Sort-Object -Property "Date/Time" -unique

foreach($line in $data){
    $datetime = $line.'Date/Time' -split '  '
    $date = $datetime[0]
    $date = $date -replace '\d{2}(\d{2})(\d{2})(\d{2})', '$2/$3/$1'
    $date = $date -as [datetime]
    $date = $date | get-date -Format M/dd/yyyy
    $time = $datetime[1]

    #$new = new-object PSObject
    $line | Add-member -name Date -value $date -MemberType NoteProperty
    $line | Add-Member -name Time -Value $time -MemberType NoteProperty

}

$data = $data | Select-Object -Property Date,Time,Open,High,Low,Close,Volume,Count,WAP,HasGaps

$data | Export-Csv ($mydocs + "\Github\es_testing\cleaned\cleaned.csv") -NoTypeInformation
