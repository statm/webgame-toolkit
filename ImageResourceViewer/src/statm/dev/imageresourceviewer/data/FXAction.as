package statm.dev.imageresourceviewer.data
{
	import flash.display.BitmapData;

	import statm.dev.imageresourceviewer.AppState;
	import statm.dev.imageresourceviewer.data.resource.ResourceBatch;

	/**
	 * 特效元素的动作。
	 *
	 * @author statm
	 *
	 */
	public class FXAction extends Action
	{
		private var _batch : ResourceBatch;

		public function FXAction(name : String)
		{
			super(name);
		}

		public function get batch() : ResourceBatch
		{
			return _batch;
		}

		public function set batch(value : ResourceBatch) : void
		{
			if (!_batch)
			{
				AppState.actionCount++;
			}
			_batch = value;
			_info.frameCount = _batch.length;
		}

		override public function getAllImages() : Vector.<BitmapData>
		{
			if (_batch)
			{
				return _batch.getImages();
			}
			else
			{
				return null;
			}
		}
	}
}
