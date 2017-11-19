$path = [environment]::getfolderpath("mydocuments") + "\GitHub\IBD50-improved"
cd $path

$capital = 800000
$sharegain = .21
$shareloss = .07
$stocks = 10
$startdate = "09/16/2008"
$enddate = "06/01/2014"

$buypoints = import-Csv voldaybuypoints.csv
    ForEach ($day in $buypoints){$day.date = $day.date -as [datetime]}
$buydates = ($buypoints.date | sort -Unique)
$amount = ($capital/$stocks)
$day = get-date $startdate
# $outlook = import-csv outlookhistory.csv
ForEach ($day in $outlook){$day.date = $day.date -as [datetime]}

$portfolio = @()
while($day -lt $enddate){
    write-host Current day is $day
    # write-host Current condition is ($outlook | Where-Object {$_.date -eq $day})
if(($portfolio | Where-Object {$_.open -eq "open").count -ne 0){
    foreach($stock in ($portfolio | Where-Object {$_.open -eq "open")){
    $stock.BuyPrice = [decimal]$stock.BuyPrice
    $date = get-date $day -Format "MM/dd/yyyy"
    $histdaily = import-csv -Header Date,Open,High,Low,Close,Volume ..\symbolhistory\daily\$($stock.symbol).txt | Where-Object {$_.date -eq $date}

    if($histdaily.High -ge ($stock.BuyPrice * (1+$sharegain))){
    $stock.CurrentDate = $day
    $stock.CurrentPrice = "{0:F2}" -f ($stock.BuyPrice * (1+$sharegain))
    $stock.CurrentValue = "{0:F2}" -f ($($stock.shares) * $($stock.CurrentPrice))
    $stock.Open = "closed"
    $stock.GainLoss = "{0:F2}" -f ($stock.CurrentValue - $stock.OrigValue)
    }elseif($histdaily.Low -lt ($stock.BuyPrice * (1-$shareloss))){
    $stock.CurrentDate = $day
    $stock.CurrentPrice = "{0:F2}" -f ([decimal]$stock.BuyPrice * (1-$shareloss))
    $stock.CurrentValue = "{0:F2}" -f ($($stock.shares) * $($stock.CurrentPrice))
    $stock.Open = "closed"
    $stock.GainLoss = "{0:F2}" -f ($stock.CurrentValue - $stock.OrigValue)
    }else{
    $stock.CurrentDate = $day
    $stock.CurrentPrice = $histdaily.Close
    $stock.CurrentValue = ($($stock.shares) * [decimal]$($stock.CurrentPrice)) # for formatting! "{0:C0}" -f 
    $stock.GainLoss = ($stock.CurrentValue - $stock.OrigValue)

    $openpos = ($portfolio.open | Where-Object {$_ -eq "open"}).count
    $totalgain = ($portfolio | Measure-Object -Property gainloss -sum).sum

    write-host ""
    write-host "Current open positions $openpos"
    Write-Host "Current gain/loss $totalgain"
    write-host 

}}}}

# check to see if current day is a buypoint day
$buydate = $null
$buydate = $buydates | Where-Object {$_ -eq $day}
if($buydate -ne $null){
foreach($stock in ($buypoints | Where-Object {$_.date -eq $buydate})){
    $owned = $null
    $owned = $portfolio | Where-Object -FilterScript {($_.symbol -eq $stock.symbol) -and ($portfolio.Open -eq "open")}
    if($owned -eq $null){
        $shares = ($amount/($stock.close))
        $shares = [decimal]("{0:N0}" -f ($shares - ($shares %100)))
        $value = ($shares * $stock.close)
        $new = New-Object PSObject
        $new  | Add-Member -Name "OpenDate" -MemberType NoteProperty -Value $day
        $new | Add-Member -Name "Symbol" -MemberType NoteProperty -Value $stock.symbol
        $new | Add-Member -Name "BuyPrice" -MemberType NoteProperty -Value $stock.close
        $new | Add-Member -Name "OrigValue" -MemberType NoteProperty -Value ("{0:F2}" -f $value)
        $new | Add-Member -Name "Shares" -MemberType NoteProperty -Value $shares
        $new | Add-Member -Name "CurrentDate" -MemberType NoteProperty -Value $day
        $new | Add-Member -Name "CurrentPrice" -MemberType NoteProperty -Value $stock.close
        $new | Add-Member -Name "CurrentValue" -MemberType NoteProperty -Value ("{0:F2}" -f $value)
        $new | Add-Member -Name "Open" -MemberType NoteProperty -Value "open"
        $new | Add-Member -Name "GainLoss" -MemberType NoteProperty -Value 0

        $portfolio += $new   
}}}    

$day = $day.AddDays(1)

}}





