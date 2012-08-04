package statm.dev.imageresourceviewer.data.resource
{
	import flash.utils.Dictionary;

	import mx.collections.ArrayCollection;

	import statm.dev.imageresourceviewer.data.Element;
	import statm.dev.imageresourceviewer.data.type.ResourceType;

	/**
	 * 资源库。
	 *
	 * @author statm
	 *
	 */
	public class ResourceLib
	{
		[Bindable]
		public static var hero : ArrayCollection;

		[Bindable]
		public static var weapon : ArrayCollection;

		[Bindable]
		public static var mount : ArrayCollection;

		[Bindable]
		public static var npc : ArrayCollection;

		[Bindable]
		public static var mob : ArrayCollection;

		[Bindable]
		public static var pet : ArrayCollection;

		[Bindable]
		public static var fx : ArrayCollection;

		[Bindable]
		public static var unknown : ArrayCollection;

		private static var heroDic : Dictionary;
		private static var weaponDic : Dictionary;
		private static var mountDic : Dictionary;
		private static var npcDic : Dictionary;
		private static var mobDic : Dictionary;
		private static var petDic : Dictionary;
		private static var fxDic : Dictionary;

		public static function reset() : void
		{
			hero = new ArrayCollection();
			weapon = new ArrayCollection();
			mount = new ArrayCollection();
			npc = new ArrayCollection();
			mob = new ArrayCollection();
			pet = new ArrayCollection();
			fx = new ArrayCollection();
			unknown = new ArrayCollection();

			heroDic = new Dictionary();
			weaponDic = new Dictionary();
			mountDic = new Dictionary();
			npcDic = new Dictionary();
			mobDic = new Dictionary();
			petDic = new Dictionary();
			fxDic = new Dictionary();
		}

		public static function addResource(resourceBatch : ResourceBatch) : void
		{
			if (resourceBatch.batchInfo.isComplete)
			{
				var type : String = resourceBatch.batchInfo.type;
				getLib(type).addItem(resourceBatch);
				getDic(type)[resourceBatch.batchInfo.name] = resourceBatch;
			}
			else
			{
				unknown.addItem(resourceBatch);
			}
		}

		private static function getElement(resourceBatch : ResourceBatch) : Element
		{
			
		}

		public static function getLib(type : String) : ArrayCollection
		{
			switch (type)
			{
				case ResourceType.HERO:
					return hero;

				case ResourceType.WEAPON:
					return weapon;

				case ResourceType.MOUNT:
					return mount;

				case ResourceType.NPC:
					return npc;

				case ResourceType.MOB:
					return mob;

				case ResourceType.PET:
					return pet;

				case ResourceType.FX:
					return fx;
			}

			throw new ArgumentError("Type 错误");
		}

		private static function getDic(type : String) : Dictionary
		{
			switch (type)
			{
				case ResourceType.HERO:
					return heroDic;

				case ResourceType.WEAPON:
					return weaponDic;

				case ResourceType.MOUNT:
					return mountDic;

				case ResourceType.NPC:
					return npcDic;

				case ResourceType.MOB:
					return mobDic;

				case ResourceType.PET:
					return petDic;

				case ResourceType.FX:
					return fxDic;
			}

			throw new ArgumentError("Type 错误");
		}

		public static function print() : void
		{
			trace(hero.length);
			trace(weapon.length);
			trace(mount.length);
			trace(npc.length);
			trace(mob.length);
			trace(pet.length);
			trace(fx.length);
		}
	}
}
