pkill -f killapps
cp ~/Development/bashfun/aliases/focushosts /etc/hosts
screen -S killapps -dm bash ~/Development/bashfun/aliases/killapps.sh
