# gmon-ipa-lab
This repo contains the CentOS 7 kickstarts, packer configurations, and test scripts used in the 
virtual lab for my [GIAC Continuous Monitoring Certification (GMON)](https://cyber-defense.sans.org/certification/gmon) 
Gold paper *Continuous Security Monitoring in non-Active Directory Environments*. The primary purpose of the paper was to 
investigate a FreeIPA directory and determine what artifacts can be leveraged by defenders to track activity--similar 
to CSM techniques used to track activity with Active Directory/Windows Event logs.

## Host Requirements

* VMWare Workstation 14+
* [Packer](https://packer.io)
* CentOS 7 Everything DVD ISO (CentOS-7-x86_64-DVD-1810.iso is automatically downloaded by Packer.)

## Important Notes

- The Packer and kickstart files expect the local virtual machine (VM) network to be **192.168.1.0/24**.
- IP addresses and credentials are hardcoded to minimize my PEBKAC errors. (Update as needed for your test environment.)
- This lab setup process was not designed to be fully automated and requires machines to be setup in a specific order.

## Lab Setup

This lab is comprised of 7 servers with assigned hostnames, IP addresses, and system requirements:

System | Domain | IP Address | RAM | Disk Size
------ | ------ | ---------- | --- | ---------
Syslog/ELK Server | elk.ipa.domain.local | 192.168.1.200 | 1GB | 20GB
Primary Directory Server | ipa01.ipa.domain.local | 192.168.1.201 | 2GB | 20GB
Secondary Directory Server | ipa02.ipa.domain.local | 192.168.1.202 | 2GB | 20GB
Client Server #1 | svr01.ipa.domain.local | 192.168.1.203 | 1GB | 20GB
Client Server #2 | svr02.ipa.domain.local | 192.168.1.206 | 1GB | 20GB
Client Workstation #1 | wkst01.ipa.domain.local | 192.168.1.204 | 1GB | 20GB
Client Workstation #2 | wkst02.ipa.domain.local |  192.168.1.205 | 1GB | 20GB

The VMs are created is a specific order and each VM must be powered on before the next one is created. 
(Packer)[https://packer.io] is used to create the VMs:

```bash
packer build log01.json
packer build ipa01.json
packer build ipa02.json
packer build srv01.json
packer build srv02.json
packer build wkst01.json
packer build wkst02.json
```

## Log Generation

The test suite is designed to perform commands associated with common administrative activity, user activity, 
and basic password attacks. 

Once all VMs are online, log on to IPA01 as `root` and execute:
```bash
/root/start-ipa-tests.sh
```

The results will be recorded to `/root/results-ipa-tests.log`.

Next, log on to WSKT01 as `root` and execute:
```bash
script -f /root/results-wkst-tests.log && /root/start-wkst-tests.sh
```

When you have completed the interactive script, type `exit` to record the results to `/root/results-wkst-tests.log`.

Finally, log on to WSKT01 as `root` and execute:
```bash
/root/start-password-attacks.sh
```

The results will be recorded to `/root/results-password-attacks.log`.

## Test Suite Coverage

Test ID | Test Type | Test Name | Status
------------ | ------------- | ------------ | -------------
T1 | Administrative | User Creation | :heavy_check_mark: Implemented
T2 | Administrative | Group Creation | :heavy_check_mark: Implemented
T3 | Administrative | User Deletion | :heavy_check_mark: Implemented
T4 | Administrative | Group Deletion | :heavy_check_mark: Implemented
T5 | Administrative | Group Membership Modification | :heavy_check_mark: Implemented
T6 | Administrative | Workstation/Server Domain Membership | :heavy_check_mark: Implemented
T7 | Administrative | Suspend User | :heavy_check_mark: Implemented
T8 | Administrative | Unsuspend User | :heavy_check_mark: Implemented
T9 | User Events | User Login | :heavy_check_mark: Implemented
T10 | User Events | User Logout | :heavy_check_mark: Implemented
T11 | User Events | Password Change | :heavy_check_mark: Implemented
T12 | User Events | Account Lockout | :heavy_check_mark: Implemented
T13 | Abnormal Activity | Directory Recon | :heavy_check_mark: Implemented
T14 | Abnormal Activity | Service Account Misuse | :x: Not Automated
T15 | Password Attack | Brute-Force Guessing | :heavy_check_mark: Implemented
T16 | Password Attack | Password Spray | :heavy_check_mark: Implemented

Please note the Moodle installation/configuration, testing, and analysis of the IPA logs for T14 is currently a manual 
process.