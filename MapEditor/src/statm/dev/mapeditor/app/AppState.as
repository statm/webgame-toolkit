package statm.dev.mapeditor.app
{
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import statm.dev.mapeditor.dom.DomNode;
	import statm.dev.mapeditor.dom.Map;
	import statm.dev.mapeditor.dom.brush.Brush;
	import statm.dev.mapeditor.dom.item.ItemDefinition;
	import statm.dev.mapeditor.dom.layers.MaskLayerBase;

	/**
	 * 应用程序状态。
	 *
	 * @author statm
	 *
	 */
	public final class AppState
	{
		private static var currentMap : Map = null;

		public static function getCurrentMap() : Map
		{
			return currentMap;
		}

		public static function setCurrentMap(map : Map) : void
		{
			if (map != currentMap)
			{
				currentMap = map;
				setCurrentSelection(map);
			}
		}


		private static var currentSelection : DomNode = null;

		public static function getCurrentSelection() : DomNode
		{
			return currentSelection;
		}

		public static function setCurrentSelection(selection : DomNode) : void
		{
			if (currentSelection)
			{
				currentSelection.deselect();
			}

			currentSelection = selection;

			if (selection)
			{
				selection.select();
				trace("select: " + selection.name);
			}
			else
			{
				trace("select: null");
			}

			AppFacade.getInstance().sendNotification(AppNotificationCode.SELECTION_CHANGED);
		}


		private static var mapSize : Point = null;

		public static function getMapSize() : Point
		{
			return mapSize;
		}

		public static function setMapSize(size : Point) : void
		{
			if (!mapSize || !size.equals(mapSize))
			{
				mapSize = size;
				AppFacade.getInstance().sendNotification(AppNotificationCode.VIEWPORT_CHANGED);
			}
		}


		private static var viewport : Rectangle = null;

		public static function getViewport() : Rectangle
		{
			return viewport;
		}

		public static function setViewport(vp : Rectangle) : void
		{
			viewport = vp;
			AppFacade.getInstance().sendNotification(AppNotificationCode.VIEWPORT_CHANGED);
		}

		private static var movingViewport : Boolean = false;

		public static function startMovingViewport() : void
		{
			movingViewport = true;
		}

		public static function stopMovingViewport() : void
		{
			movingViewport = false;
		}

		public static function isMovingViewport() : Boolean
		{
			return movingViewport;
		}

		private static var drawingMask : Boolean = false;

		public static function startDrawingMask(brush : Brush) : void
		{
			drawingMask = true;
			currentBrush = brush;
		}

		public static function stopDrawingMask() : void
		{
			drawingMask = false;
		}

		public static function isDrawingMask() : Boolean
		{
			return drawingMask;
		}

		private static var movingGrid : Boolean = false;

		public static function startMovingGrid() : void
		{
			movingGrid = true;
		}

		public static function stopMovingGrid() : void
		{
			movingGrid = false;
		}

		public static function isMovingGrid() : Boolean
		{
			return movingGrid;
		}

		private static var drawingItem : Boolean = false;

		public static function startDrawingItem(itemDef : ItemDefinition) : void
		{
			drawingItem = true;
			setCurrentItemDef(itemDef);
		}

		public static function stopDrawingItem() : void
		{
			drawingItem = false;
		}

		public static function isDrawingItem() : Boolean
		{
			return drawingItem;
		}

		private static var movingItem : Boolean = false;

		public static function startMovingItem() : void
		{
			movingItem = true;
		}

		public static function stopMovingItem() : void
		{
			movingItem = false;
		}

		public static function isMovingItem() : Boolean
		{
			return movingItem;
		}

		private static var currentMaskLayer : MaskLayerBase;

		public static function getCurrentMaskLayer() : MaskLayerBase
		{
			return currentMaskLayer;
		}

		public static function setCurrentMaskLayer(layer : MaskLayerBase) : void
		{
			currentMaskLayer = layer;
		}

		private static var currentBrush : Brush;

		public static function getCurrentBrush() : Brush
		{
			return currentBrush;
		}

		public static function setCurrentBrush(brush : Brush) : void
		{
			currentBrush = brush;
		}

		private static var currentItem : ItemDefinition;

		public static function getCurrentItemDef() : ItemDefinition
		{
			return currentItem;
		}

		public static function setCurrentItemDef(itemDef : ItemDefinition) : void
		{
			currentItem = itemDef;
		}

		public static var xmlUID : String;
	}
}
