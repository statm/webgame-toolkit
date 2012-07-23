package statm.dev.mapeditor.ui
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.sampler.getLexicalScopes;
	import flash.utils.Dictionary;
	
	import spark.core.SpriteVisualElement;
	
	import statm.dev.mapeditor.utils.assert;


	/**
	 * 无限大位图。
	 *
	 * @author statm
	 *
	 */
	public class BigBitmap extends SpriteVisualElement
	{
		private var UNIT_WIDTH : int;
		private var UNIT_HEIGHT : int;

		public function BigBitmap(unitWidth : int = 600, unitHeight : int = 600) : void
		{
			super();

			UNIT_WIDTH = unitWidth;
			UNIT_HEIGHT = unitHeight;
		}

		private var tileDic : Dictionary = new Dictionary();

		private function globalToTile(x : Number, y : Number) : Point
		{
			return new Point(Math.floor(x / UNIT_WIDTH), Math.floor(y / UNIT_HEIGHT));
		}

		private function hasTile(tileCoord : Point) : Boolean
		{
			return (tileDic[tileCoord.x + "," + tileCoord.y] != null);
		}

		public function getTile(tileCoord : Point) : BitmapData
		{
			if (hasTile(tileCoord))
			{
				return tileDic[tileCoord.x + "," + tileCoord.y];
			}

			var tileBitmapData : BitmapData = new BitmapData(UNIT_WIDTH, UNIT_HEIGHT, true,
				0x00000000);
			var tile : Bitmap = new Bitmap(tileBitmapData);

			tile.x = tileCoord.x * UNIT_WIDTH;
			tile.y = tileCoord.y * UNIT_HEIGHT;

			tileDic[tileCoord.x + "," + tileCoord.y] = tileBitmapData;

			this.addChild(tile);

			return tileBitmapData;
		}

		private function getTileRect(tileCoord : Point) : Rectangle
		{
			return new Rectangle(tileCoord.x * UNIT_WIDTH, tileCoord.y * UNIT_HEIGHT, UNIT_WIDTH,
				UNIT_HEIGHT);
		}

		public function copyPixels(sourceBitmapData : BitmapData, destPoint : Point) : void
		{
			var rect : Rectangle = sourceBitmapData.rect;
			rect.offsetPoint(destPoint);

			var xMin : int = Math.floor(rect.x / UNIT_WIDTH);
			var xMax : int = Math.ceil(rect.right / UNIT_WIDTH);
			var yMin : int = Math.floor(rect.y / UNIT_HEIGHT);
			var yMax : int = Math.ceil(rect.bottom / UNIT_HEIGHT);
			
			assert(xMin >= 0);
			assert(yMin >= 0);
			assert(xMax >= xMin);
			assert(yMax >= yMin);

			for (var i : int = xMin; i < xMax; i++)
			{
				for (var j : int = yMin; j < yMax; j++)
				{
					var tileCoord : Point = new Point(i, j); // 格子坐标
					var tileRect : Rectangle = getTileRect(tileCoord); // 格子的像素框
					var intersect : Rectangle = rect.intersection(tileRect); // 实际绘制的像素区域

					getTile(tileCoord).copyPixels(sourceBitmapData,
						new Rectangle(intersect.x - destPoint.x,
						intersect.y - destPoint.y,
						intersect.width,
						intersect.height),
						new Point(intersect.x - tileRect.x, intersect.y - tileRect.y));
				}
			}
		}

		public function clear() : void
		{
			for each (var tileBitmapData : BitmapData in tileDic)
			{
				tileBitmapData.fillRect(tileBitmapData.rect, 0x00000000);
			}
		}

		public function fillRect(rect : Rectangle, color : uint) : void
		{
			var xMin : int = Math.floor(rect.x / UNIT_WIDTH);
			var xMax : int = Math.ceil(rect.right / UNIT_WIDTH);
			var yMin : int = Math.floor(rect.y / UNIT_HEIGHT);
			var yMax : int = Math.ceil(rect.bottom / UNIT_HEIGHT);
			
			assert(xMin >= 0);
			assert(yMin >= 0);
			assert(xMax >= xMin);
			assert(yMax >= yMin);

			for (var i : int = xMin; i < xMax; i++)
			{
				for (var j : int = yMin; j < yMax; j++)
				{
					var tileCoord : Point = new Point(i, j);
					var tileRect : Rectangle = getTileRect(tileCoord);
					var intersection : Rectangle = getTileRect(tileCoord).intersection(rect);
					intersection.offset(-tileRect.x, -tileRect.y);

					getTile(tileCoord).fillRect(intersection, color);
				}
			}
		}

		[Bindable]
		override public function get visible() : Boolean
		{
			return super.visible;
		}

		override public function set visible(value : Boolean) : void
		{
			super.visible = value;
		}
	}
}
