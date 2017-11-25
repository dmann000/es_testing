﻿$mydocs = [Environment]::GetFolderPath("MyDocuments")
# this run works!
$newer = import-csv ($mydocs + "\Github\es_testing\vol_match\newer.csv") | Sort-Object -Property "Date/Time" -unique
$older = import-csv ($mydocs + "\Github\es_testing\vol_match\older.csv") | Sort-Object -Property "Date/Time" -unique
$cleaned = import-csv ($mydocs + "\Github\es_testing\cleaned\cleaned.csv")

foreach($line in $newer){
    $datetime = $line.'Date/Time' -split '  '
    $date = $datetime[0]
    $date = $date -replace '\d{2}(\d{2})(\d{2})(\d{2})', '$2/$3/$1'
    $date = $date -as [datetime]
    $date = $date | get-date -Format M/d/yyyy
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
    $date = $date | get-date -Format M/d/yyyy
    $time = $datetime[1]

    #$new = new-object PSObject
    $line | Add-member -name Date -value $date -MemberType NoteProperty
    $line | Add-Member -name Time -Value $time -MemberType NoteProperty

}

$older = $older | Select-Object -Property Date,Time,Open,High,Low,Close,Volume,Count,WAP,HasGaps


$newdates = foreach($line in $newer){get-date $line.date -Format M/d/yyyy}
$newdates = $newdates | get-unique

$olddates = foreach($line in $older){get-date $line.date -Format M/d/yyyy}
$olddates = $olddates | get-unique

$newvol = @()

# stopping here

# working on summing volume for both new and old data...
# then will do a compare or something and spit out where to split?  then maybe have the script combine them for me...

foreach($day in $newdates){
    $new = $null
    $temp = $newer | where-object -Property Date -EQ $day
    $temp = $temp | Measure-Object -sum -Property Volume

    $new = new-object PSObject
    $new | Add-member -name Date -value $day -MemberType NoteProperty
    $new | Add-member -Name Volume -value $temp.sum -MemberType NoteProperty

    $newvol += $new
}

$oldvol = @()

# stopping here

# working on summing volume for both new and old data...
# then will do a compare or something and spit out where to split?  then maybe have the script combine them for me...

foreach($day in $olddates){
    $new = $null
    $temp = $older | where-object -Property Date -EQ $day
    $temp = $temp | Measure-Object -sum -Property Volume

    $new = new-object PSObject
    $new | Add-member -name Date -value $day -MemberType NoteProperty
    $new | Add-member -Name Volume -value $temp.sum -MemberType NoteProperty

    $oldvol += $new

}

foreach($line in $oldvol){
    $temp = $newvol | where-object -Property Date -eq $line.date
    if($line.Volume -lt $temp.volume){
        write-host "volume was larger in newvol on " $line.date
        }
    }


$cutdate = $null
$cutdate = read-host -Prompt 'What day do you want to start the newer contract?'

$cleaned += $older | Where-Object -Property Date -lt $cutdate
$cleaned += $newer | where-object -Property Date -ge $cutdate

$cleaned | Export-Csv ($mydocs + "\Github\es_testing\cleaned\cleaned.csv") -NoTypeInformation
