package statm.dev.mapeditor.dom.layers
{
	import flash.geom.Point;
	import flash.utils.Dictionary;

	import mx.collections.ArrayCollection;
	import mx.core.IVisualElement;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;

	import spark.collections.Sort;
	import spark.collections.SortField;
	import spark.components.Group;
	import spark.primitives.Ellipse;
	import spark.primitives.Line;

	import statm.dev.mapeditor.dom.DomNode;
	import statm.dev.mapeditor.dom.DomObject;
	import statm.dev.mapeditor.dom.Map;
	import statm.dev.mapeditor.dom.item.ItemFactory;
	import statm.dev.mapeditor.dom.objects.Waypoint;
	import statm.dev.mapeditor.dom.objects.WaypointConnection;
	import statm.dev.mapeditor.utils.GridUtils;


	/**
	 * DOM 对象：路点层
	 *
	 * @author renjie.zh
	 *
	 */
	public class WaypointLayer extends PlacementLayerBase
	{
		public function WaypointLayer(root : DomNode)
		{
			super(root);
			_name = "路点";
			_children = new ArrayCollection();
			var sort : Sort = new Sort();
			sort.fields = [new SortField("wid", false, true)];
			_children.sort = sort;
			_children.refresh();

			shadowLayer = new Group();
			shadowLayer.mouseEnabled = false;

			lineLayer = new Group();

			waypointDic = new Dictionary();
			connectionDic = new Dictionary();

			dim();
		}

		private var shadowLayer : Group;

		private var lineLayer : Group;

		private var waypointDic : Dictionary;

		private var connectionDic : Dictionary;

		override public function addItem(item : DomObject) : void
		{
			if (item is Waypoint)
			{
				addWaypoint(Waypoint(item));
			}
		}

		public function addWaypoint(waypoint : Waypoint) : void
		{
			if (Map(root).testWalk(waypoint.x, waypoint.y))
			{
				super.addItem(waypoint);
				redrawShadow(waypoint);
				connectAdjacantWaypoints(waypoint);
				waypointDic[waypoint.wid] = waypoint;
			}
		}

		public function addConnection(connection : WaypointConnection, endpoint1 : Waypoint, endpoint2 : Waypoint) : void
		{
			connection.parent = this;
			connection.endPoints = [endpoint1, endpoint2];
			lineLayer.addElement(IVisualElement(connection.display));
		}

		public function removeConnection(connection : WaypointConnection) : void
		{
			Waypoint(connection.endPoints[0]).removeAdjacantWaypoint(Waypoint(connection.endPoints[1]));
			lineLayer.removeElement(IVisualElement(connection.display));
			var lineKey : String = getLineKey(Waypoint(connection.endPoints[0]), Waypoint(connection.endPoints[1]));
			if (connectionDic[lineKey] == connection)
			{
				delete connectionDic[lineKey];
			}
			connection.endPoints = [];
		}

		override public function removeItem(item : DomObject) : void
		{
			if (item is Waypoint)
			{
				removeWaypoint(Waypoint(item));
			}
			else if (item is WaypointConnection)
			{
				removeConnection(WaypointConnection(item));
			}
		}

		public function removeWaypoint(waypoint : Waypoint) : void
		{
			super.removeItem(waypoint);
			removeShadow(waypoint);
			delete waypointDic[waypoint.wid];

			var i : int = waypoint.adjacantWaypoints.length;
			while (--i > -1)
			{
				var wp : Waypoint = Waypoint(waypoint.adjacantWaypoints[i]);
				var key : String = getLineKey(wp, waypoint);
				var conn : WaypointConnection = connectionDic[key] as WaypointConnection;
				removeConnection(conn);
			}
		}

		private var shadows : Dictionary = new Dictionary();

		public function redrawShadow(waypoint : Waypoint) : void
		{
			var circlePos : Point = GridUtils.gridToGlobal(new Point(waypoint.x, waypoint.y));

			var circleSize : int = GridUtils.WAYPOINT_DIST_THRESHOLD * GridUtils.GRID_WIDTH;

			var circle : Ellipse = shadows[waypoint] as Ellipse;
			if (!circle)
			{
				shadows[waypoint] = circle = new Ellipse();
				circle.width = circle.height = circleSize;
				circle.fill = new SolidColor(0x000000, 0.3);
				shadowLayer.addElement(circle);
			}
			circle.x = circlePos.x - circleSize / 2 + GridUtils.GRID_WIDTH / 2;
			circle.y = circlePos.y - circleSize / 2 + GridUtils.GRID_HEIGHT / 2;
		}

		private function removeShadow(waypoint : Waypoint) : void
		{
			var circle : Ellipse = shadows[waypoint] as Ellipse;
			if (circle)
			{
				shadowLayer.removeElement(circle);
				delete shadows[waypoint];
			}
		}

		public function connectAdjacantWaypoints(waypoint : Waypoint, createPath : Boolean = true) : void
		{
			var wp : Waypoint;
			var connection : WaypointConnection;
			var lineKey : String;
			var connectingGrids : Vector.<Point>;

			if (createPath)
			{
				// 检查所有的路点，如果相邻那么建立连接
				for each (wp in this.children)
				{
					if (wp == waypoint)
					{
						continue;
					}

					if (GridUtils.distance(wp, waypoint) <= GridUtils.WAYPOINT_DIST_THRESHOLD
						&& isPathAvailable(GridUtils.getPathBetween(new Point(wp.x, wp.y), new Point(waypoint.x, waypoint.y))))
					{
						if (!waypoint.isAdjacantTo(wp))
						{
							waypoint.addAdjacantWaypoint(wp);
						}

						lineKey = getLineKey(wp, waypoint);
						connection = connectionDic[lineKey] as WaypointConnection;

						if (!connection)
						{
							connectionDic[lineKey] = connection = new WaypointConnection(root);
							addConnection(connection, wp, waypoint);
						}

						GridUtils.connectGrids(new Point(waypoint.x, waypoint.y), new Point(wp.x, wp.y), connection.line);
					}
					else
					{
						if (waypoint.isAdjacantTo(wp))
						{
							waypoint.removeAdjacantWaypoint(wp);

							lineKey = getLineKey(wp, waypoint);
							connection = connectionDic[lineKey] as WaypointConnection;

							if (connection)
							{
								removeConnection(connection);
							}
						}
					}
				}
			}
			else
			{
				for each (wp in waypoint.adjacantWaypoints)
				{
					lineKey = getLineKey(wp, waypoint);
					connection = connectionDic[lineKey] as WaypointConnection;

					if (!connection)
					{
						connectionDic[lineKey] = connection = new WaypointConnection(root);
						addConnection(connection, wp, waypoint);
					}

					GridUtils.connectGrids(new Point(waypoint.x, waypoint.y), new Point(wp.x, wp.y), connection.line);
				}
			}
		}

		private function isPathAvailable(path : Vector.<Point>) : Boolean
		{
			for each (var p : Point in path)
			{
				if (!Map(root).testWalk(p.x, p.y))
				{
					return false;
				}
			}

			return true;
		}

		private function getLineKey(wp1 : Waypoint, wp2 : Waypoint) : String
		{
			return Math.min(wp1.wid, wp2.wid) + "," + Math.max(wp1.wid, wp2.wid);
		}

		public function getWaypointByWid(wid : int) : Waypoint
		{
			return waypointDic[wid];
		}

		public function light() : void
		{
			shadowLayer.alpha = lineLayer.alpha = 1;
		}

		public function dim() : void
		{
			shadowLayer.alpha = lineLayer.alpha = .3;
		}

		override public function select() : void
		{
			super.select();
			light();
		}

		override public function deselect() : void
		{
			super.deselect();
			dim();
		}

		override public function set display(d : Object) : void
		{
			super.display = d;

			Group(d).addElementAt(shadowLayer, 0);
			Group(d).addElementAt(lineLayer, 1);
		}

		override public function readXML(xml : XML) : void
		{
			ItemFactory.domRoot = root;
			for each (var waypointXML : XML in xml.waypoint)
			{
				var waypoint : Waypoint = Waypoint(ItemFactory.createItemFromXML(waypointXML));
				super.addItem(waypoint);
				waypointDic[waypoint.wid] = waypoint;
			}

			for each (var wp : Waypoint in children)
			{
				for each (var wid : int in wp.adjacantWaypointIDs)
				{
					if (wid < wp.wid)
					{
						wp.addAdjacantWaypoint(waypointDic[wid]);
					}
				}

				connectAdjacantWaypoints(wp, false);
			}
		}

		override public function toXML() : XML
		{
			// 要根据 wid 排序。
			var result : XML = <waypointLayer/>;

			for each (var wp : Waypoint in children)
			{
				result.appendChild(wp.toXML());
			}

			return result;
		}
	}
}
