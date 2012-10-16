package statm.dev.npceditor.dom.objects
{
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.utils.Dictionary;

	import mx.collections.ArrayCollection;
	import mx.core.IVisualElement;
	import mx.graphics.SolidColorStroke;

	import spark.components.Group;
	import spark.primitives.Line;

	import statm.dev.npceditor.dom.DomNode;
	import statm.dev.npceditor.dom.Map;
	import statm.dev.npceditor.dom.item.ItemFactory;
	import statm.dev.npceditor.utils.GridUtils;


	/**
	 * DOM 对象：连接点。
	 *
	 * @author statm
	 *
	 */
	public class LinkPoint extends Item
	{
		public function LinkPoint(root : DomNode)
		{
			super(root);
			_name = "连接点";
			display = new Group();
			display.addElement(_iconImage);
			_children = new ArrayCollection();
		}

		public function addLinkDestination(dest : LinkDestPoint) : void
		{
			display.addElement(IVisualElement(dest.display));
			_children.addItem(dest);
			dest.parent = this;
		}

		public function removeLinkDestination(dest : LinkDestPoint) : void
		{
			display.removeElement(IVisualElement(dest.display));
			if (arrowLines[dest])
			{
				display.removeElement(IVisualElement(arrowLines[dest]));
			}
			_children.removeItemAt(_children.getItemIndex(dest));
		}

		override protected function mouseDownHandler(event : MouseEvent) : void
		{
			for each (var child : LinkDestPoint in _children)
			{
				if (child.display
					&& child.display.owns(event.target))
				{
					return;
				}
			}

			super.mouseDownHandler(event);
		}

		override public function set x(value : int) : void
		{
			var dx : int = value - _x;
			super.x = value;
			for each (var child : LinkDestPoint in _children)
			{
				child.x -= dx;
			}
		}

		override public function set y(value : int) : void
		{
			var dy : int = value - _y;
			super.y = value;
			for each (var child : LinkDestPoint in _children)
			{
				child.y -= dy;
			}
		}

		private var arrowLines : Dictionary = new Dictionary();

		public function redrawArrow(dest : LinkDestPoint) : void
		{
			var line : Line = arrowLines[dest];

			if (dest.mapID != Map(root).mapID)
			{
				dest.display.visible = false;
				if (line)
				{
					Group(this.display).removeElement(line);
					delete arrowLines[dest];
				}
				return;
			}

			dest.display.visible = true;

			if (!line)
			{
				arrowLines[dest] = line = new Line();
				Group(this.display).addElement(line);
			}

			line.stroke = new SolidColorStroke(0xFF0000, 1);
			line.depth = -1000;

			GridUtils.connectGrids(new Point(0, 0), new Point(dest.x - this.x, dest.y - this.y), line);
		}

		override public function select() : void
		{
			var filterArray : Array = [new GlowFilter(0xFF9900)];
			this._iconImage.filters = filterArray;
			for each (var child : LinkDestPoint in _children)
			{
				child.display.filters = filterArray;
			}
			_selectionRect.x = _border.x;
			_selectionRect.y = _border.y;
			_selectionRect.width = _border.width;
			_selectionRect.height = _border.height;
			displayGroup.addElement(_selectionRect);
		}

		override public function deselect() : void
		{
			this._iconImage.filters = [];
			for each (var child : LinkDestPoint in _children)
			{
				child.display.filters = [];
			}
			displayGroup.removeElement(_selectionRect);
		}

		override public function toXML() : XML
		{
			var result : XML = <linkPoint x={x} y={y}>
					<destinations/>
				</linkPoint>;

			for each (var dest : LinkDestPoint in _children)
			{
				result.destinations.appendChild(dest.toXML());
			}

			return result;
		}

		override public function readXML(xml : XML) : void
		{
			this.x = xml.@x;
			this.y = xml.@y;

			for each (var destXML : XML in xml.destinations.linkDestPoint)
			{
				addLinkDestination(LinkDestPoint(ItemFactory.createItemFromXML(destXML)));
			}
		}
	}
}
