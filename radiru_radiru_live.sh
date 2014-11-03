#/bin/sh


if [ $# -eq 1 ]; then
	channel=$1
	area="tokyo"

elif [ $# -eq 2 ]; then
	channel=$1
	area=$2

else
	echo "usage : $0 channel_name<fm, r1, r2> [area]"
	exit 1

fi

area=`echo $area | tr '[a-z]' '[A-Z]'`
channel=`echo $channel | tr '[a-z]' '[A-Z]'`

HOME_PATH=/home/ubuntu/radiru-man
PROG_PATH=$HOME_PATH
COMMON_PATH=$PROG_PATH/common

. $COMMON_PATH/base.sh
cd $PROG_PATH

AUTHOR="NHK"
STATION_NAME="NHK-$channel($area)"

#
# rtmpdump
#
$PROG_PATH/radiru_radiru_download.sh $channel live $area live-$REC_DATE | vlc --meta-title " " --meta-author $AUTHOR --meta-artist "$STATION_NAME" --meta-date $REC_DATE --play-and-exit --no-one-instance --no-sout-display-video - 2> /dev/null 
exit 0

