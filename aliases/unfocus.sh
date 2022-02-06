a=$(jot -r 1 100 9999)
b=$(jot -r 1  100 9999)
correctresult=$((a+b))

echo "If you really dont want to focus, tell me what is $a+$b?"

read result

if [ "$result" != "$correctresult" ]; then
  echo "Incorrect solution, try 2/3"
  read result
fi

if [ "$result" != "$correctresult" ]; then
	echo "Incorrect solution, try 3/3"
        read result
fi

if [ "$result" != "$correctresult" ]; then
        echo "Incorrect solution, should be $correctresult"
        exit 1
fi

echo "Correct!"

pkill -f killapps
open -a Skype
open -a Slack
open -a WhatsApp
open -a Telegram
open -a Viber
open -a Zoom.us
cp ~/Development/bashfun/aliases/unfocushosts /etc/hosts
