using UnityEditor;
using UnityEngine;
using System.Collections.Generic;
using System;

/*
 *  Batch Build Helper
 *
 *   by liu
 *
 */

namespace MoleMole
{
	public static class BatchBuildHelper
	{
		#region Public Functions
		public static void BuildPackageByChannel(string channelName, BuildTarget buildTarget, bool debugMode = false, bool il2cpp = false, bool developmentBuild = false, bool isIosHook = false)
		{
			/*
				bake all data, include in level json and excel data, to asset
			*/
			if (System.IO.Directory.Exists("Assets/Resources/Data/_ExcelOutput"))
			{
				BakeDataTool.BakeAllData();
			}

			/* switch platform */
			if (EditorUserBuildSettings.activeBuildTarget != buildTarget)
			{
				Debug.Log("Start switch active BuildTarget to " + buildTarget);
				EditorUserBuildSettings.SwitchActiveBuildTarget(buildTarget);
				Debug.Log("Finish switch active BuildTarget to " + buildTarget);
			}

			ProcessBuild(channelName, buildTarget, Environment.CurrentDirectory + "/AutoBuild", debugMode, il2cpp, developmentBuild, isIosHook);
		}

		#endregion 

		#region Private Functions

		private static bool ProcessBuild(string channelName, BuildTarget target, string targetFolder = "", bool debugMode = false, bool il2cpp = false, bool developmentBuild = false, bool isIosHook = false)
		{
			// reimport all shaders
			string shaderFolderPath = "Assets/Standard Assets/Shaders";
			AssetDatabase.ImportAsset(shaderFolderPath, ImportAssetOptions.ImportRecursive | ImportAssetOptions.DontDownloadFromCacheServer);

			TextAsset mChannelTextAsset = AssetDatabase.LoadAssetAtPath<TextAsset>("Assets/OriginalResRepos/DataPersistent/BuildChannel/ChannelConfig.json");
			ConfigChannel channelConfig = ConfigUtil.LoadJSONStrConfig<ConfigChannel>(mChannelTextAsset.text);

			// ! 用设置里的配置
			/*
			if(target==BuildTarget.iOS)
			{
				PlayerSettings.SetPropertyInt("ScriptingBackend", (int)ScriptingImplementation.IL2CPP, BuildTarget.iOS);
				//PlayerSettings.SetPropertyInt("Architecture", (int)iPhoneArchitecture.Universal, BuildTargetGroup.iOS);
				PlayerSettings.SetGraphicsAPIs(BuildTarget.iOS, new UnityEngine.Rendering.GraphicsDeviceType[] { UnityEngine.Rendering.GraphicsDeviceType.OpenGLES2 });
			}
			*/

			PlayerSettings.productName = channelConfig.ProductName;
			PlayerSettings.bundleIdentifier = channelConfig.BundleIdentifier;
			PlayerSettings.bundleVersion = GlobalVars.VERSION;

			/* 安卓要设置version code */
			if (target == BuildTarget.Android)
			{
				PlayerSettings.Android.bundleVersionCode = Mathf.Max(channelConfig.VersionCode, GlobalVars.BUNDLE_VERSION_CODE);
				PlayerSettings.Android.useAPKExpansionFiles = channelConfig.Obb;
			}

			string DefineSymbols = channelConfig.PreDefines;
			if (debugMode)
			{
				DefineSymbols += ";NG_HSOD_PROFILE"; // ! 打包机出来的设备上 Debug 模式总是用 PROFILE 设置
			}
			if (target == BuildTarget.iOS && isIosHook)
			{
				DefineSymbols += ";NG_HSOD_IOS_HOOK_RES"; // ios 分包
			}
			// for behavior manager
			DefineSymbols += ";DLL_RELEASE";
			// avpro
			if (!debugMode)
			{
				AkPluginActivator.ActivateRelease();
				DefineSymbols += ";AVPROVIDEO_DISABLE_DEBUG_GUI;AVPROVIDEO_DISABLE_LOGGING";
			}
			else
			{
				// activate wwise profile
				AkPluginActivator.ActivateProfile();
			}

			BuildOptions mBuildOptions = BuildOptions.SymlinkLibraries;
			if (developmentBuild)
			{
				mBuildOptions |= BuildOptions.Development;
				mBuildOptions |= BuildOptions.ConnectWithProfiler;
				mBuildOptions |= BuildOptions.AllowDebugging;
			}

			// 如果不是安卓只用il2cpp，如果是安卓用参数开关il2cpp
			if (target != BuildTarget.Android || il2cpp)
			{
				PlayerSettings.SetPropertyInt("ScriptingBackend", (int)ScriptingImplementation.IL2CPP, target);
				PlayerSettings.strippingLevel = StrippingLevel.Disabled;
			}
			else
			{
				PlayerSettings.SetPropertyInt("ScriptingBackend", (int)ScriptingImplementation.Mono2x, target);
				PlayerSettings.strippingLevel = StrippingLevel.Disabled;
			}

			var targetGroup = target == BuildTarget.Android ? BuildTargetGroup.Android : BuildTargetGroup.iOS;
			PlayerSettings.SetScriptingDefineSymbolsForGroup(targetGroup, DefineSymbols);

			var scenes = GetBuildScenes(DefineSymbols);
			var buildPath = targetFolder;
			if (scenes == null || scenes.Length == 0 || buildPath == null)
			{
				return false;
			}

			Debug.Log("Start building player for " + target.ToString());
			Debug.Log("ChannelName= " + channelName);
			Debug.Log("DefineSymbols= " + DefineSymbols);
			Debug.Log("developmentBuild= " + developmentBuild);

			AssetDatabase.Refresh();

			BuildPipeline.BuildPlayer(scenes, buildPath, target, mBuildOptions);

			Debug.Log("Build player finished!");

			return true;
		}

		private static string[] GetBuildScenes(string defineSymbols)
		{
			List<string> names = new List<string>();

			/* 由于新加的Scene而导致国服不需要的资源增加，想办法去掉 */
			string distributeScene = "DistributeScene";
			string japanDownloadScene = "JapanDownloadScene";

			string japanDistributeScene = "JapanDistributeScene";

			bool needDownloadHookRes = defineSymbols.Contains("NG_HSOD_IOS_HOOK_RES");
			bool needDownloadObb = defineSymbols.Contains("NG_HSOD_GOOGLE_PLAY_OFFICIAL");
			Debug.Log("needDownloadHookRes= " + needDownloadHookRes);
			Debug.Log("needDownloadObb= " + needDownloadObb);
			
			foreach (EditorBuildSettingsScene e in EditorBuildSettings.scenes)
			{
				if (e == null) continue;

				if (e.path.Contains(distributeScene))
					e.enabled = !needDownloadObb;

				if (e.path.Contains(japanDistributeScene))
					e.enabled = needDownloadObb;

				if (e.path.Contains(japanDownloadScene))
					e.enabled = needDownloadHookRes;

				if (e.enabled) names.Add(e.path);
			}

			return names.ToArray();
		}
		
		#endregion 
	}
}
