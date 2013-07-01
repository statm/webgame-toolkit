package statm.dev.imageresourceviewer
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	import statm.dev.imageresourceviewer.data.Action;
	import statm.dev.imageresourceviewer.data.Element;
	import statm.dev.imageresourceviewer.data.FXElement;
	import statm.dev.imageresourceviewer.data.resource.ResourceCategory;
	import statm.dev.imageresourceviewer.data.type.DirectionType;
	import statm.dev.imageresourceviewer.data.type.ResourceType;

	/**
	 * 应用程序状态。
	 *
	 * @author statm
	 *
	 */
	public final class AppState extends EventDispatcher
	{
		/**
		 * 当前选择的列表。
		 */
		[Bindable]
		public var selectedCategory:ResourceCategory;

		/**
		 * 当前的列表模式，
		 * 只允许为 ResourceType.HERO、ResourceType.NPC、ResourceType.MOB、ResourceType.PET、ResourceType.FX。
		 */
		public var categoryMode:String;

		/**
		 * 当前选择的动作。
		 */
		[Bindable]
		public var currentAction:String;

		/**
		 * 当前的方向。
		 */
		[Bindable]
		public var currentDirection:String = DirectionType.S;


		// 各层选中内容
		[Bindable]
		public var selectedHero:Element = new Element("无", ResourceType.HERO);
		[Bindable]
		public var selectedWeapon:Element = new Element("无", ResourceType.WEAPON);
		[Bindable]
		public var selectedWings:Element = new Element("无", ResourceType.WINGS);
		[Bindable]
		public var selectedMount:Element = new Element("无", ResourceType.MOUNT);
		[Bindable]
		public var selectedNPC:Element = new Element("无", ResourceType.NPC);
		[Bindable]
		public var selectedMob:Element = new Element("无", ResourceType.MOB);
		[Bindable]
		public var selectedPet:Element = new Element("无", ResourceType.PET);
		[Bindable]
		public var selectedFX:FXElement = new FXElement("无");

		[Bindable]
		public var playingElements:ArrayCollection = new ArrayCollection();

		[Bindable]
		public var currentActionList:ArrayCollection = new ArrayCollection();

		[Bindable]
		public var fxEnabled:Boolean = true;

		[Bindable]
		public var actionCount:int = 0;

		// 播放控制 
		[Bindable]
		public var playing:Boolean = false;

		[Bindable]
		public var currentFrame:int = 0;

		[Bindable]
		public var frameTotal:int = 0;

		private var _frameRate:int = ImageResourceViewer.DEFAULT_FRAME_RATE;

		[Bindable]
		public function get frameRate():int
		{
			return _frameRate;
		}

		public function set frameRate(value:int):void
		{
			if (value != _frameRate)
			{
				_frameRate = value;
				for each (var elem:Element in playingElements)
				{
					var action:Action = elem.getAction(currentAction);
					if (action)
					{
						action.frameRate = value;
					}
				}
			}
		}

		[Bindable]
		public var movingSpeed:int = 30;

		// 锚点
		private var _anchor:int = ImageResourceViewer.DEFAULT_ANCHOR;

		[Bindable(event = "anchorChanged")]
		public function get anchor():int
		{
			return _anchor;
		}

		public function set anchor(value:int):void
		{
			trace("anchor=" + value);
			_anchor = value;
			dispatchEvent(new Event("anchorChanged"));
			for each (var elem:Element in playingElements)
			{
				elem.anchor = _anchor;
			}
		}

		// 主图片尺寸
		private var _primaryImageHeight:int = ImageResourceViewer.DEFAULT_IMAGE_DIMENSION;

		[Bindable(event = "primaryImageHeightChanged")]
		public function get primaryImageHeight():int
		{
			return _primaryImageHeight;
		}

		public function set primaryImageHeight(value:int):void
		{
			trace("primaryImageHeight=" + value);
			_primaryImageHeight = value;
			dispatchEvent(new Event("primaryImageHeightChanged"));
		}
		
		// Y 偏移
		[Bindable]
		public var offsetY:int = 0;

		// 单例
		private static var _instance:AppState = new AppState();

		public static function get instance():AppState
		{
			return _instance;
		}
	}
}
