/*****************************************************
 *  
 *  Jonathan Sjölund and Andreas Nordberg
 *  
 *****************************************************/

package org.osmf.player.chrome.widgets
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import org.osmf.layout.LayoutMode;
	import org.osmf.player.chrome.assets.AssetsManager;
	

	public class GeoMapSprite extends Sprite
	{
		private var geomapObject:GeoMapObject,geomapObject2:GeoMapObject,geomapObject3:GeoMapObject;
		private var x2:int;
		private var y2:int;
		private var Mapradius:int;
		private var assetManager:AssetsManager;
		
		public function GeoMapSprite(x1:int,y1:int,Mapradius:int, assetManager:AssetsManager) 
		{
			super();
			this.x2 = x1;
			this.y2 = y1;
			this.Mapradius = Mapradius;
			this.assetManager = assetManager;
			
			graphics.clear();
			graphics.beginFill(0xffffff,1);
			graphics.drawCircle(x1,y1,Mapradius);
			graphics.endFill();
			createObjects();
			
			
		}
		
		private function createObjects():void
		{		
			geomapObject = new GeoMapObject(Mapradius+40,0,assetManager);
			geomapObject.setDirection(40);
			geomapObject2 = new GeoMapObject(Mapradius+200,-20,assetManager);
			geomapObject2.setDirection(270);
			geomapObject3 = new GeoMapObject(Mapradius+50,40, assetManager);
			geomapObject3.setDirection(70);
			addChild(geomapObject);
			addChild(geomapObject2);
			addChild(geomapObject3);
		}
		
		public function onMouseClick(event:MouseEvent):void
		{
			geomapObject.onMouseClick(event);
			geomapObject2.onMouseClick(event);
			geomapObject3.onMouseClick(event);
		}
	}
}


