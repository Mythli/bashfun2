#!/bin/bash
cd /Users/tobiasanhalt/Development/dcc-handler
/Users/tobiasanhalt/Development/bashfun/aliases/rsyncsubfolders.sh /Users/tobiasanhalt/Development/dcc-handler /var/www/dcc-handler app public config database routes
/opt/homebrew/bin/fswatch -o app resources routes public database tests | xargs -n1 -I{} /Users/tobiasanhalt/Development/bashfun/aliases/rsyncsubfolders.sh /Users/tobiasanhalt/Development/dcc-handler /var/www/dcc-handler app public config database routes
