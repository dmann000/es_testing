# 5_min_18_bar.ps1

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
$data = import-csv ($mydocs + "\Github\es_testing\cleaned\cleaned.csv")

<#
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
#>


#convert date value to date/time format for posh
foreach($line in $data){
$datetime = $line.date + " " + $line.time
$line.date = $datetime -as [datetime]
}

$data = $data | Select-Object -Property Date,Open,High,Low,Close,Volume,Count,WAP,HasGaps

<# ************* STOPPING ABOVE HERE FOR NOW ********************#>

$dates = foreach($line in $data){get-date $line.date.date -Format MM/dd/yyyy}
$dates = $dates | get-unique | sort

# $day = $dates[0]

$data | Where-Object {$_.date.date -eq $day}

$highcount = $null
$lowcount = $null
$bothcount = $null
$nonecount = $null
$totalcount = $null
$totals = @()

foreach($day in $dates){

    $highbroke = $null
    $lowbroke = $null
    $bothbroke = $null
    $nonebroke = $null
    $11amhigh = $null
    $11amlow = $null
    $rodhigh = $null
    $rodlow = $null
    $rod = $null
    $time = $null
    $endofday = $null

    $testtime = get-date -hour 10 -Minute 29 -Millisecond 0
    $endofday = get-date -hour 16 -Minute 15 -Millisecond 0

    $time = ($data | Where-Object {$_.date.date -eq $day} | Where-Object {$_.date.timeofday -lt $testtime.TimeOfDay})
    $11amhigh = ($time | Measure-Object -Property High -Maximum).Maximum
    $11amlow = ($time | Measure-Object -Property Low -Minimum).Minimum
    $rod = ($data | Where-Object {$_.date.date -eq $day} | Where-Object {$_.date.timeofday -ge $testtime.TimeOfDay -and $_.date.timeofday -le $endofday.TimeOfDay})
    $rodhigh = ($rod | Measure-Object -Property High -Maximum).Maximum
    $rodlow = ($rod | Measure-Object -Property Low -Minimum).Minimum

    if($rodhigh -gt $11amhigh){$highbroke = 1}
    if($rodlow -lt $11amlow){$lowbroke = 1}
    if($highbroke -eq $null -and $lowbroke -eq $null){$nonebroke = 1}
    if($highbroke -eq 1 -and $lowbroke -eq 1){
        $bothbroke = 1
        $highbroke = 0
        $lowbroke = 0
        }
    
    if($bothbroke -eq 1){
    $bothcount = $bothcount + 1
    $totalcount = $totalcount +1
    }else{
    if($highbroke -eq 1){$highcount = $highcount + 1}
    if($lowbroke -eq 1){$lowcount = $lowcount +1}
    if($nonebroke -eq 1){
    $nonecount = $nonecount +1
    }
    $totalcount = $totalcount + 1
    }

    <#
    $new = new-object PSObject
    $new | Add-Member -name Date -value $day -MemberType NoteProperty
    $new | Add-member -name 11amhigh -value $11amhigh -MemberType NoteProperty
    $new | Add-member -Name rodhigh -value $rodhigh -MemberType NoteProperty
    $new | Add-member -Name 11amlow -value $11amlow -membertype NoteProperty
    $new | Add-member -Name rodlow -value $rodlow -membertype NoteProperty
    $new | Add-member -Name highbroke -value $highbroke -membertype NoteProperty
    $new | Add-member -Name lowbroke -value $lowbroke -membertype NoteProperty
    $new | Add-member -Name bothbroke -value $bothbroke -membertype NoteProperty
    $new | Add-member -Name nonebroke -value $nonebroke -membertype NoteProperty
    

    $counter += $new #>

    }
    
$finaltally = @()

$highper = $null
$lowper = $null
$bothper = $null
$noneper = $null
$totalper = $null

$highper = ("{0:P2}" -f ($highcount / ($totalcount - $nonecount)))
$lowper = ("{0:P2}" -f ($lowcount / ($totalcount - $nonecount)))
$bothper = ("{0:P2}" -f ($bothcount / ($totalcount - $nonecount)))
$noneper = ("{0:P2}" -f ($nonecount / ($totalcount)))


$final = new-object PSObject
$final | Add-Member -name Time -value "10 AM" -MemberType NoteProperty
$final | Add-Member -name HighPercentage -value $highper -membertype NoteProperty
$final | Add-Member -name LowPercentage -value $lowper -MemberType NoteProperty
$final | Add-Member -name BothPercentage -value $bothper -MemberType NoteProperty
$final | Add-Member -name NeitherPercentage -value $noneper -MemberType NoteProperty

$finaltally += $final

$finaltally | ft

$finaltally | export-csv ($mydocs + "\Github\es_testing\1min_18-bar-analysis.csv") -NoTypeInformation -Append