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
		private var numberOfPoi:int = 0;
		private var x2:int;
		private var y2:int;
		private var Mapradius:int;
		private var assetManager:AssetsManager;
		private var pointOfInterest:PointOfInterest;
		
		public var object:int;
		public var smp:StrobeMediaPlayback;
		
		private var geomapDict:Object = new Object();
		private var objectDict:Object = new Object();
		private var pointOfInterestDict:Object = new Object();
		
		private var cDTextSize:int = 20;
		
		private var poiRadius:int=32;
		private var moveDistance:int;
		
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
			
			this.moveDistance = Mapradius;
			
			//If you draw something on the bottom the y-axis needs to be updated with half of that length otherwise the UI will be moved upwards
			this.y2 = y2 + (Mapradius-cDTextSize)/2;
			
			//Similiar thing will happen when moving the x-axis to the right-hand side but with 1/4 of that length
			this.x2 = x2 + (Mapradius-cDTextSize/2)/4;
			
			//These two Cardinal directions are the one that causes the UI to move
			drawCardinalDirections("S",3,Mapradius-cDTextSize);
			drawCardinalDirections("E",Mapradius-cDTextSize/2,0);
			
			drawCardinalDirections("N",3,-Mapradius+cDTextSize/2);
			drawCardinalDirections("W",-Mapradius+cDTextSize/2,0);
			
			graphics.clear();
			graphics.lineStyle(1,0x000000);
			graphics.beginFill(0xffffff,1);
			graphics.drawCircle(x2,y2,Mapradius);
			graphics.endFill();
			
			createObjects();		
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
		
		// 	relativa intervall för x/y-koordinater som vi kan arbeta med våra givna efterblivna begränsningar
		//	Används för att senare skala koordinater relativt varandra inom denna ramen
		//  -125<=X<=110	(mindre värden flyttar objektet till vänster, större till höger)
		//	-130<=Y<=110	(mindre värden höjer objektet, större värden sänker objektet)
		
		protected function createObjects():void {
			createGeoMapObjects(58.400992, 15.577557,180,"http://130.236.207.47/vod/A1.flv");
			createGeoMapObjects(58.401020, 15.577354,135,"http://130.236.207.47/vod/A2.flv");
			createGeoMapObjects(58.400676, 15.577424,45,"http://130.236.207.47/vod/A3.flv");
			createGeoMapObjects(58.400727, 15.577550,0,"http://130.236.207.47/vod/J1.flv");
			createGeoMapObjects(58.400863, 15.577821,270,"http://130.236.207.47/vod/J2.flv");
			createGeoMapObjects(58.400605, 15.577439,35,"http://130.236.207.47/vod/J3.flv");
			
			createPointOfInterest(58.400843, 15.577512);
			
			/*createGeoMapObjects(58.573290, 15.793486,0,"http://localhost/vod/Video_1.flv");
			createGeoMapObjects(58.571718, 15.792166,0,"http://localhost/vod/Video_2.flv");
			createGeoMapObjects(58.572434, 15.795149,0,"http://localhost/vod/Video_3.flv");
			createGeoMapObjects(58.572490, 15.792156,0,"http://localhost/vod/Video_4.flv");
			createGeoMapObjects(58.571791, 15.795053,0,"http://localhost/vod/Video_5.flv");
			
			createGeoMapObjects(58.572921, 15.793497,0,"http://localhost/vod/Video_1.flv");
			createGeoMapObjects(58.572283, 15.792800,0,"http://localhost/vod/Video_2.flv");
			createGeoMapObjects(58.572311, 15.794323,0,"http://localhost/vod/Video_3.flv");
			
			createPointOfInterest(58.572177, 15.793485);*/
			
			calculatePositionAlgorithm();
			
			if(geomapDict[0]){
				geomapDict[0].setDefault();
			}
		}
		
		protected function createGeoMapObjects(latitude:Number,longitude:Number,angle:int, url:String):void
		{	
			geomapObject = new GeoMapObject(this,x2,y2,assetManager, smp, mediaContainer, mediaFactory, mediaPlayer);
			geomapObject.setDirection(angle);
			geomapObject.setURL(url);
			
			geomapObject.setYcoordinate(latitude);
			geomapObject.setXcoordinate(longitude);
			
			geomapObject.mouseEnabled = true;
			addChild(geomapObject);
			
			geomapDict[incrementer] = geomapObject;
			objectDict[incrementer] = geomapObject;
			incrementer = incrementer+1;
		}
		
		//Can only create one point of interest
		private function createPointOfInterest(latitude:Number,longitude:Number):void
		{
			pointOfInterest = new PointOfInterest(longitude,latitude,x2,y2,poiRadius);
			addChild(pointOfInterest);
			
			objectDict[incrementer] = pointOfInterest;
			pointOfInterestDict[numberOfPoi] = pointOfInterest;
			incrementer = incrementer+1;
			numberOfPoi++;
		}
		
		/**
		 * Checks if fullscreen or not and rescale the GeoMapObjects accordingly.
		 */
		public function rescaleObjects(sizeDown:Boolean):void {
			var geoPos:int=0;
			var poiPos:int=0;
			if(sizeDown) {
				for each(var obj:* in geomapDict) {
					obj.normal.scaleX = 0.75;
					obj.normal.scaleY = 0.75;
					obj.selected.scaleX = 0.75;
					obj.selected.scaleY = 0.75;

				}
				
				for each(var obj2:* in pointOfInterestDict){
					pointOfInterestDict[poiPos].scaleSize = 0.75;
					poiPos++;
				}
			} else {
				for each(var obj3:* in geomapDict) {
					obj3.normal.scaleX = 1;
					obj3.normal.scaleY = 1;
					obj3.selected.scaleX = 1;
					obj3.selected.scaleY = 1;
				}
				
				for each(var obj4:* in pointOfInterestDict){
					pointOfInterestDict[poiPos].scaleSize = 1;
					poiPos++;
				}
			}
		}
		
		public function onMouseClick(event:MouseEvent):void
		{
			for each(var obj:* in geomapDict) {
				obj.onMouseClick(event,geomapDict);
			}
		}
		
		public function onMouseMove(event:MouseEvent):void
		{
			for each(var obj:* in objectDict) {
				obj.onMouseMove(event);
			}
			if (stage) {
				//pointOfInterest.TextToSee =/* "Event.localX: "+event.localX.toString() + "\n Event.localY: " + event.localY.toString() + */"MouseX: " + mouseX.toString() + "\n MouseY: " + mouseY.toString();
			}
		}
		
		//Calculates the position of each geomapObject
		protected function calculatePositionAlgorithm():void
		{
			var i:int = 0;
			var j:int = 0;
			var adjuster:int = 0;
			var moveDistance:int = this.moveDistance;
			
			//Scales the distance in which the objects are moving.
			if(incrementer>1){
				moveDistance = this.moveDistance/(incrementer);
			}
			
			var valueX:int = moveDistance;
			var valueY:int = moveDistance;
			
			var x:Number=0;
			var y:Number=0;
			var z:Number=0;
			
			//Checks if there is more than one object
			if(incrementer>1){
				for each(var obj:* in objectDict){
					j = 0;
					for each(var obj2:* in objectDict){
						if(i != j){
							
							//Checks if there is more than 10 objects and then changes the way x and are measured 
							//to make relativity better for more objects.
							if(incrementer < 11){
								x = (objectDict[j].getXcoordinate-objectDict[i].getXcoordinate)*40000*Math.cos((objectDict[i].getYcoordinate+objectDict[j].getYcoordinate)*Math.PI/360)/360;   
								y = (objectDict[i].getYcoordinate-objectDict[j].getYcoordinate)*40000/360;
							}else{
								x = objectDict[i].getXcoordinate-objectDict[j].getXcoordinate;
								y = objectDict[i].getYcoordinate-objectDict[j].getYcoordinate;
							}
							z = Math.sqrt(Math.pow(x,2)+Math.pow(y,2));
							
							/*trace("x: "+x+", y: "+y+", z: "+z);
							trace(Math.pow(x,2)/Math.pow(z,2));
							trace(Math.pow(y,2)/Math.pow(z,2));*/
							valueX = moveDistance*(Math.abs(x/z));
							valueY = moveDistance*(Math.abs(y/z));
							
							if(valueX==0){
								valueX = moveDistance;
							}
							
							if(valueY==0){
								valueY = moveDistance;
							}
							
							if (objectDict[i].getXcoordinate > objectDict[j].getXcoordinate){
								objectDict[i].setPositionX = objectDict[i].getPositionX + valueX;
							}else{
								objectDict[i].setPositionX = objectDict[i].getPositionX - valueX;
							}
							
							if (objectDict[i].getYcoordinate > objectDict[j].getYcoordinate){
								objectDict[i].setPositionY = objectDict[i].getPositionY - valueY;
							}else{
								objectDict[i].setPositionY = objectDict[i].getPositionY + valueY;
							}
						}
						j++;
					}
					i++;
				}
				checkIfOutsideMap();
			}
		}
		
		//Checks if the objects are outside the map and adjust them if it so happens
		protected function checkIfOutsideMap():void
		{
			var i:int=0;
			for each(var obj:* in objectDict){
				var x:Number = objectDict[i].getPositionX-x2;
				var y:Number = objectDict[i].getPositionY-y2;
				var z:Number = Math.sqrt(Math.pow(x,2)+Math.pow(y,2));
				
				if(z > Mapradius-36){
					var extra:Number=36;
					if(z >Mapradius){
						extra = 52;
					}
					var value:Number = z-Mapradius+extra; 
					if(x<0){
						objectDict[i].setPositionX = objectDict[i].getPositionX+((Math.pow(x,2)/Math.pow(z,2)))*value+((Math.pow(x,2)/Math.pow(z,2))*extra/2);         
					}else{
						objectDict[i].setPositionX = objectDict[i].getPositionX-((Math.pow(x,2)/Math.pow(z,2)))*value-((Math.pow(x,2)/Math.pow(z,2))*extra/2);
					}
					
					if(y<0){
						objectDict[i].setPositionY = objectDict[i].getPositionY+((Math.pow(y,2)/Math.pow(z,2))*value)+((Math.pow(y,2)/Math.pow(z,2))*extra/2);
					}else{
						objectDict[i].setPositionY = objectDict[i].getPositionY-((Math.pow(y,2)/Math.pow(z,2))*value)-((Math.pow(y,2)/Math.pow(z,2))*extra/2);
					}
				}
				i++;
			}
		}
	}
}


