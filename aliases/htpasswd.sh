perl -le 'print $ARGV[0]' -- "$1"
perl -le 'print crypt($ARGV[0], "salt-hash")' -- "$1"
