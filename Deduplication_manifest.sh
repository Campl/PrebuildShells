#!/bin/bash
# 请将该文件放在AndroidAutoBuild
# 统计各渠道manifest文件共有的uses-permission输出到normal文件夹中

# parameter  contentFormat inputFileName outputFileName
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
					echo -ne "\t$line">>"$3"
				else
					echo -e "\t$line">>"$3"
				fi
			fi
		fi
	done < "$2"
}


# 到ext目录下，遍历文件夹，输出渠道名
# if 有android文件夹
# then
# 	对manifest处理，只输出不重复的权限
# else
# 	输出None

# 渠道列表目录
CHANNEL_PATH=../Ext/

CONDITION="<uses-permission.*/>"
LIST_MANIFEST=normal/list_manifest.xml
ANDROID_MANIFEST=AndroidManifest.xml
NORMAL_MANIFEST=normal/manifest.xml

android_dir_num=0
temp="temp.xml"

cd $CHANNEL_PATH
if [ ! $? -eq 0 ];then
	echo "[ERROR] Error at CHANNEL_PATH"
	read a
	exit 1
fi
if [ ! -d normal ];then
	mkdir normal
fi

echo "---start listing info of manifest to list_manifest.xml---"
echo -n "">$LIST_MANIFEST
find . -type d -maxdepth 1 | while read channel_name
do
	channel_name=`echo $channel_name | sed 's/.\///'`
	echo "[${channel_name}]:">>$LIST_MANIFEST
	if [ ! -d ${channel_name}/Android ];then
		echo -e "\tNone">>$LIST_MANIFEST
	else
		deduplication "$CONDITION" "${channel_name}/Android/${ANDROID_MANIFEST}" "${LIST_MANIFEST}"
		android_dir_num=$[$android_dir_num+1]
		echo -n $android_dir_num>$temp
	fi
	echo "$channel_name done"
done
android_dir_num=$(cat $temp)
rm -f $temp
echo "---done---"

# 统计有多少个android文件夹
# 使用桶排序的思想统计每种权限出现次数，等于上述个数的即为公共权限
echo "---start listing common content to $NORMAL_MANIFEST---"

# init输出文件uses-permission部分
if [ -e %NORMAL_MANIFEST ];then
	sed -i '/^<!-- uses-permission  start -->$/,/^<!-- uses-permission  end -->$/{//!d}' $NORMAL_MANIFEST
else
	echo "<!-- uses-permission  start -->">>$NORMAL_MANIFEST
	echo -n "<!-- uses-permission  end -->">>$NORMAL_MANIFEST
fi

contentNum=()
DONE="false"
until [ "$DONE" = "true" ]
do read line || DONE="true"
	if [[ $line =~ $CONDITION ]]
	then
		lineNoSpace=`echo "$line"|sed 's/ //g'`
		if [[ ${contentArray[@]} =~ $lineNoSpace ]]
		then
			for i in `seq 0 $[${#contentArray[@]}-1]`
			do
				if [ $lineNoSpace = ${contentArray[$i]} ];then
					contentNum[$i]=$[${contentNum[$i]}+1]
					if [[ ${contentNum[$i]} -eq $android_dir_num ]]; then
						sed -i '/^<!-- uses-permission  end -->$/i\'"\t$line" $NORMAL_MANIFEST
					fi
				fi
			done
		else
			contentArray=(${contentArray[@]} $lineNoSpace)
			contentNum[$[${#contentArray[@]}-1]]=1
		fi
	fi
done < $LIST_MANIFEST
echo "---done---"
