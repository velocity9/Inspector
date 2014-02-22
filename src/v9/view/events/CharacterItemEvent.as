package v9.view.events
{
	import v9.model.swf.vo.SWFCharacterVO;

	import flash.events.Event;

	public class CharacterItemEvent extends Event
	{
		public static const CHANGE:String = "characterItemChange";
		
		public var item:SWFCharacterVO;
		
		public function CharacterItemEvent(type:String, item:SWFCharacterVO, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.item = item;
		}
	}
}
