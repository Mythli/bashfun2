#!/bin/bash
cd /Users/tobiasanhalt/Development/websailsetup2
/Users/tobiasanhalt/Development/bashfun/aliases/rsyncsubfolders.sh /Users/tobiasanhalt/Development/websailsetup2 /home/tobias/Development/wsconsole src setups ui bin
/opt/homebrew/bin/fswatch -o src setups ui bin | xargs -n1 -I{} /Users/tobiasanhalt/Development/bashfun/aliases/rsyncsubfolders.sh /Users/tobiasanhalt/Development/websailsetup2 /home/tobias/Development/wsconsole src setups ui bin