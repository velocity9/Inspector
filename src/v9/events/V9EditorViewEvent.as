package v9.events
{
	import v9.model.swf.vo.SWFCharacterVO;
	import v9.model.swf.vo.SWFTagVO;

	import flash.events.Event;

	public class V9EditorViewEvent extends Event
	{
		private static const NAME:String = "V9EditorViewEvent";
		
		public static const ITEM_CHANGE:String = NAME + "ItemChange";
		 
		public static const ITEM_CHANGED:String = NAME + "ItemChanged";
		
		public var item:Object;
		
		public function V9EditorViewEvent(type:String, item:Object, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.item = item;
		}
		
		public function get characterVO():SWFCharacterVO
		{
			return item as SWFCharacterVO;
		}
		
		public function get tagVO():SWFTagVO
		{
			return item as SWFTagVO;
		}
		
		public override function clone():Event
		{
			return new V9EditorViewEvent(type, item, bubbles, cancelable);
		}
	}
}
