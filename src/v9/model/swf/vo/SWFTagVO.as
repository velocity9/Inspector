package v9.model.swf.vo
{
	import com.codeazur.as3swf.data.SWFRecordHeader;
	import com.codeazur.as3swf.tags.IDefinitionTag;
	import com.codeazur.as3swf.tags.ITag;
	import com.codeazur.as3swf.tags.TagDefineSprite;
	import com.codeazur.as3swf.tags.TagEnd;
	import com.codeazur.as3swf.tags.TagShowFrame;
	
	import flash.display.IGraphicsData;

	[Bindable]
	public class SWFTagVO
	{
		public var tag:ITag;
		public var tagHeader:SWFRecordHeader;
		public var parent:SWFTagVO;
		public var expanded:Boolean = false;

		public var name:String;
		public var frame:uint;
		public var index:uint;
		public var size:uint;
		public var characterId:uint;
		
		public var children:Array;
		
		public var graphicsData:Vector.<IGraphicsData>;
		
		public function SWFTagVO(tag:ITag, tagHeader:SWFRecordHeader, index:uint, frame:uint, parent:SWFTagVO = null)
		{
			this.tag = tag;
			this.tagHeader = tagHeader;
			this.index = index;
			this.frame = frame;
			this.parent = parent;
			this.name = tag.name;
			this.characterId = (tag is IDefinitionTag) ? IDefinitionTag(tag).characterId : 0;

			this.children = [];
			
			if(tag.type == TagDefineSprite.TYPE) {
				initializeChildren();
			}
		}
		
		protected function initializeChildren():void {
			var child:ITag;
			var spriteFrame:uint = 1;
			var sprite:TagDefineSprite = tag as TagDefineSprite;
			var count:uint = sprite.tags.length;
			for(var i:uint = 0; i < count; i++) {
				child = sprite.tags[i];
				if(child.type != TagEnd.TYPE || i < count - 1) {
					children.push(new SWFTagVO(child, sprite.tagsRaw[i].header, i, spriteFrame, this));
					if(child.type == TagShowFrame.TYPE) {
						spriteFrame++;
					}
				}
			}
		}
	}
}
