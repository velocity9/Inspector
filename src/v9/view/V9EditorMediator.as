package v9.view
{
	import org.robotlegs.mvcs.Mediator;
	
	import v9.events.SWFParseEvent;
	import v9.events.SetMainViewEvent;
	import v9.events.V9EditorViewEvent;
	import v9.model.SWFModel;
	import v9.model.V9EditorViewModel;
	import v9.model.swf.V9SWF;
	import v9.model.swf.vo.SWFCharacterVO;
	import v9.view.events.CharacterItemEvent;
	import v9.view.events.TagItemEvent;
	
	public class V9EditorMediator extends Mediator
	{
		[Inject]
		public var view:V9Editor;
		
		[Inject]
		public var viewModel:V9EditorViewModel;
		
		[Inject]
		public var swfModel:SWFModel;
		
		public function V9EditorMediator()
		{
			super();
		}
		
		public override function onRegister():void
		{
			eventMap.mapListener(view, CharacterItemEvent.CHANGE, characterItemSelectionChangeHandler);
			eventMap.mapListener(view, TagItemEvent.CHANGE, tagItemSelectionChangeHandler);
			eventMap.mapListener(eventDispatcher, V9EditorViewEvent.ITEM_CHANGED, itemChangedHandler);
		}
		
		public override function onRemove():void
		{
			eventMap.unmapListener(view, CharacterItemEvent.CHANGE, characterItemSelectionChangeHandler);
			eventMap.unmapListener(view, TagItemEvent.CHANGE, tagItemSelectionChangeHandler);
			eventMap.unmapListener(eventDispatcher, V9EditorViewEvent.ITEM_CHANGED, itemChangedHandler);
		}

		private function itemChangedHandler(event:V9EditorViewEvent):void
		{
			var mainPanelVisible:Boolean = true;
			switch(viewModel.activeItemType) {
				case V9EditorViewModel.ITEM_TYPE_CHARACTER:
					switch(viewModel.characterVO.name) {
						case SWFCharacterVO.NAME_MOVIECLIP:
							view.mainPanel.selectedChild = view.animationNavItem;
							break;
						case SWFCharacterVO.NAME_SHAPE:
						case SWFCharacterVO.NAME_MORPHSHAPE:
							view.mainPanel.selectedChild = view.shapeNavItem;
							break;
						case SWFCharacterVO.NAME_BITMAP:
							view.mainPanel.selectedChild = view.bitmapNavItem;
							break;
						case SWFCharacterVO.NAME_BUTTON:
							// TODO: Implement button panel
							mainPanelVisible = false;
							break;
						case SWFCharacterVO.NAME_FONT:
							// TODO: Implement font panel
							mainPanelVisible = false;
							break;
						default:
							mainPanelVisible = false;
							break;
					}
					break;
				case V9EditorViewModel.ITEM_TYPE_TAG:
					view.mainPanel.selectedChild = view.tagNavItem;
					break;
			}
			view.navigation.unSelectAllBut(event.item);
			view.mainPanel.visible = mainPanelVisible;
			view.mainPanel.validateNow();
		}

		private function characterItemSelectionChangeHandler(event:CharacterItemEvent):void
		{
			dispatch(new V9EditorViewEvent(V9EditorViewEvent.ITEM_CHANGE, event.item));
		}
		
		private function tagItemSelectionChangeHandler(event:TagItemEvent):void
		{
			dispatch(new V9EditorViewEvent(V9EditorViewEvent.ITEM_CHANGE, event.item));
		}
	}
}