$data = import-csv $env:userprofile + "\Documents\personal\es_5min_sample.csv"
$high = $null
$low = $null
$hod = $null
$lod = $null
$day = $null


foreach($line in $data[0-3]){
    if $day -eq $null{
        $day = $data.date
    }
    if ($line.high -gt $hod){
        $line.high = $hod
    }
    if ($line.low -lt $lod){
        $line.low = $lod
    }

    

}