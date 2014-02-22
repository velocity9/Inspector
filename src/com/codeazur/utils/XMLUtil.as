package com.codeazur.utils
{
	public class XMLUtil
	{		
		public static function jsDomToE4X(domElement:Object):XML {
			return _jsDomToE4X(domElement);
		}
		
		private static function _jsDomToE4X(domElement:Object, xml:XML = null):XML {
			var element:Object = domElement ? domElement.firstChild : null;
			while(element) {
				switch(element.nodeType) {
					case JSDOM_ELEMENT_NODE:
						try {
							// Create an E4X copy of the current element node
							var child:XML = <{element.localName} />;
							if(xml == null) {
								// This is the root node
								xml = child;
							} else {
								// This is a child node of the current node
								xml.appendChild(child);	
							}
							// Set the namespace, if appropriate
							if(element.namespaceURI != null && element.namespaceURI.toString().length > 0) {
								child.setNamespace(new Namespace(element.prefix, element.namespaceURI));
							}
							// Set the attributes
							for(var i:uint = 0; i < element.attributes.length; i++) {
								child.@[element.attributes[i].localName] = element.attributes[i].nodeValue;
								// TODO: namespaced attributes
							}
							// And recurse
							_jsDomToE4X(element, child);
						} catch(e:Error) {
							//trace(e);
						}
						break;
					case JSDOM_TEXT_NODE:
						// This is a text node: append the string value 
						// ugly workaround for an ugly bug, see:
						// http://gist.github.com/456446
						var dummy:XML = <dummy>{element.nodeValue}</dummy>.children()[0];
						if(dummy != null) {
							xml.appendChild(dummy);
						}
						break;
					case JSDOM_COMMENT_NODE:
						// This is a comment node.
						if(!XML.ignoreComments) {
							xml.appendChild(XML("<!--" + element.nodeValue + "-->"));
						}
						break;
					case JSDOM_DOCUMENT_TYPE_NODE:
					case JSDOM_ATTRIBUTE_NODE:
					case JSDOM_CDATA_SECTION_NODE:
					case JSDOM_ENTITY_REFERENCE_NODE:
					case JSDOM_ENTITY_NODE:
					case JSDOM_PROCESSING_INSTRUCTION_NODE:
					case JSDOM_DOCUMENT_NODE:
					case JSDOM_DOCUMENT_FRAGMENT_NODE:
					case JSDOM_NOTATION_NODE:
						// TODO: Implement other node types (CData would be handy, etc)
						break;
					
				}
				element = element.nextSibling;
			}
			return xml;
		}
		
		public static function getCharacterData(xml:XML):String {
			return _getCharacterData(xml);
		}
		
		private static function _getCharacterData(xml:XML):String {
			if(xml.hasSimpleContent()) {
				return xml.text();
			} else {
				var desc:XMLList = xml.descendants();
				var descNum:int = desc.length();
				var text:String = "";
				for(var i:uint = 0; i < descNum; i++) {
					if(desc[i].nodeKind() == "text") {
						text += desc[i];
					}
				}
				return text;
			}
		}
		
		private static const JSDOM_ELEMENT_NODE:uint = 1;
		private static const JSDOM_ATTRIBUTE_NODE:uint = 2;
		private static const JSDOM_TEXT_NODE:uint = 3;
		private static const JSDOM_CDATA_SECTION_NODE:uint = 4;
		private static const JSDOM_ENTITY_REFERENCE_NODE:uint = 5;
		private static const JSDOM_ENTITY_NODE:uint = 6;
		private static const JSDOM_PROCESSING_INSTRUCTION_NODE:uint = 7;
		private static const JSDOM_COMMENT_NODE:uint = 8;
		private static const JSDOM_DOCUMENT_NODE:uint = 9;
		private static const JSDOM_DOCUMENT_TYPE_NODE:uint = 10;
		private static const JSDOM_DOCUMENT_FRAGMENT_NODE:uint = 11;
		private static const JSDOM_NOTATION_NODE:uint = 12;
	}
}