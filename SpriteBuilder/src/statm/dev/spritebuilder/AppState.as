package statm.dev.spritebuilder
{
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
		public static var batches : ArrayCollection = new ArrayCollection();

		[Bindable]
		public static var activeBatch : Batch;

		// 播放状态
		// playStatus => 0: 停止; 1: 播放; -1: 倒放
		private static var _playStatus : int = 0;

		[Bindable]
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
	}
}
