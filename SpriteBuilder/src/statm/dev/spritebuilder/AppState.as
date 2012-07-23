package statm.dev.spritebuilder
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	import mx.collections.ArrayCollection;

	/**
	 * 应用程序状态。
	 *
	 * @author statm
	 *
	 */
	public class AppState
	{
		[Bindable]
		public static var files : ArrayCollection;

		public static var originalBitmaps : Vector.<BitmapData>;

		public static var originalBitmapBounds : Vector.<Rectangle>;

		public static var croppedBitmaps : Vector.<BitmapData>;

		public static function reset() : void
		{
			files = null;
			originalBitmaps = null;
			originalBitmapBounds = null;
			croppedBitmaps = null;
		}
	}
}
