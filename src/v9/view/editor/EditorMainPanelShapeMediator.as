package v9.view.editor
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.robotlegs.mvcs.Mediator;
	
	import v9.events.PopupEvent;
	import v9.events.V9EditorViewEvent;
	import v9.model.SWFModel;
	import v9.model.V9EditorViewModel;
	import v9.model.swf.exporters.SpriteExporterBackend;
	import v9.model.swf.vo.SWFShapeVO;
	import v9.view.popups.ExportShapeCanvasPopup;
	import v9.view.popups.ExportShapePopup;
	
	public class EditorMainPanelShapeMediator extends Mediator
	{
		[Inject]
		public var view:EditorMainPanelShape;
		
		[Inject]
		public var swfModel:SWFModel;
		
		[Inject]
		public var viewModel:V9EditorViewModel;
		
		public function EditorMainPanelShapeMediator()
		{
			super();
		}
		
		public override function onRegister():void
		{
			eventMap.mapListener(eventDispatcher, V9EditorViewEvent.ITEM_CHANGED, itemChangedHandler);
			eventMap.mapListener(view.exportJSONButton, MouseEvent.CLICK, exportJSONClickHandler);
			eventMap.mapListener(view.exportCanvasButton, MouseEvent.CLICK, exportCanvasClickHandler);

			itemChange();
		}
		
		public override function onRemove():void
		{
			eventMap.unmapListener(eventDispatcher, V9EditorViewEvent.ITEM_CHANGED, itemChangedHandler);
			eventMap.unmapListener(view.exportJSONButton, MouseEvent.CLICK, exportJSONClickHandler);
			eventMap.unmapListener(view.exportCanvasButton, MouseEvent.CLICK, exportCanvasClickHandler);
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
			if(viewModel.characterVO is SWFShapeVO) {
				var backend:SpriteExporterBackend = new SpriteExporterBackend(swfModel.swf);
				viewModel.characterVO.export(backend);
				view.content = backend.sprite;
			}
		}

		private function exportJSONClickHandler(event:Event):void
		{
			var data:Object = {
				swf: swfModel.swf,
				characterVO: viewModel.characterVO
			};
			dispatch(new PopupEvent(PopupEvent.OPEN, new ExportShapePopup(), data));
		}
		
		private function exportCanvasClickHandler(event:Event):void
		{
			var data:Object = {
				swf: swfModel.swf,
					characterVO: viewModel.characterVO
			};
			dispatch(new PopupEvent(PopupEvent.OPEN, new ExportShapeCanvasPopup(), data));
		}
	}
}