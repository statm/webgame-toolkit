package statm.dev.mapeditor.commands
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	import statm.dev.mapeditor.app.AppState;
	import statm.dev.mapeditor.dom.Map;

	/**
	 * 命令：导入 NPC 数据。
	 *
	 * @author statm
	 *
	 */
	public class ImportNPCCommand extends SimpleCommand
	{
		public function ImportNPCCommand()
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
			
			var fileToOpen:File = File.desktopDirectory;
			fileToOpen.addEventListener(Event.SELECT, function(event:Event):void
			{
				var fileStream:FileStream = new FileStream();
				fileStream.open(fileToOpen, FileMode.READ);
				
				var fileXML:XML = new XML(fileStream.readMultiByte(fileStream.bytesAvailable, "utf-8"));
				fileStream.close();
				
				map.itemDefinitionList.importNPCXML(fileXML);
			});
			
			fileToOpen.browseForOpen("打开NPC数据文件", [new FileFilter("NPC数据(*.xml)", "*.xml")]);
		}
	}
}
