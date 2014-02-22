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
	import flash.errors.IllegalOperationError;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	/**
	 * A class for working with GZIP-encoded data. There are methods for compressing
	 * data to GZIP format data (in a ByteArray). There are also methods for
	 * uncompressing a ByteArray containing GZIP data and accessing it in memory as a ByteArray.
	 *
	 * <p>In order to avoid dependencies on Adobe AIR, this class does not support
	 * the use of File objects for reading directly from or writing directly to
	 * the filesystem. For a version which supports File-related functionality
	 * (and which consequently requires Adobe AIR) see the
	 * GZIPEncoder class.</p>
	 */
	public class GZIPBytesEncoder
	{
	
		/**
		 * Writes bytes of data as GZIP compressed data in a byte array.
		 *
		 * <p>This particular method takes a "least effort" approach, meaning any optional
		 * metadata fields are not included in the GZIP data.</p>
		 *
		 * @param src	The source data to compress and embed in the GZIP bytes. The source is a
		 * 				ByteArray instance whose contents are compressed and output to the result
		 * 				byte array.
		 *
		 * @param timestamp	The file modification timestamp to encode into the GZIP format data.
		 *
		 * @throws ArgumentError	If the src argument is null.
		 */
		public function compressToByteArray(src:ByteArray, timeStamp:Date=null):ByteArray
		{
			if (src == null)
			{
				throw new ArgumentError("src can't be null.");
			}
			
			var srcPosition:uint = src.position;
			var srcBytes:ByteArray = new ByteArray();
			srcBytes.writeBytes(src);
			var outStream:ByteArray = new ByteArray();
			
			// For details of gzip format, see IETF RFC 1952:
			// http://www.ietf.org/rfc/rfc1952
			
			// gzip is little-endian
			outStream.endian = Endian.LITTLE_ENDIAN;
			
			// 1 byte ID1 -- should be 31/0x1f
			var id1:uint = 31;
			outStream.writeByte(id1);
			
			// 1 byte ID2 -- should be 139/0x8b
			var id2:uint = 139;
			outStream.writeByte(id2);
			
			// 1 byte CM -- should be 8 for DEFLATE
			var cm:uint = 8;
			outStream.writeByte(cm);
			
			// 1 byte FLaGs
			var flags:int = parseInt("00000000", 2);
			outStream.writeByte(flags);
			
			// 4 bytes MTIME (Modification Time in Unix epoch format; 0 means no time stamp is available)
			var mtime:uint = (timeStamp == null) ? 0 : timeStamp.time;
			outStream.writeUnsignedInt(mtime);
			
			// 1 byte XFL (flags used by specific compression methods)
			var xfl:uint = parseInt("00000100", 2);
			outStream.writeByte(xfl);
			// 1 byte OS
			var os:uint;
			if (Capabilities.os.indexOf("Windows") >= 0)
			{
				os = 11; // NTFS -- WinXP, Win2000, WinNT
			}
			else if (Capabilities.os.indexOf("Mac OS") >= 0)
			{
				os = 7; // Macintosh
			}
			else // Linux is the only other OS supported by Adobe AIR
			{
				os = 3; // Unix
			}
			outStream.writeByte(os);
			
			// calculate crc32 and filesize before compressing data
			var crc32Gen:CRC32Generator = new CRC32Generator();
			var crc32:uint = crc32Gen.generateCRC32(srcBytes);
			
			var isize:uint = srcBytes.length % Math.pow(2, 32);
			
	 		// Actual compressed data (up to end - 8 bytes)
			srcBytes.deflate();
			outStream.writeBytes(srcBytes, 0, srcBytes.length);
			
			// 4 bytes CRC32
	 		outStream.writeUnsignedInt(crc32);
	
			// 4 bytes ISIZE (input size -- size of the original input data modulo 2^32)
			outStream.writeUnsignedInt(isize);
			
			
			return outStream;
		}
		
		
		/**
		 * Uncompresses a GZIP-compressed-format ByteArray to a ByteArray object.
		 *
		 * @param src	The ByteArray object to uncompress. The ByteArray's
		 * 				contents are uncompressed and output as the result. In
		 * 				either case the <code>src</code> object must
		 * 				be compressed using the GZIP file format.
		 *
		 * @returns		A ByteArray containing the uncompressed bytes that were
		 * 				compressed and encoded in the source file or ByteArray.
		 *
		 * @throws ArgumentError	If the <code>src</code> argument is null.
		 *
		 * @throws IllegalOperationError If the specified ByteArray
		 * 								 is not GZIP-format file or data.
		 */
		public function uncompressToByteArray(src:ByteArray):ByteArray
		{
			var gzipData:GZIPFile;
			
			gzipData = parseGZIPData(src);
			
			var data:ByteArray = gzipData.getCompressedData();
			
			try
			{
				data.inflate();
			}
			catch (error:Error)
			{
				throw new IllegalOperationError("The specified source is not a GZIP file format file or data.");
			}
			
			return data;
		}
		
		
		/**
		 * Parses a GZIP-format ByteArray into an object with properties representing the important
		 * characteristics of the GZIP data (the header and footer metadata, as well as the
		 * actual compressed data).
		 *
		 * @param srcBytes	The bytearay of the GZIP data to parse.
		 * @param srcName	The name of the GZIP file.
		 *
		 * @returns		An object containing the information from the source GZIP data.
		 *
		 * @throws ArgumentError	If the <code>srcBytes</code> argument is null
		 *
		 * @throws IllegalOperationError If the specified data is not in GZIP-format.
		 */
		public function parseGZIPData(srcBytes:ByteArray, srcName:String = ""):GZIPFile
		{
			if (srcBytes == null)
			{
				throw new ArgumentError("The srcBytes ByteArray can't be null.");
			}
			
			// For details of gzip format, see IETF RFC 1952:
			// http://www.ietf.org/rfc/rfc1952
			
			// gzip is little-endian
			srcBytes.endian = Endian.LITTLE_ENDIAN;
			
			// 1 byte ID1 -- should be 31/0x1f or else throw an error
			var id1:uint = srcBytes.readUnsignedByte();
			if (id1 != 0x1f)
			{
				throw new IllegalOperationError("The specified data is not in GZIP file format structure.");
			}
			
			// 1 byte ID2 -- should be 139/0x8b or else throw an error
			var id2:uint = srcBytes.readUnsignedByte();
			if (id2 != 0x8b)
			{
				throw new IllegalOperationError("The specified data is not in GZIP file format structure.");
			}

			// 1 byte CM -- should be 8 for DEFLATE or else throw an error
			var cm:uint = srcBytes.readUnsignedByte();
			if (cm != 8)
			{
				throw new IllegalOperationError("The specified data is not in GZIP file format structure.");
			}
			
			// 1 byte FLaGs
			var flags:int = srcBytes.readByte();
			
			// ftext: the file is probably ASCII text
			var hasFtext:Boolean = ((flags >> 7) & 1) == 1;
			
			// fhcrc: a CRC16 for the gzip header is present
			var hasFhcrc:Boolean = ((flags >> 6) & 1) == 1;
			
			// fextra: option extra fields are present
			var hasFextra:Boolean = ((flags >> 5) & 1) == 1;
			
			// fname: an original file name is present, terminated by a zero byte
			var hasFname:Boolean = ((flags >> 4) & 1) == 1;
			
			// fcomment: a zero-terminated file comment (intended for human consumption) is present
			var hasFcomment:Boolean = ((flags >> 3) & 1) == 1;
			
			// must throw an error if any of the remaining bits are non-zero
			var flagsError:Boolean = false;
			flagsError = ((flags >> 2) & 1 == 1) ? true : flagsError;
			flagsError = ((flags >> 1) & 1 == 1) ? true : flagsError;
			flagsError = (flags & 1 == 1) ? true : flagsError;
			if (flagsError)
			{
				throw new IllegalOperationError("The specified data is not in GZIP file format structure.");
			}
			
			// 4 bytes MTIME (Modification Time in Unix epoch format; 0 means no time stamp is available)
			var mtime:uint = srcBytes.readUnsignedInt();
			
			// 1 byte XFL (flags used by specific compression methods)
			var xfl:uint = srcBytes.readUnsignedByte();
			
			// 1 byte OS
			var os:uint = srcBytes.readUnsignedByte();
			
			// (if FLG.EXTRA is set) 2 bytes XLEN, XLEN bytes of extra field
			if (hasFextra)
			{
				var extra:String = srcBytes.readUTF();
			}
			
			// (if FLG.FNAME is set) original filename, terminated by 0
			var fname:String = null;
	 		if (hasFname)
			{
				var fnameBytes:ByteArray = new ByteArray();
				while (srcBytes.readUnsignedByte() != 0)
				{
					// move position back by 1 to make up for the readUnsignedByte() in the conditional
					srcBytes.position -= 1;
					fnameBytes.writeByte(srcBytes.readByte());
				}
				fnameBytes.position = 0;
				fname = fnameBytes.readUTFBytes(fnameBytes.length);
			}
			
			// (if FLG.FCOMMENT is set) file comment, zero terminated
			var fcomment:String;
	 		if (hasFcomment)
			{
				var fcommentBytes:ByteArray = new ByteArray();
				while (srcBytes.readUnsignedByte() != 0)
				{
					// move position back by 1 to make up for the readUnsignedByte() in the conditional
					srcBytes.position -= 1;
					fcommentBytes.writeByte(srcBytes.readByte());
				}
				fcommentBytes.position = 0;
				fcomment = fcommentBytes.readUTFBytes(fcommentBytes.length);
			}
			
			// (if FLG.FHCRC is set) 2 bytes CRC16
	 		if (hasFhcrc)
			{
				var fhcrc:int = srcBytes.readUnsignedShort();
			}
			
			// Actual compressed data (up to end - 8 bytes)
			var dataSize:int = (srcBytes.length - srcBytes.position) - 8;
			var data:ByteArray = new ByteArray();
			srcBytes.readBytes(data, 0, dataSize);
			
			// 4 bytes CRC32
			var crc32:uint = srcBytes.readUnsignedInt();
			
			// 4 bytes ISIZE (input size -- size of the original input data modulo 2^32)
			var isize:uint = srcBytes.readUnsignedInt();
			
			return new GZIPFile(data, isize, new Date(mtime), srcName, fname, fcomment);
		}
	}
}