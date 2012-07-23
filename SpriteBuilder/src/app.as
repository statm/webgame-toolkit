import flash.desktop.ClipboardFormats;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.events.Event;
import flash.events.NativeDragEvent;
import flash.filesystem.File;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.net.URLRequest;

import mx.collections.ArrayCollection;
import mx.managers.DragManager;

import spark.collections.Sort;

import statm.dev.spritebuilder.AppState;

protected function app_nativeDragEnterHandler(event : NativeDragEvent) : void
{
	if (event.clipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT))
	{
		var fileArray : Array = event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
		if (fileArray.length == 1
			&& fileArray[0] is File
			&& fileArray[0].isDirectory)
		{
			DragManager.acceptDragDrop(this);
		}
	}
}

protected function app_nativeDragDropHandler(event : NativeDragEvent) : void
{
	var folder : File = event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT)[0];
	this.currentState = "config";
	AppState.reset();
	setupConfig(folder);
}

private function setupConfig(folder : File) : void
{
	var fileArray : Array = filterFiles(folder);
	AppState.files = new ArrayCollection(fileArray);
	var sort : Sort = new Sort();
	sort.compareFunction = compareFiles;
	AppState.files.sort = sort;
	AppState.files.refresh();

	AppState.originalBitmaps = new Vector.<BitmapData>(fileArray.length, true);
	AppState.originalBitmapBounds = new Vector.<Rectangle>(fileArray.length, true);
	AppState.croppedBitmaps = new Vector.<BitmapData>(fileArray.length, true);

	loadBitmaps();
}

private function filterFiles(folder : File) : Array
{
	var files : Array = folder.getDirectoryListing();
	var i : int = files.length;
	while (--i > -1)
	{
		isImageFile(files[i]) || files.splice(i, 1);
	}

	return files;
}

private function isImageFile(file : File) : Boolean
{
	var acceptedExt : Array = ["jpg", "jpeg", "bmp", "png"];

	return acceptedExt.indexOf(file.extension) > -1;
}

private function compareFiles(a : Object, b : Object, fields : Array) : int
{
	var id1 : int = parseInt(a.name.split(".")[0]);
	var id2 : int = parseInt(b.name.split(".")[0]);

	if (id1 > id2)
	{
		return 1;
	}
	else if (id1 == id2)
	{
		return 0;
	}
	else
	{
		return -1;
	}
}

private var bitmapLoader : Loader;

private var loadingIndex : int = -1;

private function loadBitmaps() : void
{
	bitmapLoader = new Loader();
	bitmapLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_next);
	loader_next();
}

private function loader_next(event : Event = null) : void
{
	if (event)
	{
		var bitmapData : BitmapData = Bitmap(bitmapLoader.content).bitmapData;
		AppState.originalBitmaps[loadingIndex] = bitmapData;

		var bound : Rectangle = bitmapData.getColorBoundsRect(0xFF000000, 0x000000);
		AppState.originalBitmapBounds[loadingIndex] = bound;

		var cropped : BitmapData = new BitmapData(bound.width, bound.height, true, 0x00000000);
		cropped.copyPixels(bitmapData, bound, new Point(0, 0));
		AppState.croppedBitmaps[loadingIndex] = cropped;
	}
	loadingIndex++;
	if (loadingIndex < AppState.files.length)
	{
		bitmapLoader.load(new URLRequest(AppState.files[loadingIndex].url));
	}
	else
	{
		assembleSprite();
	}
}

private function assembleSprite() : void
{
	
}
