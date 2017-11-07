$data = import-csv C:\Users\dmann\Documents\personal\es_5min_sample.csv
$high = $null
$low = $null
$hod = $null
$lod = $null
$day = $null


foreach($line in $data){
    if ($line.high -gt $high){
        $line.high = $high
    }
    if ($line.low -lt $low){
        $line.low = $low
    }

    

}