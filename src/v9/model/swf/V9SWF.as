package v9.model.swf
{
	import com.codeazur.as3swf.SWF;
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.SWFTimelineContainer;
	import com.codeazur.as3swf.data.SWFRawTag;
	import com.codeazur.as3swf.data.SWFSymbol;
	import com.codeazur.as3swf.tags.*;
	
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import mx.collections.ArrayCollection;
	
	import org.as3commons.bytecode.abc.AbcFile;
	import org.as3commons.bytecode.abc.enum.Opcode;
	import org.as3commons.bytecode.emit.IAbcBuilder;
	import org.as3commons.bytecode.emit.IClassBuilder;
	import org.as3commons.bytecode.emit.ICtorBuilder;
	import org.as3commons.bytecode.emit.IPackageBuilder;
	import org.as3commons.bytecode.emit.impl.AbcBuilder;
	import org.as3commons.bytecode.io.AbcSerializer;
	
	import v9.model.swf.events.SWFAssetCreationEvent;
	import v9.model.swf.vo.*;
	
	[Bindable]
	public class V9SWF extends SWF
	{
		protected static const PACKAGE_PREFIX:String = "v9.generated.";
		
		protected var frame:uint;
		protected var assetsCount:uint;
		protected var assetsProcessed:uint;
		protected var assetSWF:SWF;
		protected var assetSWFLoader:Loader;
		protected var assetSWFSymbolClass:TagSymbolClass;
		protected var assetSWFHasJPEGTables:Boolean;
		protected var characterMap:Dictionary;
		protected var symbolMap:Dictionary;
		protected var documentClassVO:SWFAnimationVO;
		
		public var animationCollection:ArrayCollection;
		public var buttonCollection:ArrayCollection;
		public var shapeCollection:ArrayCollection;
		public var morphShapeCollection:ArrayCollection;
		public var bitmapCollection:ArrayCollection;
		public var fontCollection:ArrayCollection;
		public var tagCollection:ArrayCollection;
		
		public function V9SWF(ba:ByteArray = null)
		{
			super(ba);
		}
		
		public function getCharacterVO(characterId:uint):SWFCharacterVO {
			return characterMap[characterId] as SWFCharacterVO;
		}
		
		public function unloadAssets():void {
			if(assetSWFLoader != null) {
				assetSWFLoader.unloadAndStop();
				assetSWFLoader = null;
			}
		}
		
		override protected function parseTagsInit(data:SWFData, version:uint):void
		{
			super.parseTagsInit(data, version);
			documentClassVO = new SWFAnimationVO();
			animationCollection = new ArrayCollection();
			animationCollection.addItem(documentClassVO);
			buttonCollection = new ArrayCollection();
			shapeCollection = new ArrayCollection();
			morphShapeCollection = new ArrayCollection();
			bitmapCollection = new ArrayCollection();
			fontCollection = new ArrayCollection();
			tagCollection = new ArrayCollection();
			frame = 1;
			assetsCount = 0;
			characterMap = new Dictionary();
			symbolMap = new Dictionary();
			assetSWF = new SWF();
			assetSWF.compressed = false;
			assetSWF.tags.push(new TagFileAttributes());
			assetSWFSymbolClass = new TagSymbolClass();
			assetSWFHasJPEGTables = false;
		}
		
		override protected function parseTag(data:SWFData, async:Boolean = false):ITag
		{
			var fontVO:SWFFontVO;
			var tag:ITag = super.parseTag(data, async);
			if (tag == null) {
				return null;
			}
			var tagIndex:uint = tags.length - 1;
			var tagRaw:SWFRawTag = tagsRaw[tagIndex];
			//if(tag.type != TagEnd.TYPE)
			//{
				tagCollection.addItem(new SWFTagVO(tag, tagsRaw[tagIndex].header, tagIndex, frame));
				var characterVO:SWFCharacterVO;
				switch(tag.type)
				{
					// Keep frame number updated
					case TagShowFrame.TYPE:
						frame++;
						break;

					// We look at the original SWF's SymbolClass and ExportAssets
					// tags here, to update the (generated) class names with the
					// ones defined in the symbols (when character id is a match)
					case TagSymbolClass.TYPE:
						updateClassNames(TagSymbolClass(tag).symbols);
						break;
					case TagExportAssets.TYPE:
						updateClassNames(TagExportAssets(tag).symbols);
						break;

					// Animations
					case TagDefineSprite.TYPE:
						var animationVO:SWFAnimationVO = new SWFAnimationVO(tag);
						animationVO.numFrames = SWFTimelineContainer(tag).frames.length;
						animationVO.numLayers = SWFTimelineContainer(tag).layers.length;
						animationCollection.addItem(animationVO);
						characterVO = animationVO;
						break;
						
					// Buttons
					case TagDefineButton.TYPE:
					case TagDefineButton2.TYPE:
						characterVO = new SWFButtonVO(tag);
						buttonCollection.addItem(characterVO);
						break;
						
					// Shapes
					case TagDefineShape.TYPE:
					case TagDefineShape2.TYPE:
					case TagDefineShape3.TYPE:
					case TagDefineShape4.TYPE:
					case TagDefineMorphShape.TYPE:
					case TagDefineMorphShape2.TYPE:
						characterVO = new SWFShapeVO(tag);
						shapeCollection.addItem(characterVO);
						break;

					// Bitmaps
					case TagDefineBits.TYPE:
						// DefineBits tags require a JPEGTables tag to be present
						if(!assetSWFHasJPEGTables && jpegTablesTag) {
							assetSWF.tags.push(jpegTablesTag);
							assetSWFHasJPEGTables = true;
						}
						// fall through
					case TagDefineBitsJPEG2.TYPE:
					case TagDefineBitsJPEG3.TYPE:
					case TagDefineBitsJPEG4.TYPE:
					case TagDefineBitsLossless.TYPE:
					case TagDefineBitsLossless2.TYPE:
						characterVO = new SWFBitmapVO(tag);
						bitmapCollection.addItem(characterVO);
						break;
						
					// Fonts
					case TagDefineFont.TYPE:
					case TagDefineFont2.TYPE:
					case TagDefineFont3.TYPE:
					case TagDefineFont4.TYPE:
						characterVO = new SWFFontVO(tag);
						fontCollection.addItem(characterVO);
						break;
					case TagDefineFontInfo.TYPE:
						var defineFontInfo:TagDefineFontInfo = tag as TagDefineFontInfo;
						fontVO = getCharacterVO(defineFontInfo.fontId) as SWFFontVO;
						if(fontVO != null) {
							fontVO.defineFontInfo = defineFontInfo;
							assetSWF.tags.push(defineFontInfo);
						}
						break;
					case TagDefineFontName.TYPE:
						var defineFontName:TagDefineFontName = tag as TagDefineFontName;
						fontVO = getCharacterVO(defineFontName.fontId) as SWFFontVO;
						if(fontVO != null) {
							fontVO.defineFontName = defineFontName;
							assetSWF.tags.push(defineFontName);
						}
						break;
					case TagDefineFontAlignZones.TYPE:
						var defineFontAlignZones:TagDefineFontAlignZones = tag as TagDefineFontAlignZones;
						fontVO = getCharacterVO(defineFontAlignZones.fontId) as SWFFontVO;
						if(fontVO != null) {
							fontVO.defineFontAlignZones = defineFontAlignZones;
							assetSWF.tags.push(defineFontAlignZones);
						}
						break;
				}
				
				if(characterVO)
				{
					if(characterVO.hasAsset)
					{
						assetsCount++;
						// Add tag to assets SWF
						assetSWF.tags.push(characterVO.tag);
						// Add entry to TagSymbolClass
						var symbol:SWFSymbol = new SWFSymbol();
						symbol.tagId = characterVO.tag.characterId;
						symbol.name = PACKAGE_PREFIX + characterVO.className;
						assetSWFSymbolClass.symbols.push(symbol);
						// Add symbol to temporary lookup map (characterId > SWFSymbol)
						symbolMap[characterVO.tag.characterId] = symbol;
					}
					// Add character to lookup map (characterId > SWFCharacterVO)
					characterMap[characterVO.tag.characterId] = characterVO;
				}
			//}
			return tag;
		}
		
		protected function updateClassNames(symbols:Vector.<SWFSymbol>):void
		{
			for(var i:int = 0; i < symbols.length; i++) {
				var symbol:SWFSymbol = symbols[i];
				if(symbol.tagId == 0) {
					documentClassVO.className = symbol.name;
				} else {
					if(characterMap[symbol.tagId] != undefined) {
						var swfCharacterVO:SWFCharacterVO = characterMap[symbol.tagId] as SWFCharacterVO;
						swfCharacterVO.className = symbol.name;
					}
					if(symbolMap[symbol.tagId] != undefined) {
						var swfSymbol:SWFSymbol = symbolMap[symbol.tagId] as SWFSymbol;
						swfSymbol.name = PACKAGE_PREFIX + symbol.name;
					}
				}
			}
		}
		
		override protected function parseTagsFinalize():void
		{
			super.parseTagsFinalize();
			if(assetsCount > 0) {
				assetsProcessed = 0;
				enterFrameProvider.addEventListener(Event.ENTER_FRAME, createAssetsEnterFrameHandler);
				dispatchEvent(new SWFAssetCreationEvent(SWFAssetCreationEvent.START, assetsProcessed, assetsCount));
			} else {
				// We're done
				createAssetsFinalize();
				dispatchEvent(new SWFAssetCreationEvent(SWFAssetCreationEvent.COMPLETE));
			}
		}
		
		protected function createAssetsEnterFrameHandler(event:Event):void
		{
			enterFrameProvider.removeEventListener(Event.ENTER_FRAME, createAssetsEnterFrameHandler);
			createAssets();
		}
		
		protected function createAssets():void
		{
			var startTime:int = getTimer();
			var timeout:Boolean = false;
			
			// Iterate over all exported characters
			for(var key:Object in symbolMap)
			{
				var characterVO:SWFCharacterVO = getCharacterVO(uint(key));
				var qname:String = PACKAGE_PREFIX + characterVO.className;
				var qnameArr:Array = qname.split(".");
				var className:String = qnameArr.pop();

				// Create package and class
				var abcBuilder:IAbcBuilder = new AbcBuilder();
				var packageBuilder:IPackageBuilder = abcBuilder.definePackage(qnameArr.join("."));
				var classBuilder:IClassBuilder = packageBuilder.defineClass(className, characterVO.superClassName);
				classBuilder.isDynamic = true;

				// BitmapData subclasses need a custom constructor:
				// public function BitmapDataSubclass(width:int = 550, height:int = 400) {
				//    super(width, height)
				// }
				if(characterVO is SWFBitmapVO) {
					var bitmapVO:SWFBitmapVO = characterVO as SWFBitmapVO;
					var ctorBuilder:ICtorBuilder = classBuilder.defineConstructor();
					ctorBuilder.defineArgument("int", true, bitmapVO.width);
					ctorBuilder.defineArgument("int", true, bitmapVO.height);
					ctorBuilder.addOpcode(Opcode.getlocal_0)
						.addOpcode(Opcode.pushscope)
						.addOpcode(Opcode.getlocal_0)
						.addOpcode(Opcode.getlocal_1)
						.addOpcode(Opcode.getlocal_2)
						.addOpcode(Opcode.constructsuper, [2])
						.addOpcode(Opcode.returnvoid);
				}

				// Create the ABC file
				var abcFile:AbcFile = abcBuilder.build();
				var abcSerializer:AbcSerializer = new AbcSerializer();
				var abcBytes:ByteArray = abcSerializer.serializeAbcFile(abcFile);
	
				// Write DoABC to assets SWF
				assetSWF.tags.push(TagDoABC.create(abcBytes));
				
				delete symbolMap[key];
				
				assetsProcessed++;
				
				if(getTimer() - startTime > 40) {
					timeout = true;
					break;
				}
			}

			if(timeout)
			{
				// We ran into a timeout. Continue in next frame.
				dispatchEvent(new SWFAssetCreationEvent(SWFAssetCreationEvent.PROGRESS, assetsProcessed, assetsCount));
				enterFrameProvider.addEventListener(Event.ENTER_FRAME, createAssetsEnterFrameHandler);
			}
			else
			{
				// We're done
				// Write SymbolClass, ShowFrame, End tags
				assetSWF.tags.push(assetSWFSymbolClass);
				assetSWF.tags.push(new TagShowFrame());
				assetSWF.tags.push(new TagEnd());
				// Publish the assets SWF to a ByteArray
				var ba:ByteArray = new ByteArray();
				assetSWF.publish(ba);
				// Load the published SWF
				var context:LoaderContext = new LoaderContext();
				context.allowCodeImport = true;
				assetSWFLoader = new Loader();
				assetSWFLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, assetSWFLoadCompleteHandler);
				assetSWFLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, assetSWFLoadErrorHandler);
				assetSWFLoader.contentLoaderInfo.addEventListener(IOErrorEvent.VERIFY_ERROR, assetSWFLoadErrorHandler);
				assetSWFLoader.loadBytes(ba, context);
				createAssetsFinalize();
			}
		}
		
		protected function createAssetsFinalize():void
		{
			assetSWF = null;
			assetSWFSymbolClass = null;
			symbolMap = null;
			// Update Root VO with frame and layer counts
			documentClassVO.numFrames = frames.length;
			documentClassVO.numLayers = layers.length;
		}
		
		protected function assetSWFLoadCompleteHandler(event:Event):void
		{
			var appDomain:ApplicationDomain = LoaderInfo(event.target).applicationDomain;
			for(var key:Object in characterMap) {
				try {
					var characterVO:SWFCharacterVO = characterMap[key] as SWFCharacterVO;
					if(characterVO.hasAsset) {
						characterVO.ClassDefinition = appDomain.getDefinition(PACKAGE_PREFIX + characterVO.className) as Class;
					}
				} catch(e:Error) {
					trace(e);
				}
			}
			dispatchEvent(new SWFAssetCreationEvent(SWFAssetCreationEvent.COMPLETE, assetsProcessed, assetsCount));
		}
		
		protected function assetSWFLoadErrorHandler(event:IOErrorEvent):void
		{
			trace(event);
		}
	}
}
