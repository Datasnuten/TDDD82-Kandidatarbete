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
	
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.LayoutMode;
	import org.osmf.player.chrome.assets.AssetIDs;
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.player.chrome.hint.WidgetHint;

	public class GeoMapObject extends Widget
	{
		private var positionX:int;
		private var positionY:int;
		private var xCoordinate:int;
		private var yCoordinate:int;
		private var direction:Number;
		
		private var normalFace:String = AssetIDs.MAP_GPS_DIRECTION_DOTARROW_NORMAL;
		private var selectedFace:String = AssetIDs.MAP_GPS_DIRECTION_DOTARROW_SELECTED;;
		
		protected var normal:DisplayObject;
		protected var selected:DisplayObject;
		
		protected var currentFace:DisplayObject;
		
		public function GeoMapObject(positionX:int,positionY:int,direction:Number,assetManager:AssetsManager)
		{
			super();
			this.positionX = positionX;
			this.positionY = positionY;
			this.direction = direction;
			
			addEventListener(MouseEvent.CLICK, onMouseClick);
			
			normal = assetManager.getDisplayObject(normalFace) || new Sprite();
			selected = assetManager.getDisplayObject(selectedFace) || new Sprite();
			
			normal.x = positionX;
			normal.y = positionY;
			normal.rotation = direction;
			
			selected.x = positionX;
			selected.y = positionY;
			selected.rotation = direction;
			
			addEventListener(MouseEvent.CLICK, onMouseClick);
			
			updateFace(normal);
		}
		
		private function updateFace(face:DisplayObject):void
		{
			if (currentFace != face)
			{
				if (currentFace)
				{
					removeChild(currentFace);
				}
				
				currentFace = face;
				
				if (currentFace)
				{
					addChild(currentFace);
				}
			}
		}
		
		protected function onMouseClick(event:MouseEvent):void
		{
			if (event.localY >= 0 && (event.localY <= height || isNaN(height)))
			{
			updateFace(selected);	
			}
		}
		
		private function update():void
		{
			
		}
		
		public function setXcoordinate(xCoordinate:int):void
		{
			this.xCoordinate = xCoordinate;
		}
		
		public function get getXcoordinate():int
		{
			return xCoordinate;
		}
		public function setYcoordinate(yCoordinate:int):void
		{
			this.yCoordinate = yCoordinate;
		}
		
		public function get getYcoordinate():int
		{
			return yCoordinate;
		}
		
		public function setDirection(direction:int):void
		{
			this.direction = direction;
			update();
		}
		
		public function get getDirection():Number
		{
			return direction;
		}
	}
}













