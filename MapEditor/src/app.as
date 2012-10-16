import flash.desktop.NativeApplication;
import flash.display.NativeWindowDisplayState;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.NativeWindowDisplayStateEvent;
import flash.text.engine.TextLine;
import flash.ui.Keyboard;

import mx.events.FlexEvent;
import mx.managers.IFocusManagerComponent;

import spark.components.Label;
import spark.components.RichEditableText;
import spark.components.TextInput;

import air.update.ApplicationUpdaterUI;
import air.update.events.StatusUpdateErrorEvent;
import air.update.events.UpdateEvent;

import statm.dev.mapeditor.app.AppFacade;
import statm.dev.mapeditor.app.AppNotificationCode;
import statm.dev.mapeditor.app.AppState;
import statm.dev.mapeditor.dom.DomNode;
import statm.dev.mapeditor.dom.DomObject;
import statm.dev.mapeditor.dom.layers.PlacementLayerBase;
import statm.dev.mapeditor.dom.objects.LinkDestPoint;
import statm.dev.mapeditor.dom.objects.LinkPoint;

public static var VERSION : String;

private function init() : void
{
	var appXML:XML = NativeApplication.nativeApplication.applicationDescriptor;
	var appNS:Namespace = appXML.namespace();
	VERSION = appXML.appNS::versionNumber[0];
	
//	stage.nativeWindow.maximize();
	
	stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
	stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
	stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
	
	XML.prettyPrinting = true;
	XML.prettyIndent = 4;
	
	checkUpdate();
}

// 版本/升级
private var appUpdater : ApplicationUpdaterUI = new ApplicationUpdaterUI();

private function checkUpdate() : void
{
	appUpdater.updateURL = "http://www.sdgs.com/fol/tools/MapEditor/update.xml";
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

private var isMouseDown : Boolean = false;

override protected function mouseDownHandler(event : MouseEvent) : void
{
	super.mouseDownHandler(event);
	
	if (!(event.target is IFocusManagerComponent)
		&& !(event.target is Label)
		&& !(event.target is TextLine))
	{
		stage.focus = null;
	}
	
	isMouseDown = true;
}

protected function mouseUpHandler(event : MouseEvent) : void
{
	isMouseDown = false;
}

override protected function keyDownHandler(event : KeyboardEvent) : void
{
	super.keyDownHandler(event);
	
	if (event.keyCode == Keyboard.SPACE
		&& !(stage.focus is TextInput)
		&& !(AppState.isDrawingMask() && isMouseDown))
	{
		AppState.startMovingViewport();
	}
	else if (event.keyCode == Keyboard.CONTROL)
	{
		AppState.startMovingGrid();
	}
}

override protected function keyUpHandler(event : KeyboardEvent) : void
{
	super.keyUpHandler(event);
	
	if (event.keyCode == Keyboard.SPACE && !isMouseDown)
	{
		AppState.stopMovingViewport();
	}
	else if (event.keyCode == Keyboard.CONTROL && !isMouseDown)
	{
		AppState.stopMovingGrid();
	}
	else if (event.keyCode == Keyboard.DELETE)
	{
		if (!(stage.focus
			&& (stage.focus is TextInput || stage.focus is TextLine || stage.focus is RichEditableText)))
		{
			var selection : DomNode = AppState.getCurrentSelection();
			
			if (!selection)
			{
				return;
			}
			
			if (selection is LinkDestPoint)
			{
				LinkPoint(selection.parent).removeLinkDestination(LinkDestPoint(selection));
			}
			else if (selection is DomObject)
			{
				PlacementLayerBase(DomObject(selection).parent).removeItem(DomObject(selection));
			}
			
			AppState.setCurrentSelection(selection.parent);
		}
	}
	else if (event.keyCode == Keyboard.MINUS
		&& event.controlKey)
	{
		mapArea.scaleX -= .1;
		mapArea.scaleY -= .1;
	}
	else if (event.keyCode == Keyboard.EQUAL
		&& event.controlKey)
	{
		mapArea.scaleX += .1;
		mapArea.scaleY += .1;
	}
	else if (event.keyCode == Keyboard.NUMBER_0
		&& event.controlKey)
	{
		mapArea.scaleX = mapArea.scaleY = 1.0;
	}
}

private function closingHandler(event : Event) : void
{
	event.preventDefault();
	AppFacade.getInstance().sendNotification(AppNotificationCode.CLOSE_APP);
}

private var panelsHidden : Boolean = false;

private function togglePanels() : void
{
	panelToggleAnimation.stop();
	
	if (panelsHidden)
	{
		panelToggleAnimation.widthTo = 350;
	}
	else
	{
		panelToggleAnimation.widthTo = 0;
	}
	
	panelsHidden = !panelsHidden;
	panelToggleAnimation.play();
}