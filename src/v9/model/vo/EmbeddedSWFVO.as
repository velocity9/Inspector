package v9.model.vo
{
	import flash.utils.ByteArray;

	[Bindable]
	public class EmbeddedSWFVO
	{
		public static const STATE_IDLE:String = "idle";
		public static const STATE_LOADING:String = "loading";
		public static const STATE_COMPLETE:String = "complete";
		public static const STATE_ERROR:String = "error";
		public static const STATE_WARNING:String = "warning";
		
		public var siteUrl:String;
		public var baseUrl:String;
		public var swfUrl:String;
		public var embedTag:XML;
		
		public var bytes:ByteArray;
		
		public var width:Number;
		public var height:Number;
		public var version:uint;
		public var frameRate:Number;
		public var fileLength:uint;
		public var fileLengthCompressed:uint;
		
		public var state:String = STATE_IDLE;
		public var bytesTotal:uint = 0;
		public var bytesLoaded:uint = 0;
		
		public function EmbeddedSWFVO()
		{
		}
		
		public function toString(verbose:Boolean = false):String {
			var ext:String = "";
			if(verbose) {
				ext = "\n  baseUrl: " + baseUrl 
					+ "\n  siteUrl: " + siteUrl;
			}
			return "[EmbeddedSWFVO] State: " + state + ", URL: " + swfUrl + ext;
		}
	}
}