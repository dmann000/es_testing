# es_testing | Carl Mann licks my balls

<#
Okay - intial goal at the moment is to grab any highs or lows that have a 5pt range between the two...

I believe this will take 5 logic statements

either - beginning of day/script - looking for high and low until we see the defined "range"
look4low - established a high, now looking for low
low4high - we think we have established a low, now looking for a high
look4high - established a low, now looking for a high
high4low - we think we have established a high, now looking for a low

We'll have a variable called current status.  it will be one of those 5 values
#>


$mydocs = [Environment]::GetFolderPath("MyDocuments")
$data = import-csv ($mydocs + "\Github\es_testing\es_5min_sample.csv")
$range = 5

# create 2 arrays for storing highs and lows
$dailyhighs = [System.Collections.ArrayList]@()
$dailylows = [System.Collections.ArrayList]@()

# Gets all unique dates within the CSV and writes them to an array variable
$dates = $data | Select-Object -Property Date -Unique

$dates = $dates[55]

# Run a loop against each day in the dates array
$day = $null 

Foreach($day in $dates) 
{
    #Set the following variables to $null on each new day
    $currhigh = $null
    $currlow = $null
    $maybehigh = $null
    $maybelow = $null
    $status = $null

    # Run a loop against only the lines that match the current $day variable
    foreach($line in ($data | where-object {$_.date -eq $day.date})) 
    {

    
    if($status -eq "look4low"){
    write-host "4low"
    }
    
    elseif($status -eq "low4high"){
    write-host "l4h"
    }
    
    elseif($status -eq "look4high"){
    write-host "4high"
    }    
    
    elseif($status -eq "high4low"){
    write-host "h4l"
    }
    else{


    # check to see if the current line/bar's high is higher than before
    
    if($line.high -gt $currhigh.high){
    $currhigh = $line | select-object -Property high,time
    }

    # check to see if the current line/bar's low is lower than before
    if($currlow -eq $null -or $line.low -lt $currlow.low){
    $currlow = $line | select-object -Property low,time
    }

    # now check to see if we have enough distance from currhigh and currlow to establish whichever is "older"
    if($currhigh.high - $currlow.low -ge $range){

    # now check to see which is "older"
    if($currhigh.time -lt $currlow.time){ # THIS SEEMS BACKWARD TO ME!!!
        $dailyhighs.add($currhigh)
        $status = "look4low"
        }

    else{
        $dailylows.add($currlow)
        $status = "look4high"
       }

    }

}
}
}