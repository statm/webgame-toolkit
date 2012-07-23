package statm.dev.mapeditor.app
{
	import org.puremvc.as3.interfaces.IFacade;
	import org.puremvc.as3.patterns.facade.Facade;
	
	import statm.dev.mapeditor.commands.AppExitCommand;
	import statm.dev.mapeditor.commands.BrowseMapFileCommand;
	import statm.dev.mapeditor.commands.CloseMapFileCommand;
	import statm.dev.mapeditor.commands.CreateMapFileCommand;
	import statm.dev.mapeditor.commands.ExportClientMapCommand;
	import statm.dev.mapeditor.commands.ExportServerMapCommand;
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

		public static function getInstance() : IFacade
		{
			if (!instance)
			{
				instance = new AppFacade();
			}

			return instance;
		}

		override protected function initializeController() : void
		{
			super.initializeController();

			this.registerCommand(AppNotificationCode.CREATE_MAP_FILE, CreateMapFileCommand);
			this.registerCommand(AppNotificationCode.BROWSE_MAP_FILE, BrowseMapFileCommand);
			this.registerCommand(AppNotificationCode.SAVE_MAP_FILE, SaveMapFileCommand);
			this.registerCommand(AppNotificationCode.CLOSE_MAP_FILE, CloseMapFileCommand);
			this.registerCommand(AppNotificationCode.CLOSE_APP, AppExitCommand);
			this.registerCommand(AppNotificationCode.EXPORT_SERVER_MAP, ExportServerMapCommand);
			this.registerCommand(AppNotificationCode.EXPORT_CLIENT_MAP, ExportClientMapCommand);
		}
	}
}
