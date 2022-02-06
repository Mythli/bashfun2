screen -dmSL wsbackend ssh -nNT -R 8080:segelschule-pieper.debug:80 root@mythli.net
screen -dmSL wsfrontend ssh -nNT -R 30300:localhost:20015 tobias@136.243.51.161

