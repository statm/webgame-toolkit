package statm.dev.mapeditor.utils
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	import spark.primitives.Line;

	import statm.dev.mapeditor.dom.DomObject;
	import statm.dev.mapeditor.dom.brush.Brush;
	import statm.dev.mapeditor.ui.BigBitmap;

	/**
	 * 网格相关工具类。
	 *
	 * @author statm
	 *
	 */
	public class GridUtils
	{
		public static const GRID_WIDTH : int = 30;

		public static const GRID_HEIGHT : int = 30;

		public static const BLOCK_DIMENSION : int = 10;

		public static const WAYPOINT_DIST_THRESHOLD : int = 12;

		private static const GRID_ERASE : BitmapData = new BitmapData(GRID_WIDTH, GRID_HEIGHT, true, 0x00000000);

		public static function drawGrids(grid : BigBitmap, rowBlocks : int, colBlocks : int) : void
		{
			if (rowBlocks * colBlocks == 0)
			{
				return;
			}

			grid.clear();

			var lineRect : Rectangle = new Rectangle();

			lineRect.width = colBlocks * BLOCK_DIMENSION * GRID_WIDTH + 1;
			lineRect.height = 1;
			lineRect.x = 0;
			var maxY : int = rowBlocks * BLOCK_DIMENSION * GRID_HEIGHT;
			for (lineRect.y = 0; lineRect.y <= maxY; lineRect.y += GRID_HEIGHT)
			{
				grid.fillRect(lineRect, 0xFF000000);
			}

			lineRect.height = rowBlocks * BLOCK_DIMENSION * GRID_HEIGHT + 1;
			lineRect.width = 1;
			lineRect.y = 0;
			var maxX : int = colBlocks * BLOCK_DIMENSION * GRID_WIDTH;
			for (lineRect.x = 0; lineRect.x <= maxX; lineRect.x += GRID_WIDTH)
			{
				grid.fillRect(lineRect, 0xFF000000);
			}
		}

		public static function drawMask(grid : BigBitmap, maskDic : Dictionary) : void
		{
			for (var key : String in maskDic)
			{
				if (!maskDic[key])
				{
					continue;
				}

				var maskArray : Array = key.split(",");
				var maskX : int = parseInt(maskArray[0]);
				var maskY : int = parseInt(maskArray[1]);

				var brush : Brush = Brush(maskDic[key]);

				grid.copyPixels(brush.icon, new Point(maskX * GRID_WIDTH, maskY * GRID_HEIGHT));
			}
		}

		public static function drawMaskBit(grid : BigBitmap, gridX : int, gridY : int, brush : Brush, eraseMode : Boolean = false) : void
		{
			grid.copyPixels(eraseMode ? GRID_ERASE : brush.icon, new Point(gridX * GRID_WIDTH, gridY * GRID_HEIGHT));
		}

		public static function globalToGrid(point : Point) : Point
		{
			return new Point(Math.floor(point.x / GRID_WIDTH), Math.floor(point.y / GRID_HEIGHT));
		}

		public static function gridToGlobal(point : Point) : Point
		{
			return new Point(point.x * GRID_WIDTH, point.y * GRID_HEIGHT);
		}

		public static function drawMaskRect(grid : BigBitmap, rect : Rectangle, brush : Brush, eraseMode : Boolean = false) : void
		{
			for (var i : int = rect.x; i < rect.right; i++)
			{
				for (var j : int = rect.y; j < rect.bottom; j++)
				{
					drawMaskBit(grid, i, j, brush, eraseMode);
				}
			}
		}

		public static function connectGrids(grid1 : Point, grid2 : Point, line : Line) : void
		{
			if (Math.abs(grid1.x - grid2.x) < 1
				&& Math.abs(grid1.y - grid2.y) < 1)
			{
				line.visible = false;
			}
			else
			{
				line.visible = true;

				line.xFrom = grid1.x * GRID_WIDTH + (GRID_WIDTH >> 1);
				line.xTo = grid2.x * GRID_WIDTH + (GRID_WIDTH >> 1);
				line.yFrom = grid1.y * GRID_HEIGHT + (GRID_HEIGHT >> 1);
				line.yTo = grid2.y * GRID_HEIGHT + (GRID_HEIGHT >> 1);
			}
		}

		public static function distance(obj1 : DomObject, obj2 : DomObject) : Number
		{
			return Point.distance(new Point(obj1.x, obj1.y), new Point(obj2.x, obj2.y));
		}

		public static function getPathBetween(grid1 : Point, grid2 : Point) : Vector.<Point>
		{
			var result : Vector.<Point> = new Vector.<Point>();

			var dx : Number = (grid2.x - grid1.x) * GRID_WIDTH;
			var dy : Number = (grid2.y - grid1.y) * GRID_HEIGHT;
			var steps : int = Math.max(Math.abs(dx), Math.abs(dy));

			var lastGrid : Point = null;

			for (var i : int = 0; i <= steps; i++)
			{
				var point : Point = new Point(grid1.x * GRID_WIDTH + GRID_WIDTH / 2 + dx * i / steps,
					grid1.y * GRID_HEIGHT + GRID_HEIGHT / 2 + dy * i / steps);
				var grid : Point = globalToGrid(point);

				if (!lastGrid ||
					!grid.equals(lastGrid))
				{
					result.push(grid);
					lastGrid = grid;
				}
			}

			return result;
		}
	}
}
