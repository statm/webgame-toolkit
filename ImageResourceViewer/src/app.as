import air.update.ApplicationUpdaterUI;
import air.update.events.StatusUpdateErrorEvent;
import air.update.events.UpdateEvent;

import flash.desktop.ClipboardFormats;
import flash.desktop.NativeApplication;
import flash.desktop.NativeDragManager;
import flash.display.NativeWindowDisplayState;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.NativeDragEvent;
import flash.events.NativeWindowDisplayStateEvent;
import flash.filesystem.File;
import flash.utils.getTimer;

import mx.collections.ArrayCollection;

import spark.events.IndexChangeEvent;

import statm.dev.imageresourceviewer.AppState;
import statm.dev.imageresourceviewer.data.Action;
import statm.dev.imageresourceviewer.data.ActionInfo;
import statm.dev.imageresourceviewer.data.Element;
import statm.dev.imageresourceviewer.data.io.SpriteWriter;
import statm.dev.imageresourceviewer.data.resource.ResourceBatch;
import statm.dev.imageresourceviewer.data.resource.ResourceCategory;
import statm.dev.imageresourceviewer.data.resource.ResourceLib;
import statm.dev.imageresourceviewer.data.type.ResourceType;
import statm.dev.imageresourceviewer.ui.itemRenderers.PlaybackItemRenderer;

public static var VERSION : String;

private function init() : void
{
	ResourceLib.reset();
	checkUpdate();

	var appXML : XML = NativeApplication.nativeApplication.applicationDescriptor;
	var appNS : Namespace = appXML.namespace();
	VERSION = appXML.appNS::versionNumber[0];
}

private var appUpdater : ApplicationUpdaterUI = new ApplicationUpdaterUI();

private function checkUpdate() : void
{
	appUpdater.updateURL = "http://www.fol.com/fol/tools/ImageResourceViewer/update.xml";
	appUpdater.isCheckForUpdateVisible = false;
	appUpdater.addEventListener(ErrorEvent.ERROR, function(event : ErrorEvent) : void
	{
	});
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

	if (this.currentState == "hidden")
	{
		this.currentState = "processing";
	}
	startProcessing(fileArray);
}

private function startProcessing(fileArray : Array) : void
{
	var c : int = fileArray.length;

	while (--c > -1)
	{
		if (!(fileArray[c] is File) || !(fileArray[c].isDirectory))
		{
			fileArray.splice(c, 1);
		}
	}

	folderList = new Vector.<File>();
	for each (var folder : File in fileArray)
	{
		folderList.push(folder);
	}
	processingIndex = 0;

//	t = getTimer();
	this.addEventListener(Event.ENTER_FRAME, traverse_enterFrameHandler);
}

//private var t:int;

private var folderList : Vector.<File>;

private var processingIndex : int = 0;

private var processingCount : int = 0;

private function traverse_enterFrameHandler(event : Event) : void
{
	processingCount = 0;

	while (processingIndex < folderList.length && processingCount < 2)
	{
		var folder : File = folderList[processingIndex];
		var batch : ResourceBatch = new ResourceBatch(folder);

		if (batch.length > 0)
		{
			ResourceLib.addResource(batch);
		}

		var folderContent : Array = folder.getDirectoryListing();
		for each (var folderItem : File in folderContent)
		{
			if (folderItem.isDirectory)
			{
				folderList.push(folderItem);
			}
		}

		processingIndex++;
		processingCount++;
	}

//	trace("pI=" + processingIndex + ", fL=" + folderList.length);

	if (processingIndex > folderList.length - 1)
	{
		$traverseComplete();
	}
}

private function $traverseComplete() : void
{
	this.removeEventListener(Event.ENTER_FRAME, traverse_enterFrameHandler);

//	trace("耗时" + (getTimer() - t) + "ms");

	ResourceLib.print();

	if (this.currentState == "processing")
	{
		this.currentState = "normal";
	}
}

