package v9.model.vo
{
	[Bindable]
	public class BrowserTabVO
	{
		public var label:String = "New Tab";
		
		protected var _url:String;

		public function BrowserTabVO()
		{
		}
		
		public function get url():String { return _url; }
		public function set url(value:String):void {
			_url = value;
		}
	}
}