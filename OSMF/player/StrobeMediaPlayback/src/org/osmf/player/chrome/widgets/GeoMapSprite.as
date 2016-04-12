/*****************************************************
 *  
 *  Jonathan Sjölund and Andreas Nordberg
 *  
 *****************************************************/

package org.osmf.player.chrome.widgets
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.Dictionary;
	import flash.utils.flash_proxy;
	
	import org.osmf.layout.LayoutMode;
	import org.osmf.logging.Log;
	import org.osmf.player.chrome.assets.AssetsManager;
	
	

	public class GeoMapSprite extends Sprite
	{
		private var geomapObject:GeoMapObject;
		private var incrementer:int = 0;
		private var x2:int;
		private var y2:int;
		private var Mapradius:int;
		private var assetManager:AssetsManager;
		private var pointOfInterest:Sprite;
		public var object:int;
		private var text:TextField;
		
		private var dict:Object = new Object();
		
		//Exempel: Lägga till geomapObject i mappen med nyckeln befintlig variabel x2
		//dict.x2 = geomapObject;
		
		//Exempel: Lägga till geomapObject i mappen med nyckeln icke-befintlig sträng 1234
		//dict["1234"] = geomapObject2;
		
		
		private var array:Array;
		/*private var aList:ArrayList;*/
		
		public function GeoMapSprite(x1:int,y1:int,Mapradius:int, assetManager:AssetsManager) 
		{
			super();
			this.x2 = x1;
			this.y2 = y1;
			this.Mapradius = Mapradius;
			this.assetManager = assetManager;
			
			drawPointOfInterest();
			
			graphics.clear();
			graphics.beginFill(0xffffff,1);
			graphics.drawCircle(x1,y1,Mapradius);
			graphics.endFill();
			
			//addEventListener(MouseEvent.CLICK, onMouseClick);
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
			tempCallCreateObjects();
		}
		
		
		private function drawPointOfInterest():void
		{
			
			var xAdjust:int = 30;
			var yAdjust:int = -100;
			var string:String = "Point Of Interest";
			var poiRadius:int = 40;
			var pointOfInterest:Sprite = new Sprite();
			text = new TextField();
			text.backgroundColor = 0xff0000;
			text.text = string;
			text.wordWrap = true;
			text.multiline = true;
			text.scaleX = 0.8;
				
			text.y = y2-poiRadius/2+yAdjust;
			text.x = x2-4*poiRadius/7+xAdjust;
			
			pointOfInterest.graphics.clear();
			pointOfInterest.graphics.beginFill(0x0040ff,1);
			pointOfInterest.graphics.drawCircle(x2+xAdjust,y2+yAdjust,poiRadius);
			pointOfInterest.graphics.endFill();
			pointOfInterest.addChild(text);
			addChild(pointOfInterest);
		}
		
		private function tempCallCreateObjects():void {
<<<<<<< HEAD
			createObjects(-100,0,20,"http://mediapm.edgesuite.net/osmf/content/test/manifest-files/dynamic_Streaming.f4m");
			//dict[0].setDefault();
			createObjects(80,-80,350,"hej");
=======
			createObjects(-100,0,70,"http://mediapm.edgesuite.net/osmf/content/test/manifest-files/dynamic_Streaming.f4m");
			createObjects(80,-80,270,"hej");
>>>>>>> origin/master
			createObjects(0,120,0,"hej");
			createObjects(0,50,180,"hej");
		}
		
		private function createObjects(x:int, y:int, angle:int, url:String):void
		{	
			geomapObject = new GeoMapObject(this,x2+x,y2+y,assetManager);
			geomapObject.setDirection(angle);
			geomapObject.setURL(url);
			
			addChild(geomapObject);
			
			dict[incrementer] = geomapObject;
			incrementer = incrementer+1;
		}
	
		public function onMouseClick(event:MouseEvent):void
		{
			for each(var obj:* in dict) {
				obj.onMouseClick(event,dict);
			}
		}
		
		public function onMouseMove(event:MouseEvent):void
		{
			Mouse.cursor = flash.ui.MouseCursor.BUTTON;			
			for each(var obj:* in dict) {
				obj.onMouseMove(event);
			}
		}
		
	}
}


