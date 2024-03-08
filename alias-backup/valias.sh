aliasFile=~/Development/bashfun/aliases/$1.sh

echo $aliasFile

touch $aliasFile
chmod +x $aliasFile
vim $aliasFile
