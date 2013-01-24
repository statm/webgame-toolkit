import flash.desktop.ClipboardFormats;
import flash.desktop.NativeApplication;
import flash.desktop.NativeDragManager;
import flash.display.NativeWindowDisplayState;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.NativeDragEvent;
import flash.events.NativeWindowDisplayStateEvent;
import flash.filesystem.File;
import flash.utils.getTimer;
import flash.utils.setTimeout;

import mx.collections.ArrayCollection;

import spark.events.IndexChangeEvent;

import air.update.ApplicationUpdaterUI;
import air.update.events.StatusUpdateErrorEvent;
import air.update.events.UpdateEvent;

import statm.dev.imageresourceviewer.AppState;
import statm.dev.imageresourceviewer.data.Action;
import statm.dev.imageresourceviewer.data.ActionInfo;
import statm.dev.imageresourceviewer.data.Element;
import statm.dev.imageresourceviewer.data.FXElement;
import statm.dev.imageresourceviewer.data.io.SpritesheetWriter;
import statm.dev.imageresourceviewer.data.resource.ResourceBatch;
import statm.dev.imageresourceviewer.data.resource.ResourceCategory;
import statm.dev.imageresourceviewer.data.resource.ResourceLib;
import statm.dev.imageresourceviewer.data.type.ResourceType;
import statm.dev.imageresourceviewer.ui.itemRenderers.PlaybackItemRenderer;

private function init():void
{
	ResourceLib.reset();
	readVersion();
	checkUpdate();
}

// 常量
public static const DEFAULT_FRAME_RATE:int = 15;

public static const DEFAULT_ANCHOR:int = 115;

public static const DEFAULT_IMAGE_DIMENSION:int = 340;

// 版本/升级
public static var VERSION:String;

private function readVersion():void
{
	var appXML:XML = NativeApplication.nativeApplication.applicationDescriptor;
	var appNS:Namespace = appXML.namespace();
	VERSION = appXML.appNS::versionNumber[0];
}

private var appUpdater:ApplicationUpdaterUI = new ApplicationUpdaterUI();

private function checkUpdate():void
{
	appUpdater.updateURL = "http://www.sdgs.com/fol/tools/ImageResourceViewer/update.xml";
	appUpdater.isCheckForUpdateVisible = false;
	appUpdater.addEventListener(ErrorEvent.ERROR, function(event:ErrorEvent):void
	{
	});
	appUpdater.addEventListener(StatusUpdateErrorEvent.UPDATE_ERROR, function(event:StatusUpdateErrorEvent):void
	{
	});
	appUpdater.addEventListener(UpdateEvent.INITIALIZED, function(event:UpdateEvent):void
	{
		appUpdater.checkNow();
	});
	appUpdater.initialize();
}

// 窗口皮肤
protected function displayStateChangeHandler(event:NativeWindowDisplayStateEvent):void
{
	this.invalidateSkinState();
}

override protected function getCurrentSkinState():String
{
	if (!this.nativeWindow.closed && this.nativeWindow.displayState == NativeWindowDisplayState.MAXIMIZED)
	{
		return "maximized";
	}
	return super.getCurrentSkinState();
}

// 文件拖放和读取
protected function nativeDragEnterHandler(event:NativeDragEvent):void
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

protected function nativeDragExitHandler(event:NativeDragEvent):void
{
	if (event.target != this)
	{
		return;
	}

	lblDragHere.setStyle("color", 0xAAAAAA);
}

protected function nativeDragDropHandler(event:NativeDragEvent):void
{
	var fileArray:Array = event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;

	if (fileArray.length == 0)
	{
		throw new Error("拖了空文件？");
		return;
	}

	lblDragHere.setStyle("color", 0xAAAAAA);

	if (this.currentState == "hidden")
	{
		this.currentState = "normal";
	}

	startProcessing(fileArray);
}

// 文件读取
private function startProcessing(fileArray:Array):void
{
	var c:int = fileArray.length;

	while (--c > -1)
	{
		if (!(fileArray[c] is File) || !(fileArray[c].isDirectory))
		{
			fileArray.splice(c, 1);
		}
	}

	folderList = new Vector.<File>();
	for each (var folder:File in fileArray)
	{
		folderList.push(folder);
	}
	processingIndex = 0;

	this.addEventListener(Event.ENTER_FRAME, traverse_enterFrameHandler);
}

