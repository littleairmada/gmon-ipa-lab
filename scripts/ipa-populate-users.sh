#!/bin/sh

echo 'Pass1234!' | kinit admin
sleep 2

echo "[$(date)] Creating accounts tuser2 -> tuser5000"

for i in `seq 2 5000`;
do
    ipa user-add tuser$i --first "Test" --last "User$i" --email "tuser$i@ipa.gmonlab.local" --random --shell=/bin/bash
done

echo "[$(date)] Setting known password for tuser10"
echo 'cooper1' | echo 'cooper1' | ipa user-mod tuser10 --password

echo "[$(date)] Setting known password for tuser20"
echo 'Spring2019' | echo 'Spring2019' | ipa user-mod tuser20 --password
