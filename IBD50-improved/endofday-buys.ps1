$path = [environment]::getfolderpath("mydocuments") + "\GitHub\IBD50-improved"
cd $path

$buypoints = import-csv .\histbuypoints.csv
$countint = $null

$collection = @()
$symbol = $null
foreach ($line in $buypoints){
    $countint += 1
    write-host "analyzed $countint lines of $($buypoints.count)"
    $line.Date = $line.date -as [datetime]

if($symbol -eq $null){
    $histdaily = import-csv -Header Date,Open,High,Low,Close,Volume ..\symbolhistory\daily\$($line.symbol).txt | Select-Object -Property Date,Open,High,Low,Close,Volume
    ForEach ($day in $histdaily){$day.date = $day.date -as [datetime]}
        $symbol = $line.symbol
}elseif($symbol -ne $line.symbol){
    $histdaily = import-csv -Header Date,Open,High,Low,Close,Volume ..\symbolhistory\daily\$($line.symbol).txt | Select-Object -Property Date,Open,High,Low,Close,Volume
    ForEach ($day in $histdaily){$day.date = $day.date -as [datetime]}
    $symbol = $line.symbol
}else{

    $50day = $histdaily | Where-Object {$_.date -lt $line.date} | sort -Property date -Descending | Select-Object -First 50

    $day = $histdaily | Where-Object {$_.date -eq $line.date}

    $count = $50day.count
    $50vol = "{0:f0}" -f ((($50day.volume | Measure-Object -Sum).sum)/$count)
    $percent = (($day.Volume - $50vol) / $50vol)

    if(($percent -gt .5) -and ($day.Close -gt $50day[0].close) -and ($day.close -gt $line.buypoint) -and ($day.close -lt $line.buypeak)){
        $array = @()
        $percent = "{0,-10:p}" -f $percent
        write-host "$($line.symbol) $($line.date) breakout volume - $percent"
        $add = New-Object PSObject
        $add | Add-Member -Name "Symbol" -MemberType NoteProperty -Value $line.symbol
        $add | Add-Member -Name "Date" -MemberType NoteProperty -Value (get-date $line.date -f "MM/dd/yyyy")
        $add | Add-Member -Name "Buytext" -MemberType NoteProperty -Value $line.buytext
        $add | Add-Member -Name "Buypoint" -MemberType NoteProperty -Value $line.buypoint
        $add | Add-Member -Name "Buypeak" -MemberType NoteProperty -Value $line.buypeak
        $add | Add-Member -Name "Open" -MemberType NoteProperty -Value $day.open
        $add | Add-Member -Name "High" -MemberType NoteProperty -Value $day.high
        $add | Add-Member -Name "Low" -MemberType NoteProperty -Value $day.low
        $add | Add-Member -Name "Close" -MemberType NoteProperty -Value $day.close
        $add | Add-Member -Name "Volume" -MemberType NoteProperty -Value $day.volume
        $add | Add-Member -Name "50dayVol" -MemberType NoteProperty -Value $50vol
        $array += $add
        $clear = "yes"
}
if($clear -eq "yes"){
$collection += $array
    $clear = $null
    }
}
}
$collection | Export-Csv -NoTypeInformation voldaybuypoints.csv