private var folderList:Vector.<File>;

private var processingIndex:int = 0;

private var processingCount:int = 0;

private function traverse_enterFrameHandler(event:Event):void
{
	processingCount = 0;

	while (processingIndex < folderList.length && processingCount < 2)
	{
		var folder:File = folderList[processingIndex];
		var batch:ResourceBatch = new ResourceBatch(folder);

		if (batch.length > 0)
		{
			ResourceLib.addResource(batch);
		}

		var folderContent:Array = folder.getDirectoryListing();
		for each (var folderItem:File in folderContent)
		{
			if (folderItem.isDirectory)
			{
				folderList.push(folderItem);
			}
		}

		processingIndex++;
		processingCount++;
	}

	if (processingIndex > folderList.length - 1)
	{
		$traverseComplete();
	}
}

private function $traverseComplete():void
{
	this.removeEventListener(Event.ENTER_FRAME, traverse_enterFrameHandler);

//	ResourceLib.print();
}

// UI 动作
private function resourceList_changeHandler(event:IndexChangeEvent):void
{
	var selectedItem:Element = resourceList.selectedItem;

	if (selectedItem.type != ResourceType.UNKNOWN)
	{
		setTimeout(function():void
		{
			playingGroup.visible = true;
		}, 500);
		AppState.instance.playingElements.removeAll();
	}

	switch (selectedItem.type)
	{
		case ResourceType.HERO:
			AppState.instance.categoryMode = ResourceType.HERO;
			categoryPanel.setSelectedCategoryButtons(["hero", "weapon", "mount", "fx"]);
			AppState.instance.selectedHero = selectedItem;
			AppState.instance.playingElements.addItem(AppState.instance.selectedMount);
			AppState.instance.playingElements.addItem(AppState.instance.selectedHero);
			AppState.instance.playingElements.addItem(AppState.instance.selectedWeapon);
			AppState.instance.playingElements.addItem(AppState.instance.selectedFX);
			break;

		case ResourceType.WEAPON:
			AppState.instance.categoryMode = ResourceType.HERO;
			categoryPanel.setSelectedCategoryButtons(["hero", "weapon", "mount", "fx"]);
			AppState.instance.selectedWeapon = selectedItem;
			AppState.instance.playingElements.addItem(AppState.instance.selectedMount);
			AppState.instance.playingElements.addItem(AppState.instance.selectedHero);
			AppState.instance.playingElements.addItem(AppState.instance.selectedWeapon);
			AppState.instance.playingElements.addItem(AppState.instance.selectedFX);
			break;

		case ResourceType.MOUNT:
			AppState.instance.categoryMode = ResourceType.HERO;
			categoryPanel.setSelectedCategoryButtons(["hero", "weapon", "mount", "fx"]);
			AppState.instance.selectedMount = selectedItem;
			AppState.instance.playingElements.addItem(AppState.instance.selectedMount);
			AppState.instance.playingElements.addItem(AppState.instance.selectedHero);
			AppState.instance.playingElements.addItem(AppState.instance.selectedWeapon);
			AppState.instance.playingElements.addItem(AppState.instance.selectedFX);
			break;

		case ResourceType.NPC:
			AppState.instance.categoryMode = ResourceType.NPC;
			categoryPanel.setSelectedCategoryButtons(["npc", "fx"]);
			AppState.instance.selectedNPC = selectedItem;
			AppState.instance.playingElements.addItem(AppState.instance.selectedNPC);
			AppState.instance.playingElements.addItem(AppState.instance.selectedFX);
			break;

		case ResourceType.MOB:
			AppState.instance.categoryMode = ResourceType.MOB;
			categoryPanel.setSelectedCategoryButtons(["mob", "fx"]);
			AppState.instance.selectedMob = selectedItem;
			AppState.instance.playingElements.addItem(AppState.instance.selectedMob);
			AppState.instance.playingElements.addItem(AppState.instance.selectedFX);
			break;

		case ResourceType.PET:
			AppState.instance.categoryMode = ResourceType.PET;
			categoryPanel.setSelectedCategoryButtons(["pet"]);
			AppState.instance.selectedPet = selectedItem;
			AppState.instance.playingElements.addItem(AppState.instance.selectedPet);
			break;

		case ResourceType.FX:
			if (AppState.instance.categoryMode == null || AppState.instance.categoryMode == ResourceType.HERO)
			{
				categoryPanel.setSelectedCategoryButtons(["hero", "weapon", "mount", "fx"]);
				AppState.instance.selectedFX = selectedItem as FXElement;
				AppState.instance.playingElements.addItem(AppState.instance.selectedMount);
				AppState.instance.playingElements.addItem(AppState.instance.selectedHero);
				AppState.instance.playingElements.addItem(AppState.instance.selectedWeapon);
			}
			else if (AppState.instance.categoryMode == ResourceType.NPC)
			{
				categoryPanel.setSelectedCategoryButtons(["npc", "fx"]);
				AppState.instance.selectedFX = selectedItem as FXElement;
				AppState.instance.playingElements.addItem(AppState.instance.selectedNPC);
			}
			else if (AppState.instance.categoryMode == ResourceType.MOB)
			{
				categoryPanel.setSelectedCategoryButtons(["mob", "fx"]);
				AppState.instance.selectedFX = selectedItem as FXElement;
				AppState.instance.playingElements.addItem(AppState.instance.selectedMob);
			}

			if (AppState.instance.fxEnabled)
			{
				AppState.instance.playingElements.addItem(AppState.instance.selectedFX);
			}
			break;
	}

	if (selectedItem.type != ResourceType.UNKNOWN)
	{
		calculateActionList();
		calculateFrameRate();
		calculateAnchor();
	}
}

