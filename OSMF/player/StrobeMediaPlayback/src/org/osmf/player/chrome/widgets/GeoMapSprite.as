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
	
	import org.osmf.containers.MediaContainer;
	import org.osmf.events.MediaFactoryEvent;
	import org.osmf.layout.LayoutMode;
	import org.osmf.logging.Log;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.media.URLResource;

	
	

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
		public var smp:StrobeMediaPlayback;
		
		private var dict:Object = new Object();
		private var text:TextField;
		
		// This is a normal video player setup.
		public var mediaFactory:MediaFactory = new DefaultMediaFactory();
		public var mediaPlayer:MediaPlayer = new MediaPlayer();
		public var mediaContainer:MediaContainer = new MediaContainer();
		
		//Exempel: Lägga till geomapObject i mappen med nyckeln befintlig variabel x2
		//dict.x2 = geomapObject;
		
		//Exempel: Lägga till geomapObject i mappen med nyckeln icke-befintlig sträng 1234
		//dict["1234"] = geomapObject2;
		
		
		public function GeoMapSprite(x1:int,y1:int,Mapradius:int, assetManager:AssetsManager, smp:StrobeMediaPlayback) 
		{
			super();
			this.x2 = x1;
			this.y2 = y1;
			this.Mapradius = Mapradius;
			this.assetManager = assetManager;
			this.smp = smp;
			
			drawPointOfInterest();
			//drawCardinalDirections("N",0,y2);
			
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
		
		private function drawCardinalDirections(string:String, xAdjust:int,yAdjust:int):void
		{
			var text:TextField = new TextField();
			text.backgroundColor = 0xffffff;
			text.text = string;
			text.wordWrap = true;
			text.multiline = true;
			text.scaleX = 0.8;
			
			text.y = y2+yAdjust;
			text.x = x2+xAdjust;
			
			addChild(text);
		}
		
		private function tempCallCreateObjects():void {
			createObjects(-100,0,70,"http://mediapm.edgesuite.net/strobe/content/test/AFaerysTale_sylviaApostol_640_500_short.flv");
			createObjects(80,-80,270,"http://mediapm.edgesuite.net/osmf/content/test/manifest-files/progressive.f4m");
			createObjects(0,120,30,"rtmp://cp67126.edgefcs.net/ondemand/mp4:mediapm/osmf/content/test/sample1_700kbps.f4v");
			dict[0].setDefault();
		}
		
		private function createObjects(x:int, y:int, angle:int, url:String):void
		{	
			geomapObject = new GeoMapObject(this,x2+x,y2+y,assetManager, smp, mediaContainer, mediaFactory, mediaPlayer);
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


