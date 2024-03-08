#!/bin/bash
cd /Users/tobiasanhalt/Development/websailsetup2
/Users/tobiasanhalt/Development/bashfun/aliases/rsyncsubfolders.sh /Users/tobiasanhalt/Development/websailsetup2 /home/tobias/Development/wsconsole src setups ui
/opt/homebrew/bin/fswatch -o src setups ui | xargs -n1 -I{} /Users/tobiasanhalt/Development/bashfun/aliases/rsyncsubfolders.sh /Users/tobiasanhalt/Development/websailsetup2 /home/tobias/Development/wsconsole src setups ui
