# set path to github folder where .txt converted pdf files are
$path = [environment]::getfolderpath("mydocuments") + "\GitHub\PDF\text\"
cd $path
# get list of all eIBD files with .txt extension
$list = (get-childitem -Filter eIBD*.txt).Name

$outlook = @()
# loop through files
foreach ($paper in $list){
#$paper = $list[1] # in case you need to just test with 1
$date = $paper.Replace("eIBD","")
$date = $date.Replace(".txt","")
$date = $date -split "(\w{2})"
$date = Get-Date ($date[1] + "/" + $date[3] + "/" + $date[5]) -Format MM/dd/yy

$paper = Get-Content $paper
$curoutlook = ($paper | Select-String "Current Outlook" -Context (0,1)).Context.PostContext
$curoutlook = [system.String]$curoutlook
$object = New-Object PSObject

$object | Add-Member -Name "Date" -MemberType NoteProperty -Value $date
$object | Add-Member -Name "Outlook" -MemberType NoteProperty -Value $curoutlook
$outlook += $object
}
$fulloutlook += $outlook
$fulloutlook | Export-Csv -NoTypeInformation $path\outlookhistory.csv
$fulloutlook = $null