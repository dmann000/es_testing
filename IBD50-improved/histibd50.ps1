# set path to github folder where .txt converted pdf files are
$path = [environment]::getfolderpath("mydocuments") + "\GitHub\PDF\text\"
cd $path
# get list of all eIBD files with .txt extension
$list = (get-childitem -Filter eIBD*.txt).Name
$array = $null
$buycount = $null
$output = @()
$badout = @()
# loop through files
$papercount = $null
foreach ($text in $list){
#$text = $list[1] # in case you need to just test with 1
$papercount += 1
$date = $text.Replace("eIBD","")
#$date = $date.Replace("IBD","")
$date = $date.Replace(".txt","")
$date = $date -split "(\w{2})"
$inprog = get-date ($date[1] + "/" + $date[3] + "/" + $date[5])
write-host "working on newspaper " $inprog.datetime
write-host $papercount of $list.count
$date = Get-Date ($date[1] + "/" + $date[3] + "/" + $date[5]) -Format MM/dd/yy

$paper = get-content $text

$rawpdf = $paper | ForEach-Object {$_ -replace "","" }

$new = $null
$new += ($rawpdf | Select-String ('\([A-Z]{1,5}\) Grp') | Select-String -Pattern '^\d')
$new += ($rawpdf | Select-String ('\([A-Z]{1,5}\)Grp') | Select-String -Pattern '^\d')

$rawibd50 = $new | Where-Object -FilterScript {$_ -match '^[1-9] '}
$rawibd50 += $new | Where-Object -FilterScript {$_ -match '^[1-4][0-9] '}
$rawibd50 += $new | Where-Object -FilterScript {$_ -match '^50 '}
$histibd = @()
$badones = @()
if ($rawibd50.Count -ge 45){
foreach ($line in $rawibd50){
# $line = $rawibd50[0]

    write-host $line
    $paren = [regex]"\((.*)\)"

    $symbol = [regex]::match($line, $paren).Groups[1].value
    $rank = $line.ToString().split(" ")[0]

    $cofilter = [regex]"$rank(.*)\("

    $company = ([regex]::match($line, $cofilter).Groups[1].Value).Split(" ", 2)[1]

$buytext = ($rawpdf | Select-String -SimpleMatch $line -Context (0,11)).Context.PostContext | Select-String -SimpleMatch "Sup/Dem" -Context (0,1)

if ($buytext -ne $null){
    $buytext = $buytext.Context.PostContext[-1]
    }else{
    $buytext = (($rawpdf | Select-String -SimpleMatch $line -Context (0,12)).Context.PostContext | Select-String ('\([A-Z]{1,5}\)') -Context (1,0)).Context.preContext[0]
    }  
      
    $regex = ‘\d{1,3}\.\d{1,3}[^%.,\-;a-z]’
    $buypoint = $buytext | select-string -Pattern $regex -AllMatches | % { $_.Matches } | % { $_.Value }
    $countvalue = $buypoint.count
    
    if($countvalue -le 1){

    $add = New-Object PSObject    
    $add | Add-Member -Name "date" -MemberType NoteProperty -Value $date
    $add | Add-Member -Name "symbol" -MemberType NoteProperty -Value $symbol
    $add | Add-Member -Name "rank" -MemberType NoteProperty -Value $rank
    $add | Add-Member -Name "buytext" -MemberType NoteProperty -Value $buytext
    $add | Add-Member -Name "buypoint" -MemberType NoteProperty -Value $buypoint
    if($countvalue -eq 1){
        $buycount += 1
        write-host "Identified $buycount buypoints's so far..."
        }

    $histibd += $add

    }else{
    $bad = New-Object PSObject
    $bad | Add-Member -Name "date" -MemberType NoteProperty -Value $date
    $bad | Add-Member -Name "symbol" -MemberType NoteProperty -Value $symbol
    $bad | Add-Member -Name "rank" -MemberType NoteProperty -Value $rank
    $bad | Add-Member -Name "buytext" -MemberType NoteProperty -Value $buytext
    $bad | Add-Member -Name "countvalue" -MemberType NoteProperty -Value $countvalue
    $badones += $bad
    }
}

$output += $histibd
$badout += $badones
}
}

$output | Export-Csv -NoTypeInformation "..\..\IBD50-improved\ibdhist.csv"
$badout | Export-Csv -NoTypeInformation "..\..\IBD50-improved\badibdhist.csv"
$total = $output
$total += $badout
$total | Export-Csv -NoTypeInformation "..\..\IBD50-improved\ibdhist_combined.csv"