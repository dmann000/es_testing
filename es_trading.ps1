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
# this run works!
#$data = import-csv ($mydocs + "\Github\es_testing\es_5min_sample.csv")
$data = import-csv ($mydocs + "\Github\es_testing\es_1min.csv")
$range = 3

# create 2 arrays for storing highs and lows
$dailyhighs = [System.Collections.ArrayList]@()
$dailylows = [System.Collections.ArrayList]@()

# Gets all unique dates within the CSV and writes them to an array variable
$dates = $data | Select-Object -Property Date -Unique

# testing sample date
#$dates= $data | Where-Object -Property Date -eq "10/16/2017"


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
    $begin = $true #for first run quirks

    # Run a loop against only the lines that match the current $day variable
    foreach($line in ($data | where-object {$_.date -eq $day.date})) 
    {
    
    if($status -eq "low4high"){
    <#
    write-host "low4high" $line.time
    write-host "high " $line.high
    write-host "low " $line.low
    write-host "currhigh " $currhigh.high
	write-host "currlow " $currlow.low
	write-host "maybehigh " $maybehigh.high
	write-host "maybelow " $maybelow.low
    pause
    #>

    if($line.low -lt $maybelow.low){
    $currhigh = $line | select-object -Property high,date,time
	$maybelow = $line | select-object -Property low,date,time
    $status = "look4low"
	
	}elseif($line.high -gt $currhigh.high){
	$currhigh = $line | select-object -Property high,date,time
    if($currhigh.high - $maybelow.low -ge $range){
    $dailylows.add($maybelow)
    $maybelow = $null
    $status = "look4high"
    }elseif($line.time -eq "16:10:00"){
    $dailylows.add($maybelow)

    $maybelow = $null
    exit
    }

    }
    }
    
    

    elseif($status -eq "look4low"){
        
    <#look4low
	we have an established low, and are now looking for the next high (but still need to check if make a new low)
	#>

    <#
    write-host "look4low" $line.time 
    write-host "high " $line.high
    write-host "low " $line.low
    write-host "currhigh " $currhigh.high
	write-host "currlow " $currlow.low
	write-host "maybehigh " $maybehigh.high
	write-host "maybelow " $maybelow.low
    pause
    #>

    #some code for the uniquness of first of day
    if($begin -eq $true){
        if($line.low -lt $currlow.low){
        $currlow = $line | Select-Object -Property low,date,time
        }elseif($line.low -ge $currlow.low){
        $maybelow = $currlow
        $begin = $false
        $currhigh = $line | select-object -Property high,date,time
        $status = "low4high"
        }
    }

	elseif($line.low -lt $currlow.low){
	    $currlow = $line | select-object -Property low,date,time
        $currhigh = $line | Select-Object -Property high,date,time
    }
	elseif($line.high -gt $currhigh.high){
        $maybelow = $currlow
        $status = "low4high"
	    $currlow = $line | select-object -Property low,date,time
		$currhigh = $line | select-object -Property high,date,time
    }elseif($line.time -eq "16:10"){
    $dailyhighs.add($currhigh)
    exit
    }
    }


        
    elseif($status -eq "high4low"){
    <#
    write-host "high4low" $line.time
    write-host "high " $line.high
    write-host "low " $line.low
    write-host "currhigh " $currhigh.high
	write-host "currlow " $currlow.low
	write-host "maybehigh " $maybehigh.high
	write-host "maybelow " $maybelow.low
    pause
    #>

    if($line.high -gt $maybehigh.high){
    $currlow = $line | select-object -Property low,date,time
	$maybehigh = $line | select-object -Property high,date,time
    $status = "look4high"

	}elseif($line.low -lt $currlow.low){
	$currlow = $line | select-object -Property low,date,time
    if($maybehigh.high - $currlow.low -ge $range){
    $dailyhighs.add($maybehigh)
    $maybehigh = $null
    $status = "look4low" # switch to low4high?
    }
    elseif($line.time -eq "16:10:00"){
    $dailyhighs.add($maybehigh)
    $maybehigh = $null
    exit
    }
    }}
    
    elseif($status -eq "look4high"){

    <#
    write-host "look4high" $line.time
    write-host "high " $line.high
    write-host "low " $line.low
    write-host "currhigh " $currhigh.high
	write-host "currlow " $currlow.low
	write-host "maybehigh " $maybehigh.high
	write-host "maybelow " $maybelow.low
    pause
    #>

    #some code for the uniquness of first of day
    if($begin -eq $true){
        if($line.high -gt $currhigh.high){
        $currhigh = $line | Select-Object -Property high,date,time
        }elseif($line.high -le $currhigh.high){
        $maybehigh = $currhigh
        $begin = $false
        $currlow = $line | select-object -Property low,date,time
        $status = "high4low"
        }
    }
	elseif($line.high -gt $currhigh.high){
	    $currhigh = $line | select-object -Property high,date,time
        $currlow = $line | Select-Object -Property low,date,time
    }
	elseif($line.low -lt $currlow.low){
        $maybehigh = $currhigh
        $status = "high4low"
	    $currhigh = $line | select-object -Property high,date,time
		$currlow = $line | select-object -Property low,date,time
    }
	}else{

    <#
    write-host "time" $line.time
    write-host "high " $line.high
    write-host "low " $line.low
    write-host "currhigh " $currhigh.high
	write-host "currlow " $currlow.low
	write-host "maybehigh " $maybehigh.high
	write-host "maybelow " $maybelow.low
    write-host "range " ($currhigh.high - $currlow.low)
    if($currhigh.time -lt $currhigh.low){
    write-host "high established"}
    else{write-host "low established"}
    pause
    #>


    # check to see if the current line/bar's high is higher than before
    
    if($line.high -gt $currhigh.high){
    $currhigh = $line | select-object -Property high,date,time
    }

    # check to see if the current line/bar's low is lower than before
    if($currlow -eq $null -or $line.low -lt $currlow.low){
    $currlow = $line | select-object -Property low,date,time
    }

    # now check to see if we have enough distance from currhigh and currlow to establish whichever is "older"
    if($currhigh.high - $currlow.low -ge $range){

    # now check to see which is "older"
    if($currhigh.time -eq $currlow.time){
        write-host $line.time "times are the same"
        }
    
    elseif($currhigh.time -gt $currlow.time){
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

$highlow = [System.Collections.ArrayList]@()
$highlow | Add-Member -MemberType NoteProperty -Name High -Value $null
$highlow | Add-Member -MemberType NoteProperty -Name Low -Value $null
$highlow | Add-Member -MemberType NoteProperty -Name Date -Value $null
$highlow | Add-Member -MemberType NoteProperty -Name Time -Value $null

$highlow = $dailyhighs + $dailylows

$highlow | sort time -Descending | sort date -Descending