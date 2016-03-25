package org.osmf.player.chrome.widgets
{
	import flash.display.Sprite;

	public class GeoMapObject extends Sprite
	{
		private var positionX:int;
		private var positionY:int;
		private var radius:int;
		private var xCoordinate:int;
		private var yCoordinate:int;
		private var direction:Number;
		
		public function GeoMapObject(positionX:int,positionY:int,radius:int,direction:Number)
		{
			
			this.positionX = positionX;
			this.positionY = positionY;
			this.radius = radius;
			this.direction = direction;
			
			graphics.clear();
			graphics.beginFill(0xf03026,1);
			graphics.drawCircle(positionX,positionY,radius);
			graphics.endFill();
		}
	
		public function get getPositionX():int
		{
			return positionX;
		}
		
		public function get getPositionY():int
		{
			return positionY;
		}
		
		public function get getRadius():int
		{
			return radius;
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
		}
		
		public function get getDirection():Number
		{
			return direction;
		}
	}
}