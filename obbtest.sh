echo "============== Copy File =============="
output_path=./output

file_name=$(date +%Y%m%d-%H%M%S)-android-stamp_name
echo $file_name
# if [ ${debug_mode} = true ]; then
# 	file_name=${file_name}-GM
# fi
# if [ ${use_assetbundle} = true ]; then
# 	file_name=${file_name}-ASB
# fi
# if [ ${il2cpp} = true ]; then
# 	file_name=${file_name}-il2cpp
# else
# 	file_name=${file_name}-mono
# fi
# if [ ${developmentBuild} = true ]; then
# 	file_name=${file_name}-DEV
# fi
obb_file=main.obb
if [ -f ${obb_file} ];then	
	echo enterif
	if [ ! -d ${output_path}/${file_name} ];then
		echo notexist
		mkdir ${output_path}/${file_name}
	fi
	# file_name=${file_name}.apk
	# if [ ${il2cpp} = true ]; then
	# 	python ${antidumper_path}/checksum.py ${zipalignApkPath} 
	# fi

	cp test.txt ${output_path}/${file_name}/${file_name}.apk

	#save build log to apkLog
	# cp -rf $PROJ_PATH/AndroidBuild.log ${output_path}Log/${file_name}.log
	# cd ..
	# rm -rf ${resign_path}
	bundlename=`grep 'BUNDLE_IDENTIFIER' GlobalVars.cs | awk '{split($0,array,"\"");print array[2]}'`
	echo $bundlename
	visioncode=`grep 'BUNDLE_VERSION_CODE' GlobalVars.cs | awk '{split($0,array,"[=/]");print array[2]}' | awk '{gsub(/[; ]/,"");print}'`
	echo $visioncode

	
	cp -f ${obb_file} "${output_path}/${file_name}/main.${visioncode}.${bundlename}.obb"
	# echo "cp -f ${obb_file} main.${visioncode}.${bundlename}.obb"
	echo "apk Build End." 
# else
# 	file_name=${file_name}.apk
# 	if [ ${il2cpp} = true ]; then
# 		python ${antidumper_path}/checksum.py ${zipalignApkPath} 
# 	fi
# 	cp ${zipalignApkPath} ${output_path}/${file_name}
# 	#save build log to apkLog
# 	cp -rf $PROJ_PATH/AndroidBuild.log ${output_path}Log/${file_name}.log
# 	cd ..
# 	rm -rf ${resign_path}

# 	echo "apk Build End." 
fi
read a