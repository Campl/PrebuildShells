using UnityEngine;
using System.Collections.Generic;
using System.Collections;

/*
 *	The Global Env Vars
 *
 *	by Hugh
 *
 */

namespace MoleMole
{
	public static class GlobalVars
	{
		public const string BUNDLE_IDENTIFIER = "com.miHoYo.enterprise.NGHSoD";

		public const string VERSION = "1.7.5";
		public const int BUNDLE_VERSION_CODE = 72;// 71;// 70;// 69;//68;

		/*	In Level Frame Rate	*/
		public const int IN_LEVEL_FRAME_RATE = 60;

		/*  In Level Time Per Frame  */
		public const float IN_LEVEL_TIME_PER_FRAME = 1.0f / IN_LEVEL_FRAME_RATE;

		/*	MouseBtnDefine	*/
		public const int MOUSE_LEFT_BUTTON = 0;
		public const int MOUSE_RIGHT_BUTTON = 1;
		public const int MOUSE_MIDDLE_BUTTON = 2;

		/*	Keyboard Control ? 	*/
		public static bool KEYBOARD_FUNCTION_BUTTON_CONTROL = true;

		/*	Load File Related 	*/
		public const string CSV_LINE_TOKEN = "\n";
		public const string CSV_MAC_LINE_TOKEN = "\r";
		public const string CSV_WORD_TOKEN = ",";
		public const string CSV_WORD_TAB_TOKEN = "\t";

		/* Level mode */
		public const string DEBUG_LEVEL_LUA_PATH = @"Lua/Levels/Common/LevelTest.lua";

		/* Network */
		public static bool DISABLE_NETWORK_DEBUG = false;

		/* get path switch */
		public static bool USE_GET_PATH_SWITCH = true;

		/* use dynamic bone switch */
		public static bool MONSTER_USE_DYNAMIC_BONE = true;

		/* use dynamic bone switch */
		public static bool AVATAR_USE_DYNAMIC_BONE = true;

		/* use dynamic bone switch */
		public static bool UI_AVATAR_USE_DYNAMIC_BONE = true;

		/*	Use Reflection	*/
		public static bool USE_REFLECTION = true;

		/* debug network delay	*/
		public static int DEBUG_NETWORK_DELAY_LEVEL = 0;

		/* Switch for all the debug buttons*/
		public static bool DEBUG_FEATURE_ON =
#if NG_HSOD_DEBUG || NG_HSOD_PROFILE
			true;
#else
			false;
#endif

		/* Asset Bundle */
		public static bool DataUseAssetBundle = false; /* 数值文件 */
		public static bool ResourceUseAssetBundle = false; /* 资源文件 */
		public static bool UseSpliteResources = false; /* 分包 */




#if UNITY_EDITOR
		private static int _simulateAssetBundleInEditor = -1;
		public static bool SimulateAssetBundleInEditor
		{
			get
			{
				if (_simulateAssetBundleInEditor == -1)
					_simulateAssetBundleInEditor = UnityEditor.EditorPrefs.GetBool("SimulateAssetBundleInEditor", true) ? 1 : 0;

				return _simulateAssetBundleInEditor != 0;
			}
			set
			{
				int newValue = value ? 1 : 0;
				if (newValue != _simulateAssetBundleInEditor)
				{
					_simulateAssetBundleInEditor = newValue;
					UnityEditor.EditorPrefs.SetBool("SimulateAssetBundleInEditor", value);
				}
			}
		}
#endif


		/*	Get Build Info, only auto build from Jenkins will have this.	*/
		public static string GetBuildInfo()
		{
#if NG_HSOD_DEBUG
			var buildInfoPath = string.Format("{0}/{1}", Application.streamingAssetsPath, "build_info.txt");
			if (buildInfoPath.Contains("://"))
				return "<unknown>";

			try
			{
				return System.IO.File.ReadAllText(buildInfoPath);
			}
			catch
			{
				return "<unknown>";
			}
#else
			return "";
#endif
		}

		/*	Set this to let all animator entity to use continouse detection		*/
		public static bool ENABLE_CONTINUOUS_DETECT_MODE = true;

		public static bool ENABLE_ISLAND_ENTRY = true;

		public static bool ENABLE_ARMADA_ENTRY = true;

		public static bool ENABLE_EXTRA_STORYA_ENTRY = true;

		public static bool IS_BENCHMARK = false;

		/*	Switch static cloud mode	*/
		public static bool STATIC_CLOUD_MODE = false;

		/*	Switch continue on exception	*/
		public static bool ENABLE_EXCEPTION_CONTINUE = true;

		/* Config check */
		public static bool CHECK_CONFIG = false;

		/* Switch auto battle	*/
		public static bool ENABLE_AUTO_BATTLE =
#if NG_HSOD_DEBUG || NG_HSOD_PROFILE
			true;
#else
			false;
#endif
		public static bool muteDamageText = false;

		public static bool muteInlevelLock = false;

		public static System.Exception luaException = null;

		/* Switch for all the debug buttons*/
		public static bool IOS_HOOK_RES =
#if NG_HSOD_IOS_HOOK_RES
			true;
#else
			false;
#endif

		public static bool GOOGLE_PLAY_OFFICIAL =
#if NG_HSOD_GOOGLE_PLAY_OFFICIAL
			true;
#else
 false;
#endif

		public static string channelConfigJsonString;

		#region profile memory
		public static bool muteVideo = false;

		public static bool mutePreloadMonster = false;

		public static bool muteCreateMonster = false;

		public static bool muteCreateAvatar = false;

		public static bool muteCreateStage = false;
		#endregion

		public static bool ENABLE_EXTRASTORY_PRELOAD = 
#if UNITY_IPHONE
			false;
#else
			false;
#endif

		public static bool ENABLE_ARMADA_PRELOAD =
#if UNITY_IPHONE
			false;
#else
			false;
#endif
        public static bool ENABLE_CampWar_PRELOAD =
#if UNITY_IPHONE
			false;
#else
            false;
#endif
        public static string ARMADA_GAMEOBJECT_NAME = "ArmadaUIManager(Clone)";
		public static string ARMADA_CONTAINER = "ArmadaContainer";

        public static string CAMP_WAR_UIMGR_GAMEOBJECT_NAME = "CampWarUIManager(Clone)";
        public static string CAMP_WAR_CONTAINER = "CampWarContainer";

		public static bool ENABLE_OPENWORLD_PRELOAD =
#if UNITY_IPHONE
			false;
#else
			false;
#endif
		public static string OPENWORLD_GAMEOBJECT_NAME = "OpenWorldUIManager(Clone)";
		public static string OPENWORLD_CONTAINER = "OpenWorldContainer";

		public static short[] sk = { 0x30, 0x67, 0x33, 0x54, 0x77, 0x62, 0x5a, 0x49, 0x52, 0x53, 0x48, 0x7e, 0x55, 0x53, 0x65, 0x4b, 0x45, 0x67, 0x4b, 0x63, 0x6e, 0x29, 0x71, 0x66, 0x76, 0x35, 0x43, 0x7e, 0x6f, 0x58, 0x49, 0x29 };
	
		/* 标识是否上次购买失败 */
		public static bool isPurchaseFailed = false;

		/* MP */
		public static bool MP_FAKE_PACKET = false;

		/* Radial Blur Fade auxobject name */
		public static string RADIAL_BLUR_FADE_OUT_NAME = "RadialBlurFadeOut";
		public static string RADIAL_BLUR_FADE_IN_NAME = "RadialBlurFadeIn";

		public static int LEAVE_MSG_MAX = 30;
	}
}
