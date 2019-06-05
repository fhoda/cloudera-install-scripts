#!/bin/bash


### Enable SELinux (enable after Cloudera install) ###
if [ $(getenforce) == "Permissive" ] || [ $(getenforce) == "Disabled" ]
then
  sed -i -e 's/SELINUX=permissive/SELINUX=enforcing/g' /etc/selinux/config
  setenforce 1
else
  echo "SELinux already set to $(getenforce)"
fi

getenforce

