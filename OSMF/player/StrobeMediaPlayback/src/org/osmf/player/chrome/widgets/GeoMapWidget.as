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
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.flash_proxy;
	
	import org.osmf.events.AudioEvent;
	import org.osmf.layout.LayoutMode;
	import org.osmf.media.MediaElement;
	import org.osmf.player.chrome.assets.AssetIDs;
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.player.chrome.events.ScrubberEvent;
	import org.osmf.traits.AudioTrait;
	import org.osmf.traits.MediaTraitType;

	public class GeoMapWidget extends Widget
	{
		private var geomapClickableArea:Sprite;
		private var geomapFace:DisplayObject;
		private var geomapSprite:GeoMapSprite;
		private var geomapWidth:int = 500;
		private var geomapHeight:int = 500;
		private var geomapRadius:int = 180;
		private var geomapAdjust:int = 90;
		
		
		public function GeoMapWidget()
		{
			super();
			mouseEnabled = true;
			
			layoutMetadata.layoutMode = LayoutMode.HORIZONTAL;
			
			geomapClickableArea = new Sprite();
			
			addEventListener(MouseEvent.CLICK, onMouseClick);
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			
			addChild(geomapClickableArea);
		}
		
		override public function configure(xml:XML, assetManager:AssetsManager):void
		{
			super.configure(xml, assetManager);	
			
			geomapSprite = new GeoMapSprite(geomapWidth-geomapWidth/3,0,geomapRadius, assetManager);
		
			geomapClickableArea.x = geomapRadius;
			geomapClickableArea.y = geomapRadius;
			geomapClickableArea.graphics.clear();
			geomapClickableArea.graphics.beginFill(0x49ff00, 0);
			geomapClickableArea.graphics.drawRect(0,0,geomapWidth+geomapRadius, geomapAdjust + geomapSprite.height/ 3.0);
			geomapClickableArea.graphics.endFill();
			geomapClickableArea.height = geomapAdjust + geomapSprite.height / 3.0;
			
			geomapClickableArea.addChild(geomapSprite);
		}
		
		private function onMouseClick(event:MouseEvent):void
		{
			event.stopPropagation();
			geomapSprite.onMouseClick(event);
		}
		
		private function onMouseOver(event:MouseEvent):void
		{
			event.stopPropagation();
		}
		
		public function onMouseMove(event:MouseEvent):void
		{
			
		}
	}
}