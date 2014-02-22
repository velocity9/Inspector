package v9.view.editor.mainpanel.timeline
{
	import com.codeazur.as3swf.timeline.Layer;
	
	import mx.collections.IList;
	
	import spark.components.DataGroup;
	import spark.components.List;
	
	public class Timeline extends List
	{
		[SkinPart(required="false")]
		public var dataGroupRuler:DataGroup;

		[SkinPart(required="false")]
		public var dataGroupCaret:DataGroup;
		
		protected var totalFrames:uint;
		
		public function Timeline()
		{
			super();
		}
		
		public override function set dataProvider(value:IList):void {
			layout.clearVirtualLayoutCache();
			if(value && value.length > 0) {
				var layer:Layer = value.getItemAt(0) as Layer;
				totalFrames = layer.frameCount;
				var listLayout:TimelineLayout = layout as TimelineLayout;
				if(listLayout) {
					listLayout.totalFrames = totalFrames;
				}
				if(dataGroupRuler) {
					var rulerLayout:TimelineLayout = dataGroupRuler.layout as TimelineLayout;
					if(rulerLayout) {
						rulerLayout.totalFrames = totalFrames;
					}
				}
				if(dataGroupCaret) {
					var caretLayout:TimelineLayout = dataGroupCaret.layout as TimelineLayout;
					if(caretLayout) {
						caretLayout.totalFrames = totalFrames;
					}
				}
			}
			super.dataProvider = value;
		}
		
		override protected function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			if (instance == dataGroupRuler) {
			}
			if (instance == dataGroupCaret) {
			}
		}
	}
}