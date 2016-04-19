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
		private var geomapFace:DisplayObject;
		private var geomapSprite:GeoMapSprite;
		private var geomapRadius:int = 180;
		public var smp:StrobeMediaPlayback;
		
		
		public function GeoMapWidget(smp:StrobeMediaPlayback)
		{
			super();
			mouseEnabled = true;
			
			this.smp = smp;
			layoutMetadata.layoutMode = LayoutMode.HORIZONTAL;
			
			addEventListener(MouseEvent.CLICK, onMouseClick);
			/*addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);*/
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
		}
		
		override public function configure(xml:XML, assetManager:AssetsManager):void
		{
			super.configure(xml, assetManager);	
			
			geomapSprite = new GeoMapSprite(2*geomapRadius,geomapRadius-geomapRadius/5,geomapRadius, assetManager, smp);
			
			geomapSprite.mouseEnabled = true;
			addChild(geomapSprite);
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