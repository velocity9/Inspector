package v9.view.editor
{
	import v9.events.V9EditorViewEvent;
	import v9.model.SWFModel;
	import v9.model.V9EditorViewModel;
	import v9.model.swf.exporters.SpriteExporterBackend;
	import v9.model.swf.vo.SWFAnimationVO;
	import v9.model.swf.vo.SWFCharacterVO;
	import v9.view.events.FrameNumberEvent;

	import com.codeazur.as3swf.SWFTimelineContainer;

	import org.robotlegs.mvcs.Mediator;
	
	public class EditorMainPanelAnimationMediator extends Mediator
	{
		[Inject]
		public var view:EditorMainPanelAnimation;
		
		[Inject]
		public var swfModel:SWFModel;
		
		[Inject]
		public var viewModel:V9EditorViewModel;
		
		public function EditorMainPanelAnimationMediator()
		{
			super();
		}
		
		public override function onRegister():void
		{
			eventMap.mapListener(eventDispatcher, V9EditorViewEvent.ITEM_CHANGED, itemChangedHandler);
			//eventMap.mapListener(view.exportButton, MouseEvent.CLICK, exportClickHandler);
			eventMap.mapListener(view.frameSelectorComponent, FrameNumberEvent.CHANGE, frameNumberChangeHandler);

			itemChange();
		}
		
		public override function onRemove():void
		{
			eventMap.unmapListener(eventDispatcher, V9EditorViewEvent.ITEM_CHANGED, itemChangedHandler);
			//eventMap.unmapListener(view.exportButton, MouseEvent.CLICK, exportClickHandler);
			eventMap.unmapListener(view.frameSelectorComponent, FrameNumberEvent.CHANGE, frameNumberChangeHandler);
		}

		private function itemChangedHandler(event:V9EditorViewEvent):void
		{
			itemChange();
		}

		private function frameNumberChangeHandler(event:FrameNumberEvent):void
		{
			view.frameNumber = event.frameNumber;
			render(event.frameNumber);
		}

		private function itemChange():void
		{
			if(viewModel.characterVO && viewModel.characterVO.name == SWFCharacterVO.NAME_MOVIECLIP) {
				var timeline:SWFTimelineContainer = viewModel.characterVO.tag as SWFTimelineContainer;
				if(timeline == null) {
					timeline = swfModel.swf as SWFTimelineContainer;
				}
				view.timeline = timeline;
				view.frameNumber = 1;
				view.frameCount = timeline.frames.length;
				render(1);
			}
		}
		
		private function render(frameNumber:uint):void
		{
			if(viewModel.characterVO is SWFAnimationVO) {
				var backend:SpriteExporterBackend = new SpriteExporterBackend(swfModel.swf, frameNumber - 1);
				viewModel.characterVO.export(backend);
				view.content = backend.sprite;
			}
		}

		/*
		private function exportClickHandler(event:Event):void
		{
			var data:Object = {
				swf: swfModel.swf,
				swfTimeline: view.timeline
			};
			dispatch(new PopupEvent(PopupEvent.OPEN, new ExportAnimationPopup(), data));
		}
		*/
	}
}
