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
	import flash.text.TextField;
	import flash.text.TextFormat;
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
	import org.osmf.media.URLResource;
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
		public var smp:StrobeMediaPlayback;
		
		private var dict:Object = new Object();
		private var text:TextField;
		private var cDTextSize:int = 20;
		
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
			
			//If you draw something on the bottom the y-axis needs to be updated with half of that length otherwise the UI will be moved upwards
			this.y2 = y2 + (Mapradius-cDTextSize)/2;
			
			//Similiar thing will happen when moving the x-axis to the right-hand side but with 1/4 of that length
			this.x2 = x2 + (Mapradius-cDTextSize/2)/4;
			
			//These two Cardinal directions are the one that causes the UI to move
			drawCardinalDirections("S",0,Mapradius-cDTextSize);
			drawCardinalDirections("E",Mapradius-cDTextSize/2,0);
			
			drawPointOfInterest(30,-100);
			
			drawCardinalDirections("N",0,-Mapradius+cDTextSize/2);
			drawCardinalDirections("W",-Mapradius+cDTextSize/2,0);
			
			graphics.clear();
			graphics.lineStyle(1,0x000000);
			graphics.beginFill(0xffffff,1);
			graphics.drawCircle(x2,y2,Mapradius);
			graphics.endFill();
			
			//addEventListener(MouseEvent.CLICK, onMouseClick);
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
			tempCallCreateObjects();
			
			setCoordinates(0,45.32,12.45);
			setCoordinates(1,44.10,20.23);
			setCoordinates(2,56.07,64.91);
			setCoordinates(3,44.56,39.01);
		}
		
		
		private function drawPointOfInterest(xAdjust:int,yAdjust:int):void
		{
			var string:String = "Point Of Interest";
			var poiRadius:int = 40;
			var pointOfInterest:Sprite = new Sprite();
			text = new TextField();
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
			var textFormat:TextFormat = new TextFormat();
			textFormat.size = cDTextSize;
			textFormat.bold = true;
			
			var text:TextField = new TextField();
			text.defaultTextFormat = textFormat;
			text.text = string;
			text.wordWrap = true;
			text.multiline = true;
			
			
			text.y = y2+yAdjust-cDTextSize/2;
			text.x = x2+xAdjust-cDTextSize/2;
			
			addChild(text);
		}
		
		private function tempCallCreateObjects():void {
			createObjects(-100,0,70,"http://localhost/vod/final_0.85.f4v");
			createObjects(80,-80,270,"http://localhost/vod/test.flv");
			createObjects(0,120,30,"http://localhost/vod/final_0.25.f4v");
			createObjects(-10,0,40,"http://localhost/vod/final_0.5.f4v");
			/*createObjects(-100,0,70,"http://130.236.206.130/vod/example.f4v");
			createObjects(80,-80,270,"http://130.236.206.130/vod/sample2_1000kbps.f4v");
			createObjects(0,120,30,"http://130.236.206.130/vod/sample1_150kbps.f4v");
			createObjects(-10,0,40,"http://130.236.206.130/vod/test.flv");*/
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
		
		private function setCoordinates(value:int,xCoordinate:Number,yCoordinate:Number):void
		{
			dict[value].setXcoordinate(xCoordinate);
			dict[value].setYcoordinate(yCoordinate);
		}
		
		public function onMouseClick(event:MouseEvent):void
		{
			for each(var obj:* in dict) {
				obj.onMouseClick(event,dict);
			}
		}
		
		public function onMouseMove(event:MouseEvent):void
		{
			for each(var obj:* in dict) {
				obj.onMouseMove(event);
			}
		}
		
		private function calculatePositionAlgorithm():void
		{
			
		}
		
	}
}


