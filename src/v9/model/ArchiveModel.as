package v9.model
{
	import by.blooddy.crypto.MD5

	import v9.model.vo.EmbeddedSWFVO;
	import com.codeazur.utils.StringUtils;

	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	public class ArchiveModel extends AbstractDatabaseModel
	{
		//[Inject]
		//public var configModel:ConfigModel;
		
		public function ArchiveModel()
		{
			super();
		}
		
		public function add(vo:EmbeddedSWFVO):void {
			/*
			var md5:String = MD5.hashBytes(vo.bytes);
			//var time:String = new Date().time.toString(16);
			var filename:String = StringUtils.printf("%032s.swf", md5);
			var file:File = configModel.archiveFolder.resolvePath(filename);
			//trace("archiving: " + file.nativePath);
			if(!file.exists) {
				var fileStream:FileStream = new FileStream();
				fileStream.open(file, FileMode.WRITE);
				fileStream.writeBytes(vo.bytes);
				fileStream.close();
			}
			*/
		}
	}
}