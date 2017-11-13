$mydocs = [Environment]::GetFolderPath("MyDocuments")
$data = import-csv ($mydocs + "\Github\es_testing\es_5min_sample.csv")
$day = $null

# Gets all unique dates within the CSV and writes them to an array variable
$dates = $data | Select-Object -Property Date -Unique

$dates = $dates[6]

# Run a loop against each day in the dates array
Foreach($day in $dates) 
{
#Set the following variables to $null on each new day
$high = $null
$low = $null
$hod = $null
$lod = $null
$hodtime = $null
$lodtime = $null

# Run a loop against only the lines that match the current $day variable
foreach($line in ($data | where-object {$_.date -eq $day.date})) 
{
if((get-date $line.time).hour -lt 11){

# check each line to see if the high is higher than prior bar
if($line.high -gt $hod){
$hod = $line.high
$hodtime = $line.time
write-host "high" $hod 
write-host "time" $hodtime
}

# check each line to see if the low is lower than the prior bar

if($lod -eq $null -or $line.low -lt $lod){
$lod = $line.low
$lodtime = $line.time
write-host "low" $lod 
write-host "time" $lodtime
}

}}}
