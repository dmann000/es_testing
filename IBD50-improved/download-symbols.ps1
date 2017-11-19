$webClient = new-object System.Net.WebClient
$webClient.Headers.Add("user-agent", "PowerShell Script")
$path = [environment]::getfolderpath("mydocuments") + "\GitHub\symbolhistory"
cd $path
$ibdhist = (import-csv D:\Users\dmann\Documents\GitHub\IBD50-improved\ibdhist.csv | Where-Object {$_.buypoint -ne ""})
$symbol = $ibdhist.symbol | sort -Unique

<#
$list = @()
$download = $null
foreach($stock in $symbol){
$download = "http://api.kibot.com/?action=history&unadjusted=1&symbol=$stock&interval=daily&startdate=6/15/2008&direct=1&attachment=1&regularsession=0&user=donmann@gmail.com&password=jaf9646hgre"
$list += $download
}
$list | Out-File $path\daily-symbols.txt

$download = $null
$intraday = @()
foreach($stock in $symbol){
$download = "http://api.kibot.com/?action=history&unadjusted=1&symbol=$stock&interval=15&startdate=6/15/2008&direct=1&attachment=1&regularsession=0&user=donmann@gmail.com&password=jaf9646hgre"
$intraday += $download
}
$intraday | Out-File $path\intraday-symbols.txt
#>

$download = $null
$dailyadj = @()
foreach($stock in $symbol){
$download = "http://api.kibot.com/?action=history&unadjusted=0&symbol=$stock&interval=daily&startdate=6/15/2008&direct=1&attachment=1&regularsession=0&user=donmann@gmail.com&password=jaf9646hgre"
$dailyadj += $download
}
$dailyadj | Out-File $path\dailyadj-symbols.txt

