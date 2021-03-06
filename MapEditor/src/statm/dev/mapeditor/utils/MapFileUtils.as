package statm.dev.mapeditor.utils
{
    import statm.dev.mapeditor.dom.Map;

    /**
     * 地图文件编解码。
     *
     * @author statm
     *
     */
    public final class MapFileUtils
    {
        public static function mapToXML(map:Map):XML
        {
            return map.toXML();
        }

        public static function XMLToMap(xml:XML, map:Map):void
        {
            map.readXML(xml);
        }
    }
}
