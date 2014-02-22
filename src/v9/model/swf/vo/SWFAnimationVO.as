package v9.model.swf.vo
{
	import v9.model.swf.exporters.IExporterBackend;

	import com.codeazur.as3swf.tags.ITag;

	[Bindable]
	public class SWFAnimationVO extends SWFCharacterVO
	{
		public var numFrames:uint;
		public var numLayers:uint;
		
		public function SWFAnimationVO(tag:ITag = null)
		{
			super(tag);
		}

		override public function get name():String { return SWFCharacterVO.NAME_MOVIECLIP; }
		override public function get superClassName():String { return "flash.display.MovieClip"; }
		override public function get hasAsset():Boolean { return false; }
		
		public override function export(backend:IExporterBackend):void {
			backend.createAnimationExporter().export(this);
		}
	}
}
