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
	
	public class PointOfInterest extends Sprite
	{
		private var xCoordinate:Number;
		private var yCoordinate:Number;
		
		private var radius:Number=38;
		private var yPosition:int;
		private var xPosition:int;
		
		private var holdingOverText:TextField;
		private var text:TextField;
		private var textBox:Sprite;
		
		public function PointOfInterest(xCoordinate:Number,yCoordinate:Number,xPosition:int,yPosition:int)
		{
			this.xCoordinate = xCoordinate;
			this.yCoordinate = yCoordinate;
			this.xPosition = xPosition;
			this.yPosition = yPosition;
			
			text = new TextField();
			text.wordWrap = true;
			text.multiline = true;
			text.scaleX = 0.8;
			
			text.text = "Point Of Interest";
			
			holdingOverText = new TextField();
			textBox = new Sprite();
			
			drawPointOfInterest(xPosition,yPosition,radius);
		}
		
		/**
		 * Draw PointOfIntreset as a circle
		 */
		public function drawPointOfInterest(x:int,y:int,radius:Number):void
		{
			graphics.clear();
			graphics.beginFill(0x0040ff,1);
			graphics.drawCircle(x,y,radius);
			graphics.endFill();
			
			text.y = y-radius/2;
			text.x = x-4*radius/7;
			addChild(text);
		}
		
		public function onMouseMove(event:MouseEvent):void
		{
			if(mouseY < this.getPositionY+radius && mouseY > this.getPositionY-radius && mouseX < this.getPositionX+radius && mouseX > this.getPositionX-radius){
				holdingOverText.text = "x-Coordinate: " + getXcoordinate + "\n" + "y-Coordinate: " + getYcoordinate;
				holdingOverText.wordWrap = true;
				holdingOverText.scaleX = 1.4;
				
				holdingOverText.x = this.getPositionX+radius+5;
				holdingOverText.y = this.getPositionY-radius;
				
				textBox.graphics.lineStyle(1,0x000000);
				textBox.graphics.beginFill(0xffffff,1);
				textBox.graphics.drawRect(this.getPositionX+radius+5,this.getPositionY-radius,holdingOverText.width,holdingOverText.height/2);
				textBox.graphics.endFill();
				
				textBox.addChild(holdingOverText);
				
				this.addChild(textBox);
				
			}else{
				textBox.graphics.clear();
				if (holdingOverText) {
					holdingOverText.text = " ";
				}
			}	
		}
		
		
		/**
		 * Sets the text to be displayed for PointOfInterest
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
		}
		
		/**
		 * Returns an Integer of the position in y-axis of the PointOfInterest. 
		 */
		public function get getPositionY():int
		{
			return this.yPosition;
		}
	}
}