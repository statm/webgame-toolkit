package statm.dev.mapeditor.utils
{

	/**
	 * 断言
	 *
	 * @author statm
	 *
	 */

	public function assert(value : Object) : void
	{
		if (!Boolean(value))
		{
			throw new Error("断言失败");
		}
	}
}
