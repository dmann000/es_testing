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


#convert date value to date/time format for posh
foreach($line in $data){
$datetime = $line.date + " " + $line.time
$line.date = $datetime -as [datetime]
}

# how many points do you want between high/lows?
$range = 5

# create 2 arrays for storing highs and lows
$dailyhighs = [System.Collections.ArrayList]@()
$dailylows = [System.Collections.ArrayList]@()

# Gets all unique dates within the CSV and writes them to an array variable
$dates = foreach($line in $data){get-date $line.date.date -Format MM/dd/yyyy}
$dates = $dates | get-unique

# $dates = "10/17/2017"

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

    write-host $day

    # Run a loop against only the lines that match the current $day variable
    foreach($line in ($data | where-object {$_.date.date -eq $day})) 
    {
    
    if($line.date.hour -ge 16 -and $line.date.minute -gt 14){
    }
    else{




    if($status -eq "low4high"){
    
    <#
    write-host "low4high" $line.date
    write-host "high " $line.high
    write-host "low " $line.low
    write-host "currhigh " $currhigh.high
	write-host "currlow " $currlow.low
	write-host "maybehigh " $maybehigh.high
	write-host "maybelow " $maybelow.low
    write-host "daily low count " $dailylows.count
    pause
    #>

    if($line.low -lt $maybelow.low){
    $currhigh = $line | select-object -Property high,date
	$maybelow = $line | select-object -Property low,date
    $status = "look4low"
	
	}elseif($line.high -gt $currhigh.high){
	$currhigh = $line | select-object -Property high,date
    if($currhigh.high - $maybelow.low -ge $range){
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

    <#
    write-host "look4low" $line.date 
    write-host "high " $line.high
    write-host "low " $line.low
    write-host "currhigh " $currhigh.high
	write-host "currlow " $currlow.low
	write-host "maybehigh " $maybehigh.high
	write-host "maybelow " $maybelow.low
    write-host "daily low count " $dailylows.count
    pause
    #>

    #some code for the uniquness of first of day
    if($begin -eq $true){
        if($line.low -lt $currlow.low){
        $currlow = $line | Select-Object -Property low,date
        }elseif($line.low -ge $currlow.low){
        $maybelow = $currlow
        $begin = $false
        $currhigh = $line | select-object -Property high,date
        $status = "low4high"
        }
    }

	elseif($line.low -lt $currlow.low){
	    $currlow = $line | select-object -Property low,date
        $currhigh = $line | Select-Object -Property high,date
    }
	elseif($line.high -gt $currhigh.high){
        $maybelow = $currlow
        $status = "low4high"
	    $currlow = $line | select-object -Property low,date
		$currhigh = $line | select-object -Property high,date
    }elseif($line.date.hour -eq 16 -and $line.date.minute -eq 14){
    $dailyhighs.add($currhigh)
    {
    }
    }
    }

        
    elseif($status -eq "high4low"){
    
    <#
    write-host "high4low" $line.date
    write-host "high " $line.high
    write-host "low " $line.low
    write-host "currhigh " $currhigh.high
	write-host "currlow " $currlow.low
	write-host "maybehigh " $maybehigh.high
	write-host "maybelow " $maybelow.low
    write-host "daily low count " $dailylows.count
    pause
    #>

    if($line.high -gt $maybehigh.high){
    $currlow = $line | select-object -Property low,date
	$maybehigh = $line | select-object -Property high,date
    $status = "look4high"

	}elseif($line.low -lt $currlow.low){
	$currlow = $line | select-object -Property low,date
    if($maybehigh.high - $currlow.low -ge $range){
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

    <#
    write-host "look4high" $line.date
    write-host "high " $line.high
    write-host "low " $line.low
    write-host "currhigh " $currhigh.high
	write-host "currlow " $currlow.low
	write-host "maybehigh " $maybehigh.high
	write-host "maybelow " $maybelow.low
    write-host "daily low count " $dailylows.count
    pause
    #>

    #some code for the uniquness of first of day
    if($begin -eq $true){
        if($line.high -gt $currhigh.high){
        $currhigh = $line | Select-Object -Property high,date
        }elseif($line.high -le $currhigh.high){
        $maybehigh = $currhigh
        $begin = $false
        $currlow = $line | select-object -Property low,date
        $status = "high4low"
        }
    }
	elseif($line.high -gt $currhigh.high){
	    $currhigh = $line | select-object -Property high,date
        $currlow = $line | Select-Object -Property low,date
    }
	elseif($line.low -lt $currlow.low){
        $maybehigh = $currhigh
        $status = "high4low"
	    $currhigh = $line | select-object -Property high,date
		$currlow = $line | select-object -Property low,date
    }
	}else{

    <#
    write-host "time" $line.date
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
    write-host "daily low count " $dailylows.count
    pause
    #>


    # check to see if the current line/bar's high is higher than before
    
    if($line.high -gt $currhigh.high){
    $currhigh = $line | select-object -Property high,date
    }

    # check to see if the current line/bar's low is lower than before
    if($currlow -eq $null -or $line.low -lt $currlow.low){
    $currlow = $line | select-object -Property low,date
    }

    # now check to see if we have enough distance from currhigh and currlow to establish whichever is "older"
    if($currhigh.high - $currlow.low -ge $range){

    # now check to see which is "older"
    if($currhigh.date -eq $currlow.date){
        }
    
    elseif($currhigh.date -lt $currlow.date){
        $dailyhighs.add($currhigh)
        $status = "look4low" # switch to low4high?
        }

    else{
        $dailylows.add($currlow)
        $status = "look4high"

        
       }

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