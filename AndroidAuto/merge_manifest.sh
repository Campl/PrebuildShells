#！/bin/bash

#parameter  <string>matchName
function merge(){
	echo -n "">temp.xml
	sed -n '/<!--'"$1"'Begin-->/,/<!--'"$1"'End-->/{//!p}' $NORMAL_MANIFEST>>temp.xml
	find . -type d -maxdepth 1 | while read channel_name
	do
		echo $channel_name
		if [ ! -d ${channel_name}/Android ];then
			continue
		fi
		sed -i '/<!--'"$1"'Begin-->/,/<!--'"$1"'End-->/{//!d}' $channel_name/Android/$ANDROID_MANIFEST
		while read line
		do
	 		sed -i '/<!--'"$1"'End-->/i\'"\t$line" $channel_name/Android/$ANDROID_MANIFEST
		done<temp.xml
	done
	rm -f temp.xml
}

IFS=$'\n'
CHANNEL_PATH=../Ext/
NORMAL_MANIFEST=normal/manifest.xml
ANDROID_MANIFEST=AndroidManifest.xml
CONDITION_1="<!--Common_Compotents_Begin-->"
CONDITION_2="<!--Common_Permissions_Begin-->"

cd $CHANNEL_PATH
while read line
do
	if [[ $line =~ $CONDITION_1 ]] || [[ $line =~ $CONDITION_2 ]];then
		matchName=`echo $line | sed -e 's/<!--//' -e 's/Begin-->//'`
		echo $matchName
		merge ${matchName}
	fi
done < $NORMAL_MANIFEST
read a