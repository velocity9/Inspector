package v9.model.swf.vo
{
	import v9.model.swf.V9SWF;
	import com.codeazur.as3swf.data.consts.BitmapFormat;
	import com.codeazur.as3swf.data.consts.BitmapType;
	import com.codeazur.as3swf.tags.ITag;
	import com.codeazur.as3swf.tags.TagDefineBits;
	import com.codeazur.as3swf.tags.TagDefineBitsJPEG2;
	import com.codeazur.as3swf.tags.TagDefineBitsJPEG3;
	import com.codeazur.as3swf.tags.TagDefineBitsJPEG4;
	import com.codeazur.as3swf.tags.TagDefineBitsLossless;
	import com.codeazur.as3swf.tags.TagDefineBitsLossless2;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.utils.ByteArray;

	[Bindable]
	public class SWFBitmapVO extends SWFCharacterVO
	{
		public static const TYPE_JPEG:String = "JPEG";
		public static const TYPE_JPEG_ALPHA:String = "JPEG+Alpha";
		public static const TYPE_GIF:String = "GIF";
		public static const TYPE_PNG:String = "PNG";
		
		protected var _width:uint = 0;
		protected var _height:uint = 0;
		protected var _typeName:String;
		
		public function SWFBitmapVO(tag:ITag)
		{
			super(tag);
			
			switch(tag.type)
			{
				case TagDefineBits.TYPE:
				case TagDefineBitsJPEG2.TYPE:
				case TagDefineBitsJPEG3.TYPE:
				case TagDefineBitsJPEG4.TYPE:
					var defineBits:TagDefineBits = tag as TagDefineBits;
					switch(defineBits.bitmapType) {
						case BitmapType.JPEG:
							_typeName = TYPE_JPEG;
							if(tag.type == TagDefineBitsJPEG3.TYPE || tag.type == TagDefineBitsJPEG4.TYPE) {
								var defineBits3:TagDefineBitsJPEG3 = tag as TagDefineBitsJPEG3;
								if(defineBits3.bitmapAlphaData.length > 0) {
									_typeName = TYPE_JPEG_ALPHA;
								}
							} 
							determineJPEGSize(defineBits.bitmapData);
							break;
						case BitmapType.GIF89A:
							_typeName = TYPE_GIF;
							determineGIFSize(defineBits.bitmapData);
							break;
						case BitmapType.PNG:
							_typeName = TYPE_PNG;
							determinePNGSize(defineBits.bitmapData);
							break;
						default:
							trace("WARNING: SWFBitmapVO: Unsupported BitmapType " + defineBits.bitmapType);
							break;
					}
					break;
				case TagDefineBitsLossless.TYPE:
				case TagDefineBitsLossless2.TYPE:
					var defineBitsLossless:TagDefineBitsLossless = tag as TagDefineBitsLossless;
					_width = defineBitsLossless.bitmapWidth;
					_height = defineBitsLossless.bitmapHeight;
					_typeName = "Lossless " + BitmapFormat.toString(defineBitsLossless.bitmapFormat);
					break;
				default:
					trace("WARNING: SWFBitmapVO: Unsupported TagType " + tag.type);
					break;
			}
		}
		
		public function render(swf:V9SWF):Sprite {
			var sprite:Sprite = new Sprite();
			var bitmapData:BitmapData = new ClassDefinition() as BitmapData;
			var bitmap:Bitmap = new Bitmap(bitmapData);
			sprite.addChild(bitmap);
			return sprite;
		}
		
		public function get width():uint { return _width; }
		public function get height():uint { return _height; }
		public function get typeName():String { return _typeName; }
		
		override public function get name():String { return SWFCharacterVO.NAME_BITMAP; }
		override public function get superClassName():String { return "flash.display.BitmapData"; }
		
		// Gets the JPEG size from the array of data passed to the function,
		// File reference: http://www.obrador.com/essentialjpeg/headerinfo.htm
		// Source: http://www.64lines.com/jpeg-width-height
		protected function determineJPEGSize(data:ByteArray):Boolean {
			var i:uint = 0; // Keeps track of the position within the file
			// Check for faulty JPEG header (SWF7 and earier) and skip it
			if (data[i] == 0xFF && data[i+1] == 0xD9 && data[i+2] == 0xFF && data[i+3] == 0xD8) {
				i = 4;
			}
			// Check for valid SOI
			//   Byte #4 varies, we thus ignore it boldly:
			//     DB - Samsung D807 JPEG file.
			//     E0 - Standard JPEG/JFIF file.
			//     E1 - Standard JPEG/Exif file.
			//     E2 - Canon EOS-1D JPEG file.
			//     E3 - Samsung D500 JPEG file.
			//     E8 - Still Picture Interchange File Format (SPIFF).
			if(data[i] == 0xFF && data[i+1] == 0xD8 && data[i+2] == 0xFF) {
				i += 4;
			} else {
				trace("WARNING: SWFBitmapVO:getJPEGSize(): Not a JPEG (no SOI found)");
				return false;
			}
			// Retrieve the block length of the first block since the 
			// first block will not contain the size of file
			var data_size:uint = data.length;
			var block_length:uint = (data[i] << 8) | data[i+1];
			while(i < data_size) {
				i += block_length; // Increase the file index to get to the next block
				if(i >= data_size) return false; // Check to protect against segmentation faults
				if(data[i] != 0xFF) return false; // Check that we are truly at the start of another block
				if(data[i+1] == 0xC0) { // 0xFFC0 is the "Start of frame" marker which contains the file size
					// The structure of the 0xFFC0 block is quite simple
					// [0xFFC0][ushort length][uchar precision][ushort x][ushort y]
					_height = (data[i+5] << 8) | data[i+6];
					_width = (data[i+7] << 8) | data[i+8];
					return true;
				} else {
					i += 2; // Skip the block marker
					block_length = (data[i] << 8) | data[i+1]; // Go to the next block
				}
			}
			trace("WARNING: SWFBitmapVO:determineJPEGSize(): No size found");
			return false; // If this point is reached then no size was found
		}
		
		// Source: http://www.wischik.com/lu/programmer/get-image-size.html
		protected function determineGIFSize(data:ByteArray):Boolean {
			// GIF: first three bytes say "GIF", next three give version number. Then dimensions
			if (data[0] == 0x47 && data[1] == 0x49 && data[2] == 0x46) { // GIF
				_width = data[6] | (data[7] << 8);
				_height = data[8] | (data[9] << 8);
				return true;
			}
			trace("WARNING: SWFBitmapVO:determineGIFSize(): No size found");
			return false;
		}
		
		// Source: http://www.wischik.com/lu/programmer/get-image-size.html
		protected function determinePNGSize(data:ByteArray):Boolean {
			// PNG: the first frame is by definition an IHDR frame, which gives dimensions
			if (data[0] == 0x89
				&& data[1] == 0x50 && data[2] == 0x4e && data[3] == 0x47 // "PNG"
				&& data[4] == 0x0D && data[5] == 0x0A && data[6] == 0x1A && data[7] == 0x0A
				&& data[12] == 0x49 && data[13] == 0x48 && data[14] == 0x44 && data[15] == 0x52) { // "IHDR"
					_width = (data[16] << 24) | (data[17] << 16) | (data[18] << 8) | data[19];
					_height = (data[20] << 24) | (data[21] << 16) | (data[22] << 8) | data[23];
					return true;
			}
			trace("WARNING: SWFBitmapVO:determinePNGSize(): No size found");
			return false;
		}
	}
}