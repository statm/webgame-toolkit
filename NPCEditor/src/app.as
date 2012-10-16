import flash.desktop.NativeApplication;
import flash.display.NativeWindowDisplayState;
import flash.events.ErrorEvent;
import flash.events.NativeWindowDisplayStateEvent;

import air.update.ApplicationUpdaterUI;
import air.update.events.StatusUpdateErrorEvent;
import air.update.events.UpdateEvent;

public static var VERSION : String;

private function init() : void
{
	var appXML:XML = NativeApplication.nativeApplication.applicationDescriptor;
	var appNS:Namespace = appXML.namespace();
	VERSION = appXML.appNS::versionNumber[0];
	
	//	stage.nativeWindow.maximize();
	
	XML.prettyPrinting = true;
	XML.prettyIndent = 4;
	
	checkUpdate();
}

// 版本/升级
private var appUpdater : ApplicationUpdaterUI = new ApplicationUpdaterUI();

private function checkUpdate() : void
{
	appUpdater.updateURL = "http://www.sdgs.com/fol/tools/NPCEditor/update.xml";
	appUpdater.isCheckForUpdateVisible = false;
	appUpdater.addEventListener(ErrorEvent.ERROR, function(event : ErrorEvent) : void {});
	appUpdater.addEventListener(StatusUpdateErrorEvent.UPDATE_ERROR, function(event : StatusUpdateErrorEvent) : void {});
	appUpdater.addEventListener(UpdateEvent.INITIALIZED, function(event : UpdateEvent) : void
	{
		appUpdater.checkNow();
	});
	appUpdater.initialize();
}

// 窗口皮肤
protected function displayStateChangeHandler(event : NativeWindowDisplayStateEvent) : void
{
	this.invalidateSkinState();
}

override protected function getCurrentSkinState() : String
{
	if (!this.nativeWindow.closed && this.nativeWindow.displayState == NativeWindowDisplayState.MAXIMIZED)
	{
		return "maximized";
	}
	return super.getCurrentSkinState();
}