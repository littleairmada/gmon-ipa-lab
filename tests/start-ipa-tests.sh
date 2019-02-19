#!/bin/sh

# This script executes GMON IPA Lab tests T1-T5 and T7-T8.
# Output is logged to /root/results-ipa-tests.log

timestamp=$( date "+%Y%m%d-%H%M%S" )
echo "Starting IPA Tests..."

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/root/results-ipa-tests.log 2>&1

echo "[$(date)] executing kinit admin prior to running ipa commands"
echo 'Pass1234!' | kinit admin

echo "[$(date)] Beginning IPA Tests"

echo "[$(date)] T1 User Creation Start"
sleep 2
ipa user-add tusert1 --first "TUser" --last "Test1" --email "tusert1@ipa.gmonlab.local" --random --shell=/bin/bash
sleep 2
echo "[$(date)] T1 User Creation End"
sleep 5

echo "[$(date)] T2 Group Creation Start"
sleep 2
ipa group-add --desc='Test Group T2' testgroupt2
sleep 2
echo "[$(date)] T2 Group Creation End"
sleep 5

echo "[$(date)] T3 User Deletion Start"
sleep 2
ipa user-del tusert1
sleep 2
echo "[$(date)] T3 User Deletion End"
sleep 5

echo "[$(date)] T5 Group Membership Modification Start"
sleep 2
ipa group-add-member testgroupt2 --users=tuser3
sleep 2
echo "[$(date)] T5 Group Membership Modification End"
sleep 5

echo "[$(date)] T4 Group Deletion Start"
sleep 2
ipa group-del testgroupt2
sleep 2
echo "[$(date)] T4 Group Deletion End"
sleep 5

echo "[$(date)] T7 Suspend User Start"
sleep 2
ipa user-disable tuser2
sleep 2
echo "[$(date)] T7 Suspend User End"
sleep 5

echo "[$(date)] T8 Unsuspend User Start"
sleep 2
ipa user-enable tuser2
sleep 2
echo "[$(date)] T8 Unsuspend User End"
sleep 5

echo "[$(date)] IPA Tests Complete"
