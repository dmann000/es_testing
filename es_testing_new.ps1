<# es_testing
attempting a rewrite of es_testing

goals are to cleanup the overall logic of the main portion of the script

will also try to comment every where possible
#>

# real-time hours
# $true = 9:30 - 4:15
# $false = all bars given
$rth = $true
# specify market hours (only gets used if rth = $true)
$startday = get-date -hour 9 -Minute 29 -Millisecond 0
$endday = get-date -hour 16 -Minute 15 -Millisecond 0

# how many points do you want between high/lows?
$range = 5


# start time to capture runtime
$start = Get-Date

$mydocs = [Environment]::GetFolderPath("MyDocuments")
$data = import-csv ($mydocs + "\Github\es_testing\cleaned\cleaned.csv")

#convert date value to date/time format for posh
foreach($line in $data){
$datetime = $line.date + " " + $line.time
$line.date = $datetime -as [datetime]
}

# *** FOR TESTING PURPOSES ONLY ***
#comment this out for the full script
$begindate = "11/15/2017"
$enddate = "11/15/2017"
$data = $data | Where-Object {$_.date.date -ge $begindate -and $_.date.date -le $enddate} # this filters the data down to the test data only...

#if you enable rth only - 
if($rth -eq $true){

    $data = $data | Where-Object {$_.date.timeofday -ge $startday.TimeOfDay -and $_.date.timeofday -lt $endday.TimeOfDay}

}



$data = $data | sort -Property Date

# create an array to store highs and lows
$highlow = [System.Collections.ArrayList]@()

    $priorhigh = $null
    $priorlow = $null
    # maybehigh and maybelow are to hold the high or low that we believe to be the established high or low (once market has turned and identified a high or low)
    # we have to hold this until the market
    # do we really need this??? not sure checking
    $maybehigh = $null
    $maybelow = $null

foreach($line in $data){


    if($line.high -gt $priorhigh.high){
        $priorhigh = $line | select-object -Property high,date
        }
    if($priorlow -eq $null -or $line.low -lt $priorlow.low){
        $priorlow = $line | Select-Object -Property low,date
        }

$recentHL = $highlow[-1]

if($recentHL -eq $null){
    $currrange = $priorhigh.high - $priorlow.low}

elseif($recentHL.highlow -eq "Low"){
    $currrange = $priorhigh.high - $recentHL.price}

elseif($recentHL.highlow -eq "High"){
    $currrange = $recentHL.price - $priorlow.low}


    if($currrange -ge $range){
        # determine if high and low timestamp are the same, if so do nothing.  wait till next bar
        if($priorhigh.date -ne $priorlow.date){
        if($priorhigh.date -lt $priorlow.date){
            $new = new-object PSObject
            $new | Add-member -name HighLow -value "High" -MemberType NoteProperty
            $new | Add-member -Name Date -value $priorhigh.Date -MemberType NoteProperty
            $new | Add-member -Name Price -value $priorhigh.high -membertype NoteProperty

            $highlow += $new
            $priorhigh = $null
            }
        if($priorhigh.date -gt $priorlow.date){
            $new = new-object PSObject
            $new | Add-member -name HighLow -value "Low" -MemberType NoteProperty
            $new | Add-member -Name Date -value $priorlow.Date -MemberType NoteProperty
            $new | Add-member -Name Price -value $priorlow.low -membertype NoteProperty

            $highlow += $new
            $priorlow = $null
            }

        }

        }
        write-host "range " $currrange
        write-host high $priorhigh.high
        write-host low $priorlow.low
        write-host $line.date
        pause

}



$end = get-date

$runtime = $end - $start
write-host $runtime