private function calculateActionList():void
{
	// 根据当前零件计算动作列表（最小公倍数）
	var actionInfo:ArrayCollection = AppState.instance.currentActionList;
	var actionNames:Array = [];

	actionInfo.removeAll();
	for each (var elem:Element in AppState.instance.playingElements)
	{
		if (!elem || (elem.type == ResourceType.FX && AppState.instance.categoryMode != ResourceType.FX))
		{
			continue;
		}

		for each (var action:Action in elem.actionList)
		{
			if (actionNames.indexOf(action.name) == -1)
			{
				actionInfo.addItem(action.info);
				actionNames[actionNames.length] = action.name;
			}
		}
	}

	if (actionNames.indexOf(AppState.instance.currentAction) == -1)
	{
		if (actionInfo.length > 0)
		{
			setAction(actionInfo[0]);
		}
		else if (AppState.instance.selectedFX && AppState.instance.selectedFX.fxAction && AppState.instance.playingElements.contains(AppState.instance.selectedFX))
		{
			setAction(AppState.instance.selectedFX.fxAction.info);
		}
	}
}

private function calculateFrameRate():void
{
	var frameRate:int = ImageResourceViewer.DEFAULT_FRAME_RATE;
	for each (var elem:Element in AppState.instance.playingElements)
	{
		var currentBatch:ResourceBatch = elem.getCurrentBatch();
		if (!currentBatch)
		{
			continue;
		}
		frameRate = elem.getCurrentBatch().frameRate;
		if (frameRate != ImageResourceViewer.DEFAULT_FRAME_RATE)
		{
			break;
		}
	}
	AppState.instance.frameRate = frameRate;
}

private function calculateAnchor():void
{
	var p:ArrayCollection = AppState.instance.playingElements;
	for each (var elem:Element in AppState.instance.playingElements)
	{
		if (!(elem is FXElement) && (elem.type != ResourceType.MOUNT) && (elem.name != "无")) // 有时坐骑会放在前面，要跳过
		{
			AppState.instance.anchor = elem.anchor;
			return;
		}
	}
}

public function setAction(info:ActionInfo):void
{
	AppState.instance.currentAction = info.name;
	AppState.instance.currentFrame = 0;
	AppState.instance.frameTotal = info.frameCount;
	updateActionAndDirection();
	calculateFrameRate();
}

public function setDirection(direction:String):void
{
	AppState.instance.currentDirection = direction;
	updateActionAndDirection();
}

