#!/bin/bash


### Get script arguements ###
# while getopts "h:" opt; do
#     case $opt in
#         h) hosts+=("$OPTARG");;
#     esac
# done
# shift $((OPTIND -1))


### Update packages ###
yum update -y


### Update Hosts file for all hosts on cluster. ###

# Iterate over list of hosts provided by user and update.
# for host in "${hosts[@]}"; do
#     IP=$(host $host | awk '/has address/ { print $4 }')
#     FQDN=$(host $host | awk '/has address/ { print $1 }')
#     echo "$IP  $FQDN   $host" >> /etc/hosts
# done

# Validate Hosts file
cat /etc/hosts



### Disable Firewall ###
iptables-save > ~/firewall.rules
systemctl disable firewalld
systemctl stop firewalld


### Disable SELinux (enable after Cloudera install) ###
if [ $(getenforce) == "Permissive" ] || [ $(getenforce) == "Disabled" ]
then
  echo "SELinux already set to $(getenforce)"
else
  sed -i -e 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
  setenforce 0
  getenforce
fi



######### Tuning for Cloudera env #########

### Disable Tuned Servies ###
systemctl start tuned
tuned-adm off
tuned-adm list
systemctl stop tuned
systemctl disable tuned



### Disable Transparent Hugepage (need root) ###
echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo never > /sys/kernel/mm/transparent_hugepage/defrag

echo "echo never > /sys/kernel/mm/transparent_hugepage/defrag" >> /etc/rc.d/rc.local
echo "echo never > /sys/kernel/mm/transparent_hugepage/enabled" >> /etc/rc.d/rc.local
chmod +x /etc/rc.d/rc.local

cat /sys/kernel/mm/transparent_hugepage/enabled
cat /sys/kernel/mm/transparent_hugepage/defrag

echo "transparent_hugepage=never" >> /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg


### Set server vm.swapiness ##
sysctl -w vm.swappiness=1
echo "vm.swappiness = 1" >> /etc/sysctl.conf
cat /proc/sys/vm/swappiness