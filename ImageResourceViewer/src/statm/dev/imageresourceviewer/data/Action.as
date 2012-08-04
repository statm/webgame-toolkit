package statm.dev.imageresourceviewer.data
{
	import flash.utils.Dictionary;

	import mx.collections.ArrayCollection;

	/**
	 * 动画元素的动作。
	 *
	 * @author statm
	 *
	 */
	public class Action
	{
		private var _name : String;

		public function get name() : String
		{
			return _name;
		}

		private var _directions : ArrayCollection;

		private var _directionDic : Dictionary;

		public function Action(name : String) : void
		{
			_name = name;
			_directions = new ArrayCollection();
			_directionDic = new Dictionary();
		}

		public function getDirection(dir : String) : Direction
		{
			var direction : Direction = _directionDic[dir];
			if (!direction)
			{
				direction = new Direction(dir);
				_directionDic[dir] = direction;
				_directions.addItem(direction);
			}
			return direction;
		}
	}
}
