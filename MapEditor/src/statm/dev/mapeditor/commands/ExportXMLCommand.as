package statm.dev.mapeditor.commands
{
    import flash.events.Event;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;

    import mx.controls.Alert;
    import mx.utils.UIDUtil;

    import org.puremvc.as3.interfaces.INotification;
    import org.puremvc.as3.patterns.command.SimpleCommand;

    import statm.dev.mapeditor.app.AppState;
    import statm.dev.mapeditor.dom.Map;
    import statm.dev.mapeditor.io.ClientLinkPointWriter;
    import statm.dev.mapeditor.io.ClientMapWriter;
    import statm.dev.mapeditor.io.ServerWriter;


    /**
     * 命令：导出 XML 数据文件。
     *
     * @author statm
     *
     */
    public class ExportXMLCommand extends SimpleCommand
    {
        public function ExportXMLCommand()
        {
            super();
        }

        private var clientMapWriter:ClientMapWriter;

        private var clientLinkPointWriter:ClientLinkPointWriter;

        private var serverWriter:ServerWriter;

        override public function execute(notification:INotification):void
        {
            var map:Map = AppState.getCurrentMap();
            if (!map)
            {
                return;
            }

            var dirToSave:File = File.desktopDirectory;
            dirToSave.addEventListener(Event.SELECT, dir_selectHandler);
            dirToSave.browseForDirectory("选择输出目录");
        }

        private function dir_selectHandler(event:Event):void
        {
            AppState.xmlUID = UIDUtil.createUID();

            var dir:File = File(event.currentTarget);

            writeClientMapFile(dir.resolvePath("./客户端/"));
            writeClientLinkPointFile(dir.resolvePath("./客户端/"));
            writeServerFile(dir.resolvePath("./服务端/"));

            var log:String = clientMapWriter.getLog() + "\n\n" + serverWriter.getLog();
            Alert.show("导出完成。\n日志:\n" + log);
        }

        private function writeClientMapFile(dir:File):void
        {
            var map:Map = AppState.getCurrentMap();
            if (!map)
            {
                return;
            }

            clientMapWriter = new ClientMapWriter();
            clientMapWriter.read(map);
            try
            {
                var fileContent:String = '<?xml version="1.0" encoding="utf-8"?>\n' + clientMapWriter.flush().toXMLString();
            }
            catch (e:Error)
            {
                Alert.show("导出失败");
                return;
            }

            var fileName:String = "Map" + map.mapID + ".xml";

            var fileStream:FileStream = new FileStream();
            fileStream.open(dir.resolvePath(fileName), FileMode.WRITE);
            fileStream.writeMultiByte(fileContent, "utf-8");
            fileStream.close();
        }

        private function writeClientLinkPointFile(dir:File):void
        {
            var map:Map = AppState.getCurrentMap();
            if (!map)
            {
                return;
            }

            clientLinkPointWriter = new ClientLinkPointWriter();
            clientLinkPointWriter.read(map);
            try
            {
                var fileContent:String = '<?xml version="1.0" encoding="utf-8"?>\n' + clientLinkPointWriter.flush().toXMLString();
            }
            catch (e:Error)
            {
                Alert.show("导出失败");
                return;
            }

            var fileName:String = "LinkPointConfig" + map.mapID + ".xml";

            var fileStream:FileStream = new FileStream();
            fileStream.open(dir.resolvePath(fileName), FileMode.WRITE);
            fileStream.writeMultiByte(fileContent, "utf-8");
            fileStream.close();
        }

        private function writeServerFile(dir:File):void
        {
            var map:Map = AppState.getCurrentMap();
            if (!map)
            {
                return;
            }

            serverWriter = new ServerWriter();
            serverWriter.read(map);
            try
            {
                var fileContent:String = '<?xml version="1.0" encoding="utf-8"?>\n' + serverWriter.flush().toXMLString();
            }
            catch (e:Error)
            {
                Alert.show("导出失败");
                return;
            }

            var fileName:String = map.mapName + map.mapID + ".xml";

            var fileStream:FileStream = new FileStream();
            fileStream.open(dir.resolvePath(fileName), FileMode.WRITE);
            fileStream.writeMultiByte(fileContent, "utf-8");
            fileStream.close();
        }
    }
}
