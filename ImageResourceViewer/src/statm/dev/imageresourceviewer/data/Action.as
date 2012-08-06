package statm.dev.imageresourceviewer.data
{
	import flash.utils.Dictionary;

	import mx.collections.ArrayCollection;

	import statm.dev.imageresourceviewer.data.resource.ResourceBatch;

	/**
	 * 动画元素的动作。
	 *
	 * @author statm
	 *
	 */
	public class Action
	{
		private var _info : ActionInfo;

		public function get info() : ActionInfo
		{
			return _info;
		}

		private var _directionDic : Dictionary;

		public function Action(name : String) : void
		{
			_info = new ActionInfo();
			_info.name = name;
			_directionDic = new Dictionary();
		}

		public function addBatch(direction : String, batch : ResourceBatch) : void
		{
			_directionDic[direction] = batch;
			_info.frameCount = batch.length;
		}

		public function getBatch(direction : String) : ResourceBatch
		{
			return _directionDic[direction];
		}

		public function toString() : String
		{
			return _info.name + "(" + _info.frameCount + ")";
		}
	}
}
