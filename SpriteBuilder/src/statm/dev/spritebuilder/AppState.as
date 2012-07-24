package statm.dev.spritebuilder
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.filesystem.File;
	import flash.geom.Point;
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
		// 文件
		[Bindable]
		public static var files : ArrayCollection;

		public static var folder : File;

		[Bindable]
		public static var fileCount : int;

		// 位图存储，切割流程
		public static var originalBitmaps : Vector.<BitmapData>;

		public static var cropBounds : Vector.<Rectangle>;

		public static var croppedBitmaps : Vector.<BitmapData>;

		public static var framePos : Vector.<Point>;

		public static var assembledSprite : BitmapData;

		// 静态显示控制
		[Bindable]
		public static var currentBitmapData : BitmapData;

		private static var _currentFrameIndex : int = -1;

		[Bindable]
		public static function get currentFrameIndex() : int
		{
			return _currentFrameIndex;
		}

		public static function set currentFrameIndex(value : int) : void
		{
			if (_currentFrameIndex != value)
			{
				_currentFrameIndex = value;

				if (_currentFrameIndex >= fileCount)
				{
					_currentFrameIndex -= fileCount;
				}

				if (_currentFrameIndex < 0)
				{
					_currentFrameIndex += fileCount;
				}

				currentBitmapData = originalBitmaps[_currentFrameIndex];
			}
		}

		// 播放状态
		// playStatus => 0: 停止; 1: 播放; -1: 倒放
		private static var _playStatus : int = 0;

		public static function get playStatus() : int
		{
			return _playStatus;
		}

		public static function set playStatus(value : int) : void
		{
			if (value != _playStatus)
			{
				_playStatus = value;
			}
		}

		public static function reset() : void
		{
			files = null;
			originalBitmaps = null;
			_currentFrameIndex = 0;
			cropBounds = null;
			croppedBitmaps = null;
		}
	}
}
