using UnityEditor;
using UnityEngine;
using System;
using System.Collections.Generic;

/*
 *  CommandLine Builder
 *
 *   by liu
 *
 */
public class CommandLineBuilder
{
	private const string CustomArgStarter = "-mihoyo-";

	[MenuItem("miHoYo/Build Tools/Build JP Windows")]
	public static void BuildJPWindows()
	{
		string defineSymbols = "NG_HSOD_DEBUG;NG_HSOD_LOAD_TEXT_DEBUG";
		PlayerSettings.SetScriptingDefineSymbolsForGroup(BuildTargetGroup.Standalone, defineSymbols);

		List<string> names = new List<string>();
		foreach (EditorBuildSettingsScene e in EditorBuildSettings.scenes)
		{
			if (e == null) continue;

			if (e.enabled) names.Add(e.path);
		}

		BuildPipeline.BuildPlayer(names.ToArray(), "WindowsBuild", BuildTarget.StandaloneWindows, BuildOptions.SymlinkLibraries);
	}

	//[MenuItem("Assets/Build Tools/Build Android")]
	public static void BuildAndroidPackage()
	{
		string channelName;
		bool debugMode;
		bool il2cpp;
		bool developmentBuild;
		bool isIosHook;
		bool rebuildAsb;
		GetChannelFromCmdLineArgs(out channelName, out debugMode, out il2cpp, out developmentBuild, out isIosHook, out rebuildAsb);

		MoleMole.AssetBundleTool.NewCSVBuildAsb(BuildTarget.Android, rebuildAsb);

		MoleMole.BatchBuildHelper.BuildPackageByChannel(channelName, BuildTarget.Android, debugMode, il2cpp, developmentBuild, false);

	}

	//[MenuItem("Assets/Build Tools/Build IOS")]
	public static void BuildIOSPackage()
	{
		string channelName;
		bool debugMode;
		bool il2cpp;
		bool developmentBuild;
		bool isIosHook;
		bool rebuildAsb;
		GetChannelFromCmdLineArgs(out channelName, out debugMode, out il2cpp, out developmentBuild, out isIosHook, out rebuildAsb);

		MoleMole.AssetBundleTool.NewCSVBuildAsb(BuildTarget.iOS, rebuildAsb);

		MoleMole.BatchBuildHelper.BuildPackageByChannel(channelName, BuildTarget.iOS, debugMode, true, false, isIosHook);
	}

	private static void GetChannelFromCmdLineArgs(out string channelName, out bool debugMode, out bool il2cpp, out bool developmentBuild, out bool isIosHook, out bool rebuildAsb)
	{
		channelName = string.Empty;
		debugMode = false;
		il2cpp = false;
		developmentBuild = false;
		isIosHook = false;
		rebuildAsb = false;

		var args = Environment.GetCommandLineArgs();
		if (args == null || args.Length == 0)
		{
			return;
		}

		foreach (var arg in args)
		{
			if (string.IsNullOrEmpty(arg)) continue;

			Debug.Log("arg=" + arg);

			if (arg.StartsWith(CustomArgStarter, StringComparison.OrdinalIgnoreCase))
			{
				var miHoYoArgs = arg.Split('-');
				channelName = miHoYoArgs.Length > 2 ? miHoYoArgs[2] : string.Empty;
				debugMode = miHoYoArgs.Length > 3 && miHoYoArgs[3] == "true";
				il2cpp = miHoYoArgs.Length > 4 && miHoYoArgs[4] == "true";
				developmentBuild = miHoYoArgs.Length > 5 && miHoYoArgs[5] == "true";
				isIosHook = miHoYoArgs.Length > 6 && miHoYoArgs[6] == "true";
				rebuildAsb = miHoYoArgs.Length > 7 && miHoYoArgs[7] == "true";
			}
		}
	}
}