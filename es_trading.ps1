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
$dailyhighs = @()
$dailylows = @()

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

# Run a loop against only the lines that match the current $day variable
foreach($line in ($data | where-object {$_.date -eq $day.date})) 
{

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
if($currhigh.time -lt $currlow.time) # THIS SEEMS BACKWARD TO ME!!!
    {$maybehigh = $currhigh
    $currhigh = $line.high
    }

else
# blah blah blah
    }

}
}
}



<#
Okay - intial goal at the moment is to grab any highs or lows that have a 5pt range between the two...

I believe this will take 5 logic statements

either
look4low
low4high
look4high
high4low

We'll have a variable called current status.  it will be one of those 5 values

either
	opening of the day... looking for either a high or a low...

	example - market opened at 100... went down to 95.  we can see that the high came first by time... so now we have an established high and are now "look4low"

we do this by checking the current bar and saying is this higher than the highest high we have seen? and same for low...

this logic is "done" I think... or darn close.  example here:
#>

if($line.high -gt $currhigh.high){
$currhigh = $line | select-object -Property high,time
#write-host high $line.high
#write-host hod $currhigh.high
}
if($currlow -eq $null -or $line.low -lt $currlow.low){
$currlow = $line | select-object -Property low,time
#write-host low $line.low
#write-host lod $currlow.low
}

if($currhigh.high - $currlow.low -ge 5){
	if($currhigh.time -gt $currlow.time){
	#first low established
	$status = low4high
	
	else{
	#first high established
	$status = high4low
	
	

<#look4low
	high is established and we are looking for the low
	#>
	
if($line.low -lt $currlow.low){
	$currlow = $line | select-object -Property low,time
	$currhigh = $line | select-object -Property high,time
	#write-host low $line.low
	#write-host lod $currlow.low
	}else{
		$status = low4high
		$currhigh = $line | select-object -Property high,time
		}
		
	
	

	
	
<#low4high
	we have an established low, and are now looking for the next high (but still need to check if make a new low)
	#>

if($line.low -lt $currlow.low){
	$currlow = $line | select-object -Property low,time
	$currhigh = $line | select-object -Property high,time
	$status = look4low
	}elseif{($line.high -gt $currhigh.high){
	$currhigh = $line | select-object -Property high,time





we do this by checking the current bar and saying is this higher than the highest high we have seen? and same for low...

this logic is "done" I think... or darn close.  example here:

if($line.high -gt $currhigh.high){
$currhigh = $line | select-object -Property high,time
#write-host high $line.high
#write-host hod $currhigh.high
}
if($currlow -eq $null -or $line.low -lt $currlow.low){
$currlow = $line | select-object -Property low,time
#write-host low $line.low
#write-host lod $currlow.low
}


# now check to see if we have enough distance from currhigh and currlow to establish whichever is "older"
if($currhigh.high - $currlow.low -ge 5){


#now, say we have established the high came first with something like this:
if($currhigh.time -gt $currlow.time)

now we are in logic 2 - looking for a new low...

if($currlow -eq $null -or $line.low -lt $currlow.low){
$currlow = $line | select-object -Property low,time
}else{
$currhigh = $line | select-object -Property high,time
}