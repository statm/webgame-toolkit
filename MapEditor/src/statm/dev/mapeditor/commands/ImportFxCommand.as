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
     * 命令：导入特效。
     *
     * @author statm
     *
     */
    public class ImportFxCommand extends SimpleCommand
    {
        public function ImportFxCommand()
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
				
				map.itemDefinitionList.importFxXML(fileXML);
			});
			
			fileToOpen.browseForOpen("打开特效数据文件", [ new FileFilter("特效数据(*.xml)", "*.xml")]);
        }
    }
}
