$webClient = new-object System.Net.WebClient
$webClient.Headers.Add("user-agent", "PowerShell Script")
$path = [environment]::getfolderpath("mydocuments") + "\GitHub\IBD50-improved"
cd $path
$ibd50 = import-csv $path\ibd50.csv
#$ibd50 = "SN"
$buypoint = import-csv $path\buypoint.csv
$intraday = Import-Csv $path\intraday.csv
$list = (-join "$($buypoint.symbol)") -replace " ","+"
$email = "mannstockalert@gmail.com"$password = ""$secstr = New-Object -TypeName System.Security.SecureString$password.ToCharArray() | ForEach-Object {$secstr.AppendChar($_)}$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $email, $secstr
#multiple recipients - 'user@user.com','user2@user.com'
#$recp = 'XXXXXXXXXX@mms.att.net'

# Get multiplier for percent of volume
If ((get-date).TimeOfDay -le "11:00") {
$multiplier = 3.5
}
If (((get-date).TimeOfDay -ge "11:00") -and ((get-date).TimeOfDay -le "13:00")) {
$multiplier = 1
}
If ((get-date).TimeOfDay -gt "13:00") {
$multiplier = .5
}

$current = $webClient.DownloadString("http://finance.yahoo.com/d/quotes.csv?s=$list&f=sl1pv") | ConvertFrom-Csv -header symbol,last,close,vol


function Convert-UnixTimeToDateTime([int]$UnixTime)
{
    (New-Object DateTime(1970, 1, 1, 0, 0, 0, 0, [DateTimeKind]::Utc)).AddSeconds($UnixTime)
}


$time = get-date
$delay = $time.addminutes(-20)
#$delay = $time.addhours(4)
$currtime = get-date -Format "HH:mm tt"

$outlook = Import-Csv .\currentoutlook.csv

if($outlook.Outlook -ne "uptrend"){
    if($time.timeofday -lt "10:15"){
    Send-MailMessage -smtpServer smtp.gmail.com -Port 587 -UseSsl -from $email -Credential $cred -to $recp -subject "Market not in uptrend" -Body "Current market condition is $($Outlook.OutlookText)"
    }
    exit}
    

if (($($delay.TimeOfDay -gt "16:30")) -or ($($delay.timeofday) -le "9:30")){
    write-host "You suck - not during market hours!"
    exit
    }

foreach ($stock in $buypoint){

$50vol = ($intraday | Where-Object -FilterScript {($_.symbol -eq $stock.symbol) -and ($_.time -le $delay.timeofday)})[-1].AverageVol
$now = $current | Where-Object {$_.symbol -eq $stock.symbol}
$now.last = [decimal]$now.last
$stock.buypoint = [decimal]$stock.buypoint
$percent = (($now.vol - $50vol) / $50vol)

if (($percent -gt $multiplier) -and ($now.last -gt $now.close) -and ($now.last -ge $stock.buypoint) -and ($now.last -le ($stock.buypoint * 1.05))){
    $shares = ([decimal]20000/($now.last))
    $shares = [decimal]("{0:N0}" -f ($shares - ($shares %100)))
    $value = "{0:C0}" -f ($shares * $now.last)
    $percent = "{0,-10:p}" -f $percent
    $curper = "{0,-10:p}" -f ([decimal](($($now.last)-$($stock.buypoint))/$($stock.buypoint)))
    # in theory - write email here!
    Send-MailMessage -smtpServer smtp.gmail.com -Port 587 -UseSsl -from $email -Credential $cred -to $recp -subject "$($stock.symbol) Buy Point Trigger | time is $currtime" -Body "$($stock.symbol) is $percent up in volume. current price is $curper above buypoint - $($now.last). buypoint is $($stock.buypoint).  Buy $shares shares at $value.  Google watchlist link - http://goo.gl/en4IZk.`nText from IBD50 newspaper:`n$($stock.text)"
}
if (($percent -gt $multiplier) -and ($now.last -gt $now.close) -and ($now.last -lt $stock.buypoint) -and ($now.last -ge ($stock.buypoint * .98))){
    $shares = (15000/($now.last))
    $shares = [decimal]("{0:N0}" -f ($shares - ($shares %100)))
    $value = "{0:C0}" -f ($shares * $now.last)
    $percent = "{0,-10:p}" -f $percent
    $curper = "{0,-10:p}" -f ([decimal](($($now.last)-$($stock.buypoint))/$($stock.buypoint)))
    Send-MailMessage -smtpServer smtp.gmail.com -Port 587 -UseSsl -from $email -Credential $cred -to $recp -subject "$($stock.symbol) Nearing Buy Point | time is $currtime" -Body "$($stock.symbol) is $percent up in volume. current price is $curper below buypoint - $($now.last). buypoint is $($stock.buypoint).  Buy $shares shares at $value.  Google watchlist link - http://goo.gl/en4IZk.`nText from IBD50 newspaper:`n$($stock.text)"
}
}