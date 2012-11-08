package statm.dev.imageresourceviewer
{
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	import statm.dev.imageresourceviewer.data.Action;
	import statm.dev.imageresourceviewer.data.Element;
	import statm.dev.imageresourceviewer.data.FXElement;
	import statm.dev.imageresourceviewer.data.resource.ResourceBatch;
	import statm.dev.imageresourceviewer.data.resource.ResourceCategory;
	import statm.dev.imageresourceviewer.data.type.DirectionType;
	import statm.dev.imageresourceviewer.data.type.ResourceType;

	/**
	 * 应用程序状态。
	 *
	 * @author statm
	 *
	 */
	public class AppState extends EventDispatcher
	{
		/**
		 * 当前选择的列表。
		 */
		[Bindable]
		public var selectedCategory : ResourceCategory;

		/**
		 * 当前的列表模式，
		 * 只允许为 ResourceType.HERO、ResourceType.NPC、ResourceType.MOB、ResourceType.PET、ResourceType.FX。
		 */
		public var categoryMode : String;

		/**
		 * 当前选择的动作。
		 */
		[Bindable]
		public var currentAction : String;

		/**
		 * 当前的方向。
		 */
		[Bindable]
		public var currentDirection : String = DirectionType.S;


		// 各层选中内容
		[Bindable]
		public var selectedHero : Element = new Element("无", ResourceType.HERO);
		[Bindable]
		public var selectedWeapon : Element = new Element("无", ResourceType.WEAPON);
		[Bindable]
		public var selectedMount : Element = new Element("无", ResourceType.MOUNT);
		[Bindable]
		public var selectedNPC : Element = new Element("无", ResourceType.NPC);
		[Bindable]
		public var selectedMob : Element = new Element("无", ResourceType.MOB);
		[Bindable]
		public var selectedPet : Element = new Element("无", ResourceType.PET);
		[Bindable]
		public var selectedFX : FXElement = new FXElement("无");

		[Bindable]
		public var playingElements : ArrayCollection = new ArrayCollection();

		[Bindable]
		public var currentActionList : ArrayCollection = new ArrayCollection();

		[Bindable]
		public var fxEnabled : Boolean = true;

		[Bindable]
		public var actionCount : int = 0;

		// 播放控制 
		[Bindable]
		public var playing : Boolean = false;

		[Bindable]
		public var currentFrame : int = 0;

		[Bindable]
		public var frameTotal : int = 0;

		private var _frameRate : int = 15;

		[Bindable]
		public function get frameRate() : int
		{
			return _frameRate;
		}

		public function set frameRate(value : int) : void
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
		public var movingSpeed : int = 30;

		// 单例
		private static var _instance : AppState = new AppState();

		public static function get instance() : AppState
		{
			return _instance;
		}
	}
}
