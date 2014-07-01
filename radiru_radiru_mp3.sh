#/bin/sh


if [ $# -eq 2 ]; then
	channel=$1
	time=$2
	area="tokyo"
	output="$channel-tokyo"

elif [ $# -eq 3 ]; then
	channel=$1
	time=$2
	area=$3
	output="$channel-$area"

elif [ $# -eq 4 ]; then
	channel=$1
	time=$2
	area=$3
	output=$4

else
	echo "usage : $0 channel_name{ FM, R1, R2 | NHKFM, NHKR1, NHKR2 | NHK-FM, NHK-R1, NHK-R2 } time [area] [outputfile]"
	exit 1

fi

area=`echo $area | tr '[a-z]' '[A-Z]'`
channel=`echo $channel | tr '[a-z]' '[A-Z]'`

HOME_PATH=/home/ubuntu/Radiru-man
PROG_PATH=$HOME_PATH
TEMP_PATH=$HOME_PATH/share/temp
COMMON_PATH=$PROG_PATH/common

. $COMMON_PATH/base.sh
cd $PROG_PATH

OUT_DIR=$HOME_PATH/share/NHK-$channel-$area
OUT_FILE=$OUT_DIR/$FILENAME.mp3
FILE_OWNER=`$COMMON_PATH/getParam common owner`

mkdir -p $OUT_DIR $TEMP_PATH $PROG_PATH/log/
$PROG_PATH/radiru_radiru_download.sh $channel $time $area $TEMP_PATH/$FILENAME.m4a
if [ $? -ne 0 ]; then
	exit 1;
fi

#
# ffmpeg 
# 
FFMPEG_LOG="$PROG_PATH/log/$channel_$FILENAME.log"
echo $OUT_FILE >> $FFMPEG_LOG
sudo ffmpeg -y -i $TEMP_PATH/$FILENAME.m4a -ab 128k -ar 44100 -ac 2 $OUT_FILE 2>> $FFMPEG_LOG
FFMPEG_STATUS=$?

#
# remove
#
if [ $FFMPEG_STATUS -ne 0 ]
then
	# エンコードミスした時の保険
	MESSAGE="$FILENAME.mp3:NHK-$channel($area) convert miss"
else
	sudo chown -R $FILE_OWNER $OUT_DIR
	rm -rf $TEMP_PATH/$FILENAME.m4a
	MESSAGE="$FILENAME.mp3:NHK-$channel($area) convert done"
fi

#$HOME_PATH/twitter/post.sh "$MESSAGE" > /dev/null
echo "$MESSAGE" 1>&2
exit $FFMPEG_STATUS

