#!/bin/sh

rpm --import http://packages.elastic.co/GPG-KEY-elasticsearch
yum install -y wget
wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-6.5.3-x86_64.rpm
yum install -y filebeat-6.5.3-x86_64.rpm

#/etc/filebeat/filebeat.yml
cat > /etc/filebeat/filebeat.yml << "__EOF__"
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/*.log
  #exclude_lines: ['^DBG']
  #include_lines: ['^ERR', '^WARN']
  #exclude_files: ['.gz$']
  #fields:
  #  level: debug
  #  review: 1

  ### Multiline options
  #multiline.pattern: ^\[
  #multiline.negate: false
  #multiline.match: after

filebeat.config.modules:
  path: ${path.config}/modules.d/*.yml
  reload.enabled: false
  #reload.period: 10s
setup.template.settings:
  index.number_of_shards: 3
  #index.codec: best_compression
  #_source.enabled: false

#name:
#tags: ["service-X", "web-tier"]
#fields:
#  env: staging

#setup.dashboards.enabled: false
#setup.dashboards.url:

#setup.kibana:
  #host: "localhost:5601"
  #space.id:

#output.elasticsearch:
#  hosts: ["localhost:9200"]
  #protocol: "https"
  #username: "elastic"
  #password: "changeme"

output.logstash:
  hosts: ["log01.ipa.gmonlab.local:5044"]
  bulk_max_size: 1024
  ssl.certificate_authorities: ["/etc/pki/tls/certs/logstash-forwarder.crt"]
  #ssl.certificate: "/etc/pki/client/cert.pem"
  #ssl.key: "/etc/pki/client/cert.key"

processors:
  - add_host_metadata: ~
  - add_cloud_metadata: ~

#logging.level: debug
#logging.selectors: ["*"]

#xpack.monitoring.enabled: false
#xpack.monitoring.elasticsearch:
__EOF__

systemctl restart filebeat
systemctl enable filebeat
