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
	import flash.text.TextFormat;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	public class PointOfInterest extends Sprite
	{
		private var xCoordinate:Number;
		private var yCoordinate:Number;
		
		private var _radius:Number;
		private var yPosition:int;
		private var xPosition:int;
		
		private var holdingOverText:TextField;
		private var text:TextField;
		private var textBox:Sprite;
		
		public function PointOfInterest(xCoordinate:Number,yCoordinate:Number,xPosition:int,yPosition:int,radius:int)
		{
			this.xCoordinate = xCoordinate;
			this.yCoordinate = yCoordinate;
			this.xPosition = xPosition;
			this.yPosition = yPosition;
			this._radius = radius;
			
			var textFormat:TextFormat = new TextFormat();
			textFormat.bold = true;
			
			text = new TextField();
			text.defaultTextFormat = textFormat;
			text.wordWrap = true;
			text.multiline = true;
			text.scaleX = 0.8;
			
			text.text = "Point Of Interest";
			
			holdingOverText = new TextField();
			textBox = new Sprite();
			
			drawPointOfInterest(xPosition,yPosition,_radius);
		}
		
		/**
		 * Draw PointOfIntreset as a circle.
		 */
		private function drawPointOfInterest(x:int,y:int,radius:Number):void
		{
			this._radius = radius;
			graphics.clear();
			graphics.beginFill(0x0040ff,1);
			graphics.drawCircle(x,y,radius);
			graphics.endFill();
			
			text.y = y-4*radius/7;
			text.x = x-5*radius/7;
			addChild(text);
		}
		
		public function onMouseMove(event:MouseEvent):void
		{
			if(mouseY < this.getPositionY+_radius && mouseY > this.getPositionY-_radius && mouseX < this.getPositionX+_radius && mouseX > this.getPositionX-_radius){
				holdingOverText.text = "x-Coordinate: " + getXcoordinate.toFixed(6) + "\n" + "y-Coordinate: " + getYcoordinate.toFixed(6);
				holdingOverText.wordWrap = true;
				holdingOverText.scaleX = 1.4;
				
				holdingOverText.x = this.getPositionX+_radius+5;
				holdingOverText.y = this.getPositionY-_radius;
				
				textBox.graphics.lineStyle(1,0x000000);
				textBox.graphics.beginFill(0xffffff,1);
				textBox.graphics.drawRect(this.getPositionX+_radius+5,this.getPositionY-_radius,holdingOverText.width,holdingOverText.height/2);
				textBox.graphics.endFill();
				
				textBox.addChild(holdingOverText);
				
				this.addChild(textBox);
				this.parent.addChild(this);
				
			}else{
				textBox.graphics.clear();
				if (holdingOverText) {
					holdingOverText.text = " ";
				}
			}	
		}
		
		/**
		 * Returns the displayed text for PointOfInterest.
		 */
		public function get getText():String{
			return text.text;
		}
		/**
		 * Sets the text to be displayed for PointOfInterest.
		 */
		public function set TextToSee(string:String):void
		{
			text.text = string;	
		}
		
		/**
		 * Gets the x-coordinate of PointOfInterest relative to real life.
		 * 
		 * NOTE!
		 * This is not the position of the PointOfInterest, it's only an coordinate.
		 */
		public function get getXcoordinate():Number
		{
			return xCoordinate;
		}
		
		/**
		 * Gets the y-coordinate of PointOfInterest relative to real life.
		 * 
		 * NOTE!
		 * This is not the position of PointOfInterest, it's only an coordinate.
		 */
		public function get getYcoordinate():Number
		{
			return yCoordinate;
		}
		
		/**
		 * Sets the x-position of the PointOfInterest.
		 */
		public function set setPositionX(xPosition:int):void
		{
			this.xPosition = xPosition;
			drawPointOfInterest(getPositionX,getPositionY,_radius);
		}
		
		/**
		 * Returns an Integer of the position in x-axis of the PointOfInterest. 
		 */
		public function get getPositionX():int
		{
			return xPosition;
		}
		
		/**
		 * Sets the y-position of the PointOfInterest.
		 */
		public function set setPositionY(yPosition:int):void
		{
			this.yPosition = yPosition;
			drawPointOfInterest(getPositionX,getPositionY,_radius);
		}
		
		/**
		 * Returns an Integer of the position in y-axis of the PointOfInterest. 
		 */
		public function get getPositionY():int
		{
			return this.yPosition;
		}
		
		/**
		 * Gets the radius of PointOfInterest.
		 */
		public function get radius():Number
		{
			return this._radius; 
		}
	}
}