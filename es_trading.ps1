# es_testing

# real-time hours
# $true = 9:30 - 4:15
# $false = all bars given
$rth = $true
# specify market hours (only gets used if rth = $true)
$startday = get-date -hour 9 -Minute 29 -Millisecond 0
$endday = get-date -hour 16 -Minute 15 -Millisecond 0

# how many points do you want between high/lows?
$range = 5

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

# start time to capture runtime
$start = Get-Date

$mydocs = [Environment]::GetFolderPath("MyDocuments")
$data = import-csv ($mydocs + "\Github\es_testing\cleaned\cleaned.csv")

#convert date value to date/time format for posh
foreach($line in $data){
$datetime = $line.date + " " + $line.time
$line.date = $datetime -as [datetime]
}


#if you enable rth only - 
if($rth -eq $true){

    $data = $data | Where-Object {$_.date.timeofday -ge $startday.TimeOfDay -and $_.date.timeofday -lt $endday.TimeOfDay}

}

$data = $data | sort -Property Date

# create 2 arrays for storing highs and lows
$dailyhighs = [System.Collections.ArrayList]@()
$dailylows = [System.Collections.ArrayList]@()

# Gets all unique dates within the CSV and writes them to an array variable
$dates = foreach($line in $data){get-date $line.date.date -Format MM/dd/yyyy}
$dates = $dates | get-unique

# *** FOR TESTING PURPOSES ONLY ***
#comment this out for the full script
$dates = "11/15/2017"

# Run a loop against each day in the dates array
$day = $null 

