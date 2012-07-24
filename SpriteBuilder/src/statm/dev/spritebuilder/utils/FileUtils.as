package statm.dev.spritebuilder.utils
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
		public static function filterImageFiles(folder : File) : Array
		{
			var files : Array = folder.getDirectoryListing();
			var i : int = files.length;
			while (--i > -1)
			{
				isValidImageFile(files[i]) || files.splice(i, 1);
			}

			return files;
		}

		private static function isValidImageFile(file : File) : Boolean
		{
			var acceptedExt : Array = ["jpg", "jpeg", "bmp", "png"];

			var fileName : String = file.name.split(".")[0];
			var l : int = fileName.length;
			for (var i : int = 0; i < l; i++)
			{
				if (fileName.charCodeAt(i) < "0".charCodeAt()
					|| fileName.charCodeAt(i) > "9".charCodeAt())
				{
					return false;
				}
			}

			return acceptedExt.indexOf(file.extension) > -1;
		}

		public static function compareFiles(a : Object, b : Object, fields : Array) : int
		{
			var id1 : int = parseInt(a.name.split(".")[0]);
			var id2 : int = parseInt(b.name.split(".")[0]);

			if (id1 > id2)
			{
				return 1;
			}
			else if (id1 == id2)
			{
				return 0;
			}
			else
			{
				return -1;
			}
		}
	}
}
