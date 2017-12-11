<# es_testing
attempting a rewrite of es_testing

goals are to cleanup the overall logic of the main portion of the script

will also try to comment every where possible
#>


Function Get-round{
Param ($price, $abovebelow)

    $temp = $price -as [int]
    $rounding = $null
    $rounding = [System.Collections.ArrayList]@()
    $rounding.add($temp)
    $rounding.add($temp + .25)
    $rounding.add($temp + .5)
    $rounding.add($temp + .75)
    $rounding.add($temp + 1)
    $rounding.add($temp - .25)
    $rounding.add($temp - .5)
    $rounding.add($temp - .75)
    $rounding.add($temp - 1)
    $rounding = $rounding | sort
    if($abovebelow -eq "below"){$price = ($rounding | Where-Object {$_ -le $price})[-1]}
    if($abovebelow -eq "above"){$price = ($rounding | Where-Object {$_ -ge $price})[0]}
#    return $price
}

$mydocs = [Environment]::GetFolderPath("MyDocuments")
write-host "importing csv"
$data = import-csv ($mydocs + "\Github\es_testing\cleaned\cleaned.csv")


write-host "converting csv to date and integer"
#convert date value to date/time format for posh
foreach($line in $data){
$datetime = $line.date + " " + $line.time
$line.date = $datetime -as [datetime]
$line.open = $line.open -as [double]
$line.high = $line.high -as [double]
$line.low = $line.low -as [double]
$line.close = $line.close -as [double]
}

<#
# *** FOR TESTING PURPOSES ONLY ***
#comment this out for the full script
$begindate = "11/15/2017"
$enddate = "11/15/2017"
$data = $data | Where-Object {$_.date.date -ge $begindate -and $_.date.date -le $enddate} # this filters the data down to the test data only...
#>

write-host "getting unique dates"
# Gets all unique dates within the CSV and writes them to an array variable
$dates = foreach($line in $data){get-date $line.date.date -Format MM/dd/yyyy}
$dates = $dates | get-unique



# *** FOR TESTING PURPOSES ONLY ***
#comment this out for the full script
$dates = "11/16/2017"
$data = $data | Where-Object {$_.date.date -eq $dates} # this filters the data down to the test data only...
#>

# specify market hours (only gets used if rth = $true)
$startday = get-date -hour 9 -Minute 29 -Millisecond 0
$endday = get-date -hour 16 -Minute 15 -Millisecond 0

write-host "filtering to market hours"
$data = $data | Where-Object {$_.date.timeofday -ge $startday.TimeOfDay -and $_.date.timeofday -lt $endday.TimeOfDay} | sort -Property Date


# create an array to store highs and lows
$highlow = [System.Collections.ArrayList]@()

    $bbhigh = $null
    $bblow = $null
    # maybehigh and maybelow are to hold the high or low that we believe to be the established high or low (once market has turned and identified a high or low)
    # we have to hold this until the market
    # do we really need this??? not sure checking

    $broken = $null

    $breaktime = get-date -hour 10 -Minute 59 -Millisecond 0
    
    $hod = $null
    $lod = $null
    $hwb = $null
    $entry = $null
    $target = $null
    $stop = $null

write-host "beginning for-each loop"

<#
$count = $count + 1; $line = $data[$count]
#>


Foreach($day in $dates){

foreach($line in ($data | where-object {$_.date.date -eq $day})){

#$count = $count + 1; $line = $data[$count]


# if before bb time track high and low... and store this data
    if($line.date.TimeOfDay -lt $breaktime.TimeOfDay){

    if($bbhigh -eq $null -or $line.high -gt $bbhigh.high){
    $bbhigh = $line | Select-Object -Property High,Date
    }

    if($bblow -eq $null -or $line.low -lt $bblow.low){
    $bblow = $line | select-object -Property low,date


    }

    write-host $line.date
    write-host "before 11"

    }
    
# if after bb time look for a break of bb... then look for hwb trade
    if($line.date.timeofday -ge $breaktime.timeofday){

    write-host $line.date
    write-host "after 11"

        if($broken -eq $null){

            if($line.high -gt $bbhigh.high){
            $broken = "high"
            $hod = $line | select-object -property High,Date
            }
        
            if($line.low -lt $bblow.low){
            $broken = "low"
            $lod = $line | select-object -property Low,Date
            }  

        }else{

            if($broken -eq "high"){

                if($line.high -gt $hod.high){
                    $hod = $line | select-object -property High,Date
                    $hwb = ($hod.high + $bblow.low)/2
                    $hwb = (get-round($hwb,"below"))
                    $hwb = $price
                    if($line.low -le $hwb){
                        $entry = $hwb
                        $stop = $hwb - 2
                        $target = (($hod.high - $bblow.low) * 23) + $hod.high
                        $target = (get-round($target,"above"))
                        $target = $price
                    }


                }else{
                if($line.low -le $hwb){
                $entry = $hwb
                $stop = $hwb - 2
                $target = (($hod.high - $bblow.low) * 23) + $hod.high
                $target = (get-round($target,"above"))
                $target = $price
                }
                }

            }
            if($broken -eq "low"){

                if($line.low -lt $lod.low){
                    $lod = $line | select-object -Property Low,Date
                    $hwb = ($lod.low + $bbhigh.high)/2
                }

            }
        



        }
    }
}
}
