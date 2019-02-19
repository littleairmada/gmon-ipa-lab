# configure installation settings
install
cdrom
lang en_US.UTF-8
keyboard us
timezone UTC
unsupported_hardware
text
skipx
firstboot --disabled
reboot

zerombr
bootloader --location=mbr --driveorder=sda
clearpart  --all --initlabel --drives=sda

part  /boot/efi --fstype='vfat'   --ondisk=sda  --size=256
part  /boot     --recommended
part  swap      --recommended
part  pv.1      --fstype='lvmpv'  --ondisk=sda  --size=1     --grow

volgroup  system  pv.1
logvol  /               --vgname=system  --fstype=xfs   --name=root           --size=1     --grow
logvol  /tmp            --vgname=system  --fstype=xfs   --name=tmp            --size=1024

# configure system settings
auth --enableshadow --passalgo=sha512 --kickstart
network --activate --hostname=ipa01.ipa.gmonlab.local --bootproto=static --device=eth0 --ip=192.168.1.201 --netmask=255.255.255.0 --gateway=192.168.1.1 --nameserver 8.8.8.8,8.8.4.4
firewall --enabled --ssh
selinux --permissive
rootpw vagrant
user --name=vagrant --password=vagrant

%packages --nobase --ignoremissing --excludedocs # install minimal packages
@core
net-tools
%end

%post # configure sudoers
echo "ALL ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/workstation
sed -i "s/^[^#].*requiretty/#Defaults requiretty/" /etc/sudoers # disable requiretty setting

echo "192.168.1.201  ipa01.ipa.gmonlab.local" | sudo tee -a /etc/hosts
echo "192.168.1.202  ipa02.ipa.gmonlab.local" | sudo tee -a /etc/hosts
hostnamectl set-hostname ipa01.ipa.gmonlab.local

yum clean all
yum update -y

echo "vagrant ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/vagrant
echo "Defaults:vagrant !requiretty" >> /etc/sudoers.d/vagrant
chmod 0440 /etc/sudoers.d/vagrant
mkdir -pm 700 /home/vagrant/.ssh
#curl -o /home/vagrant/.ssh/authorized_keys https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub
cat <<EOK >/home/vagrant/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8Y\
Vr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdO\
KLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7Pt\
ixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmC\
P3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcW\
yLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key
EOK
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant.vagrant /home/vagrant/.ssh
%end