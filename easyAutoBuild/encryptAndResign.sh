#!/bin/sh -xe

# project path
#PROJ_PATH=/Users/mihoyo/ng_hsod_android
PROJ_PATH=$1

# dir path
#output_path=/Volumes/MYHD/AutoBuild/apk618034
output_path=$2

#origin_apk_path=$PROJ_PATH/UWA_Builds/Android/ng_hsod_android.apk
origin_apk_path=$3

resign_path=$PROJ_PATH/Resign
#origin_apk_path=$PROJ_PATH/AutoBuild
unsigned_apk=$resign_path/AutoBuildUnsigned.apk
resigned_apk=$resign_path/AutoBuildResigned.apk
il2cpp_arm_development=$PROJ_PATH/Miscs/android/il2cpp_arm_development
il2cpp_x86_development=$PROJ_PATH/Miscs/android/il2cpp_x86_development
mono_arm_development=$PROJ_PATH/Miscs/android/mono_arm_development
mono_x86_development=$PROJ_PATH/Miscs/android/mono_x86_development
il2cpp_arm_release=$PROJ_PATH/Miscs/android/il2cpp_arm_release
il2cpp_x86_release=$PROJ_PATH/Miscs/android/il2cpp_x86_release
mono_arm_release=$PROJ_PATH/Miscs/android/mono_arm_release
mono_x86_release=$PROJ_PATH/Miscs/android/mono_x86_release
shader_py_path=$PROJ_PATH/Miscs/android/shader.py
signapk_path=$PROJ_PATH/Miscs/android/signapk.jar
certificate_path=$PROJ_PATH/Miscs/android/nghsod.cert.x509.pem
private_key_path=$PROJ_PATH/Miscs/android/nghsod.pk8
obfuscator_path=$PROJ_PATH/Miscs/obfuscator
antidumper_path=$PROJ_PATH/AndroidAutoBuild
debug_mode=$4

il2cpp=$5

use_obfuscator=$6

use_assetbundle=$7

developmentBuild=$8

if [ ! -d ${resign_path} ]; then
	mkdir ${resign_path}
fi

cd $resign_path

