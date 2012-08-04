package statm.dev.imageresourceviewer.data.type
{

	/**
	 * 资源类型。
	 *
	 * @author statm
	 *
	 */
	public class ResourceType
	{
		/**
		 * 角色/装备模型。
		 */
		public static const HERO : String = "角色";

		/**
		 * 武器模型。
		 */
		public static const WEAPON : String = "武器";

		/**
		 * NPC 模型。
		 */
		public static const NPC : String = "NPC";

		/**
		 * 怪物模型。
		 */
		public static const MOB : String = "怪物";

		/**
		 * 坐骑模型。
		 */
		public static const MOUNT : String = "坐骑";

		/**
		 * 宠物模型。
		 */
		public static const PET : String = "宠物";

		/**
		 * 特效模型。
		 */
		public static const FX : String = "特效";

		public static const typeList : Array = [HERO, WEAPON, NPC, MOB, MOUNT, PET, FX];
	}
}
