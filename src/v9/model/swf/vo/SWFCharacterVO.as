package v9.model.swf.vo
{
	import v9.model.swf.exporters.IExporterBackend;

	import com.codeazur.as3swf.tags.IDefinitionTag;
	import com.codeazur.as3swf.tags.ITag;

	[Bindable]
	public class SWFCharacterVO
	{
		public static const NAME_BITMAP:String = "Bitmap";
		public static const NAME_BUTTON:String = "Button";
		public static const NAME_FONT:String = "Font";
		public static const NAME_MOVIECLIP:String = "MovieClip";
		public static const NAME_SHAPE:String = "Shape";
		public static const NAME_MORPHSHAPE:String = "MorphShape";
		
		protected var _tag:IDefinitionTag;
		protected var _hasClassName:Boolean;
		protected var _className:String;
		
		protected var _ClassDefinition:Class;
		
		public function SWFCharacterVO(tag:ITag)
		{
			_hasClassName = false;
			_tag = (tag as IDefinitionTag);
			if(_tag) {
				// Default class name, e.g. "Bitmap_123"
				_className = name + "_" + _tag.characterId;
			}
		}
		
		public function get tag():IDefinitionTag { return _tag; }
		public function get hasClassName():Boolean { return _hasClassName; }

		public function get className():String { return _className; }
		public function set className(value:String):void {
			if(_className != value) {
				_className = value;
				_hasClassName = true;
			}
		}

		// The class definition of the asset
		// To create a display object to add to the display list:
		//   var dobj:DisplayObject = new characterVO.ClassDefinition() as DisplayObject;
		//   addChild(dobj);
		// You may also cast it to [superClassName] instead of DisplayObject, e.g.:
		//   var bitmapData:BitmapData = new bitmapVO.ClassDefinition() as BitmapData;
		//   var bitmap:Bitmap = new Bitmap(bitmapData);
		//   addChild(bitmap);
		public function get ClassDefinition():Class { return _ClassDefinition; }
		public function set ClassDefinition(value:Class):void {
			_ClassDefinition = value;
		}
		
		public function get name():String { throw(new Error("Implement in subclass.")); }
		public function get superClassName():String { throw(new Error("Implement in subclass.")); }
		public function get hasAsset():Boolean { return true; }
		
		public function export(backend:IExporterBackend):void {
			// Override in subclass.
		}
		
		public function toString():String {
			if(hasClassName) {
				return className;
			} else if(_tag) {
				return "[ " + name + " ]";
			} else {
				return "[ Main Timeline ]";
			}
		}
	}
}