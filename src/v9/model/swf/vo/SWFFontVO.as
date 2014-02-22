package v9.model.swf.vo
{
	import com.codeazur.as3swf.tags.ITag;
	import com.codeazur.as3swf.tags.TagDefineFont2;
	import com.codeazur.as3swf.tags.TagDefineFontAlignZones;
	import com.codeazur.as3swf.tags.TagDefineFontInfo;
	import com.codeazur.as3swf.tags.TagDefineFontName;

	[Bindable]
	public class SWFFontVO extends SWFCharacterVO
	{
		public var defineFontInfo:TagDefineFontInfo;
		public var defineFontName:TagDefineFontName;
		public var defineFontAlignZones:TagDefineFontAlignZones;
		
		public function SWFFontVO(tag:ITag)
		{
			super(tag);
		}
		
		public function get fontName():String {
			var defineFont2:TagDefineFont2 = tag as TagDefineFont2;
			if(defineFont2 != null) {
				return defineFont2.fontName;
			} else if (defineFontInfo != null) {
				 return defineFontInfo.fontName;
			}
			return null;
		}
		public function set fontName(value:String):void {}
		
		public function get fontCopyright():String {
			return (defineFontName != null) ? defineFontName.fontCopyright : null;
		}
		public function set fontCopyright(value:String):void {}
		
		override public function get name():String { return SWFCharacterVO.NAME_FONT; }
		override public function get superClassName():String { return "flash.text.Font"; }
	}
}
