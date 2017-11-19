$webClient = new-object System.Net.WebClient
$webClient.Headers.Add("user-agent", "PowerShell Script")
$path = [environment]::getfolderpath("mydocuments") + "\GitHub\IBD50-improved"
cd $path

$stock = "SPY"
# needed for collecting 50-day volume average below
$cm = (Get-Date).AddMonths(-1).Month
$cy = (Get-Date).AddMonths(-1).Year
$day = (Get-Date).Day
$pm = (Get-Date).AddMonths(-3).Month
$py = (Get-Date).AddYears(-6).Year

$50days = $webClient.DownloadString("http://ichart.finance.yahoo.com/table.csv?s=$($stock)&a=$pm&b=$day&c=$py&d=$cm&e=$day&f=$cy&g=d&ignore=.csv") | ConvertFrom-Csv
$spy = $50days | select -first 1461
foreach ($day in $spy){
$day.date = $day.Date | Get-Date -Format yyyy-MM-dd
}
$spy = $spy | sort -Property Date

foreach ($day in $spy){
$day.date = $day.date | Get-Date -Format MM/dd/yyyy
}

$spy | Export-Csv -NoTypeInformation $path\spy-daily.csv