private function updateActionAndDirection():void
{
	for each (var elem:Element in AppState.instance.playingElements)
	{
		if (!elem)
		{
			continue;
		}
		AppState.instance.playingElements.itemUpdated(elem);
	}
}

public function setFXVisibility(value:Boolean):void
{
	if (value != AppState.instance.fxEnabled)
	{
		AppState.instance.fxEnabled = value;
		if (value)
		{
			AppState.instance.playingElements.addItem(AppState.instance.selectedFX);
		}
		else
		{
			var index:int = AppState.instance.playingElements.getItemIndex(AppState.instance.selectedFX);
			if (index > -1)
			{
				AppState.instance.playingElements.removeItemAt(index);
			}
		}
	}
}

// 输出
public function writeSpritesheet():void
{
	var folderPath:File = File.desktopDirectory;
	folderPath.addEventListener(Event.SELECT, $writeSpritesheet);
	folderPath.browseForDirectory("选择输出目录");
}

private function $writeSpritesheet(event:Event):void
{
	var folder:File = event.currentTarget as File;

	for each (var typeName:String in ResourceType.typeList)
	{
		var category:ResourceCategory = ResourceLib.getCategory(typeName);
		if (category.elements.length > 1) // 至少有一个“无”
		{
			var path:File = folder.resolvePath(typeName);
			path.createDirectory();

			for each (var elem:Element in category.elements)
			{
				if (elem.name == "无")
				{
					continue;
				}

				var elemPath:File = path;
				if (!(elem is FXElement))
				{
					elemPath = path.resolvePath(elem.name);
					elemPath.createDirectory();
				}

				for each (var action:Action in elem.actionList)
				{
					new SpritesheetWriter().writeActionSpritesheet(action, elemPath, (elem.type != ResourceType.FX));
				}
			}
		}
	}
}

// 播放
public function play():void
{
	AppState.instance.playing = true;

	this.addEventListener(Event.ENTER_FRAME, $play);
}

private var lastFrameTime:int = int.MIN_VALUE;

private function $play(event:Event):void
{
	var l:int = AppState.instance.playingElements.length;
	var currentTime:int = getTimer();
	if (lastFrameTime == int.MIN_VALUE)
	{
		AppState.instance.currentFrame++;
		lastFrameTime = currentTime;
	}
	else
	{
		var delta:int = currentTime - lastFrameTime;
		var deltaRatio:Number = delta * AppState.instance.frameRate * 0.001;
		if (deltaRatio > .75)
		{
			lastFrameTime = currentTime;
			AppState.instance.currentFrame += Math.round(deltaRatio);
				//			trace("actual fps=" + (1000 / delta));
		}
	}
	AppState.instance.currentFrame %= AppState.instance.frameTotal;

	for (var i:int = 0; i < l; i++)
	{
		var itemRenderer:PlaybackItemRenderer = PlaybackItemRenderer(playbackPanel.layerDataGroup.getElementAt(i));
		if (!itemRenderer)
		{
			continue;
		}
		itemRenderer.player.gotoFrame(AppState.instance.currentFrame);
			// TODO: 特效帧数和动作帧数不一定一致，需要单独处理播放
	}

	playbackPanel.updateBackground();
}

public function gotoFrame(frame:int):void
{
	var l:int = playbackPanel.layerDataGroup.numElements;
	AppState.instance.currentFrame = frame % AppState.instance.frameTotal;

	for (var i:int = 0; i < l; i++)
	{
		PlaybackItemRenderer(playbackPanel.layerDataGroup.getElementAt(i)).player.gotoFrame(AppState.instance.currentFrame);
	}
}

public function stop():void
{
	AppState.instance.playing = false;
	AppState.instance.currentFrame = 0;

	var l:int = playbackPanel.layerDataGroup.numElements;
	for (var i:int = 0; i < l; i++)
	{
		PlaybackItemRenderer(playbackPanel.layerDataGroup.getElementAt(i)).player.gotoFrame(0);
	}

	this.removeEventListener(Event.ENTER_FRAME, $play);
}

public function togglePlay():void
{
	if (AppState.instance.playing)
	{
		stop();
	}
	else
	{
		play();
	}
}
