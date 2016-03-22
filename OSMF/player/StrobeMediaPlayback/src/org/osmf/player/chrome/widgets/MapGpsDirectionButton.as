/*****************************************************
 *  
 *  Jonathan Sjölund and Andreas Nordberg
 *  
 *****************************************************/

package org.osmf.player.chrome.widgets
{
	import flash.display.DisplayObject;
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
	
	import org.osmf.logging.Log;
	import org.osmf.logging.Logger;
	import org.osmf.net.httpstreaming.HTTPDownloadManager;
	import org.osmf.player.chrome.assets.AssetIDs;
	
	public class MapGpsDirectionButton extends ButtonWidget
	{
		private var test:DisplayObject;
		private var sprite:Sprite;
		private var state:Boolean = false;
		
		public function MapGpsDirectionButton()
		{
			super();
			
			upFace = AssetIDs.MAP_GPS_DIRECTION_BUTTON_NORMAL
			downFace = AssetIDs.MAP_GPS_DIRECTION_BUTTON_DOWN;
			overFace = AssetIDs.MAP_GPS_DIRECTION_BUTTON_OVER;
			sprite = new Sprite();
			addChild(sprite);
			
		}
		
		override protected function onMouseClick(event:MouseEvent):void
		{
			
		/*	sprite.x = 10;
			sprite.graphics.clear();
			sprite.graphics.beginFill(0xFFFFFF, 0);
			sprite.graphics.drawRect(0,5,10,20);
			sprite.graphics.endFill();
			sprite.height = 40;
			
			sprite.addChild(test);
			*/
			state = !state;
			if(state){
				setFace(down);
			}
			else
				setFace(over);
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
			if(!state){
			setFace(up);
			}
			mouseOver = false;
		}
		
	}
}