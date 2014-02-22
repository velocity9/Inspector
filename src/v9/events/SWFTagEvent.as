package v9.events
{
	import v9.model.swf.vo.SWFTagVO;
	
	import flash.events.Event;
	
	public class SWFTagEvent extends Event
	{
		public static const TAG_SELECTED:String = "tagSelected";
		
		public var tag:SWFTagVO;
		
		public function SWFTagEvent(type:String, tag:SWFTagVO = null)
		{
			super(type, true, true);
			this.tag = tag;
		}
		
		override public function clone():Event {
			return new SWFTagEvent(type, tag);
		}
	}
}