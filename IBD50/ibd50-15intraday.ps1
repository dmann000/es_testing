$webClient = new-object System.Net.WebClient
$webClient.Headers.Add("user-agent", "PowerShell Script")
$path = [environment]::getfolderpath("mydocuments") + "\GitHub\IBD50"
cd $path
$ibd50 = (import-csv $path\ibd50.csv)
#$ibd50 = "SN"

function Convert-UnixTimeToDateTime([int]$UnixTime)
{
    (New-Object DateTime(1970, 1, 1, 0, 0, 0, 0, [DateTimeKind]::Utc)).AddSeconds($UnixTime)
}

# needed for collecting 50-day volume average below
$cm = (Get-Date).AddMonths(-1).Month
$cy = (Get-Date).AddMonths(-1).Year
$day = (Get-Date).Day
$pm = (Get-Date).AddMonths(-4).Month
$py = (Get-Date).AddMonths(-4).Year

foreach ($stock in $ibd50) {
    Write-Output "Collecting information for "$stock.symbol "IBD50 #"$stock.'IBD 50 Rank' "Company Name "$stock.'Company Name'""
    $50days = $webClient.DownloadString("http://ichart.finance.yahoo.com/table.csv?s=$($stock.symbol)&a=$pm&b=$day&c=$py&d=$cm&e=$day&f=$cy&g=d&ignore=.csv") | ConvertFrom-Csv | Select-Object -First 50
    $50count = $50days.Count
    $50vol = (($50days.volume | Measure-Object -Sum).Sum)/$50count
    $today = $webClient.DownloadString("http://chartapi.finance.yahoo.com/instrument/1.0/"+$stock.symbol+"/chartdata;type=quote;range=20d/csv") | ConvertFrom-Csv -header Timestamp,close,high,low,open,volume | Where-Object {$_.Timestamp -match '^\d'}
    foreach ($line in $today) {
        # $line | select-string -Pattern '[^0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]*'
        $line.Timestamp = Convert-UnixTimeToDateTime $line.Timestamp
        $line.Timestamp = $line.Timestamp.ToLocalTime()
        }
    $count = ($today.timestamp.date | get-unique | Measure-Object -Line).Lines
    # $hours | Where-Object {$_.timeofday -le "10:00:00"}

# create 15 min increments from 9:30AM to 4PM
$a = get-date "09:30:00"
$b = get-date "16:00:00"
$test = @()
While ($a -lt $b) {
$new2 = New-Object PSObject
$a = $a.AddMinutes(15)
$avg = (($today | Where-Object {$_.timestamp.timeofday -le $a.TimeOfDay} | Measure-Object -Property volume -sum).sum)/$count
$total = (($today.volume | Measure-Object -sum).sum)/$count
$new2 | Add-Member -Name "Symbol" -MemberType NoteProperty -Value $stock.symbol
$new2 | Add-Member -Name "Time" -MemberType NoteProperty -Value ($a.TimeOfDay -f "HH:mm")
$new2 | Add-Member -Name "AverageVol" -MemberType NoteProperty -Value (($avg/$total)*$50vol)
$test += $new2
}
$intraday += $test
#>
}
$intraday | Export-Csv -NoTypeInformation $path\intraday.csv
