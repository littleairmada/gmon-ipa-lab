#!/bin/sh

yum install -y wget

# rsyslog
#yum install -y rsyslog-gnutls rsyslog
#
#sed -ie 's%^#$ModLoad imudp%$ModLoad imudp%g' /etc/rsyslog.conf
#sed -ie 's%^#$UDPServerRun 514%$UDPServerRun 514%g' /etc/rsyslog.conf
#sed -ie 's%^#$ModLoad imtcp%$ModLoad imtcp%g' /etc/rsyslog.conf
#sed -ie 's%^#$InputTCPServerRun 514%$InputTCPServerRun 514%g' /etc/rsyslog.conf
#systemctl restart rsyslog
#systemctl enable rsyslog

# Configure firewalld
systemctl enable firewalld
systemctl restart firewalld
firewall-cmd --zone=public --permanent --add-service=syslog
firewall-cmd --zone=public --permanent --add-port=514/tcp
firewall-cmd --zone=public --permanent --add-service=http
firewall-cmd --zone=public --permanent --add-service=https
firewall-cmd --zone=public --permanent --add-service=elasticsearch
firewall-cmd --zone=public --permanent --add-service=kibana
firewall-cmd --reload

# Install ELK
yum install -y java-1.8.0-openjdk
yum -y install epel-release

wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.5.3.rpm
wget https://artifacts.elastic.co/downloads/kibana/kibana-6.5.3-x86_64.rpm
wget https://artifacts.elastic.co/downloads/logstash/logstash-6.5.3.rpm
wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-6.5.3-x86_64.rpm
wget https://artifacts.elastic.co/downloads/beats/auditbeat/auditbeat-6.5.3-x86_64.rpm
wget https://artifacts.elastic.co/downloads/beats/heartbeat/heartbeat-6.5.3-x86_64.rpm
wget https://artifacts.elastic.co/downloads/beats/packetbeat/packetbeat-6.5.3-x86_64.rpm
wget https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-6.5.3-x86_64.rpm

yum install -y elasticsearch-6.5.3.rpm
yum install -y kibana-6.5.3-x86_64.rpm
yum install -y logstash-6.5.3.rpm
yum install -y filebeat-6.5.3-x86_64.rpm
yum install -y auditbeat-6.5.3-x86_64.rpm
yum install -y heartbeat-6.5.3-x86_64.rpm
yum install -y packetbeat-6.5.3-x86_64.rpm
yum install -y metricbeat-6.5.3-x86_64.rpm

# Configure ElasticSearch
cat > /etc/elasticsearch/elasticsearch.yml << "__EOF__"
#cluster.name: my-application
#node.name: node-1
#node.attr.rack: r1
path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch
#bootstrap.memory_lock: true
#network.host: 192.168.0.1
#http.port: 9200
#discovery.zen.ping.unicast.hosts: ["host1", "host2"]
#discovery.zen.minimum_master_nodes:
#gateway.recover_after_nodes: 3
#action.destructive_requires_name: true
__EOF__

# Configure Kibana
cat > /etc/kibana/kibana.yml << "__EOF__"
server.port: 5601
server.host: "localhost"
#server.basePath: ""
#server.rewriteBasePath: false
#server.maxPayloadBytes: 1048576
#server.name: "your-hostname"
elasticsearch.url: "http://localhost:9200"
#elasticsearch.preserveHost: true
#kibana.index: ".kibana"
#kibana.defaultAppId: "home"
#elasticsearch.username: "user"
#elasticsearch.password: "pass"
#server.ssl.enabled: false
#server.ssl.certificate: /path/to/your/server.crt
#server.ssl.key: /path/to/your/server.key
#elasticsearch.ssl.certificate: /path/to/your/client.crt
#elasticsearch.ssl.key: /path/to/your/client.key
#elasticsearch.ssl.certificateAuthorities: [ "/path/to/your/CA.pem" ]
#elasticsearch.ssl.verificationMode: full
#elasticsearch.pingTimeout: 1500
#elasticsearch.requestTimeout: 30000
#elasticsearch.requestHeadersWhitelist: [ authorization ]
#elasticsearch.customHeaders: {}
#elasticsearch.shardTimeout: 30000
#elasticsearch.startupTimeout: 5000
#elasticsearch.logQueries: false
#pid.file: /var/run/kibana.pid
#logging.dest: stdout
#logging.silent: false
#logging.quiet: false
#logging.verbose: false
#ops.interval: 5000
#i18n.locale: "en"
__EOF__

