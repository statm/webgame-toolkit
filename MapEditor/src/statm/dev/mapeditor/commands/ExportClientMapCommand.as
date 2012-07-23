package statm.dev.mapeditor.commands
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.controls.Alert;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	import statm.dev.mapeditor.app.AppState;
	import statm.dev.mapeditor.dom.Map;
	import statm.dev.mapeditor.io.ClientWriter;
	import statm.dev.mapeditor.io.ServerWriter;
	
	
	/**
	 * 命令：导出客户端文件。
	 *
	 * @author renjie.zh
	 *
	 */
	public class ExportClientMapCommand extends SimpleCommand
	{
		public function ExportClientMapCommand()
		{
			super();
		}
		
		override public function execute(notification : INotification) : void
		{
			var map : Map = AppState.getCurrentMap();
			if (!map)
			{
				return;
			}
			
			var fileToSave : File = new File();
			var now : Date = new Date();
			var fileName : String = map.mapName + "_"
				+ now.fullYear
				+ padLeft((now.month + 1).toString(), '0', 2)
				+ padLeft(now.date.toString(), '0', 2)
				+ "_"
				+ padLeft(now.hours.toString(), '0', 2)
				+ padLeft(now.minutes.toString(), '0', 2)
				+ padLeft(now.seconds.toString(), '0', 2)
				+ "_C.xml";
			
			var writer : ClientWriter = new ClientWriter();
			writer.read(map);
			var mapXML : XML = writer.flush();
			
			var fileStream : FileStream = new FileStream();
			
			fileToSave.addEventListener(Event.COMPLETE, function(event : Event) : void
			{
				fileStream.open(fileToSave, FileMode.WRITE);
				fileStream.writeMultiByte('<?xml version="1.0" encoding="utf-8"?>\n'
					+ mapXML.toXMLString(), "utf-8");
				fileStream.close();
			});
			
			fileToSave.addEventListener(IOErrorEvent.IO_ERROR, function(event : IOErrorEvent) : void
			{
				Alert.show("文件保存失败");
			});
			
			fileToSave.save("", fileName);
		}
		
		private function padLeft(str : String, padChar : String, length : int) : String
		{
			if (str.length >= length)
			{
				return str;
			}
			
			var result : String = str;
			
			while (result.length < length)
			{
				result = padChar + result;
			}
			
			return result;
		}
	}
}
