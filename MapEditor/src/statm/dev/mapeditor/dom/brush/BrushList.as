package statm.dev.mapeditor.dom.brush
{
	import mx.collections.ArrayCollection;
	
	import statm.dev.mapeditor.io.IXMLSerializable;
	import statm.dev.mapeditor.ui.UIResource;

	/**
	 * 画笔列表。
	 *
	 * @author renjie.zh
	 *
	 */
	public class BrushList implements IXMLSerializable
	{
		public function BrushList(enforcer : SingletonEnforcer) : void
		{
			addBrush(new Brush("可行走",
				new XMLList(""),
				new UIResource.WALK_ICON().bitmapData,
				BrushType.WALKING));
			addBrush(new Brush("行走半透明",
				new XMLList(""),
				new UIResource.WALK_OPAQUE_ICON().bitmapData,
				BrushType.WALKING_OPAQUE));
			addBrush(new Brush("PVE",
				new XMLList("<battleType>PVP</battleType>"),
				new UIResource.PVE_ICON().bitmapData,
				BrushType.COMBAT));
			addBrush(new Brush("PVE/PVP",
				new XMLList(""),
				new UIResource.PVE_AND_PVP_ICON().bitmapData,
				BrushType.COMBAT));
			addBrush(new Brush("PVP",
				new XMLList("<battleType>PVE</battleType>"),
				new UIResource.PVP_ICON().bitmapData,
				BrushType.COMBAT));
		}

		public var regionBrushes : ArrayCollection = new ArrayCollection();

		public var walkingBrushes : ArrayCollection = new ArrayCollection();

		public var walkingOpaqueBrushes : ArrayCollection = new ArrayCollection();

		public var combatBrushes : ArrayCollection = new ArrayCollection();

		public function toXML() : XML
		{
			var result : XML = <brushList/>;
			var brush : Brush;

			for each (brush in regionBrushes)
			{
				result.appendChild(brush.toXML());
			}

			for each (brush in walkingBrushes)
			{
				result.appendChild(brush.toXML());
			}

			for each (brush in walkingOpaqueBrushes)
			{
				result.appendChild(brush.toXML());
			}

			for each (brush in combatBrushes)
			{
				result.appendChild(brush.toXML());
			}

			return result;
		}

		public function readXML(xml : XML) : void
		{
			regionBrushes.removeAll();
			walkingBrushes.removeAll();
			walkingOpaqueBrushes.removeAll();
			combatBrushes.removeAll();
			brushArray.length = 0;

			var brushList : XMLList = xml.brush;

			for each (var brushXML : XML in brushList)
			{
				var brush : Brush = new Brush();
				brush.readXML(brushXML);
				addBrush(brush);
			}
		}

		private function addBrush(brush : Brush) : void
		{
			switch (brush.type)
			{
				case BrushType.REGION:
					regionBrushes.addItem(brush);
					break;

				case BrushType.WALKING:
					walkingBrushes.addItem(brush);
					break;

				case BrushType.WALKING_OPAQUE:
					walkingOpaqueBrushes.addItem(brush);
					break;

				case BrushType.COMBAT:
					combatBrushes.addItem(brush);
					break;
			}

			brushArray[brush.id] = brush;
		}

		private var brushArray : Array = [];

		public function getBrushById(id : int) : Brush
		{
			return brushArray[id];
		}

		private static var currentInstance : BrushList;

		public static function getInstance() : BrushList
		{
			return currentInstance;
		}

		public static function createInstance() : BrushList
		{
			currentInstance = new BrushList(new SingletonEnforcer());
			return currentInstance;
		}
	}
}

class SingletonEnforcer
{
}
