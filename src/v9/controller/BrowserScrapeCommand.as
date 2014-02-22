package v9.controller
{
	import v9.events.BrowserScrapeEvent;
	import v9.services.ScrapeService;
	
	import org.robotlegs.mvcs.Command;
	
	public class BrowserScrapeCommand extends Command
	{
		[Inject]
		public var event:BrowserScrapeEvent;
	
		[Inject]
		public var scrapeService:ScrapeService;
		
		public function BrowserScrapeCommand()
		{
			super();
		}
		
		public override function execute():void {
			scrapeService.scrape(event.domWindow);
		}
	}
}