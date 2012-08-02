package statm.dev.libs.imageplayer.loader
{

	/**
	 * 图片组加载状态。
	 *
	 * @author statm
	 *
	 */
	public class ImageBatchState
	{

		/**
		 * 准备就绪，等待加载。
		 */
		public static const READY : int = 0;

		/**
		 * 正在加载。
		 */
		public static const LOADING : int = 1;

		/**
		 * 加载完成。
		 */
		public static const COMPLETE : int = 2;

		/**
		 * 错误。
		 */
		public static const ERROR : int = -1;
	}
}