private function resourceList_changeHandler(event : IndexChangeEvent) : void
{
	playingGroup.visible = true;

	AppState.activeLayers.removeAll();

	var selectedItem : Element = resourceList.selectedItem;

	switch (selectedItem.type)
	{
		case ResourceType.HERO:
			AppState.categoryMode = ResourceType.HERO;
			categoryPanel.setSelectedCategoryButtons(["hero", "weapon", "mount", "fx"]);
			AppState.selectedHero = selectedItem;
			AppState.activeLayers.addItem(AppState.selectedMount);
			AppState.activeLayers.addItem(AppState.selectedHero);
			AppState.activeLayers.addItem(AppState.selectedWeapon);
			AppState.activeLayers.addItem(AppState.selectedFX);
			break;

		case ResourceType.WEAPON:
			AppState.categoryMode = ResourceType.HERO;
			categoryPanel.setSelectedCategoryButtons(["hero", "weapon", "mount", "fx"]);
			AppState.selectedWeapon = selectedItem;
			AppState.activeLayers.addItem(AppState.selectedMount);
			AppState.activeLayers.addItem(AppState.selectedHero);
			AppState.activeLayers.addItem(AppState.selectedWeapon);
			AppState.activeLayers.addItem(AppState.selectedFX);
			break;

		case ResourceType.MOUNT:
			AppState.categoryMode = ResourceType.HERO;
			categoryPanel.setSelectedCategoryButtons(["hero", "weapon", "mount", "fx"]);
			AppState.selectedMount = selectedItem;
			AppState.activeLayers.addItem(AppState.selectedMount);
			AppState.activeLayers.addItem(AppState.selectedHero);
			AppState.activeLayers.addItem(AppState.selectedWeapon);
			AppState.activeLayers.addItem(AppState.selectedFX);
			break;

		case ResourceType.NPC:
			AppState.categoryMode = ResourceType.NPC;
			categoryPanel.setSelectedCategoryButtons(["npc", "fx"]);
			AppState.selectedNPC = selectedItem;
			AppState.activeLayers.addItem(AppState.selectedNPC);
			AppState.activeLayers.addItem(AppState.selectedFX);
			break;

		case ResourceType.MOB:
			AppState.categoryMode = ResourceType.MOB;
			categoryPanel.setSelectedCategoryButtons(["mob", "fx"]);
			AppState.selectedMob = selectedItem;
			AppState.activeLayers.addItem(AppState.selectedMob);
			AppState.activeLayers.addItem(AppState.selectedFX);
			break;

		case ResourceType.PET:
			AppState.categoryMode = ResourceType.PET;
			categoryPanel.setSelectedCategoryButtons(["pet"]);
			AppState.selectedPet = selectedItem;
			AppState.activeLayers.addItem(AppState.selectedPet);
			break;

		case ResourceType.FX:
			if (AppState.categoryMode == null || AppState.categoryMode == ResourceType.HERO)
			{
				categoryPanel.setSelectedCategoryButtons(["hero", "weapon", "mount", "fx"]);
				AppState.selectedFX = selectedItem;
				AppState.activeLayers.addItem(AppState.selectedMount);
				AppState.activeLayers.addItem(AppState.selectedHero);
				AppState.activeLayers.addItem(AppState.selectedWeapon);
			}
			else if (AppState.categoryMode == ResourceType.NPC)
			{
				categoryPanel.setSelectedCategoryButtons(["npc", "fx"]);
				AppState.selectedFX = selectedItem;
				AppState.activeLayers.addItem(AppState.selectedNPC);
			}
			else if (AppState.categoryMode == ResourceType.MOB)
			{
				categoryPanel.setSelectedCategoryButtons(["mob", "fx"]);
				AppState.selectedFX = selectedItem;
				AppState.activeLayers.addItem(AppState.selectedMob);
			}

			if (AppState.fxEnabled)
			{
				AppState.activeLayers.addItem(AppState.selectedFX);
			}

			break;

		case ResourceType.UNKNOWN:
			AppState.categoryMode = ResourceType.UNKNOWN;
			categoryPanel.setSelectedCategoryButtons(["unknown"]);
			AppState.selectedUnknown = selectedItem;
			AppState.activeLayers.addItem(AppState.selectedUnknown);
			break;
	}

	calculateActionList();
}

