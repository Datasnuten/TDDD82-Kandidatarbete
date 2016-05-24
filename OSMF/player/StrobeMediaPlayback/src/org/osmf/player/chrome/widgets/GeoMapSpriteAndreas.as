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
	import flash.sampler.NewObjectSample;
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
		
		private var xMin:Number = -125;
		private var xMax:Number = 110;
		private var yMin:Number = -130;
		private var yMax:Number = 110;
		
		private var relativeXposition:Number = 100;
		private var relativeYposition:Number = 100;
		private var frameDistance:Number = 40;
		private var center:Number = 50;
		private var dyMax:Number = 0;
		private var dxMax:Number = 0;
		private var maxPointNr1New:int = 0;
		private var maxPointNr2Old:int = 0;
		private var currentXmaxIndex:Number = 0;
		private var currentYmaxIndex:Number = 0;
		
		private var debug:Number;
		
		private var Mapradius:int;
		private var assetManager:AssetsManager;
		private var pointOfInterest:Sprite;
		public var object:int;
		public var smp:StrobeMediaPlayback;
		
		private var geomapDict:Object = new Object();
		private var pointOfInterestDict:Object = new Object();
		private var arrowDict:Object = new Object();
		private var arrowIncrementer:int = 0;
		private var incArrowDict:Object = new Object();
		private var incArrowIncrementer:int = 0;
		

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
			drawCardinalDirections("S",3,Mapradius-cDTextSize);
			drawCardinalDirections("E",Mapradius-cDTextSize/2,0);
			
			drawPointOfInterest(30,-100);
			
			drawCardinalDirections("N",3,-Mapradius+cDTextSize/2);
			drawCardinalDirections("W",-Mapradius+cDTextSize/2,0);
			
			graphics.clear();
			graphics.lineStyle(1,0x000000);
			graphics.beginFill(0xffffff,1);
			graphics.drawCircle(x2,y2,Mapradius);
			graphics.endFill();
			
			//addEventListener(MouseEvent.CLICK, onMouseClick);
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
			tempAddInfoToList();
			
			setCoordinates(0,arrowDict[0].getLat,arrowDict[0].getLong);
			setCoordinates(1,arrowDict[1].getLat,arrowDict[1].getLong);
			//setCoordinates(2,56.07,64.91);
			//setCoordinates(3,44.56,39.01);
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
		
		// 	relativa intervall för x/y-koordinater som vi kan arbeta med våra givna efterblivna begränsningar
		//	Används för att senare skala koordinater relativt varandra inom denna ramen
		//  -125<=X<=110	(mindre värden flyttar objektet till vänster, större till höger)
		//	-130<=Y<=110	(mindre värden höjer objektet, större värden sänker objektet)
		
		private function tempAddInfoToList():void {

			dynamicAddObjects(58.407508, 15.605103,0,"http://mediapm.edgesuite.net/strobe/content/test/AFaerysTale_sylviaApostol_640_500_short.flv");
			dynamicAddObjects(58.406991, 15.606229,90,"http://mediapm.edgesuite.net/osmf/content/test/manifest-files/dynamic_Streaming.f4m");
			dynamicAddObjects(58.406912, 15.605457,180,"http://mediapm.edgesuite.net/strobe/content/test/AFaerysTale_sylviaApostol_640_500_short.flv");
			dynamicAddObjects(58.407109, 15.607441,320,"http://mediapm.edgesuite.net/osmf/content/test/manifest-files/dynamic_Streaming.f4m");
			
			calculateRelativePositions();
			
			for each(var obj:* in incArrowDict) {
				createObjects(convertXpercentageCoords(obj.getProcX),convertYpercentageCoords(obj.getProcY),obj.getAngle,obj.getUrl);
			}
			
			//createObjects(0,0,270,"http://130.236.206.130/vod/sample2_1000kbps.f4v");
			//createObjects(0,120,30,"http://130.236.206.130/vod/sample1_150kbps.f4v");
			//createObjects(-10,0,40,"http://130.236.206.130/vod/test.flv");

			//createObjects(-100,0,70,"http://localhost/vod/final_0.85.f4v");
			//createObjects(80,-80,270,"http://localhost/vod/test.flv");
			//createObjects(0,120,30,"http://localhost/vod/final_0.25.f4v");
			//createObjects(-10,0,40,"http://localhost/vod/final_0.5.f4v");
			//createObjects(-100,0,70,"http://130.236.206.130/vod/example.f4v");
			//createObjects(80,-80,270,"http://130.236.206.130/vod/sample2_1000kbps.f4v");
			//createObjects(0,120,30,"http://130.236.206.130/vod/sample1_150kbps.f4v");
			//createObjects(-10,0,40,"http://130.236.206.130/vod/test.flv");

			geomapDict[0].setDefault();
		}
		
		private function dynamicAddObjects(lat:Number, long:Number, angle:int, url:String):void {
			arrowDict[arrowIncrementer] = new ObjectInfo(lat,long,angle,url);
			arrowIncrementer++;
			//public var fooe:ObjectInfo = new ObjectInfo(lat,long,angle,url);
		}
		
		private function calculateRelativePositions():void {
			
			var i:int = 0;
			for(i=0; i<arrowIncrementer; i++) {
				incArrowDict[i] = arrowDict[i];
				incArrowIncrementer++;
				if (i==0) {
					incArrowDict[i].setProcX = center;
					incArrowDict[i].setProcY = center;
					relativeXposition = relativeXposition/2;
					relativeYposition = relativeYposition/2;
				} else {
					
					//should rescale previous points if the new point is outside of the boundries of the previous points
					//rescale accordingly to the newly added point
					var shouldRescale:Boolean = false;
					for each(var obj:* in incArrowDict) {
						if(incArrowDict[i] != obj) {
							if (dxMax < (incArrowDict[i].getLong-obj.getLong)*40000*Math.cos((obj.getLat+incArrowDict[i].getLat)*Math.PI/360)/360) {
								text.text = "dmax";
								//new dx max
								dxMax = (incArrowDict[i].getLong-obj.getLong)*40000*Math.cos((obj.getLat+incArrowDict[i].getLat)*Math.PI/360)/360;
								maxPointNr1New = i;
								maxPointNr2Old = obj; //?? vill ha nyckeln
								shouldRescale = true;
							} 
							if (dyMax < (obj.getLat-incArrowDict[i].getLat)*40000/360) {
								text.text = "ymax";
								//new dy max
								dyMax = (obj.getLat-incArrowDict[i].getLat)*40000/360;
								maxPointNr1New = i;
								maxPointNr2Old = obj;
								shouldRescale = true;
							} 
						}
					}
					
					if (shouldRescale) {
						
						var dxBetweenMax:Number = (arrowDict[maxPointNr1New].getLong-arrowDict[maxPointNr2Old].getLong)*40000*Math.cos((arrowDict[maxPointNr2Old].getLat+arrowDict[maxPointNr1New].getLat)*Math.PI/360)/360;
						var dyBetweenMax:Number = (arrowDict[maxPointNr2Old].getLat-arrowDict[maxPointNr1New].getLat)*40000/360;
						
						if (dxMax > dyMax) {
							//rescale according to the new dxMax
							
							//skalan blir negativ här???? om inte abs
							var yScale:Number = Math.abs(dyBetweenMax/dxBetweenMax);
							
							if (arrowDict[maxPointNr1New].getLong >= arrowDict[maxPointNr2Old].getLong) {
								// i-1 till vänster om i
								arrowDict[maxPointNr1New].setProcX = center + frameDistance;
								arrowDict[maxPointNr2Old].setProcX = center - frameDistance;
							} else {
								// i-1 till höger om i
								arrowDict[maxPointNr1New].setProcX = center - frameDistance;
								arrowDict[maxPointNr2Old].setProcX = center + frameDistance;
							}
							if (arrowDict[maxPointNr1New].getLat <= arrowDict[maxPointNr2Old].getLat) {
								// i-1 över i
								trace("gammal över ny");
								arrowDict[maxPointNr1New].setProcY = arrowDict[maxPointNr2Old].getProcY - (Math.abs(arrowDict[maxPointNr1New].getProcX-arrowDict[maxPointNr2Old].getProcX) * yScale);
								text.text = arrowDict[maxPointNr1New].getProcY + "";
							} else {
								// i-1 under i
								trace("ny över gammal");
								arrowDict[maxPointNr1New].setProcY = arrowDict[maxPointNr2Old].getProcY + (Math.abs(arrowDict[maxPointNr1New].getProcX-arrowDict[maxPointNr2Old].getProcX) * yScale);
								//text.text = arrowDict[maxPointNr2Old].getProcY+ " " + (Math.abs(arrowDict[maxPointNr1New].getProcX-arrowDict[maxPointNr2Old].getProcX) * yScale) + "";
							}
						} else {
							//rescale according to the new dyMax
							text.text = "huehue";
							var xScale:Number = Math.abs(dxBetweenMax/dyBetweenMax);
							if (arrowDict[maxPointNr1New].getLat <= arrowDict[maxPointNr2Old].getLat) {
								// i-1 över i
								arrowDict[maxPointNr1New].setProcY = center - frameDistance;
								arrowDict[maxPointNr2Old].setProcY = center + frameDistance;
							} else {
								// i-1 under i
								arrowDict[maxPointNr1New].setProcY = center + frameDistance;
								arrowDict[maxPointNr2Old].setProcY = center - frameDistance;
							}
							if (arrowDict[maxPointNr1New].getLong >= arrowDict[maxPointNr2Old].getLong) {
								// i-1 till vänster om i
								
								// lägg till den nya punkten relativt den gamla andra max.. osäker(?)
								text.text = dxBetweenMax + " " + xScale + " " + dxBetweenMax*xScale;
								arrowDict[maxPointNr1New].setProcX = arrowDict[maxPointNr2Old].getProcX + (Math.abs(arrowDict[maxPointNr1New].getProcY-arrowDict[maxPointNr2Old].getProcY) * xScale);					
								
							} else {
								// i-1 till höger om i
								arrowDict[maxPointNr1New].setProcX = arrowDict[maxPointNr2Old].getProcX - (Math.abs(arrowDict[maxPointNr1New].getProcY-arrowDict[maxPointNr2Old].getProcY) * xScale);;	
							}
							
						}
						
						if (arrowDict[maxPointNr1New].getProcX > arrowDict[maxPointNr2Old].getProcX) {
							currentXmaxIndex = maxPointNr1New;
						} else {
							currentXmaxIndex = maxPointNr2Old;
						}
						
						if (arrowDict[maxPointNr1New].getProcY > arrowDict[maxPointNr2Old].getProcY) {
							currentYmaxIndex = maxPointNr1New;
						} else {
							currentYmaxIndex = maxPointNr2Old;
						}
						
						// the new point has been placed and rescaled along with the other point making up the frame
						// shrink/scale the other previous points that isn't part of the scale-frame
						for each(var obj1:* in incArrowDict) {
							if (obj1 != incArrowDict[maxPointNr1New] && obj1 != incArrowDict[maxPointNr2Old]) {
								trace("huehuehuehue");
								//scale x
								var scaleX:Number = obj1.getLong/incArrowDict[currentXmaxIndex].getLong;
								obj1.setProcX = scaleX * incArrowDict[currentXmaxIndex].getProcX;
								//scale y
								var scaleY:Number = obj1.getLat/incArrowDict[currentYmaxIndex].getLat;
								obj1.setProcY = scaleY * incArrowDict[currentYmaxIndex].getProcY;
							}
						}
						
					} else {
						// scale the new point according to the existing scale
						
						//scale x
						var scaleX1:Number = incArrowDict[i].getLong/incArrowDict[currentXmaxIndex].getLong;
						incArrowDict[i].setProcX = scaleX1 * incArrowDict[currentXmaxIndex].getProcX;
						//scale y
						var scaleY1:Number = incArrowDict[i].getLat/incArrowDict[currentYmaxIndex].getLat;
						incArrowDict[i].setProcY = scaleY1 * incArrowDict[currentYmaxIndex].getProcY;
					}
				}
			}
			
			//dx = (lon2-lon1)*40000*math.cos((lat1+lat2)*math.pi/360)/360
			//dy = (lat1-lat2)*40000/360
		}
		
		private function createObjects(x:int, y:int, angle:int, url:String):void
		{	
			geomapObject = new GeoMapObject(this,x2+x,y2+y,assetManager, smp, mediaContainer, mediaFactory, mediaPlayer);
			geomapObject.setDirection(angle);
			geomapObject.setURL(url);

			addChild(geomapObject);
			
			geomapDict[incrementer] = geomapObject;
			incrementer = incrementer+1;
		}
		
		private function setCoordinates(value:int,xCoordinate:Number,yCoordinate:Number):void
		{
			if (geomapDict[value]) {
				geomapDict[value].setXcoordinate(xCoordinate);
				geomapDict[value].setYcoordinate(yCoordinate);
			}
		}
		
		public function rescaleArrows(sizeDown:Boolean):void {
			if(sizeDown) {
				for each(var obj:* in geomapDict) {
					obj.normal.scaleX = 0.75;
					obj.normal.scaleY = 0.75;
					obj.selected.scaleX = 0.75;
					obj.selected.scaleY = 0.75;

				}
			} else {
				for each(var obj2:* in geomapDict) {
					obj2.normal.scaleX = 1;
					obj2.normal.scaleY = 1;
					obj2.selected.scaleX = 1;
					obj2.selected.scaleY = 1;
				}
			}
		}
		
		private function convertXpercentageCoords(x:Number):Number {
			var temp:Number = (x/100) * (Math.abs(xMin)+xMax);
			var temp2:Number = temp - Math.abs(xMin);
			return temp2;
		}
		
		private function convertYpercentageCoords(y:Number):Number {
			var temp:Number = (y/100) * (Math.abs(yMin)+yMax);
			var temp2:Number = Math.abs(yMax) - temp;
			debug = temp;
			return temp2;
		}
		
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
			for each(var obj:* in geomapDict) {
				obj.onMouseMove(event);
			}
			if (stage) {
				//text.text = event.localX.toString() + "\n" + event.localY.toString() + "\n" + mouseX.toString() + "\n" + mouseY.toString();
			}
			//text.text = arrowDict[0].getProcX.toString() + "\n" + arrowDict[0].getProcY.toString() + "\n" + arrowDict[1].getProcX.toString() + "\n" + arrowDict[1].getProcY.toString();
			//text.text = arrowDict[0].getProcX + " " + arrowDict[0].getProcY + "\n" + arrowDict[1].getProcX + " " + arrowDict[1].getProcY;
		}
		
	}
}


