package statm.dev.mapeditor.utils
{

    /**
     * 版本号工具类。
     *
     * @author statm
     *
     */
    public class VersionUtils
    {
        /**
         * 比较两个版本号。
         * <ul>
         * <li>如果版本号 <code>a</code> 大于 <code>b</code>，则返回1；</li>
         * <li>如果版本号 <code>a</code> 和 <code>b</code> 相同，则返回0；</li>
         * <li>如果版本号 <code>a</code> 小于 <code>b</code> 相同，则返回-1；</li>
         * </ul>
         *
         * @param a
         * @param b
         * @return
         *
         */
        public static function compareVersion(a:String, b:String):int
        {
            if (!a && !b)
            {
                return 0;
            }

            if (b && !a)
            {
                return -1;
            }

            if (a && !b)
            {
                return 1;
            }

            if (a.length == 0 && b.length == 0)
            {
                return 0;
            }

            if (b.length > 0 && a.length == 0)
            {
                return -1;
            }

            if (a.length > 0 && b.length == 0)
            {
                return 1;
            }

            var versionArr1:Array = a.split(".");
            var versionArr2:Array = b.split(".");

            if (versionArr1.length != 3 || versionArr2.length != 3)
            {
                throw new ArgumentError("版本号格式有误");
            }

            versionArr1[0] = parseInt(versionArr1[0]);
            versionArr1[1] = parseInt(versionArr1[1]);
            versionArr1[2] = parseInt(versionArr1[2]);
            versionArr2[0] = parseInt(versionArr2[0]);
            versionArr2[1] = parseInt(versionArr2[1]);
            versionArr2[2] = parseInt(versionArr2[2]);

            if (versionArr1[0] > versionArr2[0])
            {
                return 1;
            }
            else if (versionArr2[0] > versionArr1[0])
            {
                return -1;
            }

            if (versionArr1[1] > versionArr2[1])
            {
                return 1;
            }
            else if (versionArr2[1] > versionArr1[1])
            {
                return -1;
            }

            if (versionArr1[2] > versionArr2[2])
            {
                return 1;
            }
            else if (versionArr2[2] > versionArr1[2])
            {
                return -1;
            }

            return 0;
        }
    }
}
