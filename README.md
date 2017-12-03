# es_testing
What I am trying to do currently...

just work with a small dataset $data[0-3] for testing

on the first day - you will replace $day with the current date...

each change in $data.date - erase all variables, and update $day

for each day...

on the first bar - save the $hod and $lod with the current $data.high and $data.low

for each new line/bar - update the $hod or $lod if the $data.high or $data.low have increased

once the $hod & $lod are 6pts apart = if $high - $low = 6 or more... - now look for a half way back trade... example



Data Capture Instructions:

Contracts expire on the 3rd Friday of quarterly months:
	Mar
	Jun
	Sep
	Dec
	
"Rollover" is typically the Thursday 1 week prior to expiration (typically the 2nd thurs of the month unless the month started on a Friday, then the 1st Thurs of the month)

when doing historical capture, we need to pay attention to this as we have to "cut" the data during that window.  I have a separate script for this effort.

Basic - 2 week capture:

Open TWS (Interactive brokers) - read-only is fine.

Open IB-historical-capture.xls - and enable activex

under general - click connect TWS
	click request current time (verify time update)
	under capture log, see what the next date window is to capture