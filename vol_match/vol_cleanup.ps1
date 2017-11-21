$mydocs = [Environment]::GetFolderPath("MyDocuments")
# this run works!
$newer = import-csv ($mydocs + "\Github\es_testing\vol_match\newer.csv") | Sort-Object -Property "Date/Time" -unique
$older = import-csv ($mydocs + "\Github\es_testing\vol_match\older.csv") | Sort-Object -Property "Date/Time" -unique

foreach($line in $newer){
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

$newer = $newer | Select-Object -Property Date,Time,Open,High,Low,Close,Volume,Count,WAP,HasGaps

foreach($line in $older){
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

$older = $older | Select-Object -Property Date,Time,Open,High,Low,Close,Volume,Count,WAP,HasGaps


$newdates = foreach($line in $newer){get-date $line.date -Format M/dd/yyyy}
$newdates = $newdates | get-unique

$olddates = foreach($line in $newer){get-date $line.date -Format M/dd/yyyy}
$olddates = $olddates | get-unique

$newvol = @()

# stopping here

# working on summing volume for both new and old data...
# then will do a compare or something and spit out where to split?  then maybe have the script combine them for me...

foreach($day in $newdates){
    $temp = $newer | where-object -Property Date -EQ $day
    $temp | Measure-Object -sum -Property Volume
}