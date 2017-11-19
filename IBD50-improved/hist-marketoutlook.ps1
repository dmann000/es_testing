# set path to github folder where .txt converted pdf files are
$path = [environment]::getfolderpath("mydocuments") + "\GitHub\PDF\text\"
cd $path
# get list of all eIBD files with .txt extension
$list = (get-childitem -Filter eIBD*.txt).Name

$outlook = @()
# loop through files
$count = $null
foreach ($paper in $list){
# $paper = $list[1] # in case you need to just test with 1
$count += 1
write-host "On paper $paper.  $count of $($list.count)"
$date = $paper.Replace("eIBD","")
$date = $date.Replace(".txt","")
$date = $date -split "(\w{2})"
$date = Get-Date ($date[1] + "/" + $date[3] + "/" + $date[5]) -Format MM/dd/yy
$paper = Get-Content $paper
$fail = $NULL
try {$outlooktext = ($paper | Select-String "Current Outlook:" -Context (0,1)).Context.PostContext[0]}
catch { $fail = "TRUE" 
    write-host "outlook was blank!"
    $outlooktext = $null
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
$outlook += $object
$outlooktext = $NULL
}
$fulloutlook += $outlook
$fulloutlook | Export-Csv -NoTypeInformation "..\..\IBD50-improved\outlookhistory.csv"
#$fulloutlook = $null

$play = 0
while ($play -lt 5){
$play += 1
(new-object Media.SoundPlayer "C:\WINDOWS\Media\notify.wav").play();
sleep 2
}