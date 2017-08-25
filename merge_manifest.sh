#！/bin/bash

#parameter  <string>matchName
function merge(){
	echo -n "">temp.xml
	sed -n '/^<!-- '"$1"'  start -->$/,/^<!-- '"$1"'  end -->$/{//!p}' $NORMAL_MANIFEST>>temp.xml
	find . -type d -maxdepth 1 | while read channel_name
	do
		echo $channel_name
		if [ ! -d ${channel_name}/Android ];then
			continue
		fi
		while read line
		do
	 		sed -i '/<!-- '"$1"'  end -->/i\'"\t$line" $channel_name/Android/$ANDROID_MANIFEST
		done<temp.xml
		rm -f temp.xml
		echo "$channel_name merge $1 done"
	done
}

CHANNEL_PATH=Ext/
NORMAL_MANIFEST=normal/manifest.xml
ANDROID_MANIFEST=AndroidManifest.xml

cd $CHANNEL_PATH
merge "TiebaShare"
read a 