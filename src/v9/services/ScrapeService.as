package v9.services
{
	import com.adobe.net.URI;
	import v9.model.ScrapeQueueModel;
	import v9.model.vo.EmbeddedSWFVO;
	import com.codeazur.utils.XMLUtil;
	
	import flash.utils.Dictionary;
	
	import org.robotlegs.mvcs.Actor;
	
	public class ScrapeService extends Actor
	{
		[Inject]
		public var scrapeQueueModel:ScrapeQueueModel;
		
		public function ScrapeService()
		{
			super();
		}
		
		public function scrape(window:Object):void {
			if(window) {
				scrapeDocument(window.document, window.location.href, window.location.href);
				trace("Scrape: " + window.location.href);
				/*if(window.frames) {
					for(var i:uint = 0; i < window.frames.length; i++) {
						var frame:Object = window.frames[i];
						trace("Scrape: " + frame.location.href + " [FRAME]");
						scrapeDocument(frame.document, frame.location.href, window.location.href);
					}
				}*/
			}
		}
		
		protected function scrapeDocument(document:Object, baseUrlRaw:String, siteUrlRaw:String):void {
			var doc:XML = XMLUtil.jsDomToE4X(document);
			if(doc) {
				var i:int, j:int;
				var swfUrlRaw:String;
				var siteUrl:URI = new URI(siteUrlRaw);
				var baseUrl:URI = new URI(baseUrlRaw);
				if(!siteUrl.isValid() || !baseUrl.isValid()) {
					trace("### ERROR ### invalid " + (!siteUrl.isValid() ? "site" : "base") + "Url");
					return;
				}
				if(baseUrl.isRelative()) {
					baseUrl.makeAbsoluteURI(siteUrl);
				}
				var swfUrls:Dictionary = new Dictionary();
				var __frames:XMLList = doc..*::iframe;
				for(i = 0; i < __frames.length(); i++) {
					trace("  [FRAME] " + __frames[i].@src.toString());
				}
				var googItems:XMLList = doc.*::body.*::div.*::div.*::div.*::div.*::div.*::ol.*::li;
				for(i = 0; i < googItems.length(); i++) {
					var x:XMLList = googItems[i].*::span.(@["class"] == "b w xsm").(text() == "[FLASH]");
					if(x.length() == 1) {
						swfUrlRaw = googItems[i].*::h3.*::a.@href.toString();
						if(swfUrlRaw && swfUrlRaw.length > 0) {
							swfUrls[swfUrlRaw] = <a/>;
						}
					}
				}
				var embeds:XMLList = doc..*::embed;
				for(i = 0; i < embeds.length(); i++) {
					swfUrlRaw = embeds[i].@src.toString();
					if(swfUrlRaw && swfUrlRaw.length > 0) {
						swfUrls[swfUrlRaw] = embeds[i];
					}
				}
				var objects:XMLList = doc..*::object;
				for(i = 0; i < objects.length(); i++) {
					swfUrlRaw = objects[i].*::param.(@name == "movie").@value.toString();
					if(swfUrlRaw && swfUrlRaw.length > 0) {
						swfUrls[swfUrlRaw] = objects[i];
					} else {
						swfUrlRaw = objects[i].@data.toString();
						if(swfUrlRaw && swfUrlRaw.length > 0) {
							swfUrls[swfUrlRaw] = objects[i];
						}
					}
				}
				var vo:EmbeddedSWFVO;
				var swfUrl:URI;
				for(swfUrlRaw in swfUrls) {
					swfUrl = new URI(swfUrlRaw);
					if(swfUrl.isValid()) {
						if(swfUrl.isRelative()) {
							swfUrl.makeAbsoluteURI(baseUrl);
						}
						vo = new EmbeddedSWFVO();
						vo.siteUrl = siteUrl.toString();
						vo.baseUrl = baseUrl.toString();
						vo.swfUrl = swfUrl.toString();
						vo.embedTag = swfUrls[swfUrlRaw] as XML;
						// add to scrape queue model
						scrapeQueueModel.add(vo);
						//trace(vo.swfUrl);
					} else {
						trace("### ERROR ### invalid swfUrl");
					}
				}
			}
		}
	}
}
