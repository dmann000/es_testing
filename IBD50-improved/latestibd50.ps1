$webClient = new-object System.Net.WebClient
$webClient.Headers.Add("user-agent", "PowerShell Script")
#location of pdftotext program (download xpdfbin for windows
$pdftotext = "C:\Program Files\xpdfbin-win-3.04\bin64\pdftotext.exe"
# path within GitHub directory for sharing if needed
$path = [environment]::getfolderpath("mydocuments") + "\Github\PDF\"
cd $path

# get list of items in path - grab the name of each file
$pdf  = ((get-childitem -Filter IBD*.pdf).Name)[-1]

write-host "$count Converting $pdf"
$text = $pdf.Split(".")[0]+".txt" #convert the .pdf extention to .txt
if (Test-Path $path\text\$text){
    write-host $text already exists
    }Else{
        & 'C:\Program Files\xpdfbin-win-3.04\bin64\pdftotext.exe' -raw $path\$pdf $path\text\$text # run conversion from pdf to txt using the "raw" format
}

write-host "Converted $pdf pdf file to text"

cd $path\text
$text  = ((get-childitem -Filter IBD*.txt).Name)[-1]

$array = $null
$buycount = $null
$output = @()
$badout = @()
$date = $text.Replace("IBD","")
$date = $date.Replace(".txt","")
$date = $date -split "(\w{2})"
$inprog = get-date ($date[5] + "/" + $date[7] + "/" + $date[3])
write-host "working on newspaper " $inprog.datetime
$date = Get-Date $inprog -Format MM/dd/yy

$paper = get-content $text

### checking current outlook conditions ###

$outlook = @()
$fail = $NULL
try {$outlooktext = ($paper | Select-String "Current Outlook:" -Context (0,1)).Context.PostContext[0]}
catch { $fail = "TRUE" 
    write-host "outlook was blank!"
    write-host $date
    write-host ""
}
$outlooktext = [system.String]$outlooktext
#if ($curoutlook -match "Market in"){$curoutlook = $curoutlook.Replace("Market in ","")}
$object = New-Object PSObject

$object | Add-Member -Name "Date" -MemberType NoteProperty -Value $date
$object | Add-Member -Name "OutlookText" -MemberType NoteProperty -Value $outlooktext
$status = $outlooktext.ToLower()
if($fail -eq "TRUE"){
    $curoutlook = "blank"
}elseif($status -match "pressure"){
    $curoutlook = "pressure"
}elseif($status -match "correction"){
    $curoutlook = "correction"
}elseif($status -match "uptrend"){
    $curoutlook = "uptrend"
}elseif($status -match "rally"){
    $curoutlook = "uptrend"
}elseif($status -match "market in confirmed"){
    $curoutlook = "uptrend"
}
$object | Add-Member -Name "Outlook" -MemberType NoteProperty -Value $curoutlook
write-host ""
write-host "Today's condition is $curoutlook $date Text was: $outlooktext"
write-host ""
$outlook += $object
$outlooktext = $NULL
$outlook | Export-Csv -NoTypeInformation ..\..\IBD50-improved\currentoutlook.csv

#### END checking current outlook condition ####

#### Starting IBD50 / buypoint collection ####

$rawpdf = $paper | ForEach-Object {$_ -replace "","" }

$new = $null
$new += ($rawpdf | Select-String ('\([A-Z]{1,5}\) Grp') | Select-String -Pattern '^\d')
$new += ($rawpdf | Select-String ('\([A-Z]{1,5}\)Grp') | Select-String -Pattern '^\d')

$new += ($rawpdf | Select-String ('\([A-Z]{1,5}\) Group') | Select-String -Pattern '^\d')
$new += ($rawpdf | Select-String ('\([A-Z]{1,5}\)Group') | Select-String -Pattern '^\d')

$rawibd50 = $new | Where-Object -FilterScript {$_ -match '^[1-9] '}
$rawibd50 += $new | Where-Object -FilterScript {$_ -match '^[1-4][0-9] '}
$rawibd50 += $new | Where-Object -FilterScript {$_ -match '^50 '}
$ibd50 = @()
$buypoints = @()
$extended = @()
if ($rawibd50.Count -ge 45){
foreach ($line in $rawibd50){
# $line = $rawibd50[6]

    write-host $line
    $paren = [regex]"\((.*)\)"

    $symbol = [regex]::match($line, $paren).Groups[1].value
    $rank = [decimal]$line.ToString().split(" ")[0]

    $cofilter = [regex]"$rank(.*)\("

    $company = ([regex]::match($line, $cofilter).Groups[1].Value).Split(" ", 2)[1]

$buytext = ($rawpdf | Select-String -SimpleMatch $line -Context (0,11)).Context.PostContext | Select-String -SimpleMatch "Sup/Dem" -Context (0,1)
$lastclose = $webClient.DownloadString("http://finance.yahoo.com/d/quotes.csv?s=$symbol&f=l1")

if ($buytext -ne $null){
    $buytext = $buytext.Context.PostContext[-1]
    }else{
    $buytext = (($rawpdf | Select-String -SimpleMatch $line -Context (0,12)).Context.PostContext | Select-String ('\([A-Z]{1,5}\)') -Context (1,0)).Context.preContext[0]
    }  
      
    $regex = ‘\d{1,3}\.\d{1,3}[^%.,\-;a-z]’
    $buypoint = [decimal]($buytext | select-string -Pattern $regex -AllMatches | % { $_.Matches } | % { $_.Value })
    if($buypoint -eq 0){$buypoint = $null}
    $countvalue = $buypoint.count

    $add50 = New-Object PSObject    
    $add50 | Add-Member -Name "Symbol" -MemberType NoteProperty -Value $symbol
    $add50 | Add-Member -Name "Company Name" -MemberType NoteProperty -Value $company
    $add50 | Add-Member -Name "IBD 50 Rank" -MemberType NoteProperty -Value $rank
    $ibd50 += $add50
    
    if(($countvalue -eq 1) -and (([decimal]$lastclose) -le ([decimal]$buypoint * 1.05))){
        $bps = $null
        $buycount += 1
        write-host "Identified $buycount buypoints's so far..."
        $bps = New-Object PSObject 
        $bps | Add-Member -Name "symbol" -MemberType NoteProperty -Value $symbol
        $bps | Add-Member -Name "buypoint" -MemberType NoteProperty -Value $buypoint
        $bps | Add-Member -Name "Text" -MemberType NoteProperty -Value $buytext
        $buypoints += $bps

    }else{
        $bad = New-Object PSObject
        $bad | Add-Member -Name "symbol" -MemberType NoteProperty -Value $symbol
        $bad | Add-Member -Name "buypoint" -MemberType NoteProperty -Value $buypoint
        $bad | Add-Member -Name "Text" -MemberType NoteProperty -Value $buytext
        $extended += $bad
    }
 
    
}}else{
write-host "Today's paper $date did not have an IBD50 list"
}

if ($rawibd50.Count -ge 45){
$ibd50 = $ibd50 | Sort-Object -Property "IBD 50 Rank"
$ibd50 | Export-Csv -NoTypeInformation "..\..\IBD50-improved\ibd50.csv"
$buypoints | Export-Csv -NoTypeInformation "..\..\IBD50-improved\buypoint.csv"
$extended | Export-Csv -NoTypeInformation "..\..\IBD50-improved\extended.csv"
}