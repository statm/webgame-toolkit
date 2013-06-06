package statm.dev.libs.imageplayer.utils
{
    import flash.filesystem.File;

    /**
     * 文件工具类。
     *
     * @author statm
     *
     */
    public class FileUtils
    {
        public static function filterImageFiles(folder:File):Array
        {
            var files:Array = folder.getDirectoryListing();
            var i:int = files.length;
            while (--i > -1)
            {
                isValidImageFile(files[i].name) || files.splice(i, 1);
            }

            return files;
        }

        public static function isValidImageFile(file:File):Boolean
        {
            var acceptedExt:Array = [ "jpg", "jpeg", "bmp", "png" ];

            return acceptedExt.indexOf(file.extension) > -1;
        }

        public static function compareFiles(a:Object, b:Object, fields:Array = null):int
        {
            var result:int = a.name.localeCompare(b.name);
            if (result == 0)
            {
                return 0;
            }
            else
            {
                return result / Math.abs(result);
            }
        }
    }
}
