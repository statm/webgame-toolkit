import flash.desktop.ClipboardFormats;
import flash.desktop.NativeDragManager;
import flash.display.NativeWindowDisplayState;
import flash.events.KeyboardEvent;
import flash.events.NativeDragEvent;
import flash.events.NativeWindowDisplayStateEvent;
import flash.filesystem.File;
import flash.utils.getTimer;

import mx.managers.DragManager;

import spark.events.IndexChangeEvent;

import statm.dev.imageresourceviewer.AppState;
import statm.dev.imageresourceviewer.data.Element;
import statm.dev.imageresourceviewer.data.resource.ResourceBatch;
import statm.dev.imageresourceviewer.data.resource.ResourceLib;
import statm.dev.imageresourceviewer.data.type.ResourceType;

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
	trace("耗时" + (getTimer() - t) + "ms");

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

private function resourceList_changeHandler(event : IndexChangeEvent) : void
{
	var selectedItem : Element = resourceList.selectedItem;

	switch (selectedItem.type)
	{
		case ResourceType.HERO:
			AppState.selectedHero = selectedItem;
			setCategoryMode(ResourceType.HERO);
			break;

		case ResourceType.WEAPON:
			AppState.selectedWeapon = selectedItem;
			setCategoryMode(ResourceType.HERO);
			break;

		case ResourceType.MOUNT:
			AppState.selectedMount = selectedItem;
			setCategoryMode(ResourceType.HERO);
			break;

		case ResourceType.NPC:
			AppState.selectedNPC = selectedItem;
			setCategoryMode(ResourceType.NPC);
			break;

		case ResourceType.MOB:
			AppState.selectedMob = selectedItem;
			setCategoryMode(ResourceType.MOB);
			break;

		case ResourceType.PET:
			AppState.selectedPet = selectedItem;
			setCategoryMode(ResourceType.NPC);
			break;

		case ResourceType.FX:
			AppState.selectedFX = selectedItem;
			setCategoryMode(ResourceType.FX);
			break;
	}
	
	calculateActionList();
}

private function setCategoryMode(mode : String) : void
{
	AppState.categoryMode = mode;
	AppState.activeLayers.removeAll();

	switch (mode)
	{
		case ResourceType.HERO:
			categoryPanel.setCategoryButtons(["hero", "weapon", "mount"]);
			AppState.activeLayers.addItem(AppState.selectedHero);
			AppState.activeLayers.addItem(AppState.selectedWeapon);
			AppState.activeLayers.addItem(AppState.selectedMount);
			break;

		case ResourceType.NPC:
			categoryPanel.setCategoryButtons(["npc"]);
			AppState.activeLayers.addItem(AppState.selectedNPC);
			break;

		case ResourceType.MOB:
			categoryPanel.setCategoryButtons(["mob"]);
			AppState.activeLayers.addItem(AppState.selectedMob);
			break;

		case ResourceType.PET:
			categoryPanel.setCategoryButtons(["pet"]);
			AppState.activeLayers.addItem(AppState.selectedPet);
			break;

		case ResourceType.FX:
			categoryPanel.setCategoryButtons(["fx"]);
			AppState.activeLayers.addItem(AppState.selectedPet);
			break;
	}
}

private function calculateActionList() : void
{
	// TODO: 根据当前零件计算动作列表（最小公倍数）
}
