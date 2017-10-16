#！/bin/bash

#parameter  <string>matchName
function merge(){
	if [ ! -d ${TARGET_PATH} ];then
		echo "/Android directory not exist."
		return 1
	fi
	if [ ! -e ${TARGET_PATH}/${ANDROID_MANIFEST} ];then
		echo "$ANDROID_MANIFEST not exist."
		return 1
	fi

	echo -n "">temp.xml
	sed -n '/<!--'"$1"'Begin-->/,/<!--'"$1"'End-->/{//!p}' $NORMAL_MANIFEST>>temp.xml
	#原本注释之间内容删除
	sed -i '/<!--'"$1"'Begin-->/,/<!--'"$1"'End-->/{//!d}' $TARGET_PATH/$ANDROID_MANIFEST

	while read line
	do
		sed -i '/<!--'"$1"'End-->/i\'"\t$line" $TARGET_PATH/$ANDROID_MANIFEST
	done<temp.xml
	rm -f temp.xml
}

IFS=$'\n'
TARGET_PATH=../Assets/Plugins/Android
NORMAL_MANIFEST=CommonResource/CommonManifest.xml
ANDROID_MANIFEST=AndroidManifest.xml
CONDITION_1="<!--Common_Compotents_Begin-->"
CONDITION_2="<!--Common_Permissions_Begin-->"

cur_dir=`dirname $0`
cd ${cur_dir}

# if [ ! -e $NORMAL_MANIFEST ];then
# 	echo "CommonManifest.xml not exists."
# 	return 1
# fi
while read line
do
	if [[ $line =~ $CONDITION_1 ]] || [[ $line =~ $CONDITION_2 ]];then
		matchName=`echo $line | sed -e 's/<!--//' -e 's/Begin-->//'`
		merge ${matchName}
	fi
done < $NORMAL_MANIFEST