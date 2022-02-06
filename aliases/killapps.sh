while :
do
sleep 3
        pkill -f Slack
        pkill -f WhatsApp
	ps -ef | grep 'Telegram' | grep -v grep | awk '{print $2}' | xargs -r kill -9
        pkill -f Zoom
        pkill -f Skype
        pkill -f Viber
        pkill -f zoom
done
