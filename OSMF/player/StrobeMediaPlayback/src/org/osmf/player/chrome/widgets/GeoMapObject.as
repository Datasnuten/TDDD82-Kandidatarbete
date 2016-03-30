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
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.LayoutMode;
	import org.osmf.layout.VerticalAlign;
	import org.osmf.player.chrome.assets.AssetIDs;
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.player.chrome.hint.OwnWidgetHint;

	public class GeoMapObject extends Widget
	{
		private var positionX:int;
		private var positionY:int;
		private var xCoordinate:int;
		private var yCoordinate:int;
		private var direction:Number = 0;
		
		private var normalFace:String = AssetIDs.MAP_GPS_DIRECTION_DOTARROW_NORMAL;
		private var selectedFace:String = AssetIDs.MAP_GPS_DIRECTION_DOTARROW_SELECTED;
		
		protected var normal:DisplayObject;
		protected var selected:DisplayObject;
		protected var currentFace:DisplayObject;
		
		protected var mouseOver:Boolean;
		
		private var state:Boolean = false;
		
		private var context:GeoMapSprite;
		
		
		public function GeoMapObject(context:GeoMapSprite,positionX:int,positionY:int,assetManager:AssetsManager)
		{
			super();
				
			this.positionY = positionY;
			this.positionX = positionX;
			this.context = context;
			
			normal = assetManager.getDisplayObject(normalFace);
			selected = assetManager.getDisplayObject(selectedFace);
			
			normal.x = this.positionX;
			normal.y = this.positionY;
			
			selected.x = this.positionX;
			selected.y = this.positionY;
			
			addEventListener(MouseEvent.CLICK, onMouseClick);
			/*addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);*/
			
			updateFace(normal);
		}
		
		private function updateFace(face:DisplayObject):void
		{
			if (currentFace != face)
			{
				if (currentFace != null)
				{
					removeChild(currentFace);
				}
				
				currentFace = face;
				
				if (currentFace != null)
				{
					addChildAt(currentFace, 0);
					
					measure();
					
					width = currentFace.width;
					height = currentFace.height;
				}
			}
		}
		
		public function onMouseClick(event:MouseEvent):void
		{
			state = !state;
			if(state){
			updateFace(selected);
			}else{
				updateFace(normal);
			}
		}
		
		public function onMouseMove(event:MouseEvent):void
		{
			if(mouseX < positionX+width && mouseX > positionX && mouseY < positionY+height && mouseY > positionY){
				Mouse.cursor = flash.ui.MouseCursor.BUTTON;
			}
			
		}
		
		/*public function onMouseOver(event:MouseEvent):void
		{
		Mouse.cursor = flash.ui.MouseCursor.BUTTON;
		}*/
		
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
			normal.rotation = direction;
			selected.rotation = direction;
		}
		
		public function get getDirection():Number
		{
			return direction;
		}
		
		public function setPositionX(positionX:int):void
		{
			this.positionX = positionX;
		}
		
		public function get getPositionX():int
		{
			return positionX;
		}
		
		public function setPositioY(positionY:int):void
		{
			this.positionY = positionY;
		}
		
		public function get getPositionY():int
		{
			return positionY;
		}
		
		public function get getCurrentFace():DisplayObject
		{
			return currentFace;
		}
	}
}













