# es_testing
What I am trying to do currently...

just work with a small dataset $data[0-3] for testing

on the first day - you will replace $day with the current date...

each change in $data.date - erase all variables, and update $day

for each day...

on the first bar - save the $hod and $lod with the current $data.high and $data.low

for each new line/bar - update the $hod or $lod if the $data.high or $data.low have increased

once the $hod & $lod are 6pts apart = if $high - $low = 6 or more... - now look for a half way back trade... example

