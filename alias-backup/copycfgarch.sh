rm -rf /Users/tobiasanhalt/Development/websail-hoster/playground/devbox
scp -r -P 12022 tobias@mythli.net:/etc/cfgarch /Users/tobiasanhalt/Development/websail-hoster/playground/devbox

rm -rf /Users/tobiasanhalt/Development/websail-hoster/playground/websail
scp -r -P 15022 tobias@mythli.net:/etc/cfgarch /Users/tobiasanhalt/Development/websail-hoster/playground/websail

rm -rf /Users/tobiasanhalt/Development/websail-hoster/playground/mythli
scp -r root@mythli.net:/etc/cfgarch /Users/tobiasanhalt/Development/websail-hoster/playground/mythli


