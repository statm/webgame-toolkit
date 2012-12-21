package statm.dev.mapeditor.utils
{
    import flash.display.BitmapData;
    import flash.utils.ByteArray;

    import mx.utils.Base64Decoder;
    import mx.utils.Base64Encoder;

    /**
     * 位图 - base64 编解码工具类。
     *
     * @author statm
     *
     */
    public class BitmapCODECUtils
    {
        public static function encode(bitmap:BitmapData):String
        {
            var result:String = "";

            if (bitmap)
            {
                var bitmapByteArray:ByteArray = bitmap.getPixels(bitmap.rect);
                bitmapByteArray.compress();
                var encoder:Base64Encoder = new Base64Encoder();
                encoder.encodeBytes(bitmapByteArray);
                result = encoder.flush();
            }

            return result;
        }

        public static function decode(base64:String, width:int, height:int):BitmapData
        {
            var result:BitmapData = new BitmapData(width, height, true, 0x00000000);

            var decoder:Base64Decoder = new Base64Decoder();
            decoder.decode(base64);
            var bitmapByteArray:ByteArray = decoder.flush();
            bitmapByteArray.uncompress();
            result.setPixels(result.rect, bitmapByteArray);

            return result;
        }
    }
}
