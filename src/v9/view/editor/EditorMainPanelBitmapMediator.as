package v9.view.editor
{
	import v9.events.V9EditorViewEvent;
	import v9.model.SWFModel;
	import v9.model.V9EditorViewModel;
	import v9.model.swf.vo.SWFBitmapVO;

	import org.robotlegs.mvcs.Mediator;
	
	public class EditorMainPanelBitmapMediator extends Mediator
	{
		[Inject]
		public var view:EditorMainPanelBitmap;
		
		[Inject]
		public var swfModel:SWFModel;
		
		[Inject]
		public var viewModel:V9EditorViewModel;
		
		public function EditorMainPanelBitmapMediator()
		{
			super();
		}
		
		public override function onRegister():void
		{
			eventMap.mapListener(eventDispatcher, V9EditorViewEvent.ITEM_CHANGED, itemChangedHandler);

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
			render();
		}
		
		private function render():void
		{
			var bitmapVO:SWFBitmapVO = viewModel.characterVO as SWFBitmapVO;
			if(bitmapVO) {
				view.content = bitmapVO.render(swfModel.swf);
			}
		}
	}
}