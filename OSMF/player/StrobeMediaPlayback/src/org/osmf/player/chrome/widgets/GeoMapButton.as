/*****************************************************
 *  
 *  Jonathan Sjölund and Andreas Nordberg
 *  
 *****************************************************/

package org.osmf.player.chrome.widgets
{
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.LayoutMode;
	import org.osmf.player.chrome.assets.AssetIDs;
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.player.chrome.hint.OwnWidgetHint;
	
	public class GeoMapButton extends ButtonWidget
	{
		private var state:Boolean = false;

		public function GeoMapButton()
		{
			super();
			
			upFace = AssetIDs.MAP_GPS_DIRECTION_BUTTON_NORMAL
			downFace = AssetIDs.MAP_GPS_DIRECTION_BUTTON_DOWN;
			overFace = AssetIDs.MAP_GPS_DIRECTION_BUTTON_OVER;
			
			layoutMetadata.layoutMode = LayoutMode.HORIZONTAL;
			
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
		}
		
		override public function configure(xml:XML, assetManager:AssetsManager):void
		{
			super.configure(xml, assetManager);
			
			StrobeMediaPlayback.geomapWidget.configure(xml, assetManager);
			StrobeMediaPlayback.geomapWidget.layoutMetadata.layoutMode = LayoutMode.VERTICAL;
			StrobeMediaPlayback.geomapWidget.layoutMetadata.width = layoutMetadata.width;
			StrobeMediaPlayback.geomapWidget.layoutMetadata.height = layoutMetadata.height;
		}
		
		override public function layout(availableWidth:Number, availableHeight:Number, deep:Boolean=true):void
		{
			if(currentFace==down){
				state=!state
				setFace(up);
			}
			OwnWidgetHint.getInstance(this).hide();
			measure();
			super.layout(Math.max(measuredWidth, availableWidth), Math.max(measuredHeight, availableHeight));
		}
		
		override protected function onMouseClick(event:MouseEvent):void
		{
			
			if (event.localY >= 0 && (event.localY <= height || isNaN(height)))
			{
				state = !state;
				OwnWidgetHint.getInstance(this).horizontalAlign = HorizontalAlign.CENTER;
			if(StrobeMediaPlayback.geomapWidget)
			{
				OwnWidgetHint.getInstance(this).widget = StrobeMediaPlayback.geomapWidget;
			}
			if(state){
				setFace(down);
			}
			else{
				OwnWidgetHint.getInstance(this).hide();
				setFace(over);
			}
			}
			else{
				if(StrobeMediaPlayback.geomapWidget) StrobeMediaPlayback.geomapWidget.dispatchEvent(event);
			}
			
		}
		
		override protected function onMouseOver(event:MouseEvent):void
		{
			if(!state){
				setFace(over);
			}
			mouseOver = true;
		}
		override protected function onMouseOut(event:MouseEvent):void
		{	
			if(!state){
				setFace(up);
				OwnWidgetHint.getInstance(this).hide();
			}
			Mouse.cursor = flash.ui.MouseCursor.ARROW;
			mouseOver = false;
			
		}
		
		private function onMouseMove(event:MouseEvent):void
		{
			if (event.localY >= 0 && (event.localY <= height || isNaN(height)))
			{
				Mouse.cursor = flash.ui.MouseCursor.BUTTON;
			}else{
				Mouse.cursor = flash.ui.MouseCursor.ARROW;
			}
			StrobeMediaPlayback.geomapWidget.onMouseMove(event);
		}
		
	}
}