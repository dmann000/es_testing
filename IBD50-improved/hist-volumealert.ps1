$path = [environment]::getfolderpath("mydocuments") + "\GitHub\IBD50-improved"
cd $path

$buypoints = import-Csv .\testcombinedvolday.csv
$symbols = $buypoints.symbol | Sort-Object -Unique


#foreach ($symbol in $symbols){
$symbol = $symbols[1]

$daily = import-csv -Header Date,Open,High,Low,Close,Volume ..\symbolhistory\daily\$symbol.txt
ForEach ($day in $daily){$day.date = $day.date -as [datetime]}

$temp = $null
$temp = import-csv ..\intradayhist\$symbol.csv
$temp = $temp | Where-Object {$_.time -eq "15:45:00"}

foreach($line in $temp){
$dayvol = ($daily | Where-Object {$_.date -eq $($line.date)}).volume
$50vol = ($daily | Where-Object {$_.date -lt $line.date} | sort -Property date -Descending | Select-Object -First 50 | Measure-Object -Average).average
write-host $line.date $dayvol
}
#}



<#
foreach ($stock in $buypoints){

$day = get-date $stock.date
$time = "15:45"
$stock.volume = [decimal]$stock.volume
$stock.fiftydayvol = [decimal]$stock.fiftydayvol
$percent = ($stock.Volume - $stock.fiftydayvol) / $stock.fiftydayvol
$percent = "{0,-10:p}" -f $percent
$percent
}
#>