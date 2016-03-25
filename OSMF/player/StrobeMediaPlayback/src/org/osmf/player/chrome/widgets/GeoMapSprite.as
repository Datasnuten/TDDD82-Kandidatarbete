/*****************************************************
 *  
 *  Jonathan Sjölund and Andreas Nordberg
 *  
 *****************************************************/

package org.osmf.player.chrome.widgets
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import org.osmf.layout.LayoutMode;
	import org.osmf.player.chrome.assets.AssetsManager;
	

	public class GeoMapSprite extends Sprite
	{
		private var geomapObject,geomapObject2,geomapObject3:GeoMapObject;
		private var x:int;
		private var y:int;
		private var Mapradius:int;
		private var assetManager:AssetsManager;
		
		public function GeoMapSprite(x:int,y:int,Mapradius:int, assetManager:AssetsManager) 
		{
			super();
			this.x = x;
			this.y = y;
			this.Mapradius = Mapradius;
			this.assetManager = assetManager;
			
			addEventListener(MouseEvent.CLICK, onMouseClick);
			
			graphics.clear();
			graphics.beginFill(0xffffff,1);
			graphics.drawCircle(x,y,Mapradius);
			graphics.endFill();
			creatObjects();
			
		}
		
		private function creatObjects():void
		{			
			geomapObject = new GeoMapObject(Mapradius+40,0,40,assetManager);
			geomapObject2 = new GeoMapObject(Mapradius+200,-20,20,assetManager);
			geomapObject3 = new GeoMapObject(Mapradius+50,40,10, assetManager);
			addChild(geomapObject);
			addChild(geomapObject2);
			addChild(geomapObject3);
		}
		
		
		private function onMouseClick(event:MouseEvent):void
		{
			event.stopPropagation();
			/*geomapObject.dispatchEvent(event);
			geomapObject2.dispatchEvent(event);
			geomapObject3.dispatchEvent(event);*/
		}
	}
}


