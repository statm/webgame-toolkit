package statm.dev.mapeditor.commands
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.setTimeout;
	
	import mx.controls.Alert;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	import statm.dev.mapeditor.app.AppNotificationCode;
	import statm.dev.mapeditor.app.AppState;
	import statm.dev.mapeditor.dom.Map;
	import statm.dev.mapeditor.utils.MapFileUtils;


	/**
	 * 命令：保存地图文件。
	 *
	 * @author statm
	 *
	 */
	public class SaveMapFileCommand extends SimpleCommand
	{
		public function SaveMapFileCommand()
		{
			super();
		}

		override public function execute(notification:INotification):void
		{
			var map:Map = AppState.getCurrentMap();

			if (!map)
			{
				return;
			}

			var fileToSave:File = new File();
			var fileName:String;
			var fileNameBody:String;
			var mapImageFile:File;

			var overwrite:Boolean;

			// 确定文件名
			if (map.filePath)
			{
				fileToSave.nativePath = map.filePath;
				fileName = fileToSave.name;
				fileNameBody = fileToSave.name.split(".")[0];
				overwrite = true;
			}
			else
			{
				fileToSave = File.desktopDirectory;
				fileName = map.mapName + ".xml";
				overwrite = false;
			}

			// 确定是否有图片文件
			if (map.bgLayer.bgPath)
			{
				mapImageFile = new File(map.bgLayer.bgPath);
			}

			try
			{
				var mapXML:XML = MapFileUtils.mapToXML(map);
			}
			catch (e:Error)
			{
				Alert.show("保存失败");
				return;
			}
			var fileStream:FileStream = new FileStream();

			if (overwrite)
			{
				fileStream.open(fileToSave, FileMode.WRITE);
				fileStream.writeMultiByte(mapXML.toXMLString(), "utf-8");
				fileStream.close();

				map.filePath = fileToSave.nativePath;
				if (mapImageFile)
				{
					var newImageFile:File = fileToSave.resolvePath(".." + File.separator + fileNameBody + "." + mapImageFile.extension);
					if (mapImageFile.nativePath != newImageFile.nativePath)
					{
						mapImageFile.copyTo(newImageFile, true);
					}
				}

				sendNotification(AppNotificationCode.MAP_FILE_SAVED);

				if (notification.getBody())
				{
					var actionStack:Array = notification.getBody().next;
					if (actionStack && actionStack.length > 0)
					{
						setTimeout(function():void
						{
							sendNotification(actionStack.pop(), {next: actionStack});
						}, 0);
					}
				}
			}
			else
			{
				// 确定保存的后续动作
				fileToSave.addEventListener(Event.COMPLETE, function(event:Event):void
				{
					fileStream.open(fileToSave, FileMode.WRITE);
					fileStream.writeMultiByte(mapXML.toXMLString(), "utf-8");
					fileStream.close();

					map.filePath = fileToSave.nativePath;

					fileNameBody = fileToSave.name.split(".")[0];
					if (mapImageFile)
					{
						mapImageFile.copyTo(fileToSave.resolvePath(".." + File.separator + fileNameBody + "." + mapImageFile.extension), true);
					}

					sendNotification(AppNotificationCode.MAP_FILE_SAVED);

					if (notification.getBody())
					{
						var actionStack:Array = notification.getBody().next;
						if (actionStack && actionStack.length > 0)
						{
							setTimeout(function():void
							{
								sendNotification(actionStack.pop(), {next: actionStack});
							}, 0);
						}
					}
				});

				fileToSave.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void
				{
					Alert.show("文件保存失败");
				});

				// 先取到合适的文件名
				// 这里要进行两次写入，实际的写入在 COMPLETE 里完成，是用 FileStream 同步做的
				// AIR 的 API 不完善导致文件保存流程很差
				fileToSave.save("", fileName);
			}
		}
	}
}
