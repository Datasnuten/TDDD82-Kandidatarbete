package org.osmf.player.chrome.widgets
{
	public class ObjectInfo
	{
		private var lat:Number;
		private var long:Number;
		private var procentX:int;
		private var procentY:int;
		private var angle:int;
		private var url:String;
		
		public function ObjectInfo(lat:Number, long:Number, angle:int, url:String)
		{
			this.lat = lat;
			this.long = long;
			this.angle = angle;
			this.url = url;
		}
		
		public function get getLat():Number
		{
			return this.lat;
		}
		public function get getLong():Number
		{
			return this.long;
		}
		public function get getProcX():Number
		{
			return this.procentX;
		}
		public function get getProcY():Number
		{
			return this.procentY;
		}
		public function set setProcX(x:Number):void
		{
			this.procentX=x;
		}
		public function set setProcY(y:Number):void
		{
			this.procentY=y;
		}
		public function set setLat(lat:Number):void
		{
			this.lat=lat;
		}
		public function set setLong(long:Number):void
		{
			this.lat=long;
		}
		public function get getAngle():Number
		{
			return angle;
		}
		public function get getUrl():String
		{
			return url;
		}
	}
}