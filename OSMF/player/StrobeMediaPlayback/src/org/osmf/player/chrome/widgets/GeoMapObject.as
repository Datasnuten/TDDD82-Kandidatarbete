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
	
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.LayoutMode;
	import org.osmf.layout.VerticalAlign;
	import org.osmf.player.chrome.assets.AssetIDs;
	import org.osmf.player.chrome.assets.AssetsManager;

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
		protected var disabled:DisplayObject;
		
		protected var mouseOver:Boolean;
		
		private var state:Boolean = false;
		
		public var disabledFace:String = null;
		
		
		public function GeoMapObject(context:GeoMapSprite,positionX:int,positionY:int,assetManager:AssetsManager)
		{
			super();
			if(positionX < context.Mapradius){
				var adjust:int = positionX-context.Mapradius;
				this.positionX = positionX-adjust;
			}
			
			this.positionY = positionY;
			
			mouseEnabled = true;
			
			layoutMetadata.verticalAlign = VerticalAlign.MIDDLE
			layoutMetadata.horizontalAlign = HorizontalAlign.LEFT;;
			
			addEventListener(MouseEvent.CLICK, onMouseClick);
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			
			normal = assetManager.getDisplayObject(normalFace);
			selected = assetManager.getDisplayObject(selectedFace);
			disabled =  assetManager.getDisplayObject(disabledFace);
			
			normal.x = positionX;
			normal.y = positionY;
			
			selected.x = positionX;
			selected.y = positionY;
			
			addEventListener(MouseEvent.CLICK, onMouseClick);
			
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
		
		public function onMouseOver(event:MouseEvent):void
		{
			Mouse.cursor = flash.ui.MouseCursor.BUTTON;
			mouseOver = true;
		}
		
		public function onMouseOut(event:MouseEvent):void
		{
			Mouse.cursor = flash.ui.MouseCursor.ARROW;
			mouseOver = false;
			updateFace(enabled ? normal : disabled);
		}
		
		protected function onMouseDown(event:MouseEvent):void
		{
			mouseOver = false;
			updateFace(enabled ? selected : disabled);
		}
		
		private function update():void
		{
			normal.rotation = direction;
			selected.rotation = direction;
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













