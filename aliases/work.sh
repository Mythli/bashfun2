pkill -f killapps
cp ~/Development/bashfun/aliases/workhosts /etc/hosts
screen -S killapps -dm bash ~/Development/bashfun/aliases/killappsnonwork.sh
