$path = [environment]::getfolderpath("mydocuments") + "\GitHub\IBD50-improved"
cd $path

$histintraday = import-csv histintraday-collection.csv
ForEach ($day in $histintraday){
$day.date = $day.date -as [datetime]
}

$lastsym = $null
$collection = $null
$indcount = $null
$totalcount = ($histintraday.Symbol | Get-Unique).count
$quickcheck = $null
foreach ($line in $histintraday) {

if (Test-Path ..\intradayhist\$($line.symbol).csv){
    if ($($line.symbol) -ne $quickcheck){
    write-host "$($line.symbol).csv already exists - skipping..."
    $quickcheck = $line.symbol
    $indcount += 1
    }
    }Else{

# $line = $histintraday[3]
    

    $startdate = get-date $line.date

    $histdaily = import-csv -Header Date,Open,High,Low,Close,Volume ..\symbolhistory\daily\$($line.symbol).txt | Select-Object -Property Date,Close,Volume
    ForEach ($day in $histdaily){$day.date = $day.date -as [datetime]}

    Write-Output "Collecting information for $($line.symbol) $($line.date)"

    $50day = $histdaily | Where-Object {$_.date -lt $startdate} | sort -Property date -Descending | Select-Object -First 50
    $count = $50day.count
    $50vol = "{0:f0}" -f ((($50day.volume | Measure-Object -Sum).sum)/$count)

    $intraday = import-csv -Header Date,Time,Open,High,Low,Close,Volume ..\symbolhistory\intraday\$($line.symbol).txt | Select-Object -Property Date,Time,Volume
    ForEach ($day in $intraday){$day.date = $day.date -as [datetime]}

    $grouphist = $intraday | Where-Object -FilterScript {($_.date -le $50day.date[0]) -and ($_.date -ge $50day.date[-1])}

$count = ($grouphist.date | sort -Unique).count
# create 15 min increments from 9:30AM to 4PM
$a = get-date "09:30:00"
$b = get-date "16:00:00"
$test = @()
While ($a -lt $b) {
$new2 = New-Object PSObject
$a = $a.AddMinutes(15)
$avg = (($grouphist | Where-Object {$_.time -le $a.TimeOfDay} | Measure-Object -Property volume -sum).sum)/$count
$total = (($grouphist.volume | Measure-Object -sum).sum)/$count
$avgvol = "{0:f0}" -f (($avg/$total)*$50vol)
$new2 | Add-Member -Name "Symbol" -MemberType NoteProperty -Value $line.symbol
$new2 | Add-Member -Name "Date" -MemberType NoteProperty -Value (get-date $startdate -format MM/dd/yyyy)
$new2 | Add-Member -Name "Time" -MemberType NoteProperty -Value ($a.TimeOfDay -f "HH:mm")
$new2 | Add-Member -Name "AverageVol" -MemberType NoteProperty -Value $avgvol
$test += $new2
}


if($lastsym -eq $line.symbol){
$collection += $test
}elseif($lastsym -eq $null){
$collection += $test
$lastsym = $line.symbol
}else{
$indcount += 1
write-host "Exporting $lastsym information"
Write-Host "Completed $indcount of totalcount $totalcount"
$collection | Export-Csv -NoTypeInformation ..\intradayhist\$($lastsym).csv
$collection = $test
$lastsym = $line.Symbol
}
}}
