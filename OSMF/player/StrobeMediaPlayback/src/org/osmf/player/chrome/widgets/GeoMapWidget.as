/*****************************************************
 *  
 *  Jonathan Sjölund and Andreas Nordberg
 *  
 *****************************************************/

package org.osmf.player.chrome.widgets
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
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
	import org.osmf.player.chrome.hint.OwnWidgetHint;
	import org.osmf.traits.AudioTrait;
	import org.osmf.traits.MediaTraitType;

	public class GeoMapWidget extends Widget
	{
		private var geomapFace:DisplayObject;
		private var geomapSprite:GeoMapSprite;
		private var geomapXpos:int = 405;
		private var geomapYPos:int = 140;
		private var geomapRadius:int = 190;
		public var smp:StrobeMediaPlayback;
		
		//
		
		
		public function GeoMapWidget(smp:StrobeMediaPlayback)
		{
			super();
			mouseEnabled = true;
			
			this.smp = smp;
			layoutMetadata.layoutMode = LayoutMode.HORIZONTAL;
			
			addEventListener(MouseEvent.CLICK, onMouseClick);
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
		}
		
		override public function layout(availableWidth:Number, availableHeight:Number, deep:Boolean=true):void
		{
			measure();
			super.layout(Math.max(measuredWidth, availableWidth), Math.max(measuredHeight, availableHeight));
		}
		
		override public function configure(xml:XML, assetManager:AssetsManager):void
		{
			super.configure(xml, assetManager);	
			
			geomapSprite = new GeoMapSprite(geomapXpos,geomapYPos,geomapRadius, assetManager, smp);
			
			geomapSprite.mouseEnabled = true;
			addChild(geomapSprite);
		}
		
		public function fullscreenMode(isFullscreen:Boolean,stageWidth:int,stageHeight:int):void {
			
			if(isFullscreen) {
				geomapSprite.width = 700
				geomapSprite.height = 700;
				//scale kan (bör) även användas för att ändra storlek
				//stage x=680 y=480 xdelta=275 ydelta=340
				//mac fullscreen x=1440 y=900 => delta(minus/ta bort) x=1160 y=950 
				geomapSprite.x = stageWidth - 1160;
				geomapSprite.y = stageHeight - 950;
				
			} else {
				geomapSprite.scaleX = 1;
				geomapSprite.scaleY = 1;
				geomapSprite.x = 0;
				geomapSprite.y = 0;
			}
			geomapSprite.rescaleObjects(isFullscreen);
		}
		
		private function onMouseClick(event:MouseEvent):void
		{
			event.stopPropagation();
			geomapSprite.onMouseClick(event);
		}
		
		public function onMouseMove(event:MouseEvent):void
		{
			geomapSprite.onMouseMove(event);
		}
	}
}