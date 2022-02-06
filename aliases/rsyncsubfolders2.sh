#!/bin/bash
set -o xtrace
cd $1

for i in "${@:3}"
do 
  rsync -avz --exclude storage --delete $i/ tobias@tobias.butlerapp2.de:$2/$i/
done

