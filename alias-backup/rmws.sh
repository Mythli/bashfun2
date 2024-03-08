#!/usr/bin/env bash

read -r -p "Are you sure to delete $1? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
   rm "/etc/cfgarch/websail-hosts/$1.js"
   rm -r "/var/www/$1"
   echo "DROP DATABASE $1;" | mysql
fi