# Enable & retart ElasticSearch & Kibana
systemctl enable elasticsearch
systemctl restart elasticsearch
systemctl enable kibana
systemctl restart kibana

# Configure Logstash
cd /etc/pki/tls
openssl req -subj '/CN=log01.ipa.gmonlab.local/' -x509 -days 3650 -batch -nodes -newkey rsa:2048 -keyout private/logstash-forwarder.key -out certs/logstash-forwarder.crt

cat > /etc/logstash/conf.d/02-beats-input.old << "__EOF__"
input {
  beats {
    port => 5044
    ssl => true
    ssl_certificate => "/etc/pki/tls/certs/logstash-forwarder.crt"
    ssl_key => "/etc/pki/tls/private/logstash-forwarder.key"
  }
}

filter {
  grok {
    match => [ "message", "%{SYSLOGBASE} (?:(?:<= (?:b|m)db_%{DATA:index_error_filter_type}_candidates: \(%{WORD:index_error_attribute_name}\) not indexed)|(?:ppolicy_%{DATA:ppolicy_op}: %{DATA:ppolicy_data})|(?:connection_input: conn=%{INT:connection} deferring operation: %{DATA:deferring_op})|(?:connection_read\(%{INT:fd_number}\): no connection!)|(?:conn=%{INT:connection} (?:(?:fd=%{INT:fd_number} (?:(?:closed(?: \(connection lost\)|))|(?:ACCEPT from IP=%{IP:src_ip}\:%{INT:src_port} \(IP=%{IP:dst_ip}\:%{INT:dst_port}\))|(?:TLS established tls_ssf=%{INT:tls_ssf} ssf=%{INT:ssf})))|(?:op=%{INT:operation_number} (?:(?:(?:(?:SEARCH )|(?:))RESULT (?:tag=%{INT:tag}|oid=(?:%{DATA:oid}(?:))) err=%{INT:error_code}(?:(?: nentries=%{INT:nentries})|(?:)) text=(?:(?:%{DATA:error_text})|(?:)))|(?:%{WORD:operation_name}(?:(?: %{DATA:data})|(?:))))))))%{SPACE}$" ]
  }
  date {
    locale => "en"
    match => [ "timestamp" , "dd/MMM/yyyy:HH:mm:ss Z" ]
    target => "@timestamp"
  }
  if [operation_name] == "BIND" {
    grok {
      match => [ "data", "(?:(?:(?<bind_dn>anonymous))|(?:dn=\"%{DATA:bind_dn}\")) (?:(?:method=%{WORD:bind_method})|(?:mech=%{WORD:bind_mech} ssf=%{INT:bind_ssf}))%{SPACE}$" ]
      add_field => [ "op_type", "BIND" ]
    }
  }
  if [operation_name] == "SRCH" {
    grok {
      match => [ "data", "(?:(?:base=\"%{DATA:search_base}\" scope=%{INT:search_scope} deref=%{INT:search_deref} filter=\"%{DATA:search_filter}\")|(?:attr=%{DATA:search_attr}))%{SPACE}$" ]
      add_field => [ "op_type", "SRCH" ]
    }
  }
  if [operation_name] == "MOD" {
    grok {
      match => [ "data", "(?:(?:dn=\"%{DATA:mod_dn}\")|(?:attr=%{DATA:mod_attr}))%{SPACE}$" ]
      add_field => [ "op_type", "MOD" ]
    }
  }
  if [operation_name] == "MODRDN" {
    grok {
      match => [ "data", "dn=\"%{DATA:modrdn_dn}\"%{SPACE}$" ]
      add_field => [ "op_type", "MODRDN" ]
    }
  }
  if [operation_name] == "ADD" {
    grok {
      match => [ "data", "dn=\"%{DATA:add_dn}\"%{SPACE}$" ]
      add_field => [ "op_type", "ADD" ]
    }
  }
  if [operation_name] == "DEL" {
    grok {
      match => [ "data", "dn=\"%{DATA:del_dn}\"%{SPACE}$" ]
      add_field => [ "op_type", "DEL" ]
    }
  }
  if [operation_name] == "CMP" {
    grok {
      match => [ "data", "dn=\"%{DATA:cmp_dn}\" attr=\"%{DATA:cmp_attr}\"%{SPACE}$" ]
      add_field => [ "op_type", "CMP" ]
    }
  }
  if [operation_name] == "EXT" {
    grok {
      match => [ "data", "oid=%{DATA:ext_oid}%{SPACE}$" ]
      add_field => [ "op_type", "EXT" ]
    }
  }
  if [ppolicy_op] == "bind" {
    grok {
      match => [ "ppolicy_data", "(?:(?:Entry %{DATA:ppolicy_bind_dn} has an expired password: %{INT:ppolicy_grace} grace logins)|(?:Setting warning for password expiry for %{DATA:ppolicy_bind_dn} = %{INT:ppolicy_expiration} seconds))%{SPACE}$" ]
      remove_field => [ "ppolicy_data" ]
    }
  }
}
__EOF__

