$path = [environment]::getfolderpath("mydocuments") + "\GitHub\IBD50-improved"
cd $path

$histintraday = import-csv histintraday-collection.csv

foreach($line in $histintraday){
    $line | Add-Member -Name "buypoint" -MemberType NoteProperty -Value ([decimal]$line.buypeak / 1.05)
    $line.date = $line.date -as [datetime]
    }

$histintraday = $histintraday | Sort-Object -Property Symbol,Date


foreach($line in $histintraday){
    $line.date = get-date $line.date -format MM/dd/yyyy
    }

$histintraday | export-csv -NoTypeInformation histbuypoints.csv