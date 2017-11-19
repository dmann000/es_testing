$path = [environment]::getfolderpath("mydocuments") + "\GitHub\IBD50-improved"
cd $path

$finalibdhist = import-csv hist-intra-unclean.csv | Where-Object {$_.buypoint -ne ""}
ForEach ($line in $finalibdhist){$line.date = $line.date -as [datetime]}

# dates of the ibd 100/50 papers
$ibdhistdates = $finalibdhist.date | sort -Unique

$outlook = Import-Csv .\outlookhistory.csv | Select-Object Date,Outlook
ForEach ($line in $outlook){$line.date = $line.date -as [datetime]}
$outlook = $outlook | sort -Property Date

$total = $null
$count = $null
$laststock = $null
$collection = @()

#$stock = $finalibdhist[124]
foreach($stock in $finalibdhist){

if($stock -ne $laststock){
$histdaily = import-csv -Header Date,Open,High,Low,Close,Volume ..\symbolhistory\daily\$($stock.symbol).txt | Select-Object -Property Date,Close,Volume
ForEach ($line in $histdaily){$line.date = $line.date -as [datetime]}
}

$day = $stock.date


$nextpaper = ($ibdhistdates | Where-Object {$_.date -gt $day})[0]

while ($day -lt $nextpaper){
write-host $stock.symbol $day

$yestoutlook = ($outlook | Where-Object -FilterScript {($_.date -lt $day) -and ($_.date -ge $day.AddDays(-7))})[-1].outlook
if($yestoutlook -eq "uptrend"){
$yestclose = [decimal]($histdaily | Where-Object -FilterScript {($_.date -lt $day) -and ($_.date -ge $day.AddDays(-7))})[-1].close
if($yestclose -lt ([decimal]$stock.buypoint * 1.05)){
    write-host $stock.symbol $day $stock.buytext
    write-host $yestclose is below ([decimal]$stock.buypoint * 1.05)
    $count += 1
    write-host ""
    write-host $count total days
    write-host $total of $finalibdhist.count
    write-host ""
    $new2 = New-Object PSObject
    $new2 | Add-Member -Name "Symbol" -MemberType NoteProperty -Value $stock.symbol
    $new2 | Add-Member -Name "Date" -MemberType NoteProperty -Value (get-date $day -format MM/dd/yyyy)
    $new2 | Add-Member -Name "BuyPeak" -MemberType NoteProperty -Value ([decimal]$stock.buypoint * 1.05)
    $new2 | Add-Member -Name "LastClose" -MemberType NoteProperty -Value $yestclose
    $new2 | Add-Member -Name "Buytext" -MemberType NoteProperty -Value $stock.buytext
    $collection += $new2
}
}else{
    write-host "market condition $yestoutlook"
    }
    $day = $day.AddDays(1)
    $total += 1
    $laststock = $stock
}
}
$collection | Export-Csv -NoTypeInformation histintraday-collection.csv
