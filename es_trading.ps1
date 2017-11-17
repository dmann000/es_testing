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
$range = 4

# create 2 arrays for storing highs and lows
$dailyhighs = [System.Collections.ArrayList]@()
$dailylows = [System.Collections.ArrayList]@()

# Gets all unique dates within the CSV and writes them to an array variable
$dates = $data | Select-Object -Property Date -Unique

$dates = $dates[-2]

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

    
    if($status -eq "low4high"){
    write-host "low4high" $line.time
    write-host "high " $line.high
    write-host "low " $line.low

    if($line.low -lt $maybelow.low){
    $currhigh = $line | select-object -Property high,time
	$maybelow = $line | select-object -Property low,time
    $status = "look4low"
	
	}elseif($line.high -gt $currhigh.high){
	$currhigh = $line | select-object -Property high,time
    if($currhigh.high - $maybelow.low -ge $range){
    $dailylows.add($maybelow)
    $status = "look4high"
    }elseif($line.time -eq "16:10:00"){
    $dailylows.add($maybelow)
    exit
    }

    }
    }
    
    

    elseif($status -eq "look4low"){
        
    <#look4low
	we have an established low, and are now looking for the next high (but still need to check if make a new low)
	#>

    write-host "look4low" $line.time 
    write-host "high " $line.high
    write-host "low " $line.low
    
    #some code for the uniquness of first of day
    if($maybehigh -eq $null){
        if($line.low -lt $currlow.low){
        $currlow = $line | Select-Object -Property low,time
        }elseif($line.low -ge $currlow.low){
        $maybelow = $currlow
        $currhigh = $line | select-object -Property high,time
        $status = "low4high"
        }
    }

	elseif($line.low -lt $currlow.low){
	    $currlow = $line | select-object -Property low,time
        $currhigh = $line | Select-Object -Property high,time
    }
	elseif($line.high -gt $currhigh.high){
        $maybelow = $currlow
        $status = "low4high"
	    $currlow = $line | select-object -Property low,time
		$currhigh = $line | select-object -Property high,time
    }elseif($line.time -eq "16:10"){
    $dailyhighs.add($currhigh)
    exit
    }
    }


        
    elseif($status -eq "high4low"){
    write-host "high4low" $line.time
    write-host "high " $line.high
    write-host "low " $line.low

    if($line.high -gt $maybehigh.high){
    $currlow = $line | select-object -Property low,time
	$maybehigh = $line | select-object -Property high,time
    $status = "look4high"

	}elseif($line.low -lt $currlow.low){
	$currlow = $line | select-object -Property low,time
    if($maybehigh.high - $currlow.low -ge $range){
    $dailyhighs.add($maybehigh)
    $status = "look4low" # switch to low4high?
    }
    elseif($line.time -eq "16:10:00"){
    $dailyhighs.add($maybehigh)
    exit
    }
    }}
    
    elseif($status -eq "look4high"){

    write-host "look4high" $line.time
    write-host "high " $line.high
    write-host "low " $line.low

    #some code for the uniquness of first of day
    if($maybelow -eq $null){
        if($line.high -gt $currhigh.high){
        $currhigh = $line | Select-Object -Property high,time
        }elseif($line.high -le $currhigh.high){
        $maybehigh = $currhigh
        $currlow = $line | select-object -Property low,time
        $status = "high4low"
        }
    }
	elseif($line.high -gt $currhigh.high){
	    $currhigh = $line | select-object -Property high,time
        $currlow = $line | Select-Object -Property low,time
    }
	elseif($line.low -lt $currlow.low){
        $maybehigh = $currhigh
        $status = "high4low"
	    $currhigh = $line | select-object -Property high,time
		$currlow = $line | select-object -Property low,time
    }
	}else{


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
    if($currhigh.time -eq $currlow.time){
        write-host $line.time "times are the same"
        }
    
    elseif($currhigh.time -lt $currlow.time){ # THIS SEEMS BACKWARD TO ME!!!
        $dailyhighs.add($currhigh)
        $status = "look4low" # switch to low4high?
        write-host "added high"
        write-host $currhigh
        write-host $line.time
        write-host "low" $currlow
        }

    else{
        $dailylows.add($currlow)
        $status = "look4high"
        write-host "added low"
        write-host $currlow
        write-host $line.time
        
       }

    }

}
}
}