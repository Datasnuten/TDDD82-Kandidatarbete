/*****************************************************
 *  
 *  Jonathan Sjölund and Andreas Nordberg
 *  
 *****************************************************/

package org.osmf.player.chrome.widgets
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Scene;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.system.System;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.LayoutMode;
	import org.osmf.player.chrome.assets.AssetIDs;
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.player.chrome.hint.WidgetHint;
	
	public class GeoMapButton extends ButtonWidget
	{
		private var state:Boolean = false;
		private var geomapWidget:GeoMapWidget;
		
		public function GeoMapButton()
		{
			super();
			
			upFace = AssetIDs.MAP_GPS_DIRECTION_BUTTON_NORMAL
			downFace = AssetIDs.MAP_GPS_DIRECTION_BUTTON_DOWN;
			overFace = AssetIDs.MAP_GPS_DIRECTION_BUTTON_OVER;
			
			layoutMetadata.layoutMode = LayoutMode.HORIZONTAL;
		}
		
		override public function configure(xml:XML, assetManager:AssetsManager):void
		{
			super.configure(xml, assetManager);
			
			geomapWidget = new GeoMapWidget();
			
			geomapWidget.configure(xml, assetManager);
			geomapWidget.layoutMetadata.layoutMode = LayoutMode.VERTICAL;
			geomapWidget.layoutMetadata.width = layoutMetadata.width;
		}
		
		override public function layout(availableWidth:Number, availableHeight:Number, deep:Boolean=true):void
		{
			WidgetHint.getInstance(this).hide();
			measure();
			super.layout(Math.max(measuredWidth, availableWidth), Math.max(measuredHeight, availableHeight));
		}
		
		override protected function onMouseClick(event:MouseEvent):void
		{
			state = !state;
			WidgetHint.getInstance(this).horizontalAlign = HorizontalAlign.CENTER;
			if(geomapWidget) WidgetHint.getInstance(this).widget = geomapWidget;
			if(state){
				setFace(down);
			}
			else{
				WidgetHint.getInstance(this).hide();
				setFace(over);
			}
			
		}
		
		override protected function onMouseOver(event:MouseEvent):void
		{
			Mouse.cursor = flash.ui.MouseCursor.BUTTON;
			if(!state){
			setFace(over);
			}
			mouseOver = true;
		}
		override protected function onMouseOut(event:MouseEvent):void
		{	
			if(state){
			state = !state;
			}
			setFace(up);
			WidgetHint.getInstance(this).hide();
			mouseOver = false;
			
		}
		
	}
}