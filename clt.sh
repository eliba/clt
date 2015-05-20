#!/bin/bash

function usage {
	cat << EOF
USAGE:
"id":	get current track
"dj":	get current dj
"y":	search last shown track on youtube

EOF
}

function gettrack {
	TRACK=$(curl -s http://www.clubtime.fm/tracklist | grep -A1 '<div style="width:345px;float:left; margin-top:11px; overflow:hidden">' | tail -1 | sed -e 's/^.*">\([^<>]*\).*$/\1/g')
	echo $TRACK
}

function getdeejay {
	DJ="$(curl -s http://www.clubtime.fm/showplan | grep -A1 '<div id="onAir" style="width:420px;overflow:hidden;">' | tail -1)"
	if [ $(echo $DJ | grep -c Playlist) -eq 1 ] ; then
		DJ=$(echo $DJ | sed -e 's/^.*">\([^<]*\).*$/\1/g')
	else
		DJ=$(echo $DJ | sed -e 's/^.*FF0">\([^<]*\).*">\([^<]*\).*$/\1 \2/')
	fi
	echo $DJ
}

function searchyt {
	if [ "x$TRACK" = "x" ]; then
		echo "no track shown so far, searching for current track:"
		gettrack
	fi
	QUERY=$(echo $TRACK | sed -e 's/\ /+/g')
	firefox -new-tab "https://www.youtube.com/results?search_query=$QUERY"
}

cvlc -v http://listen.clubtime.fm > /dev/null &

while true ; do
	read command
	case $command in
		id ) gettrack ;;
		dj ) getdeejay ;;
		y ) searchyt ;;
		* ) usage ;;
	esac
done
