package statm.dev.mapeditor.dom.layers
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.collections.ArrayCollection;
	
	import statm.dev.mapeditor.app.AppFacade;
	import statm.dev.mapeditor.app.AppNotificationCode;
	import statm.dev.mapeditor.app.MapEditingActions;
	import statm.dev.mapeditor.dom.DomNode;
	import statm.dev.mapeditor.utils.GridUtils;

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
				_walkingOpaqueLayer = new WalkingOpaqueLayer(root),
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

		private var _walkingOpaqueLayer : WalkingOpaqueLayer;

		public function get walkingOpaqueLayer() : WalkingOpaqueLayer
		{
			return _walkingOpaqueLayer;
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

				_gridRange.width = _gridSize.y * GridUtils.BLOCK_DIMENSION;
				_gridRange.height = _gridSize.x * GridUtils.BLOCK_DIMENSION;

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
			var result : XML = <grids row={gridSize.x} col={gridSize.y} x={gridAnchor.x} y={gridAnchor.y}/>;

			result.appendChild(regionLayer.toXML())
				.appendChild(walkingLayer.toXML())
				.appendChild(walkingOpaqueLayer.toXML())
				.appendChild(combatLayer.toXML());

			return result;
		}

		override public function readXML(xml : XML) : void
		{
			this.gridSize = new Point(parseInt(xml.@row), parseInt(xml.@col));
			this.gridAnchor = new Point(parseInt(xml.@x), parseInt(xml.@y));

			this.regionLayer.readXML(xml.regionLayer[0]);
			this.walkingLayer.readXML(xml.walkingLayer[0]);
			this.walkingOpaqueLayer.readXML(xml.walkingOpaqueLayer[0]);
			this.combatLayer.readXML(xml.combatLayer[0]);
		}
	}
}
