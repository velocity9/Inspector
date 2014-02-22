/*
For the latest version of this code, visit:
http://probertson.com/projects/gzipencoder/

Copyright (c) 2009 H. Paul Robertson

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

package com.probertson.utils
{
	import flash.utils.ByteArray;
	
	// For details of CRC32 encoding, see notes in IETF RFC 1952:
	// http://www.ietf.org/rfc/rfc1952.txt
	public class CRC32Generator
	{
		// ------- CRC Table -------
		private static var _crcTable:Array;
		private static var _tableComputed:Boolean = false;
		private static function makeCRCTable():void
		{
			_crcTable = new Array(256);
			var val:uint;
			for (var i:int = 0; i < 256; i++)
			{
				val = i;
				for (var j:int = 0; j < 8; j++)
				{
					if ((val & 1) != 0)
					{
						val = 0xedb88320 ^ (val >>> 1);
					}
					else
					{
						val = val >>> 1;
					}
				}
				_crcTable[i] = val;
			}
			_tableComputed = true;
		}
		
		
		// ------- Constructor -------
		public function CRC32Generator()
		{
			
		}
		
		
		// ------- Public methods -------
		public function generateCRC32(buffer:ByteArray):uint
		{
			if (!_tableComputed)
			{
				makeCRCTable();
			}
			var result:uint = ~0;
			var len:int = buffer.length;
			for (var i:int = 0; i < len; i++)
			{
				result = _crcTable[(result ^ buffer[i]) & 0xff] ^ (result >>> 8);
			}
			result = ~result;
			
			return (result & 0xffffffff);
		}
	}
}