package statm.dev.imageresourceviewer
{
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	import statm.dev.imageresourceviewer.data.Element;
	import statm.dev.imageresourceviewer.data.resource.ResourceCategory;
	import statm.dev.imageresourceviewer.data.type.DirectionType;

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
		 * 只允许为 ResourceType.HERO、ResourceType.NPC、ResourceType.MOB、ResourceType.PET、ResourceType.FX。
		 */
		public static var categoryMode : String;

		/**
		 * 当前选择的动作。
		 */
		public static var currentAction : String = "攻击";

		/**
		 * 当前的方向。
		 */
		public static var currentDirection : String = DirectionType.E;


		// 各层选中内容
		[Bindable]
		public static var selectedHero : Element;
		[Bindable]
		public static var selectedWeapon : Element;
		[Bindable]
		public static var selectedMount : Element;
		[Bindable]
		public static var selectedNPC : Element;
		[Bindable]
		public static var selectedMob : Element;
		[Bindable]
		public static var selectedPet : Element;
		[Bindable]
		public static var selectedFX : Element;

		[Bindable]
		public static var activeLayers : ArrayCollection = new ArrayCollection();

		// 播放控制 
		public static var playingBatches : Array = [];

		// TODO
	}
}
