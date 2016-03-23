/*****************************************************
 *  
 *  Jonathan Sjölund and Andreas Nordberg
 *  
 *****************************************************/

package org.osmf.player.chrome.widgets
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import org.osmf.layout.LayoutMode;
	import org.osmf.player.chrome.assets.AssetIDs;
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.player.chrome.events.ScrubberEvent;

	public class GeoMapWidget extends Widget
	{
		private var geomapClickableArea:Sprite;
		private var geomapFace:DisplayObject;
		private var geomap:GeoMapSprite;
		private var geomapWidth:int = 500;
		private var geomapHeight:int = 500;
		private var geomapRadius:int = 170;
		private var geomapAdjust:int = 90;
		
		public function GeoMapWidget()
		{
			super();
			mouseEnabled = true;
			
			layoutMetadata.layoutMode = LayoutMode.HORIZONTAL;
			
			geomapClickableArea = new Sprite();
			
			addEventListener(MouseEvent.CLICK, onMouseClick);
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
			addChild(geomapClickableArea);
			
		}
		
		override public function configure(xml:XML, assetManager:AssetsManager):void
		{
			super.configure(xml, assetManager);	
			
			geomap = new GeoMapSprite(geomapWidth-geomapWidth/3,0,geomapRadius);
		
			geomapClickableArea.x = geomapRadius;
			geomapClickableArea.y = geomapRadius;
			geomapClickableArea.graphics.clear();
			geomapClickableArea.graphics.beginFill(0x49ff00, 0);
			geomapClickableArea.graphics.drawRect(0,0,geomapWidth+geomapRadius, geomapAdjust + geomap.height/ 3.0);
			geomapClickableArea.graphics.endFill();
			geomapClickableArea.height = geomapAdjust + geomap.height / 3.0;
			
			geomapClickableArea.addChild(geomap);
		}
		
		public function get Geomap():GeoMapSprite
		{
			return geomap;
		}
		
		private function onMouseClick(event:MouseEvent):void
		{
			event.stopPropagation();
			
			/*if(mouseY > (sliderStart - _slider.height / 2.0) && (_slider.y + _slider.mouseY  < sliderEnd + _slider.height / 2.0))
			{
				_slider.y = volumeClickArea.mouseY - _slider.height / 2.0;
				slider.start(false);
			}*/
			
		}
		protected function onMouseMove(event:MouseEvent):void
		{
			// stop event from propagating back to parent
			event.stopPropagation();
			/*if(mouseY > (sliderStart - _slider.height / 2.0) && (_slider.y + _slider.mouseY  < sliderEnd + _slider.height / 2.0))
			{
				_slider.y = volumeClickArea.mouseY - _slider.height / 2.0;
				slider.start(false);
			}*/
			
		}
		
		protected function onMouseDown(event:MouseEvent):void
		{
			event.stopPropagation();
			
			/*if(mouseY > (sliderStart - _slider.height / 2.0) && (_slider.y + _slider.mouseY  < sliderEnd + _slider.height / 2.0))
			{
				_slider.y = volumeClickArea.mouseY - _slider.height / 2.0;
				slider.start(false);
			}*/
		}
	}
}