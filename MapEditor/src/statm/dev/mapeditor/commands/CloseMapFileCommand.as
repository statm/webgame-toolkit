package statm.dev.mapeditor.commands
{
	import flash.filesystem.File;
	import flash.utils.setTimeout;
	
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	import statm.dev.mapeditor.app.AppNotificationCode;
	import statm.dev.mapeditor.app.AppState;
	import statm.dev.mapeditor.dom.Map;


	/**
	 * 命令：关闭地图文件。
	 *
	 * @author renjie.zh
	 *
	 */
	public class CloseMapFileCommand extends SimpleCommand
	{
		public function CloseMapFileCommand()
		{
			super();
		}

		private var actionStack : Array = [];

		override public function execute(notification : INotification) : void
		{
			var map : Map = AppState.getCurrentMap();

			if (!map)
			{
				return;
			}

			if (notification.getBody())
			{
				actionStack = notification.getBody().next;
				actionStack || (actionStack = []);
			}

			if (map.isDirty)
			{
				var fileName : String = map.mapName + ".map";
				if (map.filePath)
				{
					var file:File = new File(map.filePath);
					fileName = file.name;
				}
				Alert.show("您要将更改保存到 " + fileName + " 吗？", "地图编辑器", Alert.YES | Alert.NO, null, confirmHandler);
			}
			else
			{
				AppState.setCurrentMap(null);
				sendNotification(AppNotificationCode.MAP_FILE_CLOSED);
				if (actionStack.length > 0)
				{
					setTimeout(function() : void
					{
						sendNotification(actionStack.pop(), {next: actionStack});
					}, 0);
				}
			}
		}

		private function confirmHandler(event : CloseEvent) : void
		{
			if (event.detail == Alert.YES)
			{
				actionStack.push(AppNotificationCode.CLOSE_MAP_FILE);
				sendNotification(AppNotificationCode.SAVE_MAP_FILE, {next: actionStack});
			}
			else // event.detail == Alert.NO
			{
				AppState.setCurrentMap(null);
				sendNotification(AppNotificationCode.MAP_FILE_CLOSED);
				if (actionStack.length > 0)
				{
					setTimeout(function() : void
					{
						sendNotification(actionStack.pop(), {next: actionStack});
					}, 0);
				}
			}
		}
	}
}
