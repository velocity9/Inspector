package v9.model.swf.exporters
{
	import v9.model.swf.vo.SWFCharacterVO;

	public interface IExporter
	{
		function export(character:SWFCharacterVO):void;
	}
}
