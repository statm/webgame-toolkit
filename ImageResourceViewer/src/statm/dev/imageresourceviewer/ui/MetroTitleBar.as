package statm.dev.imageresourceviewer.ui
{
	import flash.events.MouseEvent;
	
	import mx.core.mx_internal;
	
	import spark.components.Group;
	import spark.components.windowClasses.TitleBar;

	use namespace mx_internal;

	[DefaultProperty("titleBarContent")]
	/**
	 * Metro 标题栏。
	 *
	 * @author statm
	 *
	 */
	public class MetroTitleBar extends TitleBar
	{
		public function MetroTitleBar()
		{
			super();
		}

		[SkinPart(required = "false")]
		public var titleBarGroup : Group;

		private var titleBarGroupProperties : Object = {};

		[ArrayElementType("mx.core.IVisualElement")]
		public function get titleBarContent() : Array
		{
			if (titleBarGroup)
			{
				return titleBarGroup.getMXMLContent();
			}
			else
			{
				return titleBarGroupProperties.titleBarContent;
			}
		}

		public function set titleBarContent(value : Array) : void
		{
			if (titleBarGroup)
			{
				titleBarGroup.mxmlContent = value;
				titleBarGroupProperties.titleBarContent = null;
				delete titleBarGroupProperties["titleBarContent"];
			}
			else
			{
				titleBarGroupProperties.titleBarContent = value;
			}

			invalidateSkinState();
		}

		override protected function partAdded(partName : String, instance : Object) : void
		{
			super.partAdded(partName, instance);

			if (instance == titleBarGroup)
			{
				titleBarGroupProperties.titleBarContent && (titleBarGroup.mxmlContent = titleBarGroupProperties.titleBarContent);
				titleBarGroup.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			}
		}

		override protected function partRemoved(partName : String, instance : Object) : void
		{
			super.partRemoved(partName, instance);

			if (instance == titleBarGroup)
			{
				titleBarGroup.mxmlContent = null;
				titleBarGroupProperties = {};
				titleBarGroup.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			}
		}

		private function mouseDownHandler(event : MouseEvent) : void
		{
			event.stopPropagation();
		}
	}
}