Foreach($day in $dates) 
{
    #Set the following variables to $null on each new day
    # priorhigh and priorlow are to hold the most recent high or low to compare against current bar
    $priorhigh = $null
    $priorlow = $null
    # maybehigh and maybelow are to hold the high or low that we believe to be the established high or low (once market has turned and identified a high or low)
    # we have to hold this until the market
    # do we really need this??? not sure checking
    $maybehigh = $null
    $maybelow = $null
    $status = $null
    $begin = $true #for first run quirks

    write-host $day

    # Run a loop against only the lines that match the current $day variable
    foreach($line in ($data | where-object {$_.date.date -eq $day})) 
    {
    
    if($status -eq "low4high"){
    
    
    write-host "low4high" $line.date
    write-host "high " $line.high
    write-host "low " $line.low
    write-host "priorhigh " $priorhigh.high
	write-host "priorlow " $priorlow.low
	write-host "maybehigh " $maybehigh.high
	write-host "maybelow " $maybelow.low
    write-host "daily low count " $dailylows.count
    pause
    

    if($line.low -lt $maybelow.low){
    $priorhigh = $line | select-object -Property high,date
	$maybelow = $line | select-object -Property low,date
    $status = "look4low"
	
	}elseif($line.high -gt $priorhigh.high){
	$priorhigh = $line | select-object -Property high,date
    if($priorhigh.high - $maybelow.low -ge $range){
    $dailylows.add($maybelow)
    $maybelow = $null
    $status = "look4high"
    }elseif($line.date.hour -eq 16 -and $line.date.minute -eq 14){
    $dailylows.add($maybelow)
    $maybelow = $null
    }
    {elseif
    {
    }
    }
    }
    }
    
    

    elseif($status -eq "look4low"){
        
    <#look4low
	we have an established low, and are now looking for the next high (but still need to check if make a new low)
	#>

    
    write-host "look4low" $line.date 
    write-host "high " $line.high
    write-host "low " $line.low
    write-host "priorhigh " $priorhigh.high
	write-host "priorlow " $priorlow.low
	write-host "maybehigh " $maybehigh.high
	write-host "maybelow " $maybelow.low
    write-host "daily low count " $dailylows.count
    pause
    

    #some code for the uniquness of first of day
    if($begin -eq $true){
        if($line.low -lt $priorlow.low){
        $priorlow = $line | Select-Object -Property low,date
        }elseif($line.low -ge $priorlow.low){
        $maybelow = $priorlow
        $begin = $false
        $priorhigh = $line | select-object -Property high,date
        $status = "low4high"
        }
    }

	elseif($line.low -lt $priorlow.low){
	    $priorlow = $line | select-object -Property low,date
        $priorhigh = $line | Select-Object -Property high,date
    }
	elseif($line.high -gt $priorhigh.high){
        $maybelow = $priorlow
        $status = "low4high"
	    $priorlow = $line | select-object -Property low,date
		$priorhigh = $line | select-object -Property high,date
    }elseif($line.date.hour -eq 16 -and $line.date.minute -eq 14){
    $dailyhighs.add($priorhigh)
    {
    }
    }
    }

        
    elseif($status -eq "high4low"){
    
    
    write-host "high4low" $line.date
    write-host "high " $line.high
    write-host "low " $line.low
    write-host "priorhigh " $priorhigh.high
	write-host "priorlow " $priorlow.low
	write-host "maybehigh " $maybehigh.high
	write-host "maybelow " $maybelow.low
    write-host "daily low count " $dailylows.count
    pause
    

    if($line.high -gt $maybehigh.high){
    $priorlow = $line | select-object -Property low,date
	$maybehigh = $line | select-object -Property high,date
    $status = "look4high"

	}elseif($line.low -lt $priorlow.low){
	$priorlow = $line | select-object -Property low,date
    if($maybehigh.high - $priorlow.low -ge $range){
    $dailyhighs.add($maybehigh)
    $maybehigh = $null
    $status = "look4low" # switch to low4high?
    }
    elseif($line.date.hour -eq 16 -and $line.date.minute -eq 14){
    $dailyhighs.add($maybehigh)
    $maybehigh = $null
    }
    }}


    elseif($status -eq "look4high"){

    
    write-host "look4high" $line.date
    write-host "high " $line.high
    write-host "low " $line.low
    write-host "priorhigh " $priorhigh.high
	write-host "priorlow " $priorlow.low
	write-host "maybehigh " $maybehigh.high
	write-host "maybelow " $maybelow.low
    write-host "daily low count " $dailylows.count
    pause
    

    #some code for the uniquness of first of day
    if($begin -eq $true){
        if($line.high -gt $priorhigh.high){
        $priorhigh = $line | Select-Object -Property high,date
        }elseif($line.high -le $priorhigh.high){
        $maybehigh = $priorhigh
        $begin = $false
        $priorlow = $line | select-object -Property low,date
        $status = "high4low"
        }
    }
	elseif($line.high -gt $priorhigh.high){
	    $priorhigh = $line | select-object -Property high,date
        $priorlow = $line | Select-Object -Property low,date
    }
	elseif($line.low -lt $priorlow.low){
        $maybehigh = $priorhigh
        $status = "high4low"
	    $priorhigh = $line | select-object -Property high,date
		$priorlow = $line | select-object -Property low,date
    }
	}

    if($begin -eq $true){

    
    write-host "time" $line.date
    write-host "high " $line.high
    write-host "low " $line.low
    write-host "priorhigh " $priorhigh.high
	write-host "priorlow " $priorlow.low
	write-host "maybehigh " $maybehigh.high
	write-host "maybelow " $maybelow.low
    write-host "range " ($priorhigh.high - $priorlow.low)
    if($priorhigh.time -lt $priorlow.time){
    write-host "high established"}
    elseif($priorlow.time -lt $priorhigh.time){
    write-host "low established"}
    write-host "daily high count " $dailyhighs.count
    write-host "daily low count " $dailylows.count
    pause
    


    # check to see if the current line/bar's high is higher than before
    
    if($priorhigh -eq $null -or $line.high -gt $priorhigh.high){
    $priorhigh = $line | select-object -Property high,date
    }

    # check to see if the current line/bar's low is lower than before
    if($priorlow -eq $null -or $line.low -lt $priorlow.low){
    $priorlow = $line | select-object -Property low,date
    }

    # now check to see if we have enough distance from priorhigh and priorlow to establish whichever is "older"
    if($priorhigh.high - $priorlow.low -ge $range){

    # now check to see which is "older"
    if($priorhigh.date -eq $priorlow.date){
        }
    
    elseif($priorhigh.date -lt $priorlow.date){
        $dailyhighs.add($priorhigh)
        $status = "look4low" # switch to low4high?
        }

    else{
        $dailylows.add($priorlow)
        $status = "look4high"

        
       }

    }

}
}

}


$combined = $null
$combined = [System.Collections.ArrayList]@()


foreach($line in $dailyhighs){
    $new = new-object PSObject
    $new | Add-member -name HighLow -value "High" -MemberType NoteProperty
    $new | Add-member -Name Date -value $line.Date -MemberType NoteProperty
    $new | Add-member -Name Price -value $line.high -membertype NoteProperty

    $combined += $new
    }

foreach($line in $dailylows){
    $new = new-object PSObject
    $new | Add-member -name HighLow -value "Low" -MemberType NoteProperty
    $new | Add-member -Name Date -value $line.Date -MemberType NoteProperty
    $new | Add-member -Name Price -value $line.low -membertype NoteProperty
    $combined += $new
    }


$combined = $combined | Sort-Object -property Date

$combined | export-csv ($mydocs + "\Github\es_testing\highlow.csv")

$end = Get-Date

$runtime = ($end - $start).TotalMinutes

$runtime