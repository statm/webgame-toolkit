package statm.dev.npceditor.dom.objects
{
	import statm.dev.npceditor.dom.DomNode;
	import statm.dev.npceditor.dom.layers.WaypointLayer;


	/**
	 * DOM 对象：路点。
	 *
	 * @author statm
	 *
	 */
	public class Waypoint extends Item
	{
		public static var WID : int = 0;

		public function Waypoint(root : DomNode)
		{
			super(root);
			_name = "路点";
			_adjacentWaypoints = [];

			_wid = ++WID;
		}

		private var _wid : int;

		public function get wid() : int
		{
			return _wid;
		}

		private var _adjacentWaypoints : Array;

		public function get adjacentWaypoints() : Array
		{
			return _adjacentWaypoints;
		}

		public function addAdjacentWaypoint(wp : Waypoint) : void
		{
			if (_adjacentWaypoints.indexOf(wp) == -1)
			{
				_adjacentWaypoints.push(wp);
				wp._adjacentWaypoints.push(this);
			}
		}

		public function isAdjacentTo(wp : Waypoint) : Boolean
		{
			return (_adjacentWaypoints.indexOf(wp) != -1);
		}

		public function removeAdjacentWaypoint(wp : Waypoint) : void
		{
			var index : int = _adjacentWaypoints.indexOf(wp);

			if (index != -1)
			{
				_adjacentWaypoints.splice(index, 1);
				var thisIndex : int = wp._adjacentWaypoints.indexOf(this);
				wp._adjacentWaypoints.splice(thisIndex, 1);
			}
		}

		override public function set x(value : int) : void
		{
			super.x = value;
			if (parent)
			{
				WaypointLayer(parent).redrawShadow(this);
				WaypointLayer(parent).connectAdjacentWaypoints(this);
			}
		}

		override public function set y(value : int) : void
		{
			super.y = value;
			if (parent)
			{
				WaypointLayer(parent).redrawShadow(this);
				WaypointLayer(parent).connectAdjacentWaypoints(this);
			}
		}

		override public function set parent(value : DomNode) : void
		{
			super.parent = value;
			WaypointLayer(parent).redrawShadow(this);
			WaypointLayer(parent).connectAdjacentWaypoints(this);
		}

		public var adjacentWaypointIDs : Vector.<int> = new Vector.<int>();

		override public function readXML(xml : XML) : void
		{
			adjacentWaypointIDs.length = 0;

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
					adjacentWaypointIDs.push(adjWid);
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

			for each (var wp : Waypoint in adjacentWaypoints)
			{
				result.appendChild(<adj>{wp.wid}</adj>);
			}

			return result;
		}
	}
}
