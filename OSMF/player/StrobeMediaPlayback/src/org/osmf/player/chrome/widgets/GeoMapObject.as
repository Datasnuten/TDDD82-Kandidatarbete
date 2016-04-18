/*****************************************************
 *  
 *  Jonathan Sjölund and Andreas Nordberg
 *  
 *****************************************************/

package org.osmf.player.chrome.widgets
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.sampler.NewObjectSample;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import org.osmf.advertisementplugin.src.org.osmf.advertisementplugin.AdvertisementPluginInfo;
	import org.osmf.containers.MediaContainer;
	import org.osmf.events.MediaFactoryEvent;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfoResource;
	import org.osmf.media.URLResource;
	import org.osmf.player.chrome.assets.AssetIDs;
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.player.containers.StrobeMediaContainer;


	public class GeoMapObject extends Widget
	{
		private var positionX:int;
		private var positionY:int;
		private var xCoordinate:int;
		private var yCoordinate:int;
		private var direction:Number = 0;
		
		protected var normalFace:String = AssetIDs.MAP_GPS_DIRECTION_DOTARROW_NORMAL;
		protected var selectedFace:String = AssetIDs.MAP_GPS_DIRECTION_DOTARROW_SELECTED;
		
		public var normal:DisplayObject;
		public var selected:DisplayObject;
		public var currentFace:DisplayObject;
		public var highlighted:Boolean;
		
		protected var mouseOver:Boolean;
		
		public var state:Boolean = false;
		public var holdingOver:Boolean = false;
		
		private var context:GeoMapSprite;
		private var url:String;
		
		
		public function GeoMapObject(context:GeoMapSprite,positionX:int,positionY:int,assetManager:AssetsManager)
		{
			super();
				
			this.positionY = positionY;
			this.positionX = positionX;
			this.context = context;
			
			normal = assetManager.getDisplayObject(normalFace);
			selected = assetManager.getDisplayObject(selectedFace);
			
			
			normal.x = this.positionX;
			normal.y = this.positionY;
			
			selected.x = this.positionX;
			selected.y = this.positionY;
			
			
			
			//addEventListener(MouseEvent.CLICK, onMouseClick);
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
			updateFace(normal);
		}
		
		public function updateFace(face:DisplayObject):void
		{
			if (currentFace != face)
			{
				if (currentFace != null)
				{
					removeChild(currentFace);
				}
				
				currentFace = face;
				
				if (currentFace != null)
				{
					addChildAt(currentFace, 1);
					
					measure();
					width = currentFace.width;
					height = currentFace.height;
				}
			}
		}
		
		public function onMouseClick(event:MouseEvent, dict:Object):void
		{
			if(holdingOver){
				state = !state;
			if(state){
				for each(var obj:* in dict) {
					if (obj.highlighted == true && obj != this) {
						obj.updateFace(obj.normal);
						obj.state = false;
						//temporär
						obj.stopURL();
					}
				}
			updateFace(selected);
			playURL();
			highlighted = true;

			}else{
				//temporär
				stopURL();
				updateFace(normal);
				highlighted = false;
			}
			
			}
		}
		
		public function onMouseMove(event:MouseEvent):void
		{
			if(mouseY < positionY+selected.height && mouseY > positionY && mouseX < positionX+selected.width && mouseX > positionX){
				Mouse.cursor = flash.ui.MouseCursor.ARROW;
				holdingOver = true;
			}else{
				holdingOver = false;
			}
			
		}
		
		
		public function setXcoordinate(xCoordinate:int):void
		{
			this.xCoordinate = xCoordinate;
		}
		
		public function get getXcoordinate():int
		{
			return xCoordinate;
		}
		public function setYcoordinate(yCoordinate:int):void
		{
			this.yCoordinate = yCoordinate;
		}
		
		public function get getYcoordinate():int
		{
			return yCoordinate;
		}
		
		public function setDirection(direction:int):void
		{
			this.direction = direction;
			var matrix:Matrix = normal.transform.matrix;
			var rect:Rectangle = normal.getBounds(normal.parent);
			
			matrix.translate(-(rect.left + (rect.width / 2)), -(rect.top + (rect.height / 2)));
			matrix.rotate((direction / 180) * Math.PI);
			matrix.translate(rect.left + (rect.width / 2), rect.top + (rect.height / 2));
			normal.transform.matrix = matrix;
			selected.transform.matrix = matrix;
			
			normal.rotation = Math.round(normal.rotation);
			selected.rotation = Math.round(selected.rotation);
		}
		
		public function get getDirection():Number
		{
			return direction;
		}
		
		public function setPositionX(positionX:int):void
		{
			this.positionX = positionX;
			normal.x = positionX;
			selected.x = positionX;
		}
		
		public function get getPositionX():int
		{
			return positionX;
		}
		
		public function setPositionY(positionY:int):void
		{
			this.positionY = positionY;
			normal.y = positionY;
			selected.y = positionY;
		}
		
		public function get getPositionY():int
		{
			return positionY;
		}
		
		public function get getCurrentFace():DisplayObject
		{
			return currentFace;
		}
		
		public function resetFace():void
		{
			updateFace(normal);
		}
		
		public function get getIfHoldingOver():Boolean
		{
			return holdingOver;
		}
		
		public function get getState():Boolean
		{
			return state;
		}
		
		public function setURL(url:String):void
		{
			this.url = url;
		}
		
		private function playURL():void
		{
			var resource:URLResource = new URLResource(url);
			var mediaElement:MediaElement = mediaFactory.createMediaElement(resource);
			mediaContainer.addMediaElement(mediaElement);
			var pluginResource:MediaResourceBase = new PluginInfoResource(new AdvertisementPluginInfo());
			
			StrobeMediaPlayback.mediaContainer = mediaContainer;
			
			pluginResource.addMetadataValue("MediaPlayer", mediaPlayer);
			pluginResource.addMetadataValue("MediaContainer", mediaContainer);
			
			//mediaPlayer.media = mediaElement;
			
			//mediaFactory.loadPlugin(pluginResource);
		}
		
		//temporär 
		public function stopURL():void
		{
			mediaPlayer.media = null;
		}
		
		public function setDefault():void
		{
			state = !state;
			highlighted = true;
			updateFace(selected);
			playURL();
		}
		
		private var advPlugin:AdvertisementPluginInfo = new AdvertisementPluginInfo();
		private var mediaFactory:MediaFactory = new DefaultMediaFactory();
		private var mediaPlayer:MediaPlayer = new MediaPlayer();
		private var mediaContainer:MediaContainer = new MediaContainer();
	}
}












