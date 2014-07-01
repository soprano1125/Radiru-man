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
OUT_FILE=$OUT_DIR/$FILENAME.m4a
FILE_OWNER=`$COMMON_PATH/getParam common owner`

mkdir -p $OUT_DIR $TEMP_PATH $PROG_PATH/log/
$PROG_PATH/radiru_radiru_download.sh $channel $time $area $TEMP_PATH/$FILENAME.m4a
if [ $? -ne 0 ]; then
	exit 1;
fi

sudo mv $TEMP_PATH/$FILENAME.m4a $OUT_FILE
sudo chown -R $FILE_OWNER $OUT_DIR

exit 0

