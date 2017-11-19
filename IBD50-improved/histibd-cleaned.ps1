$webClient = new-object System.Net.WebClient
$webClient.Headers.Add("user-agent", "PowerShell Script")
$path = [environment]::getfolderpath("mydocuments") + "\GitHub\IBD50-improved"
cd $path\..\symbolhistory

# get list of items in path - grab the name of each file
$list = (get-childitem -Filter *.txt).Name

$newlist = @()
foreach($line in $list){
    $line = $line.Replace(".txt","")
    $newlist += $line
    }

$ibdhist = import-csv $path\ibdhist.csv
$ibdhist = $ibdhist | Where-Object {$_.buypoint -ne ""}

$finalibdhist = @()
foreach ($line in $newlist){
    $collected = $ibdhist | Where-Object {$_.symbol -eq $line}
    $finalibdhist += $collected
}

$finalibdhist | export-csv -NoTypeInformation $path\finalibdhist.csv
