#!/bin/bash
#dt=`date '+%d/%m/%Y_%H:%M:%S'`
dt=`date '+%d%m%Y'`

sudo cat /var/log/audit/audit.log | grep EnableBrowsers.sh   | perl -ne 'chomp; if ( /(.*msg=audit\()(\d+)(\.\d+:\d+.*)/ ) { $td = scalar localtime $2; print "$1$td$3\n"; }' >> ~/logs/$dt.txt


grep -E 'res=success' ~/logs/$dt.txt >> ~/logs/success.$dt.log

grep -E res=failed ~/logs/$dt.txt >> ~/logs/failed.$dt.log







