package statm.dev.mapeditor.ui
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.utils.Dictionary;

	/**
	 * 各种鼠标指针。
	 *
	 * @author renjie.zh
	 *
	 */
	[Mixin]
	public class MouseCursors
	{
		[Embed(source = "../../../../assets/ui/select.png")]
		public static var SELECT : Class;

		[Embed(source = "../../../../assets/ui/hand.png")]
		public static var HAND : Class;

		[Embed(source = "../../../../assets/ui/erase.png")]
		public static var ERASE : Class;

		[Embed(source = "../../../../assets/ui/brush.png")]
		public static var BRUSH : Class;

		[Embed(source = "../../../../assets/ui/move.png")]
		public static var MOVE : Class;


		private static var offsets : Dictionary;

		public static function init(root : DisplayObject) : void
		{
			offsets = new Dictionary();
			offsets[SELECT] = new Point(-7, 0);
			offsets[HAND] = new Point(-7, 0);
			offsets[ERASE] = new Point(-7, 0);
			offsets[BRUSH] = new Point(-7, 0);
			offsets[MOVE] = new Point(-7, 0);
		}

		public static function getOffset(cursorClass : Class) : Point
		{
			return offsets[cursorClass] as Point;
		}
	}
}
