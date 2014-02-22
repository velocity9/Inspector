package v9.view.editor
{
	import flash.events.MouseEvent;
	import flash.system.System;
	
	import org.robotlegs.mvcs.Mediator;
	
	import v9.events.V9EditorViewEvent;
	import v9.model.SWFModel;
	import v9.model.V9EditorViewModel;
	
	public class EditorMainPanelTagMediator extends Mediator
	{
		[Inject]
		public var view:EditorMainPanelTag;
		
		[Inject]
		public var swfModel:SWFModel;
		
		[Inject]
		public var viewModel:V9EditorViewModel;
		
		public function EditorMainPanelTagMediator()
		{
			super();
		}
		
		public override function onRegister():void
		{
			eventMap.mapListener(eventDispatcher, V9EditorViewEvent.ITEM_CHANGED, itemChangedHandler);
			eventMap.mapListener(view.clipboardButton, MouseEvent.CLICK, clipboardClickHandler);

			itemChange();
		}
		
		public override function onRemove():void
		{
			eventMap.unmapListener(eventDispatcher, V9EditorViewEvent.ITEM_CHANGED, itemChangedHandler);
		}

		private function itemChangedHandler(event:V9EditorViewEvent):void
		{
			itemChange();
		}

		private function itemChange():void
		{
			if(viewModel.tagVO) {
				view.tagVO = viewModel.tagVO;
			}
		}
		
		private function clipboardClickHandler(event:MouseEvent):void
		{
			System.setClipboard(viewModel.tagVO.tag.toString());
		}
	}
}
