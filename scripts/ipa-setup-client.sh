#!/bin/sh

hostname=$(hostname)

yum install -y bind-utils freeipa-client

ipa-client-install -U --mkhomedir -p admin --domain=ipa.gmonlab.local --server=ipa01.ipa.gmonlab.local --realm=IPA.GMONLAB.LOCAL --hostname="$hostname" --force-join -w Pass1234!
