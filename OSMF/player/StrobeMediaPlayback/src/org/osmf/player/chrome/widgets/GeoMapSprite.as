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
		private var radius:int = 7;
		
		public function GeoMapSprite(x:int,y:int,Mapradius:int) 
		{
			super();
			this.x = x;
			this.y = y;
			this.Mapradius = Mapradius;
			
			graphics.clear();
			graphics.beginFill(0xffffff,1);
			graphics.drawCircle(x,y,Mapradius);
			graphics.endFill();
			creatObjects();
			
		}		
		
		private function creatObjects():void
		{			
			geomapObject = new GeoMapObject(Mapradius+radius,0,radius,0);
			geomapObject2 = new GeoMapObject(Mapradius+radius+200,-20,radius,0);
			geomapObject3 = new GeoMapObject(Mapradius+radius+50,40,radius,0);
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


