$path = [environment]::getfolderpath("mydocuments") + "\GitHub\IBD50-improved"
cd $path

$finalibdhist = import-csv finalibdhist.csv


# ibddates = all of the dates there are buypoints in the paper...
$ibddates = @()
foreach($line in ($finalibdhist.date | Sort-Object -Unique)){
#$line=$finalibdhist.date[1]
$line = get-date $line
$ibddates += $line
}

#foreach ($line in $finalibdhist) {
$line = $finalibdhist[0]
    Write-Output "Collecting information for $($line.symbol) $($line.date)"
    
    $50days = $webClient.DownloadString("http://ichart.finance.yahoo.com/table.csv?s=$($line.symbol)&a=$pm&b=$day&c=$py&d=$cm&e=$day&f=$cy&g=d&ignore=.csv") | ConvertFrom-Csv | Select-Object -First 50
    $50count = $50days.Count
    $50vol = (($50days.volume | Measure-Object -Sum).Sum)/$50count

    $histdata = import-csv -Header Date,Time,Open,High,Low,Close,Volume ..\symbolhistory\$($line.symbol).txt

    $dates = @()
    foreach ($date in $50days.date){
        $date = get-date $date -f MM/dd/yyyy
        $dates += $date
        }

    $grouphist = $histdata | Group-Object -Property Date

    $temparray = @()
    foreach($day in $dates){
        $indday = ($grouphist | where-object {$_.name -eq $day}).group
        $temparray += $indday
        }
$count = ($temparray.date | Get-Unique).count
# create 15 min increments from 9:30AM to 4PM
$a = get-date "09:30:00"
$b = get-date "16:00:00"
$test = @()
While ($a -lt $b) {
$new2 = New-Object PSObject
$a = $a.AddMinutes(15)
$avg = (($temparray | Where-Object {(get-date $_.time).timeofday -le $a.TimeOfDay} | Measure-Object -Property volume -sum).sum)/$count
$total = (($temparray.volume | Measure-Object -sum).sum)/$count
$avgvol = "{0:f0}" -f (($avg/$total)*$50vol)
$new2 | Add-Member -Name "Symbol" -MemberType NoteProperty -Value $line.symbol
$new2 | Add-Member -Name "Date" -MemberType NoteProperty -Value (get-date $startdate -format MM/dd/yyyy)
$new2 | Add-Member -Name "Time" -MemberType NoteProperty -Value ($a.TimeOfDay -f "HH:mm")
$new2 | Add-Member -Name "AverageVol" -MemberType NoteProperty -Value $avgvol
$test += $new2
$tempsym = $line.stock
}
$test | Export-Csv -NoTypeInformation -Append ..\intradayhist\$($line.symbol).csv
#>
}
#$intraday | Export-Csv -NoTypeInformation $path\intraday.csv