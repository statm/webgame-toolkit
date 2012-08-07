package statm.dev.imageresourceviewer.data
{
	import flash.utils.Dictionary;

	import mx.collections.ArrayCollection;

	import statm.dev.imageresourceviewer.data.resource.ResourceBatch;
	import statm.dev.imageresourceviewer.data.type.DirectionType;

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

		public function get name() : String
		{
			return _info.name;
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
			var actualDirection : String = direction;

			if (actualDirection == DirectionType.NW)
			{
				actualDirection = DirectionType.NE;
			}

			if (actualDirection == DirectionType.W)
			{
				actualDirection = DirectionType.E;
			}

			if (actualDirection == DirectionType.SW)
			{
				actualDirection = DirectionType.SE;
			}

			return _directionDic[actualDirection];
		}

		public function toString() : String
		{
			return _info.name + "(" + _info.frameCount + ")";
		}
	}
}
