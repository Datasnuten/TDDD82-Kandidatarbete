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
	
	import org.osmf.layout.LayoutMode;
	import org.osmf.logging.Log;
	import org.osmf.player.chrome.assets.AssetsManager;
	

	public class GeoMapSprite extends Sprite
	{
		private var geomapObject:GeoMapObject,geomapObject2:GeoMapObject,geomapObject3:GeoMapObject;
		private var x2:int;
		private var y2:int;
		private var Mapradius:int;
		private var assetManager:AssetsManager;
		private var pointOfInterest:Sprite;
		public var object:int;
		
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
			
			addEventListener(MouseEvent.CLICK, onMouseClick);
			/*addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);*/
			
			createObjects();
		}
		
		
		private function drawPointOfInterest():void
		{
			var xAdjust:int = 30;
			var yAdjust:int = -100;
			var string:String = "Point Of Interest";
			var poiRadius:int = 40;
			var pointOfInterest:Sprite = new Sprite();
			var text:TextField = new TextField();
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
		
		private function createObjects():void
		{	
			var array:Array = new Array();
			geomapObject = new GeoMapObject(this,x2-100,y2,assetManager);
			geomapObject.setDirection(180);
			geomapObject2 = new GeoMapObject(this,x2+80,-80+y2,assetManager);
			geomapObject2.setDirection(270);
			geomapObject3 = new GeoMapObject(this,x2,120+y2, assetManager);
			geomapObject3.setDirection(0);
			
			array.push(geomapObject);
			array.push(geomapObject2);
			array.push(geomapObject3);
			
			for each( var widget:Widget in array)
			{
				if (widget)
				{
					widget.configure(<default/>, assetManager);					
				}
			}
			
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
		
		public function onMouseMove(event:MouseEvent):void
		{
			geomapObject.onMouseMove(event);
			geomapObject2.onMouseMove(event);
			geomapObject3.onMouseMove(event);
		}
		
		/*public function onMouseOver(event:MouseEvent):void
		{
			geomapObject.onMouseOver(event);
			geomapObject2.onMouseOver(event);
			geomapObject3.onMouseOver(event);
		}
		*/
	}
}


