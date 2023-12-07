#!/bin/bash
# audit - sudo log :
#    file:
#     /etc/audit/rules.d
#    rulse:
# -a always,exit -F arch=b64 -S execve -F euid=0 -F auid>=1000 -F auid!=-1 -F key=sudo_log
# -a always,exit -F arch=b32 -S execve -F euid=0 -F auid>=1000 -F auid!=-1 -F key=sudo_log
#
#dt=`date '+%d/%m/%Y_%H:%M:%S'`
dt=`date '+%d%m%Y'`

#sudo cat /var/log/audit/audit.log | grep EnableBrowsers.sh   | perl -ne 'chomp; if ( /(.*msg=audit\()(\d+)(\.\d+:\d+.*)/ ) { $td = scalar localtime $2; print "$1$td$3\n"; }' >> /var/log/audit/sudo/$dt.txt


sudo cat /var/log/audit/audit.log | perl -ne 'chomp; if ( /(.*msg=audit\()(\d+)(\.\d+:\d+.*)/ ) { $td = scalar localtime $2; print "$1$td$3\n"; }' >> /var/log/audit/sudo/$dt.txt

grep -E 'res=success' /var/log/audit/sudo/$dt.txt >> /var/log/audit/sudo/success.$dt.log

grep -E 'res=failed' /var/log/audit/sudo/$dt.txt >> /var/log/audit/sudo/failed.$dt.log


cat "/var/log/audit/sudo/success.$dt.log"

echo ---------------------

cat "/var/log/audit/sudo/failed.$dt.log"










