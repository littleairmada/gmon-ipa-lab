#!/bin/sh

# This script executes GMON IPA Lab tests T9-T13.
# Output is logged to /root/results-wkst-tests.log

#exec 3>&1 4>&2
#trap 'exec 2>&4 1>&3' 0 1 2 3
#exec 1>/root/results-wkst-tests.log 2>&1

yum install -y openldap-clients

echo "[$(date)] Beginning WKST Tests"

sleep 5

echo "[$(date)] T9 User Login Start"
sleep 2

echo "In the next 60 seconds, login as tuser20 (command follows) using the password Spring2019"
echo "If prompted to change the user's password, use Spring2019 for both the old and new passwords."
echo "REMAIN LOGGED INTO THE NEW SSH SESSION AS TUSER20."
echo ""
echo "ssh tuser20@192.168.1.204"
echo ""
echo "[$(date)] T9 Pausing 60 seconds for user login"
sleep 60
echo "[$(date)] T9 User Login End"

sleep 5

# TODO: T11 | User Events | Password Change
echo "[$(date)] T11 Password Change Start"
sleep 2
echo "In the next 60 seconds in the ssh terminal you logged into as tuser20, change the user's password using the command:"
echo ""
echo "passwd"
echo ""
echo "[$(date)] T11 Pausing 60 seconds for user password change"
sleep 60
echo "[$(date)] T11 Password Change End"

sleep 5

# TODO: T10 | User Events | User Logout
echo "[$(date)] T10 User Logout Start"
sleep 2
echo "In the next 60 seconds in the ssh terminal you logged into as tuser20, issue the exit command to logout:"
echo ""
echo "exit"
echo ""
echo "[$(date)] T10 Pausing 60 seconds for user logout"
sleep 60
echo "[$(date)] T10 User Logout End"

sleep 5

# TODO: T12 | User Events | Account Lockout
echo "[$(date)] T12 Account Lockout Start"
sleep 2
echo "In the next 120 seconds, attempt to login as tuser20 10+ times using the password WrongPassword"
echo ""
echo "ssh tuser20@192.168.1.204"
echo ""
echo "[$(date)] T12 Pausing 120 seconds for user logout"
sleep 120
echo "[$(date)] T12 Account Lockout End"

sleep 5

# TODO: T13 | Abnormal Activity | Directory Recon
echo "[$(date)] T13 Directory Recon Start"
sleep 2
echo 'Pass1234!' | kinit admin
sleep 2
ldapsearch -x -b "cn=users,cn=accounts,dc=ipa,dc=gmonlab,dc=local" -s one -E \!pr=5000 -E \!sss=uid/givenName/sn "(objectclass=*)"
sleep 5
echo "[$(date)] T13 Directory Recon End"

sleep 5

echo "[$(date)] WKST Tests Complete"