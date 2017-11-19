$FirstNumArray = @()
For($first = 18; $first -le 25; $first ++)
{
 $FirstNumArray += $first
}

$SecondNumArray = @()
For($second = 3; $second -le 8; $second++)
{
 $SecondNumArray += $second
}

$ThirdNumArray = @()
For($Third = 4; $Third -le 7; $Third++)
{
 $ThirdNumArray += $Third
}


$values = @()
Foreach ($1Number in $FirstNumArray) {
 Foreach ($2Number in $SecondNumArray) {
  Foreach ($3Number in $ThirdNumArray) {
    $add = New-Object PSObject
    $add | Add-Member -Name "sharegain" -MemberType NoteProperty -Value ($1Number/100)
    $add | Add-Member -Name "shareloss" -MemberType NoteProperty -Value ($2Number/100)
    $add | Add-Member -Name "trailstop" -MemberType NoteProperty -Value ($3Number/100)
    $values += $add
}
}
}
