package statm.dev.mapeditor.dom.objects
{
	import statm.dev.mapeditor.dom.DomNode;
	import statm.dev.mapeditor.dom.layers.WaypointLayer;


	/**
	 * DOM 对象：路点。
	 *
	 * @author renjie.zh
	 *
	 */
	public class Waypoint extends Item
	{
		public static var WID : int = 0;

		public function Waypoint(root : DomNode)
		{
			super(root);
			_name = "路点";
			_adjacantWaypoints = [];

			_wid = ++WID;
		}

		private var _wid : int;

		public function get wid() : int
		{
			return _wid;
		}

		private var _adjacantWaypoints : Array;

		public function get adjacantWaypoints() : Array
		{
			return _adjacantWaypoints;
		}

		public function addAdjacantWaypoint(wp : Waypoint) : void
		{
			if (_adjacantWaypoints.indexOf(wp) == -1)
			{
				_adjacantWaypoints.push(wp);
				wp._adjacantWaypoints.push(this);
			}
		}

		public function isAdjacantTo(wp : Waypoint) : Boolean
		{
			return (_adjacantWaypoints.indexOf(wp) != -1);
		}

		public function removeAdjacantWaypoint(wp : Waypoint) : void
		{
			var index : int = _adjacantWaypoints.indexOf(wp);

			if (index != -1)
			{
				_adjacantWaypoints.splice(index, 1);
				var thisIndex : int = wp._adjacantWaypoints.indexOf(this);
				wp._adjacantWaypoints.splice(thisIndex, 1);
			}
		}

		override public function set x(value : int) : void
		{
			super.x = value;
			if (parent)
			{
				WaypointLayer(parent).redrawShadow(this);
				WaypointLayer(parent).connectAdjacantWaypoints(this);
			}
		}

		override public function set y(value : int) : void
		{
			super.y = value;
			if (parent)
			{
				WaypointLayer(parent).redrawShadow(this);
				WaypointLayer(parent).connectAdjacantWaypoints(this);
			}
		}

		override public function set parent(value : DomNode) : void
		{
			super.parent = value;
			WaypointLayer(parent).redrawShadow(this);
			WaypointLayer(parent).connectAdjacantWaypoints(this);
		}

		public var adjacantWaypointIDs : Vector.<int> = new Vector.<int>();

		override public function readXML(xml : XML) : void
		{
			adjacantWaypointIDs.length = 0;

			x = xml.@x;
			y = xml.@y;
			_wid = xml.@wid;
			if (_wid > WID)
			{
				WID = _wid;
			}
			for each (var adj : XML in xml.adj)
			{
				var adjWid : int = parseInt(adj.toString());
				if (adjWid < _wid)
				{
					adjacantWaypointIDs.push(adjWid);
				}
			}
		}

		override public function select() : void
		{
			super.select();
			if (parent)
			{
				WaypointLayer(parent).light();
			}
		}

		override public function deselect() : void
		{
			super.deselect();
			if (parent)
			{
				WaypointLayer(parent).dim();
			}
		}

		override public function toXML() : XML
		{
			var result : XML = <waypoint x={x} y={y} wid={wid}/>;

			for each (var wp : Waypoint in adjacantWaypoints)
			{
				result.appendChild(<adj>{wp.wid}</adj>);
			}

			return result;
		}
	}
}
