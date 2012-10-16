package statm.dev.npceditor.dom.objects
{
	import flash.display.BitmapData;
	import flash.filters.GlowFilter;

	import spark.components.Image;
	import spark.primitives.BitmapImage;

	import statm.dev.npceditor.dom.DomNode;
	import statm.dev.npceditor.dom.DomObject;


	/**
	 * 物件基类。
	 *
	 * @author statm
	 *
	 */
	public class Item extends DomObject
	{
		public function Item(root : DomNode)
		{
			super(root);
			_name = "物件";
			display = _iconImage;
		}

		protected var _iconImage : Image = new Image();

		public function get iconImage() : Image
		{
			return _iconImage;
		}
	}
}
