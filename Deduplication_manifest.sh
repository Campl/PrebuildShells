#!/bin/bash

#parameter  contentFormat inputFileName outputFileName
function deduplication()
{
	contentArray=()

	if [ $# -ne 3 ]
	then
		echo "[ERROR] Parameter num error in deduplication"
		exit 1
	fi
	
	if [ "$2" = "$3" ]
	then 
		echo "[ERROR] Same input and output filename in deduplication"
		exit 1
	fi

	DONE="false"
	until [ "$DONE" = "true" ]
	do read line || DONE="true"
		if [[ $line =~ $1 ]]
		then
			lineNoSpace=`echo "$line"|sed 's/ //g'`
			if [[ ${contentArray[@]} =~ $lineNoSpace ]]
			then
				continue
			else
				contentArray=(${contentArray[@]} $lineNoSpace)
				if [ "$DONE" = "true" ]
				then
					echo -n "$line">>"$3"
				else
					echo "$line">>"$3"
				fi
			fi
		fi
	done < "$2"
}


#到ext目录下，遍历文件夹，输出渠道名
#if 有android文件夹
#then
#	对manifest处理，只输出不重复的权限
#else
#	输出None

# 渠道列表目录
CHANNEL_PATH=Ext/

CONDITION="<uses-permission.*/>"
OUTPUT_FILE=list_manifest.xml
INPUT_FILE=AndroidManifest.xml

cd $CHANNEL_PATH
if [ ! $? -eq 0 ];then
	echo "[ERROR] Error at CHANNEL_PATH"
	read a
	exit 1
fi

echo -n "">$OUTPUT_FILE
find . -type d -maxdepth 1 | while read channel_name
do
	channel_name=`echo $channel_name | sed 's/.\///'`
	echo "[${channel_name}]:">>$OUTPUT_FILE
	if [ ! -d ${channel_name}/Android ];then
		echo -e "\tNone">>$OUTPUT_FILE
	else
		deduplication "$CONDITION" "${channel_name}/Android/${INPUT_FILE}" "${OUTPUT_FILE}"
	fi
done


# 统计渠道个数
# 统计输出为none的个数
# 二者之差为有多少个android文件夹
# 使用桶排序的思想统计每种权限出现次数，等于上述个数的即为公共权限




read a