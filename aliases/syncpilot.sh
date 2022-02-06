#!/bin/bash
cd /Users/tobiasanhalt/Development/websail.pilot
/Users/tobiasanhalt/Development/bashfun/aliases/rsyncsubfolders.sh /Users/tobiasanhalt/Development/websail.pilot /var/www/websail/tobias2 app public
/opt/homebrew/bin/fswatch -o app resources routes public database tests | xargs -n1 -I{} /Users/tobiasanhalt/Development/bashfun/aliases/rsyncsubfolders.sh /Users/tobiasanhalt/Development/websail.piloti /var/www/websail/tobias2 app public
