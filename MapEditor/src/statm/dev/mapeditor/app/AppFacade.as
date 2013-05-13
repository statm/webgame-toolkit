package statm.dev.mapeditor.app
{
    import org.puremvc.as3.interfaces.IFacade;
    import org.puremvc.as3.patterns.facade.Facade;
    
    import statm.dev.mapeditor.commands.AppExitCommand;
    import statm.dev.mapeditor.commands.CloseMapFileCommand;
    import statm.dev.mapeditor.commands.CreateMapFileCommand;
    import statm.dev.mapeditor.commands.ExportXMLCommand;
    import statm.dev.mapeditor.commands.ImportDecorationCommand;
    import statm.dev.mapeditor.commands.ImportFxCommand;
    import statm.dev.mapeditor.commands.ImportMineralCommand;
    import statm.dev.mapeditor.commands.ImportMobCommand;
    import statm.dev.mapeditor.commands.ImportNPCCommand;
    import statm.dev.mapeditor.commands.OpenMapFileCommand;
    import statm.dev.mapeditor.commands.SaveMapFileCommand;


    /**
     * 应用程序 Facade。
     *
     * @author statm
     *
     */
    public class AppFacade extends Facade
    {
        public function AppFacade()
        {
            super();
        }

        public static function getInstance():IFacade
        {
            if (!instance)
            {
                instance = new AppFacade();
            }

            return instance;
        }

        override protected function initializeController():void
        {
            super.initializeController();

            this.registerCommand(AppNotificationCode.CREATE_MAP_FILE, CreateMapFileCommand);
            this.registerCommand(AppNotificationCode.BROWSE_MAP_FILE, OpenMapFileCommand);
            this.registerCommand(AppNotificationCode.SAVE_MAP_FILE, SaveMapFileCommand);
            this.registerCommand(AppNotificationCode.CLOSE_MAP_FILE, CloseMapFileCommand);
            this.registerCommand(AppNotificationCode.CLOSE_APP, AppExitCommand);
            this.registerCommand(AppNotificationCode.EXPORT_XML, ExportXMLCommand);
            this.registerCommand(AppNotificationCode.IMPORT_NPC, ImportNPCCommand);
            this.registerCommand(AppNotificationCode.IMPORT_MOB, ImportMobCommand);
            this.registerCommand(AppNotificationCode.IMPORT_MINERAL, ImportMineralCommand);
            this.registerCommand(AppNotificationCode.IMPORT_FX, ImportFxCommand);
			this.registerCommand(AppNotificationCode.IMPORT_DECORATION, ImportDecorationCommand);
        }
    }
}
