package statm.dev.imageresourceviewer
{
	import mx.collections.ArrayCollection;
	
	import statm.dev.imageresourceviewer.data.Element;
	import statm.dev.imageresourceviewer.data.resource.ResourceCategory;
	import statm.dev.imageresourceviewer.data.type.DirectionType;
	import statm.dev.imageresourceviewer.data.type.ResourceType;

	/**
	 * 应用程序状态。
	 *
	 * @author statm
	 *
	 */
	public class AppState
	{
		/**
		 * 当前选择的列表。
		 */
		[Bindable]
		public static var selectedCategory : ResourceCategory;

		/**
		 * 当前的列表模式，
		 * 只允许为 ResourceType.HERO、ResourceType.NPC、ResourceType.MOB、ResourceType.PET、ResourceType.FX、ResourceType.UNKNOWN。
		 */
		public static var categoryMode : String;

		/**
		 * 当前选择的动作。
		 */
		[Bindable]
		public static var currentAction : String;

		/**
		 * 当前的方向。
		 */
		[Bindable]
		public static var currentDirection : String = DirectionType.S;


		// 各层选中内容
		[Bindable]
		public static var selectedHero : Element = new Element("无", ResourceType.HERO);
		[Bindable]
		public static var selectedWeapon : Element = new Element("无", ResourceType.WEAPON);
		[Bindable]
		public static var selectedMount : Element = new Element("无", ResourceType.MOUNT);
		[Bindable]
		public static var selectedNPC : Element = new Element("无", ResourceType.NPC);
		[Bindable]
		public static var selectedMob : Element = new Element("无", ResourceType.MOB);
		[Bindable]
		public static var selectedPet : Element = new Element("无", ResourceType.PET);
		[Bindable]
		public static var selectedFX : Element = new Element("无", ResourceType.FX);
		[Bindable]
		public static var selectedUnknown : Element;

		[Bindable]
		public static var activeLayers : ArrayCollection = new ArrayCollection();

		[Bindable]
		public static var currentActions : ArrayCollection = new ArrayCollection();

		[Bindable]
		public static var fxEnabled : Boolean = true;
		
		[Bindable]
		public static var actionCount:int = 0;

		// 播放控制 
		[Bindable]
		public static var playing : Boolean = false;

		[Bindable]
		public static var currentFrame : int = 0;

		[Bindable]
		public static var frameTotal : int = 0;

		[Bindable]
		public static var frameRate : int = 15;

		[Bindable]
		public static var movingSpeed : int = 30;
	}
}
