package statm.dev.npceditor.ui
{
	import mx.core.mx_internal;

	import spark.components.WindowedApplication;

	use namespace mx_internal;

	/**
	 * Metro 窗口。
	 *
	 * @author statm
	 *
	 */
	public class MetroChromeWindowedApplication extends WindowedApplication
	{
		public function MetroChromeWindowedApplication()
		{
			super();
		}

		private var titleBarProperties : Object = {};

		[ArrayElementType("mx.core.IVisualElement")]
		public function get titleBarContent() : Array
		{
			if (titleBar)
			{
				return MetroTitleBar(titleBar).titleBarContent;
			}
			else
			{
				return titleBarProperties.titleBarContent;
			}
		}

		public function set titleBarContent(value : Array) : void
		{
			if (titleBar)
			{
				MetroTitleBar(titleBar).titleBarContent = value;
			}
			else
			{
				titleBarProperties.titleBarContent = value;
			}

			invalidateSkinState();
		}

		override protected function partAdded(partName : String, instance : Object) : void
		{
			super.partAdded(partName, instance);

			if (instance == titleBar)
			{
				titleBarProperties.titleBarContent && (MetroTitleBar(titleBar).titleBarContent = titleBarProperties.titleBarContent);
			}
		}

		override protected function partRemoved(partName : String, instance : Object) : void
		{
			super.partRemoved(partName, instance);

			if (instance == titleBar)
			{
				MetroTitleBar(titleBar).titleBarContent = null;
				titleBarProperties = {};
			}
		}
	}
}
