package v9.events
{
	import flash.events.Event;

	public class UpdaterEvent extends Event
	{
		public static const UPDATE_AVAILABLE:String = "updateAvailable";
		public static const UPDATE_DOWNLOAD_PROGRESS:String = "updateDownloadProgress";
		public static const UPDATE_DOWNLOAD_COMPLETE:String = "updateDownloadComplete";

		public static const UPDATE_CHECK:String = "updateCheck";
		public static const UPDATE_DOWNLOAD:String = "updateDownload";
		public static const UPDATE_INSTALL:String = "updateInstall";
		
		public var localVersion:String;
		public var remoteVersion:String;

		public var bytesLoaded:uint;
		public var bytesTotal:uint;
		
		public function UpdaterEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
		
		public static function createUpdateAvailable(localVersion:String, remoteVersion:String):UpdaterEvent
		{
			var event:UpdaterEvent = new UpdaterEvent(UpdaterEvent.UPDATE_AVAILABLE);
			event.localVersion = localVersion;
			event.remoteVersion = remoteVersion;
			return event;
		}
		
		public static function createUpdateDownloadProgress(bytesLoaded:uint, bytesTotal:uint):UpdaterEvent
		{
			var event:UpdaterEvent = new UpdaterEvent(UpdaterEvent.UPDATE_DOWNLOAD_PROGRESS);
			event.bytesLoaded = bytesLoaded;
			event.bytesTotal = bytesTotal;
			return event;
		}
		
		public function get progress():Number {
			return bytesLoaded / bytesTotal;
		}
		
		public function get progressPercent():Number {
			return Math.round(progress * 100);
		}
	}
}
