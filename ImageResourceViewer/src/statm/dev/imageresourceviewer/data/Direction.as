package statm.dev.imageresourceviewer.data
{
	import statm.dev.imageresourceviewer.data.resource.ResourceBatch;

	/**
	 * 动画动作的方向。
	 *
	 * @author statm
	 *
	 */
	public class Direction
	{
		private var _direction : String;

		private var _batch : ResourceBatch;

		public function Direction(direction : String) : void
		{
			_direction = direction;
		}

		public function setBatch(batch : ResourceBatch) : void
		{
			_batch = batch;
		}
	}
}
