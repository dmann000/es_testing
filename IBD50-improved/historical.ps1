$webClient = new-object System.Net.WebClient
$webClient.Headers.Add("user-agent", "PowerShell Script")
$path = [environment]::getfolderpath("mydocuments") + "\GitHub\IBD50-improved"
cd $path
$ibd50 = (import-csv $path\ibd50.csv)

function Convert-UnixTimeToDateTime([int]$UnixTime)
{
    (New-Object DateTime(1970, 1, 1, 0, 0, 0, 0, [DateTimeKind]::Utc)).AddSeconds($UnixTime)
}

cd ..\intraday_collection

# *** NOTE ***
# Need to build a check in to ensure daily data is "close" to all data points - approx 85 or so
# ***

$output = $null
foreach ($stock in $ibd50) {
    Write-Output "Collecting information for "$stock.symbol "IBD50 #"$stock.'IBD 50 Rank' "Company Name "$stock.'Company Name'""
    $today = $webClient.DownloadString("http://chartapi.finance.yahoo.com/instrument/1.0/"+$stock.symbol+"/chartdata;type=quote;range=15d/csv") | ConvertFrom-Csv -header Timestamp,close,high,low,open,volume,symbol | Where-Object {$_.Timestamp -match '^\d'}
    foreach ($line in $today) {
        $line.Timestamp = Convert-UnixTimeToDateTime $line.Timestamp
        $line.Timestamp = $line.Timestamp.ToLocalTime()
        $line.symbol = $stock.symbol
    }
    $count = ($today.timestamp.date | get-unique | Measure-Object -Line).Lines

    if (Test-Path ./$($stock.symbol).csv) {
        $historical = Import-Csv ./$($stock.symbol).csv
        $historical | ForEach-Object {$_.timestamp = Get-Date $_.timestamp}
        $histdate = $historical.timestamp.date | Sort-Object | Get-Unique | Select-Object -last 15
        $currdate = $today.timestamp.date | Sort-Object | Get-Unique
        $date = Compare-Object -ReferenceObject $histdate -DifferenceObject $currdate | Where-Object {$_.sideindicator -eq '=>'}
        foreach ($day in $date.inputobject){
            $output = $output + ($today | Where-Object {$_.timestamp.date -eq $day})
            }
        if ($output -ne $null) {$output | Export-Csv -Append -NoTypeInformation ./$($stock.symbol).csv}
        $output = $null
    }Else{
    $today | Export-Csv -NoTypeInformation ./$($stock.symbol).csv
    }
    
}