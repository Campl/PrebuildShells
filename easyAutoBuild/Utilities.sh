#!/bin/sh

function get_provision_profile_by_channel {
    channel_name=$1
    case ${channel_name} in
        Master | Release | ServerTest | exam_cb | cb3_android | cb3_ios ) echo "ca0dd75a-183f-4c3d-a8cd-92931afdbead" #
            ;;
        CE_ICons2 ) echo "f8fd7058-73c5-4ace-a376-2187ed28a123" #
            ;;
	banshu ) echo "4815670a-da06-40ef-a8dd-016c037eb6d0"
	    ;;
    IOSIAP ) echo "a1d1e50d-b09d-499f-b437-ed8d1b271de5"
        ;;
        * ) echo ""
            ;;
    esac
}

function get_sigining_identity_by_channel {
    channel_name=$1
    case ${channel_name} in
        Master | Release | ServerTest | exam_cb | cb3_android | cb3_ios ) echo "iPhone Distribution: miHoYo Co., Ltd." #
            ;;
        CE_ICons2 ) echo "iPhone Distribution: miHoYo Co., Ltd." #
            ;;
        banshu ) echo "iPhone Developer: Wei Liu (WP2X69NK54)" #
            ;;
        IOSIAP ) echo "iPhone Developer: YANSHU SUN (72VV4A8DA7)"
            ;;
        * ) echo ""
            ;;
    esac
}

function preprocess_by_channel {
    channel_name=$1
    proj_path=$2

    chmod +x ${proj_path}/Ext/${channel_name}/Prebuild.sh
    ${proj_path}/Ext/${channel_name}/Prebuild.sh
    chmod +x ${proj_path}/AndroidAutoBuild/merge_common_manifest.sh
    ${proj_path}/AndroidAutoBuild/merge_common_manifest.sh
}
