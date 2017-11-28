$mydocs = [Environment]::GetFolderPath("MyDocuments")
# this run works!
$data = import-csv ($mydocs + "\Github\es_testing\cleanup\cleanup.csv") # | Sort-Object -Property "Date/Time" -unique
$cleaned = import-csv ($mydocs + "\Github\es_testing\cleaned\cleaned.csv")

foreach($line in $data){
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

foreach($line in $data){
    $datetime = $line.date + " " + $line.time
    $line.'Date/Time' = $datetime -as [datetime]
}

foreach($line in $cleaned){
    $datetime = $line.date + " " + $line.Time
    $line | Add-member -name 'Date/Time' -value ($datetime -as [datetime]) -MemberType NoteProperty
}


$data = $data | sort -Property 'Date/Time'
$cleaned = $cleaned | sort -Property 'Date/Time'

$errorcount = $null

$dates = foreach($line in $data){get-date $line.'Date/Time'.date -Format MM/dd/yyyy}
$dates = $dates | get-unique

$cleandates = foreach($line in $cleaned){get-date $line.'Date/Time'.date -Format MM/dd/yyyy}
$cleandates = $cleandates | get-unique

$overlap = $null
$overlap = (Compare-Object $cleandates $dates -IncludeEqual -ExcludeDifferent)

if($overlap -eq $null){
$data = $data + $cleaned
$dates = $dates + $cleandates
$data = $data | sort -Property 'Date/Time'

Foreach($day in $dates){
$start = get-date
$count = $null
$count = ($data | where-object {$_.'Date/Time'.date -eq $day}).count
$count1 = $count1 + 1
$end = Get-Date

write-host $day " done. Took " ($end-$start).seconds "seconds"
write-host "count " $count1

if($count -gt 1366){
write-host "warning - count higher than standard day!"
write-host $day $count
$errorcount = $errorcount + 1
}
}
}else{
write-host "error - overlapping dates"
}

if($errorcount -eq $null){
$data | Export-Csv ($mydocs + "\Github\es_testing\cleaned\cleaned.csv") -NoTypeInformation
}else{
write-host "data error - try again.  too many lines for a specific date"
}