/*****************************************************
 *  
 *  Jonathan Sjölund and Andreas Nordberg
 *  
 *****************************************************/

package org.osmf.player.chrome.widgets
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	

	public class GeoMapSprite extends Sprite
	{
		private var geomapObject,geomapObject2,geomapObject3:GeoMapObject;
		private var x:int;
		private var y:int;
		private var Mapradius:int;
		private var radius:int = 10;
		
		public function GeoMapSprite(x:int,y:int,radius:int) 
		{
			super();
			this.x = x;
			this.y = y;
			this.Mapradius = radius;
			
			graphics.clear();
			graphics.beginFill(0xffffff,1);
			graphics.drawCircle(x,y,radius);
			graphics.endFill();
			creatObjects();
			
		}		
		
		private function creatObjects():void
		{			
			geomapObject = new GeoMapObject(Mapradius+radius,0,radius);
			geomapObject2 = new GeoMapObject(Mapradius+radius+200,-20,radius);
			geomapObject3 = new GeoMapObject(Mapradius+radius+50,40,radius);
			addChild(geomapObject);
			addChild(geomapObject2);
			addChild(geomapObject3);
		}
		
		
		protected function onMouseClick(event:MouseEvent):void
		{
			event.stopPropagation();
		}
		
		protected function onMouseOver(event:MouseEvent):void
		{
			event.stopPropagation();
		}
		protected function onMouseOut(event:MouseEvent):void
		{	
			event.stopPropagation();
		}
	}
}


