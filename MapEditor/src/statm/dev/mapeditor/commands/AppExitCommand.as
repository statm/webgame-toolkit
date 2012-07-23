package statm.dev.mapeditor.commands
{
	import mx.core.FlexGlobals;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	import statm.dev.mapeditor.app.AppNotificationCode;
	import statm.dev.mapeditor.app.AppState;
	import statm.dev.mapeditor.dom.Map;


	/**
	 * 命令：关闭程序。
	 *
	 * @author statm
	 *
	 */
	public class AppExitCommand extends SimpleCommand
	{
		public function AppExitCommand()
		{
			super();
		}

		override public function execute(notification : INotification) : void
		{
			var map : Map = AppState.getCurrentMap();
			
			if (map)
			{
				sendNotification(AppNotificationCode.CLOSE_MAP_FILE, {next: [AppNotificationCode.CLOSE_APP]});
				return;
			}
			
			FlexGlobals.topLevelApplication.exit();
		}
	}
}
