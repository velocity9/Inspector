package v9.events
{
	import v9.model.swf.vo.SWFTagVO;
	
	import flash.events.Event;
	
	public class SetMainViewEvent extends Event
	{
		public static const SWITCH:String = "SetMainViewEvent_SWITCH";
		
		public var index:int;
		
		public function SetMainViewEvent(type:String, index:int)
		{
			super(type);
			this.index = index;
		}
		
		override public function clone():Event {
			return new SetMainViewEvent(type, index);
		}
	}
}