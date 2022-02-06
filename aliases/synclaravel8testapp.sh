#!/bin/bash
cd /Users/tobiasanhalt/Development/laravel8testapp 
/Users/tobiasanhalt/Development/bashfun/aliases/rsyncsubfolders.sh /Users/tobiasanhalt/Development/laravel8testapp resources app routes public database tests
/opt/homebrew/bin/fswatch -o app resources routes public database tests | xargs -n1 -I{} /Users/tobiasanhalt/Development/bashfun/aliases/rsyncsubfolders.sh /Users/tobiasanhalt/Development/laravel8testapp resources app routes public database tests