#delete all old apk in project
rm -rf ./*.apk

echo "============== Copy APK =============="

cp -rf ${origin_apk_path} ${unsigned_apk}

echo "============== Process APK =============="

assets0Num=`unzip -v ${unsigned_apk} | grep assets/bin/Data/sharedassets0.assets | wc -l`
echo "assets0Num="${assets0Num}

if [ ${assets0Num} = 2 ]; then
	source $PROJ_PATH/Miscs/android/PreProcess.sh $PROJ_PATH
elif [ ${assets0Num} = 3 ]; then
	source $PROJ_PATH/Miscs/android/_onlyForAssetSplit3/PreProcess.sh $PROJ_PATH
fi

temp_path=assets/bin/Data/Managed
#replace obfuscator CSharp dll
if [ ${use_obfuscator} = true ] && [ -d $obfuscator_path ]; then
	mkdir -p ${temp_path}
	cp -rf ${obfuscator_path}/*.dll ${temp_path}
	zip -ur ${unsigned_apk} ${temp_path}/*
	rm -rf ${temp_path}
fi

# AntiDumper
if [ ${il2cpp} = true ]; then
	temp_path=AntiDumperPath
	unzip  ${unsigned_apk} -d ${temp_path} > /dev/null
	python ${antidumper_path}/AntiDumper.py ${temp_path}
	cd ${temp_path}
	zip -ur ${unsigned_apk} *
	cd ${resign_path}
	rm -rf ${temp_path}
fi

temp_path=lib
temp_arm_path=${temp_path}/armeabi-v7a
temp_x86_path=${temp_path}/x86
mkdir -p ${temp_arm_path}
mkdir -p ${temp_x86_path}
# replace lib
if [ ${il2cpp} = true ]; then
	if [ ${developmentBuild} = true ]; then
		cp -rf ${il2cpp_arm_development}/libunity.so ${temp_arm_path}/libunity.so
		cp -rf ${il2cpp_arm_development}/libulua.so ${temp_arm_path}/libulua.so
		cp -rf ${il2cpp_x86_development}/libunity.so ${temp_x86_path}/libunity.so
		cp -rf ${il2cpp_x86_development}/libulua.so ${temp_x86_path}/libulua.so
	else
		cp -rf ${il2cpp_arm_release}/libunity.so ${temp_arm_path}/libunity.so
		cp -rf ${il2cpp_arm_release}/libulua.so ${temp_arm_path}/libulua.so
		cp -rf ${il2cpp_x86_release}/libunity.so ${temp_x86_path}/libunity.so
		cp -rf ${il2cpp_x86_release}/libulua.so ${temp_x86_path}/libulua.so
	fi
else
	if [ ${developmentBuild} = true ]; then
		cp -rf ${mono_arm_development}/libunity.so ${temp_arm_path}/libunity.so
		cp -rf ${mono_arm_development}/libulua.so ${temp_arm_path}/libulua.so
		cp -rf ${mono_x86_development}/libunity.so ${temp_x86_path}/libunity.so
		cp -rf ${mono_x86_development}/libulua.so ${temp_x86_path}/libulua.so
	else
		cp -rf ${mono_arm_release}/libunity.so ${temp_arm_path}/libunity.so
		cp -rf ${mono_arm_release}/libulua.so ${temp_arm_path}/libulua.so
		cp -rf ${mono_x86_release}/libunity.so ${temp_x86_path}/libunity.so
		cp -rf ${mono_x86_release}/libulua.so ${temp_x86_path}/libulua.so
	fi
fi
zip -ur ${unsigned_apk} ${temp_path}/*
rm -rf ${temp_path}

# 360 copy
qihoo_unipath=${PROJ_PATH}/Assets/Plugins/Android/com
if [ -d ${qihoo_unipath} ]; then
	temp_path=com
	mkdir -p ${temp_path}
	cp -rf ${qihoo_unipath}/* ${temp_path}/
	zip -ur ${unsigned_apk} ${temp_path}/*
	rm -r ${temp_path}
fi

temp_asb_path=assets/Asb/android
temp_path=assets/bin/Data
temp_dll_path=${temp_path}/Managed

mkdir -p ${temp_path}
mkdir -p ${temp_dll_path}
mkdir -p ${temp_asb_path}

### ADHOC PROCESS OF item.unity3d, as it needs to be using STORE
unzip -q -o ${unsigned_apk} ${temp_asb_path}/item.unity3d -d .
python ${shader_py_path} ${temp_asb_path}/item.unity3d
cp -rf ${temp_asb_path}/item.unity3d.enc ${temp_asb_path}/item.unity3d
rm -rf ${temp_asb_path}/item.unity3d.enc

#	!!! MUST USE -0
zip -0 -u ${unsigned_apk} ${temp_asb_path}/item.unity3d

rm -rf ${temp_asb_path}
### END OF - ADHOC PROCESS of item.unity3d -

# encrypt shader

if [ ${assets0Num} = 2 ]; then
	echo "split = 2"
	unzip -q -o ${unsigned_apk} assets/bin/Data/sharedassets0.assets.split0 -d .
	python ${shader_py_path} ${temp_path}/sharedassets0.assets.split0
	cp -rf ${temp_path}/sharedassets0.assets.split0.enc ${temp_path}/sharedassets0.assets.split0
	rm -rf ${temp_path}/sharedassets0.assets.split0.enc

	unzip -q -o ${unsigned_apk} assets/bin/Data/sharedassets0.assets.split1 -d .
	python ${shader_py_path} ${temp_path}/sharedassets0.assets.split1
	cp -rf ${temp_path}/sharedassets0.assets.split1.enc ${temp_path}/sharedassets0.assets.split1
	rm -rf ${temp_path}/sharedassets0.assets.split1.enc
elif [ ${assets0Num} = 3 ]; then
	echo "split = 3"
	shader_by_path_split3=$PROJ_PATH/Miscs/android/_onlyForAssetSplit3/shader.py
	unzip -q -o ${unsigned_apk} assets/bin/Data/sharedassets0.assets.split0 -d .
	python ${shader_by_path_split3} ${temp_path}/sharedassets0.assets.split0
	cp -rf ${temp_path}/sharedassets0.assets.split0.enc ${temp_path}/sharedassets0.assets.split0
	rm -rf ${temp_path}/sharedassets0.assets.split0.enc

	unzip -q -o ${unsigned_apk} assets/bin/Data/sharedassets0.assets.split1 -d .
	python ${shader_by_path_split3} ${temp_path}/sharedassets0.assets.split1
	cp -rf ${temp_path}/sharedassets0.assets.split1.enc ${temp_path}/sharedassets0.assets.split1
	rm -rf ${temp_path}/sharedassets0.assets.split1.enc

	unzip -q -o ${unsigned_apk} assets/bin/Data/sharedassets0.assets.split2 -d .
	python ${shader_by_path_split3} ${temp_path}/sharedassets0.assets.split2
	cp -rf ${temp_path}/sharedassets0.assets.split2.enc ${temp_path}/sharedassets0.assets.split2
	rm -rf ${temp_path}/sharedassets0.assets.split2.enc
else
	unzip -q -o ${unsigned_apk} assets/bin/Data/sharedassets0.assets -d .
	python ${shader_py_path} ${temp_path}/sharedassets0.assets
	cp -rf ${temp_path}/sharedassets0.assets.enc ${temp_path}/sharedassets0.assets
	rm -rf ${temp_path}/sharedassets0.assets.enc
fi

if [ ${il2cpp} != true ]; then
	# encrypt dll
	unzip -q -o ${unsigned_apk} ${temp_dll_path}/Assembly-CSharp.dll -d .
	python ${shader_py_path} ${temp_dll_path}/Assembly-CSharp.dll
	cp -rf ${temp_dll_path}/Assembly-CSharp.dll.enc ${temp_dll_path}/Assembly-CSharp.dll
	rm -rf ${temp_dll_path}/Assembly-CSharp.dll.enc

	# encrypt dll
	unzip -q -o ${unsigned_apk} ${temp_dll_path}/Assembly-CSharp-firstpass.dll -d .
	python ${shader_py_path} ${temp_dll_path}/Assembly-CSharp-firstpass.dll
	cp -rf ${temp_dll_path}/Assembly-CSharp-firstpass.dll.enc ${temp_dll_path}/Assembly-CSharp-firstpass.dll
	rm -rf ${temp_dll_path}/Assembly-CSharp-firstpass.dll.enc

	# encrypt dll
	unzip -q -o ${unsigned_apk} ${temp_dll_path}/Assembly-UnityScript.dll -d .
	python ${shader_py_path} ${temp_dll_path}/Assembly-UnityScript.dll
	cp -rf ${temp_dll_path}/Assembly-UnityScript.dll.enc ${temp_dll_path}/Assembly-UnityScript.dll
	rm -rf ${temp_dll_path}/Assembly-UnityScript.dll.enc

	# encrypt dll
	unzip -q -o ${unsigned_apk} ${temp_dll_path}/NetCommand.dll -d .
	python ${shader_py_path} ${temp_dll_path}/NetCommand.dll
	cp -rf ${temp_dll_path}/NetCommand.dll.enc ${temp_dll_path}/NetCommand.dll
	rm -rf ${temp_dll_path}/NetCommand.dll.enc
fi
zip -ur ${unsigned_apk} ${temp_path}/*
rm -rf ${temp_path}

# delete META-INF
zip -d ${unsigned_apk} META-INF/*

# delete streaming asset bundle manifests
# !!! USE SINGLE QUOTE OR * WILL BE EXPANEDED
zip -d ${unsigned_apk} 'assets/Asb/android/*.manifest' > /dev/null
zip -d ${unsigned_apk} assets/Asb/android/AsbResVersion.csv

echo "============== Resign APK =============="

java -jar ${signapk_path} ${certificate_path} ${private_key_path} ${unsigned_apk} ${resigned_apk}

echo "============== ZipAlign APK =============="

cd $PROJ_PATH/Miscs/android

zipalignApkPath=${resign_path}/AutoBuildResignedZipalign.apk

./zipalign -v 4 ${resigned_apk} ${zipalignApkPath} > /dev/null

cd ${resign_path}


echo "============== Copy File =============="

file_name=$(date +%Y%m%d-%H%M%S)-${channel_name}-${stamp_name}
if [ ${debug_mode} = true ]; then
	file_name=${file_name}-GM
fi
if [ ${use_assetbundle} = true ]; then
	file_name=${file_name}-ASB
fi
if [ ${il2cpp} = true ]; then
	file_name=${file_name}-il2cpp
else
	file_name=${file_name}-mono
fi
if [ ${developmentBuild} = true ]; then
	file_name=${file_name}-DEV
fi
if [ ${il2cpp} = true ]; then
	python ${antidumper_path}/checksum.py ${zipalignApkPath} 
fi
	
obb_file=${origin_apk_path}.main.obb
if [ -f ${obb_file} ];then
	if [ ! -d ${output_path}/${file_name} ];then
		mkdir ${output_path}/${file_name}
	fi
	cp ${zipalignApkPath} ${output_path}/${file_name}/${file_name}.apk
	#save build log to apkLog
	cp -rf $PROJ_PATH/AndroidBuild.log ${output_path}Log/${file_name}.apk.log
	cd ..
	rm -rf ${resign_path}

	GlobalVars="${PROJ_PATH}/Assets/Standard Assets/Common/GlobalVars.cs"
	bundlename=`grep 'BUNDLE_IDENTIFIER' $GlobalVars | awk '{split($0,array,"\"");print array[2]}'`
	visioncode=`grep 'BUNDLE_VERSION_CODE' $GlobalVars | awk '{split($0,array,"[=/]");print array[2]}' | awk '{gsub(/[; ]/,"");print}'`

	cp -f ${obb_file} "${output_path}/${file_name}/main.$visioncode.$bundlename.obb"
else
	cp ${zipalignApkPath} ${output_path}/${file_name}.apk
	#save build log to apkLog
	cp -rf $PROJ_PATH/AndroidBuild.log ${output_path}Log/${file_name}.apk.log
	cd ..
	rm -rf ${resign_path}
fi	
echo "apk Build End." 



