package v9.view
{
	import v9.events.BrowserScrapeEvent;
	import v9.model.ScrapeQueueModel;
	import v9.model.vo.BrowserTabVO;
	import v9.view.V9Browser;
	import v9.view.events.BrowserTabEvent;
	
	import mx.collections.ArrayList;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class V9BrowserMediator extends Mediator
	{
		[Inject]
		public var browser:V9Browser;
		
		[Inject]
		public var scrapeQueueModel:ScrapeQueueModel;
		
		protected var tabs:ArrayList;
		
		public function V9BrowserMediator()
		{
			super();
			tabs = new ArrayList();
			addTab();
		}
		
		override public function onRegister():void {
			browser.dataProvider = tabs;
			browser.scrapeQueue.list.dataProvider = scrapeQueueModel.queue;
			eventMap.mapListener(browser, BrowserTabEvent.SCRAPE, scrapeHandler);
			eventMap.mapListener(browser, BrowserTabEvent.ADD_TAB, addTabHandler);
		}
		
		override public function onRemove():void {
			eventMap.unmapListener(browser, BrowserTabEvent.SCRAPE, scrapeHandler);
			eventMap.unmapListener(browser, BrowserTabEvent.ADD_TAB, addTabHandler);
		}
		
		protected function scrapeHandler(event:BrowserTabEvent):void {
			dispatch(new BrowserScrapeEvent(BrowserScrapeEvent.SCRAPE, event.payload));
		}
		
		protected function addTabHandler(event:BrowserTabEvent):void {
			addTab(event.url);
		}
		
		protected function addTab(url:String = null):void {
			var tab:BrowserTabVO = new BrowserTabVO();
			tab.url = url;
			tabs.addItem(tab);
		}
	}
}
