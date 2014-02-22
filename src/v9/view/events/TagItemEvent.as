package v9.view.events
{
	import v9.model.swf.vo.SWFTagVO;

	import flash.events.Event;

	public class TagItemEvent extends Event
	{
		public static const CHANGE:String = "tagItemChange";
		
		public var item:SWFTagVO;
		
		public function TagItemEvent(type:String, item:SWFTagVO, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.item = item;
		}
	}
}
