import flash.desktop.ClipboardFormats;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.events.Event;
import flash.events.NativeDragEvent;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.utils.ByteArray;

import mx.collections.ArrayCollection;
import mx.graphics.codec.PNGEncoder;
import mx.managers.DragManager;

import spark.collections.Sort;

import statm.dev.spritebuilder.AppState;
import statm.dev.spritebuilder.Batch;

private function init() : void
{
	XML.prettyPrinting = true;
	XML.prettyIndent = 4;
}

protected function app_nativeDragEnterHandler(event : NativeDragEvent) : void
{
	if (event.clipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT))
	{
		var fileArray : Array = event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;

		var c : int = fileArray.length;

		if (c == 0)
		{
			return;
		}

		while (--c > -1)
		{
			if (!(fileArray[c] is File)
				|| !(fileArray[c].isDirectory))
			{
				return;
			}
		}
		DragManager.acceptDragDrop(this);
	}
}

protected function app_nativeDragDropHandler(event : NativeDragEvent) : void
{
	this.currentState = "loading";
	AppState.reset();

	var folders : Array = event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
	for each (var folder : File in folders)
	{
		var batch : Batch = new Batch();
		batch.folder = folder;
		AppState.batches.addItem(batch);
	}

	startBatchLoading();
}

private var batchLoadingIndex : int;

private function startBatchLoading() : void
{
	batchLoadingIndex = -1;
	nextBatch();
}

private function nextBatch(event : Event = null) : void
{
	var currentBatch : Batch;

	if (batchLoadingIndex > -1)
	{
		currentBatch = AppState.batches[batchLoadingIndex];
		currentBatch.removeEventListener(Event.CHANGE, updateBatchProgress);
		currentBatch.removeEventListener(Event.COMPLETE, nextBatch);
	}

	batchLoadingIndex++;

	lblStatus.text = "正在读取文件，第" + (batchLoadingIndex + 1) + "组，共" + AppState.batches.length + "组";

	if (batchLoadingIndex < AppState.batches.length)
	{
		currentBatch = AppState.batches[batchLoadingIndex];
		currentBatch.addEventListener(Event.CHANGE, updateBatchProgress);
		currentBatch.addEventListener(Event.COMPLETE, nextBatch);
		currentBatch.load();
	}
	else
	{
		this.currentState = "config";

		var c : int = AppState.batches.length;
		while (--c > -1)
		{
			if (AppState.batches[c].files.length == 0)
			{
				AppState.batches.removeItemAt(c);
			}
		}
		
		if (AppState.batches.length == 0)
		{
			this.currentState = "init";
			return;
		}

		AppState.activeBatch = AppState.batches[0];
		AppState.activeBatch.currentFrameIndex = 0;
	}
}

private function updateBatchProgress(event : Event) : void
{
	var currentBatch : Batch = event.currentTarget as Batch;
	loadingProgBar.setProgress(currentBatch.loadingIndex + 1, currentBatch.fileCount);
}

private function enterFrameHandler(event : Event) : void
{
	if (AppState.activeBatch
		&& AppState.playStatus != 0)
	{
		AppState.activeBatch.currentFrameIndex += AppState.playStatus;
	}
}
