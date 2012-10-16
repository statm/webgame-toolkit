package statm.dev.npceditor.io
{

	/**
	 * XML 序列化接口。
	 *
	 * @author statm
	 *
	 */
	public interface IXMLSerializable
	{
		function toXML() : XML;

		function readXML(xml : XML) : void;
	}
}
