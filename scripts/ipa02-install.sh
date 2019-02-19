#!/bin/sh

firewall-cmd --add-service={dns,freeipa-ldap,freeipa-ldaps} --permanent
firewall-cmd --reload

yum install -y bind-utils freeipa-client

#ipa-client-install -U --mkhomedir -p admin --domain=ipa.gmonlab.local --server=ipa01.ipa.gmonlab.local --realm=IPA.GMONLAB.LOCAL --hostname=ipa02.ipa.gmonlab.local --force-join -w Pass1234!

yum install -y ipa-server ipa-server-common ipa-server-dns ipa-server-trust-ad

ipa-replica-install -U -r IPA.GMONLAB.LOCAL -n ipa.gmonlab.local -P admin -p Pass1234! --hostname=ipa02.ipa.gmonlab.local --server=ipa01.ipa.gmonlab.local --setup-ca --setup-dns --mkhomedir --force-join --auto-reverse --auto-forwarders

#yum install -y rsyslog-gnutls rsyslog
#systemctl restart rsyslog
#systemctl enable rsyslog