private function calculateActionList() : void
{
	// 根据当前零件计算动作列表（最小公倍数）
	var actions : ArrayCollection = AppState.currentActions;
	var actionNames : Array = [];

	actions.removeAll();
	for each (var elem : Element in AppState.activeLayers)
	{
		if (!elem || (elem.type == ResourceType.FX && AppState.categoryMode != ResourceType.FX))
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

	if (actionNames.indexOf(AppState.currentAction) == -1 && actions.length > 0)
	{
		setAction(actions[0]);
	}
}

public function setAction(info : ActionInfo) : void
{
	AppState.currentAction = info.name;
	AppState.currentFrame = 0;
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
	for each (var elem : Element in AppState.activeLayers)
	{
		if (!elem)
		{
			continue;
		}
		AppState.activeLayers.itemUpdated(elem);
	}
}

public function setFXVisibility(value : Boolean) : void
{
	if (value != AppState.fxEnabled)
	{
		AppState.fxEnabled = value;
		if (value)
		{
			AppState.activeLayers.addItem(AppState.selectedFX);
		}
		else
		{
			var index : int = AppState.activeLayers.getItemIndex(AppState.selectedFX);
			if (index > -1)
			{
				AppState.activeLayers.removeItemAt(index);
			}
		}
	}
}

public function writeSprites() : void
{
	var folderPath : File = File.desktopDirectory;
	folderPath.addEventListener(Event.SELECT, $writeSprites);
	folderPath.browseForDirectory("选择输出目录");
}

private function $writeSprites(event : Event) : void
{
	var folder : File = event.currentTarget as File;

	for each (var typeName : String in ResourceType.typeList)
	{
		var category : ResourceCategory = ResourceLib.getCategory(typeName);
		if (category.elements.length > 1) // 至少有一个“无”
		{
			var path : File = folder.resolvePath(typeName);
			path.createDirectory();

			for each (var elem : Element in category.elements)
			{
				if (elem.name == "无")
				{
					continue;
				}

				var elemPath : File = path.resolvePath(elem.name);
				elemPath.createDirectory();

				for each (var action:Action in elem.actionList)
				{
					new SpriteWriter().writeActionSprite(action, elemPath);
				}
			}
		}
	}
}

// 播放
public function play() : void
{
	AppState.playing = true;

	this.addEventListener(Event.ENTER_FRAME, $play);
}

private var lastFrameTime : int = int.MIN_VALUE;

private function $play(event : Event) : void
{
	var l : int = AppState.activeLayers.length;
	var currentTime : int = getTimer();
	if (lastFrameTime == int.MIN_VALUE)
	{
		AppState.currentFrame++;
		lastFrameTime = currentTime;
	}
	else
	{
		var delta : int = currentTime - lastFrameTime;
		var deltaRatio : Number = delta * AppState.frameRate * 0.001;
		if (deltaRatio > .75)
		{
			lastFrameTime = currentTime;
			AppState.currentFrame += Math.round(deltaRatio);
//			trace("actual fps=" + (1000 / delta));
		}
	}
	AppState.currentFrame %= AppState.frameTotal;

	for (var i : int = 0; i < l; i++)
	{
		var itemRenderer : PlaybackItemRenderer = PlaybackItemRenderer(playbackPanel.layerDataGroup.getElementAt(i));
		if (!itemRenderer)
		{
			continue;
		}
		itemRenderer.player.gotoFrame(AppState.currentFrame);
	}

	playbackPanel.updateBackground();
}

public function gotoFrame(frame : int) : void
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

public function togglePlay() : void
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
