#!/bin/sh -xe

# project path
#PROJ_PATH=/Users/mihoyo/ng_hsod_android
PROJ_PATH=$1

# unity app path
UNITY_PATH=/Applications/Unity/Unity.app/Contents/MacOS/Unity

# dir path
#dir_path=/Volumes/MYHD/AutoBuild/apk618034
dir_path=$2

git_branch_name=$3
git_commit_hash=$4
stamp_name=$5
if [ ${stamp_name} = "none" ]
	then
	stamp_name=${git_branch_name}
else
	stamp_name=${git_branch_name}-${stamp_name}
fi

stamp_name=${stamp_name////-}
stamp_name=${stamp_name//\\/-}

channel_name=$6
# debug_mode=$7
# encryptor=true
# use_assetbundle=$8
# il2cpp=$9
# developmentBuild=${10}
# ios_hook=false
# version=${11}
# bundle_version_code=${12}
# rebuild_asb=${13}

echo "=====================================git_branch_name: ${git_branch_name}"
echo "=====================================git_commit_hash: ${git_commit_hash}"
echo "=====================================stamp_name: ${stamp_name}"
echo "=====================================channel_name: ${channel_name}"
# echo "=====================================debug_mode: ${debug_mode}"
# echo "=====================================use_assetbundle: ${use_assetbundle}"
# echo "=====================================il2cpp: ${il2cpp}"
# echo "=====================================developmentBuild: ${developmentBuild}"
# echo "=====================================rebuild_asb: ${rebuild_asb}"

# Source external functions
source ./Utilities.sh

output_path=$PROJ_PATH/AutoBuild

cd $PROJ_PATH

# rotate autobuild save last apk
old_apk_path=../android_autobuild
if [ ! -d ${old_apk_path} ]; then
	mkdir ${old_apk_path}
fi

if [ -e $output_path ]; then
	cp -rf ${output_path} ${old_apk_path}/AutoBuild_pre.apk
fi

commit_now=`git log -1 --pretty=format:"%h"`

echo ${commit_now} > $PROJ_PATH/Assets/StreamingAssets/build_info.txt
stamp_name=${stamp_name}-${commit_now}

# Pre-process before build
if [ ${channel_name} != "none" ]; then
echo "================= Preprocess =================="
	preprocess_by_channel ${channel_name} ${PROJ_PATH}
	if [ ! $? -eq 0 ]; then
    	echo "[ERROR] Fail at preprocess!"
    	exit 1 
	fi
fi

# TODO:
# if [ ${use_assetbundle} = true ]; then
	# rewrite ChannelConfig.json
	# rm data, lua	
# fi

# delete old project
if [ -d $output_path ]; then
	rm -rf $output_path
elif [ -f $output_path ]; then
	rm -f $output_path
fi

# TODO:change ios 5.3.4 to 5.3.6
# TODO:change version and bundle_version_code (in GlobalVars.cs)

echo "============== Unity Build =============="
# build for Apk
$UNITY_PATH -projectPath $PROJ_PATH -executeMethod CommandLineBuilder.BuildAndroidPackage -mihoyo-${channel_name} -logFile $PROJ_PATH/AndroidBuild_${channel_name}.log -batchMode -quit

echo "============== Unity Build APK Finish =============="

source ${PROJ_PATH}/AndroidAutoBuild/encryptAndResign.sh ${PROJ_PATH} ${dir_path} ${output_path} 



