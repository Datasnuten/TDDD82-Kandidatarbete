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
		private var currentFace:DisplayObject;
		
		/*protected var currentFace:DisplayObject;*/
		
		private var state:Boolean = false;
		
		public function GeoMapObject(positionX:int,positionY:int,assetManager:AssetsManager)
		{
			super();
			this.positionX = positionX;
			this.positionY = positionY;
			
			layoutMetadata.verticalAlign = VerticalAlign.MIDDLE
			layoutMetadata.horizontalAlign = HorizontalAlign.LEFT;;
			
			addEventListener(MouseEvent.CLICK, onMouseClick);
			
			normal = assetManager.getDisplayObject(normalFace) || new Sprite();
			selected = assetManager.getDisplayObject(selectedFace) || new Sprite();
			
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













