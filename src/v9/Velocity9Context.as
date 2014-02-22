package v9
{
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeDragManager;
	import flash.display.DisplayObjectContainer;
	import flash.events.NativeDragEvent;
	
	import org.robotlegs.base.ContextEvent;
	import org.robotlegs.mvcs.Context;
	
	import v9.controller.BrowseSWFCommand;
	import v9.controller.BrowserScrapeCommand;
	import v9.controller.ChangeEditorItemCommand;
	import v9.controller.ClosePopupCommand;
	import v9.controller.LoadSWFCommand;
	import v9.controller.OpenPopupCommand;
	import v9.controller.StartupCommand;
	import v9.controller.UpdaterCommand;
	import v9.events.BrowserScrapeEvent;
	import v9.events.PopupEvent;
	import v9.events.SWFEvent;
	import v9.events.UpdaterEvent;
	import v9.events.V9EditorViewEvent;
	import v9.exporters.SVGExporter;
	import v9.model.ArchiveModel;
	import v9.model.SWFModel;
	import v9.model.ScrapeQueueModel;
	import v9.model.UpdaterModel;
	import v9.model.V9EditorViewModel;
	import v9.services.ScrapeService;
	import v9.view.V9Browser;
	import v9.view.V9BrowserMediator;
	import v9.view.V9Editor;
	import v9.view.V9EditorMediator;
	import v9.view.V9Main;
	import v9.view.V9MainMediator;
	import v9.view.components.Footer;
	import v9.view.components.FooterMediator;
	import v9.view.components.Header;
	import v9.view.components.HeaderMediator;
	import v9.view.editor.EditorMainPanelAnimation;
	import v9.view.editor.EditorMainPanelAnimationMediator;
	import v9.view.editor.EditorMainPanelBitmap;
	import v9.view.editor.EditorMainPanelBitmapMediator;
	import v9.view.editor.EditorMainPanelShape;
	import v9.view.editor.EditorMainPanelShapeMediator;
	import v9.view.editor.EditorMainPanelTag;
	import v9.view.editor.EditorMainPanelTagMediator;
	import v9.view.popups.AppUpdateLoaderProgressPopup;
	import v9.view.popups.AppUpdateLoaderProgressPopupMediator;
	import v9.view.popups.ExportAnimationPopup;
	import v9.view.popups.ExportAnimationPopupMediator;
	import v9.view.popups.ExportShapeCanvasPopup;
	import v9.view.popups.ExportShapeCanvasPopupMediator;
	import v9.view.popups.ExportShapePopup;
	import v9.view.popups.ExportShapePopupMediator;
	import v9.view.popups.ParseSWFProgressPopup;
	import v9.view.popups.ParseSWFProgressPopupMediator;


	
	public class Velocity9Context extends Context
	{
		public function Velocity9Context(contextView:DisplayObjectContainer = null, autoStartup:Boolean = true)
		{
			super(contextView, autoStartup);
		}
		
		override public function startup():void
		{
			// Controller
			commandMap.mapEvent(SWFEvent.LOAD, LoadSWFCommand, SWFEvent);
			commandMap.mapEvent(SWFEvent.BROWSE, BrowseSWFCommand, SWFEvent);
			commandMap.mapEvent(PopupEvent.OPEN, OpenPopupCommand, PopupEvent);
			commandMap.mapEvent(PopupEvent.CLOSE, ClosePopupCommand, PopupEvent);
			commandMap.mapEvent(UpdaterEvent.UPDATE_CHECK, UpdaterCommand, UpdaterEvent);
			commandMap.mapEvent(UpdaterEvent.UPDATE_DOWNLOAD, UpdaterCommand, UpdaterEvent);
			commandMap.mapEvent(UpdaterEvent.UPDATE_INSTALL, UpdaterCommand, UpdaterEvent);
			commandMap.mapEvent(V9EditorViewEvent.ITEM_CHANGE, ChangeEditorItemCommand, V9EditorViewEvent);
			commandMap.mapEvent(ContextEvent.STARTUP_COMPLETE, StartupCommand, ContextEvent);
			commandMap.mapEvent(BrowserScrapeEvent.SCRAPE, BrowserScrapeCommand, BrowserScrapeEvent);
			
			// Model
			injector.mapSingleton(SWFModel);
			injector.mapSingleton(UpdaterModel);
			injector.mapSingleton(V9EditorViewModel);
			injector.mapSingleton(ScrapeQueueModel);
			injector.mapSingleton(ArchiveModel);
			
			// Services
			injector.mapSingleton(SVGExporter);
			injector.mapSingleton(ScrapeService);
			
			// View
			mediatorMap.mapView(V9Main, V9MainMediator);
			mediatorMap.mapView(V9Editor, V9EditorMediator);
			mediatorMap.mapView(V9Browser, V9BrowserMediator);
			mediatorMap.mapView(Header, HeaderMediator);
			mediatorMap.mapView(Footer, FooterMediator);
			mediatorMap.mapView(EditorMainPanelAnimation, EditorMainPanelAnimationMediator);
			mediatorMap.mapView(EditorMainPanelShape, EditorMainPanelShapeMediator);
			mediatorMap.mapView(EditorMainPanelBitmap, EditorMainPanelBitmapMediator);
			mediatorMap.mapView(EditorMainPanelTag, EditorMainPanelTagMediator);
			mediatorMap.mapView(AppUpdateLoaderProgressPopup, AppUpdateLoaderProgressPopupMediator, null, false, false);
			mediatorMap.mapView(ParseSWFProgressPopup, ParseSWFProgressPopupMediator, null, false, false);
			mediatorMap.mapView(ExportAnimationPopup, ExportAnimationPopupMediator, null, false, false);
			mediatorMap.mapView(ExportShapePopup, ExportShapePopupMediator, null, false, false);
			mediatorMap.mapView(ExportShapeCanvasPopup, ExportShapeCanvasPopupMediator, null, false, false);
			
			contextView.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, nativeDragEnterHandler);
			contextView.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, nativeDragDropHandler);
			
			// Startup complete
			super.startup();
		}
		
		protected function nativeDragEnterHandler(event:NativeDragEvent):void {
			if(event.clipboard.hasFormat(ClipboardFormats.URL_FORMAT)) {
				var url:String = event.clipboard.getData(ClipboardFormats.URL_FORMAT) as String;
				if(url) {
					NativeDragManager.acceptDragDrop(contextView);
				}
			}
		}
		
		protected function nativeDragDropHandler(event:NativeDragEvent):void {
			var url:String = event.clipboard.getData(ClipboardFormats.URL_FORMAT) as String;
			if(url) {
				dispatchEvent(new SWFEvent(SWFEvent.LOAD, url));
			}
		}
	}
}