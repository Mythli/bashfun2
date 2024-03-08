while :
do
sleep 3
        pkill -f WhatsApp
	ps -ef | grep 'Telegram' | grep -v grep | awk '{print $2}' | xargs -r kill -8
        pkill -f Skype
        pkill -f Viber
done
