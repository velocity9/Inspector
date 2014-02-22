package v9.model.swf.vo
{
	import com.codeazur.as3swf.tags.ITag;

	[Bindable]
	public class SWFButtonVO extends SWFCharacterVO
	{
		public function SWFButtonVO(tag:ITag = null)
		{
			super(tag);
		}

		override public function get name():String { return SWFCharacterVO.NAME_BUTTON; }
		override public function get superClassName():String { return "flash.display.SimpleButton"; }
		override public function get hasAsset():Boolean { return false; }
	}
}