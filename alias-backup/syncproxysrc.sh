#!/bin/bash
/opt/homebrew/bin/fswatch -o /Users/tobiasanhalt/Development/WebsailProxy/src | xargs -n1 -I{} rsync -avz --delete ~/Development/WebsailProxy/src tobias@tobias.veranstaltungsbutler.de:/home/tobias/Development/WebsailProxyDev
