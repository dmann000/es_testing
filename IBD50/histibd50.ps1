# set path to github folder where .txt converted pdf files are
$path = [environment]::getfolderpath("mydocuments") + "\GitHub\PDF\text\"
cd $path
# get list of all eIBD files with .txt extension
$list = (get-childitem -Filter eIBD*.txt).Name


$array = $null
# loop through files
foreach ($text in $list){
#$paper = $list[1] # in case you need to just test with 1
$date = $text.Replace("eIBD","")
$date = $date.Replace(".txt","")
$date = $date -split "(\w{2})"
$inprog = get-date ($date[1] + "/" + $date[3] + "/" + $date[5])
write-host "working on newspaper " $inprog.datetime
$date = Get-Date ($date[1] + "/" + $date[3] + "/" + $date[5]) -Format MM/dd/yy

$paper = get-content $text

$rawpdf = $paper | ForEach-Object {$_ -replace "","" }

$new = $null
$new = $new + ($rawpdf | Select-String ('\([A-Z][A-Z][A-Z][A-Z]\) Grp') | Select-String -Pattern '^\d')
$new = $new + ($rawpdf | Select-String ('\([A-Z][A-Z][A-Z]\) Grp') | Select-String -Pattern '^\d')
$new = $new + ($rawpdf | Select-String ('\([A-Z][A-Z]\) Grp') | Select-String -Pattern '^\d')
$new = $new + ($rawpdf | Select-String ('\([A-Z]\) Grp') | Select-String -Pattern '^\d')

$new = $new + ($rawpdf | Select-String ('\([A-Z][A-Z][A-Z][A-Z]\)Grp') | Select-String -Pattern '^\d')
$new = $new + ($rawpdf | Select-String ('\([A-Z][A-Z][A-Z]\)Grp') | Select-String -Pattern '^\d')
$new = $new + ($rawpdf | Select-String ('\([A-Z][A-Z]\)Grp') | Select-String -Pattern '^\d')
$new = $new + ($rawpdf | Select-String ('\([A-Z]\)Grp') | Select-String -Pattern '^\d')

$rawibd50 = $new | Where-Object -FilterScript {$_ -match '^[1-9] '}
$rawibd50 += $new | Where-Object -FilterScript {$_ -match '^[1-4][0-9] '}
$rawibd50 += $new | Where-Object -FilterScript {$_ -match '^50 '}

foreach ($line in $rawibd50){
# $line = $rawibd50[0]

    $paren = [regex]"\((.*)\)"

    $symbol = [regex]::match($line, $paren).Groups[1]
    $rank = $line.ToString().split(" ")[0]

    $cofilter = [regex]"$rank(.*)\("

    $company = ([regex]::match($line, $cofilter).Groups[1].Value).Split(" ", 2)[1]


    $buytext = (($rawpdf | Select-String -SimpleMatch $line -Context (0,11)).Context.PostContext | Select-String -SimpleMatch "Sup/Dem" -Context (0,1)).Context.PostContext[-1]
    # Write-Host "Symbol: " $symbol "IBD50 rank: " $rank "Company Name: " $company
    write-host $date - $rank - $buytext
    $array += $date+" - "+$buytext + "`r`n"
}
}
write-host $array