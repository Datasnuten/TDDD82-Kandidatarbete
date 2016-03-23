package org.osmf.player.chrome.widgets
{
	import flash.display.Sprite;

	public class GeoMapObject extends Sprite
	{
		private var positionX:int;
		private var positionY:int;
		private var radius:int;
		
		public function GeoMapObject(positionX:int,positionY:int,radius:int)
		{
			
			this.positionX = positionX;
			this.positionY = positionY;
			this.radius = radius;
			
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
	}
}