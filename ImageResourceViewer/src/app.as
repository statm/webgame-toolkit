import flash.desktop.ClipboardFormats;
import flash.desktop.NativeDragManager;
import flash.display.NativeWindowDisplayState;
import flash.events.KeyboardEvent;
import flash.events.NativeDragEvent;
import flash.events.NativeWindowDisplayStateEvent;
import flash.filesystem.File;
import flash.utils.getTimer;

import mx.managers.DragManager;

import statm.dev.imageresourceviewer.data.resource.ResourceBatch;
import statm.dev.imageresourceviewer.data.resource.ResourceLib;
import statm.dev.libs.imageplayer.loader.ImageBatch;

private function init() : void
{
	//nativeWindow.maximize();
	ResourceLib.reset();
}

protected function displayStateChangeHandler(event : NativeWindowDisplayStateEvent) : void
{
	this.invalidateSkinState();
}

override protected function getCurrentSkinState() : String
{
	if (nativeWindow.displayState == NativeWindowDisplayState.MAXIMIZED)
	{
		return "maximized";
	}
	return super.getCurrentSkinState();
}

override protected function keyDownHandler(event : KeyboardEvent) : void
{
	categoryPanel.currentState = "expanded";
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

	categoryPanel.currentState = "expanded";
	NativeDragManager.acceptDragDrop(this);
}

protected function nativeDragExitHandler(event : NativeDragEvent) : void
{
	if (event.target != this)
	{
		return;
	}

	categoryPanel.currentState = "normal";
}

protected function nativeDragDropHandler(event : NativeDragEvent) : void
{
	var fileArray : Array = event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
	var c : int = fileArray.length;

	if (c == 0)
	{
		throw new Error("拖了空文件？");
		return;
	}

	while (--c > -1)
	{
		if (!(fileArray[c] is File)
			|| !(fileArray[c].isDirectory))
		{
			fileArray.splice(c, 1);
		}
	}

	// ？
	if (fileArray.length == 0)
	{
		categoryPanel.currentState = "normal";
	}
	// =

	var t : int = getTimer();
	traverseFolders(fileArray);
	trace(getTimer() - t);
	
	ResourceLib.print();

	DragManager.acceptDragDrop(this);
}

private function traverseFolders(folders : Array) : void
{
	for each (var folder : File in folders)
	{
		// 建立一个 batch
		var batch : ResourceBatch = new ResourceBatch(folder);
		if (batch.length > 0)
		{
			ResourceLib.addResource(batch);
		}

		// 遍历目录内容，递归	
		var folderContent : Array = folder.getDirectoryListing();
		for each (var folderItem : File in folderContent)
		{
			if (folderItem.isDirectory)
			{
				traverseFolders([folderItem]);
			}
		}
	}
}
