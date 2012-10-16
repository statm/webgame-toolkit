package statm.dev.mapeditor.dom.layers
{
	import mx.collections.ArrayCollection;
	
	import statm.dev.mapeditor.app.AppState;
	import statm.dev.mapeditor.dom.DomNode;
	import statm.dev.mapeditor.dom.item.ItemFactory;
	import statm.dev.mapeditor.dom.objects.BornPoint;
	import statm.dev.mapeditor.dom.objects.Item;
	import statm.dev.mapeditor.dom.objects.LinkDestPoint;
	import statm.dev.mapeditor.dom.objects.LinkPoint;
	import statm.dev.mapeditor.dom.objects.NPC;
	import statm.dev.mapeditor.dom.objects.TeleportPoint;
	import statm.dev.mapeditor.dom.objects.Waypoint;


	/**
	 * DOM 对象：物件层（文件夹）。
	 *
	 * @author statm
	 *
	 */
	public class Items extends DomNode
	{
		public function Items(root : DomNode)
		{
			super(root);

			_name = "物件";
			_parent = root;
			_children = new ArrayCollection([
				_npcLayer = new NPCLayer(root),
				_mobLayer = new MobLayer(root),
				_transportPoints = new TransportPoints(root),
				_waypoints = new WaypointLayer(root)]);
			_npcLayer.parent
				= _mobLayer.parent
				= _transportPoints.parent
				= _waypoints.parent
				= this;
		}

		private var _npcLayer : NPCLayer;

		public function get npcLayer() : NPCLayer
		{
			return _npcLayer;
		}

		private var _mobLayer : MobLayer;

		public function get mobLayer() : MobLayer
		{
			return _mobLayer;
		}

		private var _transportPoints : TransportPoints;

		public function get transportPoints() : TransportPoints
		{
			return _transportPoints;
		}

		private var _waypoints : WaypointLayer;

		public function get waypoints() : WaypointLayer
		{
			return _waypoints;
		}

		public function addItem(item : Item) : void
		{
			if ((item is TeleportPoint)
				|| (item is LinkPoint)
				|| (item is BornPoint))
			{
				transportPoints.addItem(item);
			}
			else if (item is LinkDestPoint)
			{
				var selection : DomNode = AppState.getCurrentSelection();
				if (selection
					&& (selection is LinkPoint))
				{
					LinkPoint(selection).addLinkDestination(LinkDestPoint(item));
				}
				else
				{
					throw new Error("添加连接目标点时出错：未选定正确的目标");
				}
			}
			else if (item is Waypoint)
			{
				waypoints.addWaypoint(Waypoint(item));
			}
			else if (item is NPC)
			{
				npcLayer.addItem(item);
			}
		}

		override public function deselect() : void
		{
			AppState.stopDrawingItem();
		}

		override public function toXML() : XML
		{
			var results : XML = <items/>;

			results.appendChild(npcLayer.toXML())
				.appendChild(mobLayer.toXML())
				.appendChild(transportPoints.toXML())
				.appendChild(waypoints.toXML());

			return results;
		}

		override public function readXML(xml : XML) : void
		{
			ItemFactory.domRoot = root;
			this.transportPoints.readXML(xml.transportLayer[0]);
			this.waypoints.readXML(xml.waypointLayer[0]);
			this.npcLayer.readXML(xml.NPCLayer[0]);
		}
	}
}
