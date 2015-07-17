#!/bin/bash

if [ -z "$1" ]; then
    echo "usage: startdiamond.sh ipaddress"
    exit
else
    IPADDR=$1
fi

BINPATH="/usr/local/bin"
COOKIE="$HOME/autosegment-cookie"
LISTEN_IP=$IPADDR

"$BINPATH/cookiecutter" -v -b "http://127.0.0.1:8080" -s $1 -e 300000 -u "127.0.0.1" > $COOKIE

echo "baseurl = 'http://127.0.0.1:8080/'" > "$HOME/.diamond/blaster_config"
#sudo systemctl start redis.service
redis-server &

# start diamond server
"$BINPATH/diamondd" &


# run scope server
python ./dermshare/simplescope/simplescope.py &

python ./dermshare/app/dermshare.py -d -s 127.0.0.1:5001 -i $COOKIE &

# run the data retriever
python ./dermshare/dataretriever/dermshare_dataretriever.py &


# start JSON Blaster
"$BINPATH/blaster" --listen=127.0.0.1:8080 --config="$HOME/.diamond/blaster_config" --logging=debug --log_file_prefix="$HOME/.diamond/log/blaster.log" &
