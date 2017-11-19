$FirstNumArray = @()
For($first = 27; $first -le 27; $first ++)
{
 $FirstNumArray += $first
}

$SecondNumArray = @()
For($second = 9; $second -le 9; $second++)
{
 $SecondNumArray += $second
}

$ThirdNumArray = @()
For($Third = 20; $Third -le 20; $Third++)
{
 $ThirdNumArray += $Third
}


$values = @()
Foreach ($1Number in $FirstNumArray) {
 Foreach ($2Number in $SecondNumArray) {
  Foreach ($3Number in $ThirdNumArray) {
    $add = New-Object PSObject
    $add | Add-Member -Name "sharegain" -MemberType NoteProperty -Value ($1Number/100)
    $add | Add-Member -Name "shareloss" -MemberType NoteProperty -Value ($2Number/100)
    $add | Add-Member -Name "trailstop" -MemberType NoteProperty -Value ($3Number/100)
    $values += $add
}
}
}


foreach ($line in $values){
#changed price from close to open...

$path = [environment]::getfolderpath("mydocuments") + "\GitHub\IBD50-improved"
cd $path

$capital = 800000
$sharegain = $line.sharegain
$shareloss = $line.shareloss
$trailstop = $line.trailstop

$stocks = 3
$startdate = "03/02/2009"
$enddate = "06/02/2014"
#$enddate = "04/23/2009"

$gaintxt = $sharegain.ToString().replace("0.","")
$losstxt = $shareloss.ToString().replace("0.","")
$trailtxt = $trailstop.ToString().replace("0.","")
$totaldays = ((get-date $enddate) - (get-date $startdate)).totaldays

$prefix = $gaintxt+"-"+$losstxt+"-"+$trailtxt+"-"+$totaldays

$outlook = import-csv .\outlookhistory.csv

$buypoints = import-Csv combinedvoldaybuypoints.csv
    ForEach ($day in $buypoints){$day.date = $day.date -as [datetime]}
$buydates = ($buypoints.date | sort -Unique)
$amount = ($capital/$stocks)
$day = get-date $startdate

$collection = @()
$portfolio = @()
while($day -lt $enddate){
    write-host Current day is $day
    # write-host Current condition is ($outlook | Where-Object {$_.date -eq $day})
if(($portfolio.Open | Where-Object {$_ -eq "open"}).count -ne 0){
    foreach($stock in ($portfolio | Where-Object {$_.open -eq "open"})){
    $date = get-date $day -Format "MM/dd/yyyy"
    $outdate = get-date $day -Format "MM/dd/yy"
    $curoutlook = ($outlook | Where-Object {$_.date -eq $outdate}).outlook
    $adjdaily = import-csv -Header Date,Open,High,Low,Close,Volume ..\symbolhistory\adjusted-daily\$($stock.symbol).txt | Where-Object {$_.date -eq $date}
    
    <#if($curoutlook -eq "correction"){
        $stock.CurrentDate = $day
        $stock.CurrentPrice = "{0:F2}" -f $adjdaily.close
        $stock.CurrentValue = "{0:F2}" -f ($($stock.shares) * $($stock.CurrentPrice))
        $stock.Open = "closed"
        $stock.Outlook = $curoutlook
        $stock.GainLoss = "{0:F2}" -f ($stock.CurrentValue - $stock.OrigValue)
        $stock.exitreason = "correction"
        $capital = $capital + $stock.CurrentValue
    }else#>
    if($adjdaily -ne $null){
    $adjdaily.high = [decimal]$adjdaily.high
    $adjdaily.low = [decimal]$adjdaily.low
    $adjdaily.close = [decimal]$adjdaily.close
    $stock.adjprice = [decimal]$stock.adjprice
    $trailstop = [decimal]$trailstop
    $stock.trailmax = [decimal]$stock.trailmax
    $stock.shares = [decimal]$stock.shares
    $stock.currentprice = [decimal]$stock.currentprice
    $stock.currentvalue = [decimal]$stock.currentvalue
    $stock.origvalue = [decimal]$stock.origvalue
    if($stock.TrailStop -eq "on"){
        if($adjdaily.high -gt $stock.trailmax){$stock.trailmax = $adjdaily.high}
        if((($stock.trailmax - $adjdaily.low)/$stock.trailmax) -ge $trailstop){
        $stock.CurrentDate = $day
        $stock.CurrentPrice = "{0:F2}" -f ([decimal]$stock.trailmax * (1-$trailstop))
        $stock.CurrentValue = "{0:F2}" -f ($($stock.shares) * $($stock.CurrentPrice))
        $stock.Open = "closed"
        $stock.exitreason = "trailstop"
        $stock.Outlook = $curoutlook
        $stock.GainLoss = "{0:F2}" -f ($stock.CurrentValue - $stock.OrigValue)
        $capital = $capital + $stock.CurrentValue
    }else{
        $stock.CurrentDate = $day
        $stock.CurrentPrice = $adjdaily.Close
        $stock.CurrentValue = ($($stock.shares) * [decimal]$($stock.CurrentPrice)) # for formatting! "{0:C0}" -f 
        $stock.GainLoss = ($stock.CurrentValue - $stock.OrigValue)
    }}
    if($stock.TrailStop -eq "off"){
    if([decimal]$adjdaily.High -ge ($stock.AdjPrice * (1+$sharegain))){
    $stock.CurrentDate = $day
    $stock.CurrentPrice = "{0:F2}" -f ($stock.AdjPrice * (1+$sharegain))
    $stock.CurrentValue = "{0:F2}" -f ($($stock.shares) * $($stock.CurrentPrice))
    $stock.GainLoss = "{0:F2}" -f ($stock.CurrentValue - $stock.OrigValue)
    if($trailstop -ne 0){
    $stock.TrailStop = "on"
    $stock.TrailMax = $adjdaily.High
    }else{
    $stock.Open = "closed"
    $stock.Outlook = $curoutlook
    $stock.GainLoss = "{0:F2}" -f ($stock.CurrentValue - $stock.OrigValue)
    $capital = $capital + $stock.CurrentValue
    $stock.exitreason = "gain"
    }
    }elseif($adjdaily.Low -lt ($stock.AdjPrice * (1-$shareloss))){
    $stock.CurrentDate = $day
    $stock.CurrentPrice = "{0:F2}" -f ([decimal]$stock.AdjPrice * (1-$shareloss))
    $stock.CurrentValue = "{0:F2}" -f ($($stock.shares) * $($stock.CurrentPrice))
    $stock.Open = "closed"
    $stock.Outlook = $curoutlook
    $stock.exitreason = "loss"
    $stock.GainLoss = "{0:F2}" -f ($stock.CurrentValue - $stock.OrigValue)
    $capital = $capital + $stock.CurrentValue
    }else{
    $stock.CurrentDate = $day
    $stock.CurrentPrice = $adjdaily.Close
    $stock.CurrentValue = ($($stock.shares) * [decimal]$($stock.CurrentPrice)) # for formatting! "{0:C0}" -f 
    $stock.GainLoss = ($stock.CurrentValue - $stock.OrigValue)
    }



}}}}

    $openpos = ($portfolio.open | Where-Object {$_ -eq "open"}).count
    $totalgain = "{0:C0}" -f ($portfolio | Measure-Object -Property gainloss -sum).sum
    $invested = "{0:C0}" -f (($portfolio | Where-Object {$_.Open -eq "open"}).currentvalue | Measure-Object -sum).sum
    $capform = "{0:C0}" -f $capital
    $combvalue = "{0:C0}" -f ($capital + ((($portfolio | Where-Object {$_.Open -eq "open"}).currentvalue | Measure-Object -sum).sum))

    write-host ""
    write-host "Current open positions $openpos"
    write-host "Total invested $invested"
    Write-Host "Current gain/loss $totalgain"
    Write-host "Current capital $capform"
    write-host ""
    Write-host "Combined Value $combvalue"
    write-host ""

# check to see if current day is a buypoint day
$buydate = $null
$outdate = get-date $day -Format "MM/dd/yy"
$curoutlook = ($outlook | Where-Object {$_.date -eq $outdate}).outlook
#if($curoutlook -eq "uptrend"){
$buydate = $buydates | Where-Object {$_ -eq $day}
#}

if($buydate -ne $null){
foreach($stock in ($buypoints | Where-Object {$_.date -eq $buydate})){
    $owned = $null
    $date = get-date $day -Format "MM/dd/yyyy"
    $adjdaily = import-csv -Header Date,Open,High,Low,Close,Volume ..\symbolhistory\adjusted-daily\$($stock.symbol).txt | Where-Object {$_.date -eq $date}
    $owned = $portfolio | Where-Object -FilterScript {($_.symbol -eq $stock.symbol) -and ($portfolio.Open -eq "open")}
    if($owned -eq $null){
        $shares = ($amount/($adjdaily.close))
        $shares = [decimal]("{0:N0}" -f ($shares - ($shares %100)))
        $value = ($shares * $adjdaily.close)
        #if($value -le $capital){
        $new = New-Object PSObject
        $new  | Add-Member -Name "OpenDate" -MemberType NoteProperty -Value $day
        $new | Add-Member -Name "Symbol" -MemberType NoteProperty -Value $stock.symbol
        $new | Add-Member -Name "BuyPrice" -MemberType NoteProperty -Value $stock.close
        $new | Add-Member -Name "AdjPrice" -MemberType NoteProperty -Value $adjdaily.close
        $new | Add-Member -Name "OrigValue" -MemberType NoteProperty -Value ("{0:F2}" -f $value)
        $new | Add-Member -Name "OrigOutlook" -MemberType NoteProperty -Value $curoutlook
        $new | Add-Member -Name "Shares" -MemberType NoteProperty -Value $shares
        $new | Add-Member -Name "CurrentDate" -MemberType NoteProperty -Value $day
        $new | Add-Member -Name "CurrentPrice" -MemberType NoteProperty -Value $adjdaily.close
        $new | Add-Member -Name "CurrentValue" -MemberType NoteProperty -Value ("{0:F2}" -f $value)
        $new | Add-Member -Name "Buytext" -MemberType NoteProperty -Value $stock.buytext
        $new | Add-Member -Name "BuyPoint" -MemberType NoteProperty -Value $stock.buypoint
        $new | Add-Member -Name "Open" -MemberType NoteProperty -Value "open"
        $new | Add-Member -Name "GainLoss" -MemberType NoteProperty -Value 0
        $new | Add-Member -Name "TrailStop" -MemberType NoteProperty -Value "off"
        $new | Add-Member -Name "TrailMax" -MemberType NoteProperty -Value 0
        $new | Add-Member -Name "Outlook" -MemberType NoteProperty -Value $curoutlook
        $new | Add-Member -Name "ExitReason" -MemberType NoteProperty -Value ""
        $portfolio = $portfolio + $new   
}}}
        

$daycost = ((($portfolio | Where-Object {$_.opendate -eq $day}).OrigValue) | Measure-Object -Sum).sum
$capital = $capital - $daycost

$day = $day.AddDays(1)

# built report of different portfolios
# sharegain,shareloss,trailstop,openpos,invested,capform,totalgain

}

$portfolio | Export-Csv -NoTypeInformation $path\portfolio\$prefix-portfolio.csv
}