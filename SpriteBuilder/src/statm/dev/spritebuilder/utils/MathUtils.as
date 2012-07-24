package statm.dev.spritebuilder.utils
{

	/**
	 * 运算工具类。
	 *
	 * @author statm
	 *
	 */
	public class MathUtils
	{
		public static function range(value : Number, lowerBound : Number, upperBound : Number) : Number
		{
			if (lowerBound > upperBound)
			{
				throw new ArgumentError("lowerBound 不能大于 upperBound。");
			}

			if (value < lowerBound)
			{
				return lowerBound;
			}

			if (value > upperBound)
			{
				return upperBound;
			}

			return value;
		}
	}
}
