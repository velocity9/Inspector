package v9.model.swf.exporters
{
	import v9.model.swf.V9SWF;
	
	public interface IExporterBackend
	{
		function createAnimationExporter():IExporter;
		function createShapeExporter():IExporter;

		function get swf():V9SWF;
	}
}
