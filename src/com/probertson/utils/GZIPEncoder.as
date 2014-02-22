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
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import flash.utils.CompressionAlgorithm;
	import flash.utils.Endian;
	
	/**
	 * A class for working with GZIP-encoded data. There are methods for compressing
	 * files or data to GZIP format and writing them to files. There are methods for
	 * uncompressing GZIP files or raw GZIP data and either writing the result data to
	 * files or accessing it in memory as a ByteArray.
	 *
	 * <p>This class requires Adobe AIR. For a version without File-related functionality
	 * (which only uses ByteArray objects for source and output data) see the
	 * GZIPBytesEncoder class.</p>
	 *
	 * <p>This class contains methods which are merely wrapper methods on the GZIPBytesEncoder
	 * class's methods. These methods exist for backwards compatibility, and if you want
	 * to work purely with ByteArray data you can use either class.</p>
	 */
	public class GZIPEncoder
	{
	
		/**
		 * Writes a GZIP compressed file format file to a file stream.
		 *
		 * <p>This particular method takes a "least effort" approach, meaning any optional
		 * metadata fields are not included in the GZIP file that's written to disk.</p>
		 *
		 * @param src	The source data to compress and embed in the GZIP file. The source
		 * 				can be a file on the filesystem (a File instance), in which case the contents of the
		 * 				file are read, compressed, and output to the file stream. Alternatively, the source can be a
		 * 				ByteArray instance, in which case the ByteArray's contents are compressed and output to the
		 * 				file stream.
		 *
		 * @param output	The File location to which the compressed GZIP format file should be written.
		 * 					The user should have permission to write to the file location. If the location
		 * 					specifies a file name, that file name will be used. If the output location is
		 * 					a directory, a new file will be created with the name "[src file name].gz". If src
		 * 					is a ByteArray, and output only specifies a directory, the output file will
		 * 					be created with the name "output.gz".
		 *
		 * @throws ArgumentError	If the <code>src</code> argument is not a File or ByteArray instance; if
		 * 							the <code>src</code> argument refers to a directory or a non-existent file;  or if
		 * 							either argument is null.
		 */
		public function compressToFile(src:Object, output:File):void
		{
			if (src == null || output == null)
			{
				throw new ArgumentError("src and output can't be null.");
			}
			
			var srcBytes:ByteArray;
			var target:File = new File(output.nativePath);
			
			var fileTime:Date;
			
			if (src is File)
			{
				var srcFile:File = src as File;
				if (!srcFile.exists || srcFile.isDirectory)
				{
					throw new ArgumentError("If src is a File instance, it must specify the location of an existing file (not a directory).");
				}
				
				var srcStream:FileStream = new FileStream();
				srcStream.open(srcFile, FileMode.READ);
				srcBytes = new ByteArray();
				srcStream.readBytes(srcBytes, 0, srcStream.bytesAvailable);
				srcStream.close();
				
				if (target.isDirectory)
				{
					target = target.resolvePath(srcFile.name + ".gz");
				}
				
				fileTime = srcFile.modificationDate;
			}
			else if (src is ByteArray)
			{
				srcBytes = src as ByteArray;
				
				if (target.isDirectory)
				{
					target = target.resolvePath("output.gz");
				}
				
				fileTime = new Date();
			}
			else
			{
				throw new ArgumentError("src must be a File instance or a ByteArray instance");
			}
			
			var encoder:GZIPBytesEncoder = new GZIPBytesEncoder();
			var gzipBytes:ByteArray = encoder.compressToByteArray(srcBytes, fileTime);
			
			var outStream:FileStream = new FileStream();
			outStream.open(target, FileMode.WRITE);
			outStream.writeBytes(gzipBytes, 0, gzipBytes.length);
			outStream.close();
		}
		
		
		/**
		 * Uncompresses a GZIP-compressed-format file to another file location.
		 *
		 * @param src	The filesystem location of the GZIP format file to uncompress.
		 *
		 * @param output	The filesystem location where the uncompressed file should be saved.
		 * 					If <code>output</code> specifies a file name, that file name will be used
		 * 					for the new file, regardless of the original file name. If the argument
		 * 					specifies a directory, the uncompressed file will be saved in that directory. In
		 * 					that case, if the GZIP file includes file name information, the new file will
		 * 					be saved with the original file name; if no file name is present, the new file
		 * 					will be saved with the name of the source GZIP file, minus the ".gz" or ".gzip"
		 * 					extension.
		 *
		 * @throws ArgumentError	If <code>src</code> or <code>output</code> argument is null;
		 * 							if <code>src</code> is a directory rather than a file; or
		 * 							if <code>src</code> points to a file location that doesn't exist.
		 */
		public function uncompressToFile(src:File, output:File):void
		{
			if (output == null)
			{
				throw new ArgumentError("output cannot be null");
			}
			
			// throws errors if src is invalid
			var gzipData:GZIPFile = parseGZIPFile(src);
			
			var outFile:File = new File(output.nativePath);
			if (outFile.isDirectory)
			{
				var fileName:String;
				if (gzipData.headerFileName != null)
				{
					fileName = gzipData.headerFileName;
				}
				else if (gzipData.gzipFileName.lastIndexOf(".gz") == gzipData.gzipFileName.length - 3)
				{
					fileName = gzipData.gzipFileName.substr(0, gzipData.gzipFileName.length - 3);
				}
				else if (gzipData.gzipFileName.lastIndexOf(".gzip") == gzipData.gzipFileName.length - 5)
				{
					fileName = gzipData.gzipFileName.substr(0, gzipData.gzipFileName.length - 5);
				}
				else
				{
					fileName = gzipData.gzipFileName;
				}
				
				outFile = outFile.resolvePath(fileName);
			}
			
			var data:ByteArray = gzipData.getCompressedData();
			try
			{
				data.uncompress(CompressionAlgorithm.DEFLATE);
			}
			catch (error:Error)
			{
				throw new IllegalOperationError("The specified file is not a GZIP file format file.");
			}
			var outStream:FileStream = new FileStream();
			outStream.open(outFile, FileMode.WRITE);
			outStream.writeBytes(data, 0, data.length);
			outStream.close();
		}
		
		
		/**
		 * Uncompresses a GZIP-compressed-format file to a ByteArray object.
		 *
		 * @param src	The location of the source file to uncompress, or the
		 * 				ByteArray object to uncompress.  The source
		 * 				can be a file on the filesystem (a File instance), in
		 * 				which case the contents of the
		 * 				file are read, uncompressed, and output as the result.
		 * 				Alternatively, the source can be a
		 * 				ByteArray instance, in which case the ByteArray's
		 * 				contents are uncompressed and output as the result. In
		 * 				either case the <code>src</code> object must
		 * 				be compressed using the GZIP file format.
		 *
		 * @returns		A ByteArray containing the uncompressed bytes that were
		 * 				compressed and encoded in the source file or ByteArray.
		 *
		 * @throws ArgumentError	If the <code>src</code> argument is not a
		 * 							File or ByteArray instance; if
		 * 							the <code>src</code> argument refers to a
		 * 							directory or a non-existent file;  or if
		 * 							either argument is null.
		 *
		 * @throws IllegalOperationError If the specified file or ByteArray
		 * 								 is not GZIP-format file or data.
		 */
		public function uncompressToByteArray(src:Object):ByteArray
		{
			var gzipData:GZIPFile;
			
			if (src is File)
			{
				var srcFile:File = src as File;
				
				// throws errors if src doesn't exist or is a directory
				gzipData = parseGZIPFile(srcFile);
			}
			else if (src is ByteArray)
			{
				gzipData = parseGZIPData(src as ByteArray);
			}
			else
			{
				throw new ArgumentError("The src argument must be a File or ByteArray instance");
			}
			
			var data:ByteArray = gzipData.getCompressedData();
			
			try
			{
				data.uncompress(CompressionAlgorithm.DEFLATE);
			}
			catch (error:Error)
			{
				throw new IllegalOperationError("The specified source is not a GZIP file format file or data.");
			}
			
			return data;
		}
		
		
		/**
		 * Parses a GZIP-format file into an object with properties representing the important
		 * characteristics of the GZIP file (the header and footer metadata, as well as the
		 * actual compressed data).
		 *
		 * @param src	The filesystem location of the GZIP file to parse.
		 *
		 * @returns		An object containing the information from the source GZIP file.
		 *
		 * @throws ArgumentError	If the <code>src</code> argument is null; refers
		 * 							to a directory; or refers to a file that doesn't
		 * 							exist.
		 *
		 * @throws IllegalOperationError If the specified file is not a GZIP-format file.
		 */
		public function parseGZIPFile(src:File):GZIPFile
		{
			// throws errors if src isn't valid
			checkSrcFile(src);
			
			var srcFile:File = new File(src.nativePath);
			
			var srcStream:FileStream = new FileStream();
			srcStream.open(srcFile, FileMode.READ);
			var srcBytes:ByteArray = new ByteArray();
			srcStream.readBytes(srcBytes, 0, srcStream.bytesAvailable);
			srcStream.close();
			
			return parseGZIPData(srcBytes, srcFile.name);
		}
		
		/**
		 * Parses a GZIP-format ByteArray into an object with properties representing the important
		 * characteristics of the GZIP data (the header and footer metadata, as well as the
		 * actual compressed data).
		 *
		 * <p>This method is simply a wrapper for the <code>GZIPBytesEncoder.parseGZIPData()</code>
		 * method.</p>
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
			var decoder:GZIPBytesEncoder = new GZIPBytesEncoder();
			return decoder.parseGZIPData(srcBytes, srcName);
		}
		
		
		// ------- Private functions -------
		private function checkSrcFile(src:File):void
		{
			if (src == null)
			{
				throw new ArgumentError("src can't be null");
			}
			
			if (src.isDirectory)
			{
				throw new ArgumentError("src must refer to the location of a file, not a directory");
			}
			
			if (!src.exists)
			{
				throw new ArgumentError("src refers to a file that doesn't exist");
			}
		}
	}
}