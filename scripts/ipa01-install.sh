#!/bin/sh

firewall-cmd --add-service={dns,freeipa-ldap,freeipa-ldaps} --permanent
firewall-cmd --reload

yum install -y ipa-server ipa-server-common ipa-server-dns ipa-server-trust-ad

ipa-server-install -r IPA.GMONLAB.LOCAL -n ipa.gmonlab.local -p Pass123456789! -a Pass1234! --hostname=ipa01.ipa.gmonlab.local --ip-address=192.168.1.201 -U --setup-dns --forwarder=8.8.8.8 --forwarder=8.8.4.4 --auto-reverse

#run "kinit admin" before running "ipa" commands
echo 'Pass1234!' | kinit admin

#Fix DNS after IPA is setup
sed -ie 's%^DNS1=.*%DNS1="192.168.1.201"%g' /etc/sysconfig/network-scripts/ifcfg-eth0
sed -ie 's%^DNS2=.*%DNS2="192.168.1.202"%g' /etc/sysconfig/network-scripts/ifcfg-eth0

ipa dnsrecord-add ipa.gmonlab.local log01 --a-rec 192.168.1.200
ipa dnsrecord-add ipa.gmonlab.local ipa01 --a-rec 192.168.1.201
ipa dnsrecord-add ipa.gmonlab.local ipa02 --a-rec 192.168.1.202
ipa dnsrecord-add ipa.gmonlab.local svr01 --a-rec 192.168.1.203
ipa dnsrecord-add ipa.gmonlab.local wkst01 --a-rec 192.168.1.204
ipa dnsrecord-add ipa.gmonlab.local wkst02 --a-rec 192.168.1.205
ipa dnsrecord-add ipa.gmonlab.local svr02 --a-rec 192.168.1.206

ipa dnsrecord-add 1.168.192.in-addr.arpa. 200 --ptr-rec log01.ipa.gmonlab.local.
ipa dnsrecord-add 1.168.192.in-addr.arpa. 202 --ptr-rec ipa02.ipa.gmonlab.local.
ipa dnsrecord-add 1.168.192.in-addr.arpa. 203 --ptr-rec svr01.ipa.gmonlab.local.
ipa dnsrecord-add 1.168.192.in-addr.arpa. 204 --ptr-rec wkst01.ipa.gmonlab.local.
ipa dnsrecord-add 1.168.192.in-addr.arpa. 205 --ptr-rec wkst02.ipa.gmonlab.local.
ipa dnsrecord-add 1.168.192.in-addr.arpa. 206 --ptr-rec svr02.ipa.gmonlab.local.

#yum install -y rsyslog-gnutls rsyslog
#systemctl restart rsyslog
#systemctl enable rsyslog

# rpm --import http://packages.elastic.co/GPG-KEY-elasticsearch
# yum install -y wget
# wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-6.5.3-x86_64.rpm
# yum install -y filebeat-6.5.3-x86_64.rpm

# # /etc/filebeat/filebeat.yml
# cat > /etc/filebeat/filebeat.yml << "__EOF__"
# filebeat.inputs:
# - type: log
  # enabled: true
  # paths:
    # - /var/log/dirsrv/slapd-IPA-GMONLAB-LOCAL/access
  # tags: ["ipa-access"]

# - type: log
  # enabled: true
  # paths:
    # - /var/log/dirsrv/slapd-IPA-GMONLAB-LOCAL/errors
  # tags: ["ipa-errors"]

# - type: log
  # enabled: true
  # paths:
    # - /var/log/dirsrv/slapd-IPA-GMONLAB-LOCAL/audit
  # tags: ["ipa-audit"]

# - type: log
  # enabled: true
  # paths:
    # - /var/log/httpd/access_log
  # tags: ["ipa-httpd-access"]

# - type: log
  # enabled: true
  # paths:
    # - /var/log/httpd/error_log
  # tags: ["ipa-httpd-error"]

# - type: log
  # enabled: true
  # paths:
    # - /var/log/kadmind.log
  # tags: ["ipa-kadmind"]

# - type: log
  # enabled: true
  # paths:
    # - /var/log/krb5kdc.log
  # tags: ["ipa-krb5kdc"]

# - type: log
  # enabled: true
  # paths:
    # - /var/log/pki/pki-tomcat/ca/transactions
  # tags: ["ipa-ca-transactions"]

# filebeat.config.modules:
  # path: ${path.config}/modules.d/*.yml
  # reload.enabled: false
  # # reload.period: 10s
# setup.template.settings:
  # index.number_of_shards: 3
  # # index.codec: best_compression
  # # _source.enabled: false

# # setup.dashboards.enabled: false
# # setup.dashboards.url:

# output.logstash:
  # hosts: ["log01.ipa.gmonlab.local:5044"]
  # bulk_max_size: 1024
  # ssl.certificate_authorities: ["/etc/pki/tls/certs/logstash-forwarder.crt"]

# processors:
  # - add_host_metadata: ~
  # - add_cloud_metadata: ~

# logging.level: debug
# # logging.selectors: ["*"]

# # xpack.monitoring.enabled: false
# # xpack.monitoring.elasticsearch:
# __EOF__

# systemctl restart filebeat
# systemctl enable filebeat

exit
