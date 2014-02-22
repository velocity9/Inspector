package v9.model
{
	import v9.events.V9EditorViewEvent;
	import v9.model.swf.vo.SWFCharacterVO;
	import v9.model.swf.vo.SWFTagVO;

	import org.robotlegs.mvcs.Actor;

	public class V9EditorViewModel extends Actor
	{
		public static const ITEM_TYPE_CHARACTER:String = "itemTypeCharacter";
		public static const ITEM_TYPE_TAG:String = "itemTypeTag";
		
		private var _activeItem:Object;
		
		public function V9EditorViewModel()
		{
		}

		public function get activeItem():Object {
			return _activeItem;
		}
		public function set activeItem(value:Object):void {
			if(_activeItem != value) {
				_activeItem = value;
				dispatch(new V9EditorViewEvent(V9EditorViewEvent.ITEM_CHANGED, value));
			}
		}
		
		public function get activeItemType():String {
			if(characterVO) {
				return ITEM_TYPE_CHARACTER;
			} else if(tagVO) {
				return ITEM_TYPE_TAG;
			} else {
				return null;
			}
		}
		
		public function get characterVO():SWFCharacterVO {
			return _activeItem as SWFCharacterVO;
		}

		public function get tagVO():SWFTagVO {
			return _activeItem as SWFTagVO;
		}
	}
}
