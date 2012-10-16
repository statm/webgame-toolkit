package statm.dev.npceditor.app
{
	import org.puremvc.as3.interfaces.IFacade;
	import org.puremvc.as3.patterns.facade.Facade;


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

			// this.registerCommand(...);
		}
	}
}
