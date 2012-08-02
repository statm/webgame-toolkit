package statm.dev.libs.imageplayer.loader
{
	import flash.events.Event;


	/**
	 * 图片批量加载事件。
	 *
	 * @author statm
	 *
	 */
	public class ImageBatchEvent extends Event
	{
		public static const PROGRESS : String = "progress";

		public static const COMPLETE : String = "complete";

		public static const ERROR : String = "error";

		public function ImageBatchEvent(type : String, bubbles : Boolean = false, cancelable : Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
