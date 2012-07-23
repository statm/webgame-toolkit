package statm.dev.mapeditor.commands
{
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	import statm.dev.mapeditor.app.AppNotificationCode;
	import statm.dev.mapeditor.app.AppState;
	import statm.dev.mapeditor.dom.Map;


	/**
	 * 命令：创建新地图。
	 *
	 * @author renjie.zh
	 *
	 */
	public class CreateMapFileCommand extends SimpleCommand
	{
		public function CreateMapFileCommand()
		{
			super();
		}

		override public function execute(notification : INotification) : void
		{
			var mapData : Map = AppState.getCurrentMap();

			if (mapData)
			{
				sendNotification(AppNotificationCode.CLOSE_MAP_FILE, {next: [AppNotificationCode.CREATE_MAP_FILE]});
				return;
			}

			var newMap : Map = new Map();
			AppState.setCurrentMap(newMap);
			sendNotification(AppNotificationCode.MAP_DATA_READY);
		}
	}
}
