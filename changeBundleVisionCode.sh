bundle_version_code=72
if [ -n "$bundle_version_code" ] && [ $bundle_version_code != "none" ]; then
	sed -i.bak "s/int BUNDLE_VERSION_CODE =/int BUNDLE_VERSION_CODE = ${bundle_version_code};\/\//" "GlobalVars.cs"
fi
