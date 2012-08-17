package statm.dev.scale9gridviewer
{
	import flash.filesystem.File;
	import flash.geom.Point;

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
		public static var fileList : ArrayCollection;

		[Bindable]
		public static var currentFile : File;

		[Bindable]
		public static var scalingCenter : Point;
	}
}
