import flash.desktop.ClipboardFormats;
import flash.desktop.NativeDragManager;
import flash.display.NativeWindowDisplayState;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.NativeDragEvent;
import flash.events.NativeWindowDisplayStateEvent;
import flash.filesystem.File;
import flash.ui.Keyboard;
import flash.utils.getTimer;

import mx.collections.ArrayCollection;
import mx.managers.DragManager;

import spark.events.IndexChangeEvent;

import statm.dev.imageresourceviewer.AppState;
import statm.dev.imageresourceviewer.data.Action;
import statm.dev.imageresourceviewer.data.ActionInfo;
import statm.dev.imageresourceviewer.data.Element;
import statm.dev.imageresourceviewer.data.resource.ResourceBatch;
import statm.dev.imageresourceviewer.data.resource.ResourceLib;
import statm.dev.imageresourceviewer.data.type.DirectionType;
import statm.dev.imageresourceviewer.data.type.ResourceType;
import statm.dev.imageresourceviewer.ui.Dashboard;
import statm.dev.imageresourceviewer.ui.skins.itemRenderers.PlaybackItemRenderer;
import statm.dev.libs.imageplayer.ImagePlayer;

private function init() : void
{
	//nativeWindow.maximize();
	ResourceLib.reset();
	this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
}

private function onKeyDown(event : KeyboardEvent) : void
{
	if (AppState.playing)
	{
		stop();
	}
	else
	{
		play();
	}
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
			AppState.activeLayers.addItem(AppState.selectedMount);
			AppState.activeLayers.addItem(AppState.selectedHero);
			AppState.activeLayers.addItem(AppState.selectedWeapon);
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
	// 根据当前零件计算动作列表（最小公倍数）
	var actions : ArrayCollection = AppState.currentActions;
	var actionNames : Array = [];

	actions.removeAll();
	for each (var elem : Element in AppState.activeLayers)
	{
		if (!elem)
		{
			continue;
		}

		for each (var action : Action in elem.actionList)
		{
			if (actionNames.indexOf(action.name) == -1)
			{
				actions.addItem(action.info);
				actionNames[actionNames.length] = action.name;
			}
		}
	}
}

public function setAction(info : ActionInfo) : void
{
	AppState.currentAction = info.name;
	AppState.frameTotal = info.frameCount;
	updateActionAndDirection();
}

public function setDirection(direction : String) : void
{
	AppState.currentDirection = direction;
	updateActionAndDirection();
}

private function updateActionAndDirection() : void
{
	var needMirroring : Boolean =
		(AppState.currentDirection == DirectionType.NW
		|| AppState.currentDirection == DirectionType.W
		|| AppState.currentDirection == DirectionType.SW);

	switch (AppState.categoryMode)
	{
		case ResourceType.HERO:
			AppState.selectedHero && categoryPanel.hero.player.setImageBatch(AppState.selectedHero.getCurrentBatch());
			AppState.selectedWeapon && categoryPanel.weapon.player.setImageBatch(AppState.selectedWeapon.getCurrentBatch());
			AppState.selectedMount && categoryPanel.mount.player.setImageBatch(AppState.selectedMount.getCurrentBatch());

			categoryPanel.hero.player.horizontalMirroring
				= categoryPanel.weapon.player.horizontalMirroring
				= categoryPanel.mount.player.horizontalMirroring
				= needMirroring;
			break;

		case ResourceType.NPC:
			AppState.selectedNPC && categoryPanel.npc.player.setImageBatch(AppState.selectedNPC.getCurrentBatch());
			categoryPanel.npc.player.horizontalMirroring = needMirroring;
			break;

		case ResourceType.MOB:
			AppState.selectedMob && categoryPanel.mob.player.setImageBatch(AppState.selectedMob.getCurrentBatch());
			categoryPanel.mob.player.horizontalMirroring = needMirroring;
			break;

		case ResourceType.PET:
			AppState.selectedPet && categoryPanel.pet.player.setImageBatch(AppState.selectedPet.getCurrentBatch());
			categoryPanel.pet.player.horizontalMirroring = needMirroring;
			break;

		case ResourceType.FX:
			AppState.selectedFX && categoryPanel.fx.player.setImageBatch(AppState.selectedFX.getCurrentBatch());
			categoryPanel.fx.player.horizontalMirroring = needMirroring;
			break;
	}

	for each (var elem : Element in AppState.activeLayers)
	{
		if (!elem)
		{
			continue;
		}
		AppState.activeLayers.itemUpdated(elem);
	}
}

// 播放
public function play() : void
{
	AppState.playing = true;

	this.addEventListener(Event.ENTER_FRAME, $play);
}

private function $play(event : Event) : void
{
	var l : int = playbackPanel.layerDataGroup.numElements;
	AppState.currentFrame++;
	AppState.currentFrame %= AppState.frameTotal;

	for (var i : int = 0; i < l; i++)
	{
		PlaybackItemRenderer(playbackPanel.layerDataGroup.getElementAt(i)).player.gotoFrame(AppState.currentFrame);
	}
}

public function gotoFrame(frame:int):void
{
	var l : int = playbackPanel.layerDataGroup.numElements;
	AppState.currentFrame = frame % AppState.frameTotal;
	
	for (var i : int = 0; i < l; i++)
	{
		PlaybackItemRenderer(playbackPanel.layerDataGroup.getElementAt(i)).player.gotoFrame(AppState.currentFrame);
	}
}

public function stop() : void
{
	AppState.playing = false;
	AppState.currentFrame = 0;

	var l : int = playbackPanel.layerDataGroup.numElements;
	for (var i : int = 0; i < l; i++)
	{
		PlaybackItemRenderer(playbackPanel.layerDataGroup.getElementAt(i)).player.gotoFrame(0);
	}

	this.removeEventListener(Event.ENTER_FRAME, $play);
}
