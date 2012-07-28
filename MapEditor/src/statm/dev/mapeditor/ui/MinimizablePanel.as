package statm.dev.mapeditor.ui
{
	import flash.events.MouseEvent;

	import spark.components.Group;
	import spark.components.Panel;
	import spark.effects.Resize;

	import statm.dev.mapeditor.ui.skins.MinimizablePanelSkin;


	/**
	 * 可最小化的面板。
	 *
	 * @author statm
	 *
	 */
	public class MinimizablePanel extends Panel
	{
		[SkinPart(required = "true")]
		public var topGroup : Group;

		public function MinimizablePanel()
		{
			super();
			this.percentWidth = 100;
			this.setStyle("dropShadowVisible", false);
			this.setStyle("skinClass", MinimizablePanelSkin);
		}

		override protected function partAdded(partName : String, instance : Object) : void
		{
			super.partAdded(partName, instance);

			if (instance == topGroup)
			{
				topGroup.addEventListener(MouseEvent.CLICK, topGroup_clickHandler);
			}
		}

		override protected function partRemoved(partName : String, instance : Object) : void
		{
			super.partRemoved(partName, instance);

			if (instance == topGroup)
			{
				topGroup.removeEventListener(MouseEvent.CLICK, topGroup_clickHandler);
			}
		}

		private var minimized : Boolean = false;

		private var oldHeight : Number;

		private function topGroup_clickHandler(event : MouseEvent) : void
		{
			minimized = !minimized;
			contentGroup.visible = !minimized;

			if (minimized)
			{
				oldHeight = this.height;
				this.height = 22;
			}
			else
			{
				this.height = oldHeight;
			}
		}
	}
}
