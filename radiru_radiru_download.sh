#!/bin/bash

if [ $# -eq 4 ]; then
	channel=$1
	time=$2
	area=$3
	DUMP_FILE=$4

else
	echo "usage : $0 channel_name time area outputfile"
	exit 1
fi

HOME_PATH=/home/ubuntu/radiru-man
PROG_PATH=$HOME_PATH/
COMMON_PATH=$HOME_PATH/common
TEMP_PATH=$HOME_PATH/share/temp

. $COMMON_PATH/base.sh

FILE_NAME=`echo $DUMP_FILE | sed -e "s|$TEMP_PATH\/||g"`

isLive=`echo FILE_NAME | perl -ne 'print $1 if(/^(\w+)-(\d+)/i)'`
if [ "$time" = "live" ]; then
	time_param=""
	isLive="live"
	DUMP_FILE="-"
	DISP_MODE="/dev/null"
else
	time_param="-B $time"
	isLive="rec"
fi

MESSAGE=`$COMMON_PATH/getStreamParam $area $channel`
if [ $? -ne 0 ]; then
	MESSAGE="$FILE_NAME:NHK-$channel($area) $MESSAGE"
	echo $MESSAGE 1>&2
	exit 1
fi
IFS=','
STREAM_PARAM=$MESSAGE
set -- $STREAM_PARAM
SERVER=$1
APPLICATION=$2
PLAYPATH=$3

#
# wait second
#
STREAM_WAIT=`$COMMON_PATH/getParam common rtmp_wait`
LAST_EXECUTE=`$COMMON_PATH/getParam common last_execute`
if [ -f $LAST_EXECUTE ];
then
	last_run=`cat $LAST_EXECUTE`
else
	last_run=`date "+%s"`
fi
now_date=`date "+%s"`
STREAM_WAIT=$((STREAM_WAIT - (now_date - last_run)))
if [ $STREAM_WAIT -le 0 ]; then
	STREAM_WAIT=0
fi

#
# rtmpdump
#
MESSAGE="$FILE_NAME:NHK-$channel($area) $isLive wait -> $STREAM_WAIT[s]"
echo $MESSAGE 1>&2
sleep $STREAM_WAIT;
MESSAGE="$FILE_NAME:NHK-$channel($area) $isLive do"
echo $MESSAGE 1>&2
#$HOME_PATH/twitter/post.sh "$MESSAGE" > /dev/null
rtmpdump -v -r "$SERVER" --playpath "$PLAYPATH" --app "$APPLICATION" -W http://www3.nhk.or.jp/netradio/files/swf/rtmpe.swf $time_param --timeout 30 --live --flv $DUMP_FILE 2> $DISP_MODE
RTMPDUMP_STATUS=$?

echo `date "+%s"` > $LAST_EXECUTE

if [ "$isLive" = "live" ]; then
	RTMPDUMP_STATUS=$((RTMPDUMP_STATUS - 1))
fi

if [ $RTMPDUMP_STATUS -ne 0 ]; then
	MESSAGE="$FILE_NAME:NHK-$channel($area) $isLive miss"
else
	MESSAGE="$FILE_NAME:NHK-$channel($area) $isLive done"
fi

#$HOME_PATH/twitter/post.sh "$MESSAGE" > /dev/null
echo $MESSAGE 1>&2
exit $RTMPDUMP_STATUS

