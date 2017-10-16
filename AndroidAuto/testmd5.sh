#!/bin/bash

#parameter FileName OutputFileName
function getMD5(){
	md5num=`md5sum $1`
	echo $md5num>>$2
}

CHANNEL_PATH=../Ext
COMMON_RESOURCE_PATH=CommonResource/bin

#move .jar and .aar to Android/bin/ 
# for channel in $CHANNEL_PATH/*
# do
# 	if [ -d $channel ];then
# 		if [ -d $channel/Android ];then
# 			if [ ! -d $channel/Android/bin ];then
# 				mkdir $channel/Android/bin
# 			fi

# 			mv $channel/Android/*.jar $channel/Android/bin
# 			mv $channel/Android/libs/*.jar $channel/Android/bin
# 			mv $channel/Android/*.aar $channel/Android/bin
# 			mv $channel/Android/libs/*.aar $channel/Android/bin
# 		fi
# 	fi
# done

#get md5 of .jar files
if [ ! -e $COMMON_RESOURCE_PATH/jarMd5.txt ];then
	touch $COMMON_RESOURCE_PATH/jarMd5.txt
fi

for channel in $CHANNEL_PATH/*
do
	if [ ! -d $channel ];then
		continue
	fi
	echo "[$channel]"
	if [ -d $channel/Android ];then
		for file in $channel/Android/bin/*
		do
			echo ${file##*.}
		done
	fi
done

read a