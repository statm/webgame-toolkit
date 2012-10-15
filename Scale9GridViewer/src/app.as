import air.update.ApplicationUpdaterUI;
import air.update.events.StatusUpdateErrorEvent;
import air.update.events.UpdateEvent;

import flash.desktop.ClipboardFormats;
import flash.desktop.NativeApplication;
import flash.desktop.NativeDragManager;
import flash.display.Bitmap;
import flash.display.Loader;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.NativeDragEvent;
import flash.filesystem.File;
import flash.geom.Point;
import flash.net.URLRequest;

import mx.collections.ArrayCollection;

import spark.events.IndexChangeEvent;

import statm.dev.scale9gridviewer.AppState;
import statm.dev.scale9gridviewer.utils.FileUtils;

public static var VERSION : String;

private function init() : void
{
	AppState.fileList = new ArrayCollection();

	checkUpdate();

	var appXML : XML = NativeApplication.nativeApplication.applicationDescriptor;
	var appNS : Namespace = appXML.namespace();
	VERSION = appXML.appNS::versionNumber[0];
}

private var appUpdater : ApplicationUpdaterUI = new ApplicationUpdaterUI();

private function checkUpdate() : void
{
	appUpdater.updateURL = "http://www.sdgs.com/fol/tools/Scale9GridViewer/update.xml";
	appUpdater.isCheckForUpdateVisible = false;
	appUpdater.addEventListener(ErrorEvent.ERROR, function(event : ErrorEvent) : void {});
	appUpdater.addEventListener(StatusUpdateErrorEvent.UPDATE_ERROR, function(event : StatusUpdateErrorEvent) : void
	{
		//Alert.show(event.subErrorID.toString());
	});
	appUpdater.addEventListener(UpdateEvent.INITIALIZED, function(event : UpdateEvent) : void
	{
		appUpdater.checkNow();
	});
	appUpdater.initialize();
}

protected function nativeDragEnterHandler(event : NativeDragEvent) : void
{
	if (event.target != this)
	{
		return;
	}

	if (!event.clipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT))
	{
		return;
	}

	lblDragHere.setStyle("color", 0x666666);
	NativeDragManager.acceptDragDrop(this);
}

protected function nativeDragExitHandler(event : NativeDragEvent) : void
{
	if (event.target != this)
	{
		return;
	}

	lblDragHere.setStyle("color", 0xAAAAAA);
}

protected function nativeDragDropHandler(event : NativeDragEvent) : void
{
	var fileArray : Array = event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;

	if (fileArray.length == 0)
	{
		throw new Error("拖了空文件？");
		return;
	}

	lblDragHere.setStyle("color", 0xAAAAAA);

	for each (var file : File in fileArray)
	{
		if (FileUtils.isValidImageFile(file))
		{
			AppState.fileList.addItem(file);
		}
	}

	this.currentState = "normal";
}

protected function fileList_changeHandler(event : IndexChangeEvent) : void
{
	setFile(fileList.selectedItem);
}

private function setFile(file : File) : void
{
	AppState.currentFile = file;
	loadImageFile(file);
}

private var imageLoader : Loader;

private function loadImageFile(file : File) : void
{
	if (!imageLoader)
	{
		imageLoader = new Loader();
		imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, $loadImageFile);
	}

	imageLoader.load(new URLRequest(file.url));
}

private function $loadImageFile(event : Event) : void
{
	this.anchorSelector.setImage(Bitmap(imageLoader.content).bitmapData);
	this.previewPanel.setImage(Bitmap(imageLoader.content).bitmapData);
}

public function setScalingCenter(point : Point) : void
{
	this.previewPanel.setScalingCenter(point);
}
