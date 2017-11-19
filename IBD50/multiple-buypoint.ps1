foreach ($line in $buypoint){
#$line = $buypoint[2]
$regex = ‘\d{1,3}\.\d{1,3}’
if (($line | select-string -Pattern $regex -AllMatches | % { $_.Matches } | % { $_.Value }).count -ge 2){
    Write-Output $line
}
}