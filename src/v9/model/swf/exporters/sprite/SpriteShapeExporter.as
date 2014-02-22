package v9.model.swf.exporters.sprite
{
	import v9.exporters.V9GraphicsDataShapeExporter;
	import v9.model.swf.exporters.IExporter;
	import v9.model.swf.exporters.SpriteExporterBackend;
	import v9.model.swf.vo.SWFCharacterVO;
	import v9.model.swf.vo.SWFShapeVO;

	import com.codeazur.as3swf.tags.TagDefineMorphShape;
	import com.codeazur.as3swf.tags.TagDefineShape;

	import flash.display.IGraphicsData;
	
	public class SpriteShapeExporter implements IExporter
	{
		protected var backend:SpriteExporterBackend;
		
		public function SpriteShapeExporter(backend:SpriteExporterBackend)
		{
			this.backend = backend;
		}
		
		public function export(character:SWFCharacterVO):void
		{
			var shapeVO:SWFShapeVO = character as SWFShapeVO;
			if(shapeVO.graphicsDataCache == null) {
				var exporter:V9GraphicsDataShapeExporter = new V9GraphicsDataShapeExporter(backend.swf);
				var graphicsData:Vector.<IGraphicsData>;
				if(shapeVO.isMorphShape) {
					var defineMorphShape:TagDefineMorphShape = shapeVO.tag as TagDefineMorphShape;
					defineMorphShape.export(exporter, backend.currentSprite.frameNumber / 65535);
					graphicsData = exporter.graphicsData;
				} else {
					var defineShape:TagDefineShape = shapeVO.tag as TagDefineShape;
					defineShape.export(exporter);
					graphicsData = shapeVO.graphicsDataCache = exporter.graphicsData;
				}
				backend.currentSprite.graphics.drawGraphicsData(graphicsData);
			} else {
				backend.currentSprite.graphics.drawGraphicsData(shapeVO.graphicsDataCache);
			}
		}
	}
}
