package v9.model.swf.vo
{
	import v9.model.swf.exporters.IExporterBackend;

	import com.codeazur.as3swf.tags.ITag;
	import com.codeazur.as3swf.tags.TagDefineMorphShape;

	import flash.display.IGraphicsData;

	[Bindable]
	public class SWFShapeVO extends SWFCharacterVO
	{
		public var isMorphShape:Boolean;
		public var graphicsDataCache:Vector.<IGraphicsData>;
		
		public function SWFShapeVO(tag:ITag = null)
		{
			super(tag);
			isMorphShape = (tag is TagDefineMorphShape);
		}

		public override function export(backend:IExporterBackend):void {
			backend.createShapeExporter().export(this);
		}
		
		override public function get name():String { return isMorphShape ? SWFCharacterVO.NAME_MORPHSHAPE : SWFCharacterVO.NAME_SHAPE; }
		override public function get superClassName():String { return "flash.display.Shape"; }
		override public function get hasAsset():Boolean { return false; }
	}
}