cat > /etc/logstash/conf.d/02-beats-input.conf << "__EOF__"
input {
  beats {
    port => 5044
    ssl => true
    ssl_certificate => "/etc/pki/tls/certs/logstash-forwarder.crt"
    ssl_key => "/etc/pki/tls/private/logstash-forwarder.key"
  }
}

filter {
  #BIND
  grok {
    "match" => { "message => [
      '%{SYSLOGTIMESTAMP:syslog_timestamp} conn=%{WORD:conn} op=%{WORD:op} BIND dn="%{WORD:dn}" method=%{WORD:method} version=%{WORD:version} mech=%{WORD:mech}',
      '%{SYSLOGTIMESTAMP:syslog_timestamp} conn=%{WORD:conn} op=%{WORD:op} BIND dn="%{WORD:dn}" method=%{WORD:method} version=%{WORD:version}'
      ] }
  }
  #UNBIND
  grok {
    "match" => { "message => [
      '%{SYSLOGTIMESTAMP:syslog_timestamp} conn=%{WORD:conn} op=%{WORD:op} UNBIND'
      ] }
  }
  #ADD
  grok {
    "match" => { "message => [
      '%{SYSLOGTIMESTAMP:syslog_timestamp} conn=%{WORD:conn} op=%{WORD:op} ADD dn="%{WORD:dn}"'
      ] }
  }
  syslog_pri { }
  date {
      match => [ "syslog_timestamp", "MMM  d HH:mm:ss", "MMM dd HH:mm:ss", "dd/MMM/yyyy:HH:mm:ss Z" ]
    }
}
__EOF__

cat > /etc/logstash/conf.d/10-syslog-filter.conf << "__EOF__"
filter {
  if [type] == "syslog" {
    grok {
      match => { "message" => "%{SYSLOGTIMESTAMP:syslog_timestamp} %{SYSLOGHOST:syslog_hostname} %{DATA:syslog_program}(?:\[%{POSINT:syslog_pid}\])?: %{GREEDYDATA:syslog_message}" }
      add_field => [ "received_at", "%{@timestamp}" ]
      add_field => [ "received_from", "%{host}" ]
    }
    syslog_pri { }
    date {
      match => [ "syslog_timestamp", "MMM  d HH:mm:ss", "MMM dd HH:mm:ss" ]
    }
  }
}
__EOF__

#TODO: /etc/logstash/conf.d/20-ipa-filter.conf 

cat > /etc/logstash/conf.d/30-elasticsearch-output.conf << "__EOF__"
output {
  elasticsearch {
    hosts => ["localhost:9200"]
    sniffing => true
    manage_template => false
    index => "%{[@metadata][beat]}-%{+YYYY.MM.dd}"
    document_type => "%{[@metadata][type]}"
  }
}
__EOF__

systemctl restart logstash
systemctl enable logstash

# Configure NGINX proxy to Kibana
#yum -y install nginx httpd-tools
yum -y install nginx

cat > /etc/nginx/conf.d/kibana.conf << "__EOF__"
server {
    listen 80;

    server_name log01.ipa.gmonlab.local;

#    auth_basic "Restricted Access";
#    auth_basic_user_file /etc/nginx/htpasswd.users;

    location / {
        proxy_pass http://localhost:5601;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;        
    }
}
__EOF__

systemctl restart nginx
systemctl enable nginx