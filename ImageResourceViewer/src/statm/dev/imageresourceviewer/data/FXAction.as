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
		private var _batch:ResourceBatch;

		override public function get batchCount():int
		{
			return 5;
		}

		public function set batch(value:ResourceBatch):void
		{
			if (!_batch)
			{
				AppState.instance.actionCount++;
			}
			_batch = value;
			_info.frameCount = _batch.length;
		}

		override public function getBatch(direction:String):ResourceBatch
		{
			return _batch;
		}

		public function FXAction(name:String)
		{
			super(name);
		}

		override public function getAllImages():Vector.<BitmapData>
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

		override public function get frameRate():int
		{
			return _batch.frameRate;
		}

		override public function set frameRate(value:int):void
		{
			_batch.frameRate = value;
		}
	}
}
