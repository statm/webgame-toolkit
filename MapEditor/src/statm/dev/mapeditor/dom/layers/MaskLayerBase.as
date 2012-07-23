package statm.dev.mapeditor.dom.layers
{
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import statm.dev.mapeditor.app.AppState;
	import statm.dev.mapeditor.app.MapEditingActions;
	import statm.dev.mapeditor.dom.DomNode;
	import statm.dev.mapeditor.dom.brush.Brush;
	import statm.dev.mapeditor.dom.brush.BrushList;
	import statm.dev.mapeditor.dom.brush.BrushType;
	import statm.dev.mapeditor.ui.BigBitmap;
	import statm.dev.mapeditor.utils.GridUtils;


	/**
	 * DOM 对象：掩码层（抽象）。
	 *
	 * @author renjie.zh
	 *
	 */
	public class MaskLayerBase extends DomNode
	{
		public function MaskLayerBase(root : DomNode)
		{
			super(root);
		}

		protected var maskDic : Dictionary = new Dictionary();

		public function getMask(gridX : int, gridY : int) : Brush
		{
			return maskDic[gridX + "," + gridY];
		}

		public function setMask(gridX : int, gridY : int, mask : Brush) : void
		{
			if (maskDic[gridX + "," + gridY] == mask)
			{
				return;
			}

			if (mask.type == BrushType.ERASE)
			{
				delete maskDic[gridX + "," + gridY];
			}
			else
			{
				maskDic[gridX + "," + gridY] = mask;
			}

			if (_display)
			{
				GridUtils.drawMaskBit(BigBitmap(_display), gridX, gridY, mask, mask.type == BrushType.ERASE);
			}
			
			notifyChange(MapEditingActions.DRAW_MASK);
		}

		public function setMaskRect(rect : Rectangle, mask : Brush) : void
		{
			var i : int;
			var j : int;

			if (mask.type != BrushType.ERASE)
			{
				for (i = rect.x; i < rect.right; i++)
				{
					for (j = rect.y; j < rect.bottom; j++)
					{
						maskDic[i + "," + j] = mask;
					}
				}
			}
			else
			{
				for (i = rect.x; i < rect.right; i++)
				{
					for (j = rect.y; j < rect.bottom; j++)
					{
						delete maskDic[i + "," + j];
					}
				}
			}

			GridUtils.drawMaskRect(BigBitmap(_display), rect, mask, mask.type == BrushType.ERASE);
			
			notifyChange(MapEditingActions.DRAW_MASK);
		}

		override public function set display(display : Object) : void
		{
			super.display = display;

			if (!display)
			{
				return;
			}

			GridUtils.drawMask(BigBitmap(display), maskDic);
		}

		override public function select() : void
		{
			AppState.setCurrentMaskLayer(this);
		}
		
		override public function deselect():void
		{
			AppState.stopDrawingMask();
		}

		override public function toXML() : XML
		{
			var result : XML = <maskLayer/>;

			for (var key : String in maskDic)
			{
				if (!maskDic[key])
				{
					continue;
				}

				var maskArray : Array = key.split(",");
				var maskX : int = parseInt(maskArray[0]);
				var maskY : int = parseInt(maskArray[1]);

				result.appendChild(<mask x={maskX} y={maskY} brush={maskDic[key].id}/>);
			}

			return result;
		}

		override public function readXML(xml : XML) : void
		{
			maskDic = new Dictionary();

			var maskList : XMLList = xml.mask;
			for each (var maskXML : XML in xml.mask)
			{
				maskDic[maskXML.@x + "," + maskXML.@y] = BrushList.getInstance().getBrushById(parseInt(maskXML.@brush));
			}
		}
	}
}
