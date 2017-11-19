# set path to github folder where .txt converted pdf files are
$path = [environment]::getfolderpath("mydocuments") + "\GitHub\IBD50-improved"
cd $path
$markethist = import-csv .\old_outlookhistory.csv

<#
$correction = "correction"
$pressure = "pressure"
$uptrend = "uptrend"
#>

$correction = -1
$pressure = 0
$uptrend = 1
#>

foreach($line in $markethist){
$line.outlook = $line.outlook.tolower()
#correction lines
$line.outlook = $line.outlook.Replace("market correction",$correction)
$line.outlook = $line.outlook.Replace("marketincorrection",$correction)
$line.outlook = $line.outlook.Replace("correction",$correction)
# under pressure lines
$line.outlook = $line.outlook.Replace("market rally under pressure",$pressure)
$line.outlook = $line.outlook.Replace("market under pressure",$pressure)
$line.outlook = $line.outlook.Replace("market uptrend under",$pressure)
$line.outlook = $line.outlook.Replace("rally under pressure",$pressure)
$line.outlook = $line.outlook.Replace("uptrend pressure",$pressure)
$line.outlook = $line.outlook.Replace("uptrend under pressure",$pressure)
$line.outlook = $line.outlook.Replace("uptrendunderpressure",$pressure)
$line.outlook = $line.outlook.Replace("under pressure",$pressure)
# uptrend lines
$line.outlook = $line.outlook.Replace("confirmed rally",$uptrend)
$line.outlook = $line.outlook.Replace("confirmed uptrend resumes",$uptrend)
$line.outlook = $line.outlook.Replace("confirmeduptrendresumes",$uptrend)
$line.outlook = $line.outlook.Replace("in confirmed uptrend",$uptrend)
$line.outlook = $line.outlook.Replace("market resumes confirmed",$uptrend)
$line.outlook = $line.outlook.Replace("market resumes uptrend",$uptrend)
$line.outlook = $line.outlook.Replace("marketinconfirmeduptrend",$uptrend)
$line.outlook = $line.outlook.Replace("confirmeduptrend",$uptrend)
$line.outlook = $line.outlook.Replace("marketinuptrend",$uptrend)
$line.outlook = $line.outlook.Replace("uptrendresumes",$uptrend)
$line.outlook = $line.outlook.Replace("market's confirmed uptrend",$uptrend)
$line.outlook = $line.outlook.Replace("confirmed uptrend",$uptrend)
$line.outlook = $line.outlook.Replace("in uptrend",$uptrend)
$line.outlook = $line.outlook.Replace("uptrend resumes",$uptrend)
$line.outlook = $line.outlook.Replace("confirmed",$uptrend)
$line.outlook = $line.outlook.Replace("uptrend",$uptrend)
$line.date = $line.date | get-date -Format yyyy/MM/dd
}

$markethist = $markethist | sort -Property date

$counting = $null
foreach($line in $markethist){
$line.outlook = [decimal]$line.outlook
$counting += $line.outlook
$line.outlook = $counting
}
