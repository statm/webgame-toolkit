package statm.dev.npceditor.dom.layers
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.collections.ArrayCollection;
	
	import statm.dev.npceditor.app.AppFacade;
	import statm.dev.npceditor.app.AppNotificationCode;
	import statm.dev.npceditor.app.MapEditingActions;
	import statm.dev.npceditor.dom.DomNode;
	import statm.dev.npceditor.dom.Map;
	import statm.dev.npceditor.utils.GridUtils;
	import statm.dev.npceditor.utils.VersionUtils;

	/**
	 * DOM 对象：网格组。
	 *
	 * @author statm
	 *
	 */
	public class Grids extends DomNode
	{
		public function Grids(root : DomNode)
		{
			super(root);

			_name = "网格";
			_parent = root;
			_children = new ArrayCollection([
				_regionLayer = new RegionLayer(root),
				_walkingLayer = new WalkingLayer(root),
				_walkingShadowLayer = new WalkingShadowLayer(root),
				_combatLayer = new CombatLayer(root)]);
			_regionLayer.parent = _walkingLayer.parent = _combatLayer.parent = this;
		}

		private var _regionLayer : RegionLayer;

		public function get regionLayer() : RegionLayer
		{
			return _regionLayer;
		}

		private var _walkingLayer : WalkingLayer;

		public function get walkingLayer() : WalkingLayer
		{
			return _walkingLayer;
		}

		private var _walkingShadowLayer : WalkingShadowLayer;

		public function get walkingShadowLayer() : WalkingShadowLayer
		{
			return _walkingShadowLayer;
		}

		private var _combatLayer : CombatLayer;

		public function get combatLayer() : CombatLayer
		{
			return _combatLayer;
		}

		private var _gridSize : Point = new Point(1, 1);

		public function get gridSize() : Point
		{
			return _gridSize;
		}

		public function set gridSize(size : Point) : void
		{
			if (!size.equals(_gridSize))
			{
				_gridSize = size;

				_gridRange.width = _gridSize.x * GridUtils.BLOCK_DIMENSION;
				_gridRange.height = _gridSize.y * GridUtils.BLOCK_DIMENSION;

				this.notifyChange(MapEditingActions.GRID_SIZE);
			}
		}

		private var _gridAnchor : Point = new Point(0, 0);

		public function get gridAnchor() : Point
		{
			return _gridAnchor;
		}

		private var _gridRange : Rectangle = new Rectangle(_gridAnchor.x, _gridAnchor.y, _gridSize.x * GridUtils.BLOCK_DIMENSION, _gridSize.y * GridUtils.BLOCK_DIMENSION);

		public function get gridRange() : Rectangle
		{
			return _gridRange;
		}

		public function set gridAnchor(anchor : Point) : void
		{
			if (!anchor.equals(_gridAnchor))
			{
				_gridAnchor = anchor;
				this.notifyChange(MapEditingActions.GRID_ANCHOR);
			}
		}

		override public function toXML() : XML
		{
			var result : XML = <grids row={gridSize.y} col={gridSize.x} x={gridAnchor.x} y={gridAnchor.y}/>;

			result.appendChild(regionLayer.toXML())
				.appendChild(walkingLayer.toXML())
				.appendChild(walkingShadowLayer.toXML())
				.appendChild(combatLayer.toXML());

			return result;
		}

		override public function readXML(xml : XML) : void
		{
			// v1.2.4 将网格单元变为了 10x10，读取以前的文件时要做修改。
			if (VersionUtils.compareVersion(Map(root).version, "1.2.4") < 0)
			{
				this.gridSize = new Point(parseInt(xml.@col) * 2, parseInt(xml.@row) * 2);
			}
			else
			{
				this.gridSize = new Point(parseInt(xml.@col), parseInt(xml.@row));
			}
			this.gridAnchor = new Point(parseInt(xml.@x), parseInt(xml.@y));

			this.regionLayer.readXML(xml.regionLayer[0]);
			this.walkingLayer.readXML(xml.walkingLayer[0]);
			this.walkingShadowLayer.readXML(xml.walkingShadowLayer[0]);
			this.combatLayer.readXML(xml.combatLayer[0]);
		}
	}
}
