package v9.model
{
	import com.codeazur.utils.AIRRemoteUpdater;
	import com.codeazur.utils.AIRRemoteUpdaterEvent;
	
	import flash.desktop.Updater;
	import flash.events.ErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	import org.robotlegs.mvcs.Actor;
	
	import v9.events.UpdaterEvent;

	public class UpdaterModel extends Actor
	{
		protected static const AIR_URL:String = "http://codeazur.com.br/downloads/Velocity9.air";
		
		protected var updater:AIRRemoteUpdater;
		protected var updaterRequest:URLRequest;

		protected var file:File;
		protected var localVersion:String;
		protected var remoteVersion:String;

		protected var timer:Timer;
		
		public function UpdaterModel()
		{
			updater = new AIRRemoteUpdater();
			updater.addEventListener(AIRRemoteUpdaterEvent.VERSION_CHECK, updaterVersionCheckHandler);
			updater.addEventListener(AIRRemoteUpdaterEvent.UPDATE, updaterUpdateHandler);
			updater.addEventListener(ProgressEvent.PROGRESS, updaterProgressHandler);
			updater.addEventListener(IOErrorEvent.IO_ERROR, updaterErrorHandler);
			updater.addEventListener(SecurityErrorEvent.SECURITY_ERROR, updaterErrorHandler);
			updaterRequest = new URLRequest(AIR_URL);
			
			timer = new Timer(1000 * 60 * 15);
			timer.addEventListener(TimerEvent.TIMER, timerHandler);
		}

		public function check():void
		{
			updater.update(updaterRequest);
		}

		public function download():void
		{
			updater.update(updaterRequest, false);
		}
		
		public function install():void
		{
			if(file != null) {
				var airUpdater:Updater = new Updater();
				airUpdater.update(file, remoteVersion);
			}
		}
		
		private function updaterVersionCheckHandler(event:AIRRemoteUpdaterEvent):void
		{
			trace("Local version: " + updater.localVersion);
			trace("Remote version: " + updater.remoteVersion);
			localVersion = updater.localVersion;
			remoteVersion = updater.remoteVersion;
			if(compareVersions(localVersion, remoteVersion) > 0) {
				dispatch(UpdaterEvent.createUpdateAvailable(localVersion, remoteVersion));
			} else {
				timer.start();
			}
			event.preventDefault();
		}
		
		private function updaterProgressHandler(event:ProgressEvent):void
		{
			dispatch(UpdaterEvent.createUpdateDownloadProgress(event.bytesLoaded, event.bytesTotal));
		}

		private function updaterUpdateHandler(event:AIRRemoteUpdaterEvent):void
		{
			trace("Installer: " + event.file.nativePath);
			file = event.file;
			dispatch(new UpdaterEvent(UpdaterEvent.UPDATE_DOWNLOAD_COMPLETE));
			//event.preventDefault();
		}
		
		private function timerHandler(event:TimerEvent):void
		{
			check();
		}

		private function updaterErrorHandler(event:ErrorEvent):void
		{
			// Ignore
			trace(event);
		}
		
		protected function compareVersions(localVersion:String, remoteVersion:String):int {
			// TODO: parse 1.2.345 version number scheme
			var lvParts:Array = localVersion.split(".");
			var rvParts:Array = remoteVersion.split(".");
			for (var i:uint = 0, n:uint = Math.min(lvParts.length, rvParts.length); i < n; i++) {
				var lv:int = parseInt(lvParts[i]);
				var rv:int = parseInt(rvParts[i]);
				if(rv > lv) {
					return 1;
				} else if(rv < lv) {
					return -1;
				}
			}
			return 0;
			/*
			var lv:Number = parseFloat(localVersion);
			var rv:Number = parseFloat(remoteVersion);
			if(rv > lv) {
				return 1;
			} else if(rv < lv) {
				return -1;
			} else {
				return 0;
			}
			*/
		}
	}
}
