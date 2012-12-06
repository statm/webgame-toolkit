package statm.dev.imageresourceviewer.data
{
	import flash.display.BitmapData;
	import flash.utils.Dictionary;

	import statm.dev.imageresourceviewer.AppState;
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
		protected var _info:ActionInfo;
		protected var _batchCount:int = 0;

		public function get info():ActionInfo
		{
			return _info;
		}

		public function get name():String
		{
			return _info.name;
		}

		public function get batchCount():int
		{
			return _batchCount;
		}

		protected var _directionDic:Dictionary;

		public function Action(name:String):void
		{
			_info = new ActionInfo();
			_info.name = name;
			_directionDic = new Dictionary();
		}

		public function addBatch(direction:String, batch:ResourceBatch):void
		{
			if (!_directionDic[direction])
			{
				_batchCount++;
			}
			_directionDic[direction] = batch;
			_info.frameCount = batch.length;
		}

		public function getBatch(direction:String):ResourceBatch
		{
			var actualDirection:String = direction;

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

		public function getAllImages():Vector.<BitmapData>
		{
			var result:Vector.<BitmapData> = new Vector.<BitmapData>();
			for each (var direction:String in DirectionType.directionList)
			{
				var batch:ResourceBatch = getBatch(direction);
				if (batch)
				{
					result = result.concat(batch.getImages());
				}
				else
				{
					result = result.concat(new Vector.<BitmapData>(_info.frameCount, true));
				}
			}
			return result;
		}

		public function get frameRate():int
		{
			for (var key:String in _directionDic)
			{
				return (_directionDic[key] as ResourceBatch).frameRate;
			}
			return ImageResourceViewer.DEFAULT_FRAME_RATE;
		}

		public function set frameRate(value:int):void
		{
			for (var key:String in _directionDic)
			{
				(_directionDic[key] as ResourceBatch).frameRate = value;
			}
		}

		private var _anchor:int = ImageResourceViewer.DEFAULT_ANCHOR;

		public function get anchor():int
		{
			for (var key:String in _directionDic)
			{
				return (_directionDic[key] as ResourceBatch).anchor;
			}
			return _anchor;
		}

		public function set anchor(value:int):void
		{
			for (var key:String in _directionDic)
			{
				(_directionDic[key] as ResourceBatch).anchor = value;
			}
			_anchor = value;
		}

		public function toString():String
		{
			return _info.name + "(" + _info.frameCount + ")";
		}
	}
}
