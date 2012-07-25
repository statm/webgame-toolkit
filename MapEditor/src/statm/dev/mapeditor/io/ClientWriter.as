package statm.dev.mapeditor.io
{
	import flash.filesystem.File;
	import flash.utils.Dictionary;
	
	import statm.dev.mapeditor.dom.DomObject;
	import statm.dev.mapeditor.dom.Map;
	import statm.dev.mapeditor.dom.brush.Brush;
	import statm.dev.mapeditor.dom.layers.CombatLayer;
	import statm.dev.mapeditor.dom.layers.RegionLayer;
	import statm.dev.mapeditor.dom.layers.WalkingLayer;
	import statm.dev.mapeditor.dom.objects.BornPoint;
	import statm.dev.mapeditor.dom.objects.LinkDestPoint;
	import statm.dev.mapeditor.dom.objects.LinkPoint;
	import statm.dev.mapeditor.dom.objects.TeleportPoint;
	import statm.dev.mapeditor.dom.objects.Waypoint;
	import statm.dev.mapeditor.utils.GridUtils;

	/**
	 * 将地图文件输出为客户端 XML 格式。
	 *
	 * @author statm
	 *
	 */
	public class ClientWriter
	{
		private var map : Map;
		private var xmlResult : XML;

		public function read(map : Map) : void
		{
			reset();
			this.map = map;
			parseMap();
		}

		public function flush() : XML
		{
			return xmlResult;
		}

		private function reset() : void
		{

		}

		private function parseMap() : void
		{
			xmlResult = <world>
					<id>{map.mapID}</id>
					<name>{map.mapName}</name>
					<max-col>{map.grids.gridSize.x * GridUtils.BLOCK_DIMENSION}</max-col>
					<max-row>{map.grids.gridSize.y * GridUtils.BLOCK_DIMENSION}</max-row>
					<grid-x>{map.grids.gridAnchor.x}</grid-x>
					<grid-y>{map.grids.gridAnchor.y}</grid-y>
					<image>{getImageName()}</image>
					<level-limit>{map.levelLimit}</level-limit>
					{generateTileAndPlanLists()}
					{generateTransportPoints()}
					{generateWaypoints()}
				</world>;
		}

		private function getImageName() : String
		{
			if (!map.bgLayer.bgPath || map.bgLayer.bgPath.length == 0)
			{
				return "";
			}

			return new File(map.bgLayer.bgPath).name.split(".")[0];
		}

		private function generateTileAndPlanLists() : XMLList
		{
			traverseTiles();

			var planList : XML = generateTilePlanList();
			var tileList : XML = generateTileList();

			return tileList + planList;
		}

		private var currentTilePlans : Dictionary = new Dictionary();
		private var currentTiles : Dictionary = new Dictionary();

		private function traverseTiles() : void
		{
			var planCount : int = 0;

			var maxX : int = map.grids.gridSize.x * GridUtils.BLOCK_DIMENSION;
			var maxY : int = map.grids.gridSize.y * GridUtils.BLOCK_DIMENSION;

			var hashString : String;

			var regionLayer : RegionLayer = map.grids.regionLayer;
			var walkingLayer : WalkingLayer = map.grids.walkingLayer;
			var combatLayer : CombatLayer = map.grids.combatLayer;

			var regionBrushID : int;
			var walkingBrushID : int;
			var combatBrushID : int;

			for (var i : int = 0; i < maxX; i++)
			{
				for (var j : int = 0; j < maxY; j++)
				{
					var regionBrush : Brush = regionLayer.getMask(i, j);
					var walkingBrush : Brush = walkingLayer.getMask(i, j);
					var combatBrush : Brush = combatLayer.getMask(i, j);

					regionBrushID = (regionBrush ? regionBrush.id : -1);
					walkingBrushID = (walkingBrush ? walkingBrush.id : -1);
					combatBrushID = (combatBrush ? combatBrush.id : -1);

					if (regionBrushID == -1
						&& walkingBrushID == -1
						&& combatBrushID == -1)
					{
						continue;
					}

					hashString = regionBrushID + "|" + walkingBrushID + "|" + combatBrushID;

					var plan : TilePlan = currentTilePlans[hashString] as TilePlan;

					if (!plan)
					{
						plan = new TilePlan();
						plan.id = ++planCount;
						plan.region = regionBrush;
						plan.walking = walkingBrush;
						plan.combat = combatBrush;

						currentTilePlans[hashString] = plan;
					}

					currentTiles[i + "," + j] = plan.id;
				}
			}
		}

		private function generateTilePlanList() : XML
		{
			var result : XML = <tile-plan-list/>;

			for each (var plan : TilePlan in currentTilePlans)
			{
				result.appendChild(plan.toXML());
			}

			return result;
		}

		private function generateTileList() : XML
		{
			var result : XML = <tile-list/>;

			for (var key : String in currentTiles)
			{
				var coordArray : Array = key.split(",");
				var x : int = parseInt(coordArray[0]);
				var y : int = parseInt(coordArray[1]);

				result.appendChild(<tile><plan-id>{currentTiles[key]}</plan-id><position col={x} row={y}/></tile>);
			}

			return result;
		}

		private function generateTransportPoints() : XMLList
		{
			var tpResult : XML = <teleporter-list/>;
			var lpResult : XML = <link-point-list/>;
			var bpResult : XML = <born-point-list/>;

			for each (var node : DomObject in map.items.transportPoints.children)
			{
				if (node is TeleportPoint)
				{
					tpResult.appendChild(generateTeleportPoint(TeleportPoint(node)));
				}
				else if (node is LinkPoint)
				{
					lpResult.appendChild(generateLinkPoint(LinkPoint(node)));
				}
				else if (node is BornPoint)
				{
					bpResult.appendChild(generateBornPoint(BornPoint(node)));
				}
			}

			return tpResult + lpResult + bpResult;
		}

		private function generateTeleportPoint(tp : TeleportPoint) : XML
		{
			var result : XML = <teleporter>
					<map-id>{tp.mapID}</map-id>
					<position col={tp.x} row={tp.y}/>
				</teleporter>;

			var allowNationNode : XML = <allow-nation/>;

			for each (var nation : String in tp.allowNations)
			{
				allowNationNode.appendChild(<nation>{nation}</nation>);
			}

			result.appendChild(allowNationNode);

			return result;
		}

		private function generateLinkPoint(lp : LinkPoint) : XML
		{
			var result : XML = <link-point>
					<source col={lp.x} row={lp.y}/>
				</link-point>;

			var destinationListNode : XML = <destination-list/>;

			for each (var ldp : LinkDestPoint in lp.children)
			{
				destinationListNode.appendChild(generateLinkDestPoint(ldp));
			}

			result.appendChild(destinationListNode);

			return result;
		}

		private function generateLinkDestPoint(ldp : LinkDestPoint) : XML
		{
			var result : XML = <teleporter>
					<map-id>{ldp.mapID}</map-id>
					<position col={ldp.x} row={ldp.y}/>
				</teleporter>;

			var allowNationNode : XML = <allow-nation/>;

			for each (var nation : String in ldp.allowNations)
			{
				allowNationNode.appendChild(<nation>{nation}</nation>);
			}

			result.appendChild(allowNationNode);

			return result;
		}

		private function generateBornPoint(bp : BornPoint) : XML
		{
			var result : XML = <born-point>
					<position col={bp.x} row={bp.y}/>
				</born-point>;

			var allowNationNode : XML = <allow-nation/>;

			for each (var nation : String in bp.allowNations)
			{
				allowNationNode.appendChild(<nation>{nation}</nation>);
			}

			result.appendChild(allowNationNode);

			return result;
		}

		private function generateWaypoints() : XML
		{
			var result : XML = <waypoint-list/>;

			for each (var waypoint : Waypoint in map.items.waypoints.children)
			{
				var waypointXML : XML = <waypoint>
						<position col={waypoint.x} row={waypoint.y}/>
					</waypoint>;

				var adjXML : XML = <adjacencies/>;
				for each (var wp : Waypoint in waypoint.adjacentWaypoints)
				{
					adjXML.appendChild(<position col={wp.x} row={wp.y}/>);
				}

				waypointXML.appendChild(adjXML);

				result.appendChild(waypointXML);
			}

			return result;
		}
	}
}
import statm.dev.mapeditor.dom.brush.Brush;

class TilePlan
{
	public var id : int;
	public var region : Brush;
	public var walking : Brush;
	public var combat : Brush;

	public function toXML() : XML
	{
		var result : XML = <tile-plan>
				<id>{id}</id>
				<site-id>{(region && region.data) ? region.data : "1"}</site-id>
				<walk-state-limit>{(walking && walking.data) ? walking.data : ""}</walk-state-limit>
				<battle-type-limit>{(combat && combat.data) ? combat.data : ""}</battle-type-limit>
			</tile-plan>;

		return result;
	}
}
