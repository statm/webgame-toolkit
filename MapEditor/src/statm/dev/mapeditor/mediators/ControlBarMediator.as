package statm.dev.mapeditor.mediators
{
	import flash.events.MouseEvent;

	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	import spark.components.Button;

	import statm.dev.mapeditor.app.AppNotificationCode;
	import statm.dev.mapeditor.app.AppState;
	import statm.dev.mapeditor.dom.Map;


	/**
	 * 菜单条 Mediator，同时控制窗口标题。
	 *
	 * @author statm
	 *
	 */
	public class ControlBarMediator extends Mediator
	{
		public static const NAME : String = "ControlBarMediator";

		public function ControlBarMediator(mediatorName : String = null, viewComponent : Object = null)
		{
			super(mediatorName, viewComponent);

			Button(viewComponent.btnNewMapFile).addEventListener(MouseEvent.CLICK, btnNewMapFile_clickHandler);
			Button(viewComponent.btnBrowseMapFile).addEventListener(MouseEvent.CLICK, btnBrowseMapFile_clickHandler);
			Button(viewComponent.btnSaveMapFile).addEventListener(MouseEvent.CLICK, btnSaveMapFile_clickHandler);
			Button(viewComponent.btnCloseMapFile).addEventListener(MouseEvent.CLICK, btnCloseMapFile_clickHandler);
			Button(viewComponent.btnExportXML).addEventListener(MouseEvent.CLICK, btnExportXML_clickHandler);
		}


		override public function listNotificationInterests() : Array
		{
			return [AppNotificationCode.MAP_DATA_READY,
				AppNotificationCode.MAP_FILE_SAVED,
				AppNotificationCode.MAP_DATA_CHANGED,
				AppNotificationCode.MAP_FILE_CLOSED
				];
		}

		override public function handleNotification(notification : INotification) : void
		{
			var map : Map = AppState.getCurrentMap();

			if (!map)
			{
				setWindowTitle(null);
				return;
			}

			switch (notification.getName())
			{
				case AppNotificationCode.MAP_DATA_READY:
				case AppNotificationCode.MAP_FILE_SAVED:
					map.setDirty(false);
					break;

				case AppNotificationCode.MAP_DATA_CHANGED:
					map.setDirty(true);
					break;
			}

			setWindowTitle(map);
		}

		private function btnNewMapFile_clickHandler(event : MouseEvent) : void
		{
			sendNotification(AppNotificationCode.CREATE_MAP_FILE);
		}

		private function btnBrowseMapFile_clickHandler(event : MouseEvent) : void
		{
			sendNotification(AppNotificationCode.BROWSE_MAP_FILE);
		}

		private function btnSaveMapFile_clickHandler(event : MouseEvent) : void
		{
			sendNotification(AppNotificationCode.SAVE_MAP_FILE);
		}

		private function btnCloseMapFile_clickHandler(event : MouseEvent) : void
		{
			sendNotification(AppNotificationCode.CLOSE_MAP_FILE);
		}

		private function btnExportXML_clickHandler(event : MouseEvent) : void
		{
			sendNotification(AppNotificationCode.EXPORT_XML);
		}

		private function setWindowTitle(map : Map = null) : void
		{
			var title : String = "";

			if (map)
			{
				title += (map.isDirty ? "*" : "");
				title += (map.filePath ? map.filePath : (map.mapName + ".xml"));
				title += " - 地图编辑器";
			}
			else
			{
				title = "地图编辑器";
			}

			viewComponent.stage.nativeWindow.title = title;
		}
	}
}
