package statm.dev.mapeditor.commands
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;

	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	import statm.dev.mapeditor.app.AppNotificationCode;
	import statm.dev.mapeditor.app.AppState;
	import statm.dev.mapeditor.dom.Map;
	import statm.dev.mapeditor.utils.MapFileUtils;


	/**
	 * 命令：浏览打开地图文件。
	 *
	 * @author statm
	 *
	 */
	public class OpenMapFileCommand extends SimpleCommand
	{
		public function OpenMapFileCommand()
		{
			super();
		}

		override public function execute(notification : INotification) : void
		{
			var map : Map = AppState.getCurrentMap();

			if (map && map.isDirty)
			{
				sendNotification(AppNotificationCode.CLOSE_MAP_FILE, {next: [AppNotificationCode.BROWSE_MAP_FILE]});
				return;
			}

			var fileToOpen : File = File.desktopDirectory;
			fileToOpen.addEventListener(Event.SELECT, function(event : Event) : void
			{
				if (map)
				{
					sendNotification(AppNotificationCode.CLOSE_MAP_FILE);
				}

				var fileStream : FileStream = new FileStream();
				fileStream.open(fileToOpen, FileMode.READ);

				var fileXML : XML = new XML(fileStream.readMultiByte(fileStream.bytesAvailable, "utf-8"));
				var map : Map = new Map();
				map.filePath = fileToOpen.nativePath;
				MapFileUtils.XMLToMap(fileXML, map);

				fileStream.close();

				AppState.setCurrentMap(map);
				sendNotification(AppNotificationCode.MAP_DATA_READY);
			});

			fileToOpen.browseForOpen("打开地图文件", [new FileFilter("地图文件(*.xml)", "*.xml")]);
		}
	}
}
