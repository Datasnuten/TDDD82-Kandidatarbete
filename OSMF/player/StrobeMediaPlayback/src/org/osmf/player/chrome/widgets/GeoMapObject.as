/*****************************************************
 *  
 *  Jonathan Sjölund and Andreas Nordberg
 *  
 *****************************************************/

package org.osmf.player.chrome.widgets
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import org.osmf.player.chrome.assets.AssetIDs;
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaPlayer;
	import org.osmf.containers.MediaContainer;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.URLResource;
	import org.osmf.media.MediaElement;
	import org.osmf.media.PluginInfoResource;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.events.MediaFactoryEvent;


	public class GeoMapObject extends Widget
	{
		private var positionX:int;
		private var positionY:int;
		private var xCoordinate:int;
		private var yCoordinate:int;
		private var direction:Number = 0;
		
		protected var normalFace:String = AssetIDs.MAP_GPS_DIRECTION_DOTARROW_NORMAL;
		protected var selectedFace:String = AssetIDs.MAP_GPS_DIRECTION_DOTARROW_SELECTED;
		
		protected var normal:DisplayObject;
		protected var selected:DisplayObject;
		protected var currentFace:DisplayObject;
		
		protected var mouseOver:Boolean;
		
		private var state:Boolean = false;
		private var holdingOver:Boolean = false;
		
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
			
			addEventListener(MouseEvent.CLICK, onMouseClick);
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
			updateFace(normal);
		}
		
		private function updateFace(face:DisplayObject):void
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
					addChildAt(currentFace, 0);
					
					measure();
					width = currentFace.width;
					height = currentFace.height;
				}
			}
		}
		
		public function onMouseClick(event:MouseEvent):void
		{
			if(holdingOver){
			state = !state;
			if(state){
			updateFace(selected);
			playURL();
			}else{
				updateFace(normal);
			}
			}
		}
		
		public function onMouseMove(event:MouseEvent):void
		{
			if(mouseY < positionY+selected.height && mouseY > positionY-selected.height && mouseX < positionX+selected.width && mouseX > positionX-selected.width){
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
			normal.rotation = direction;
			selected.rotation = direction;
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
		
		public function setPositioY(positionY:int):void
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
			// This is a normal video player setup.
			var mediaFactory:MediaFactory = new DefaultMediaFactory();
			var mediaPlayer:MediaPlayer = new MediaPlayer();
			var mediaContainer:MediaContainer = new MediaContainer();
			var resource:URLResource = new URLResource("rtmp://cp67126.edgefcs.net/ondemand/mp4:mediapm/osmf/content/test/sample1_700kbps.f4v");
			var mediaElement:MediaElement = mediaFactory.createMediaElement(resource);
			mediaContainer.addMediaElement(mediaElement);
			this.addChild(mediaContainer);
			
			// Load the plugin statically
			//var pluginResource:MediaResourceBase = new PluginInfoResource(new AdvertisementPluginInfo());
			
			// You can load it as a dynamic plugin as well
			 var pluginResource:MediaResourceBase = new URLResource("http://localhost/AdvertisementPlugin/bin/AdvertisementPlugin.swf");
			
			// Pass the references to the MediaPlayer and the MediaContainer instances to the plug-in.
			pluginResource.addMetadataValue("MediaPlayer", mediaPlayer);
			pluginResource.addMetadataValue("MediaContainer", mediaContainer);
			
			// Once the plugin is loaded, play the media.
			// The event handler is not needed if you use the statically linked plugin,
			// but is here in case you load the plugin dynamically.
			// For readability, we don’t provide error handling here, but you should.
			mediaFactory.addEventListener(
				MediaFactoryEvent.PLUGIN_LOAD,
				function(event:MediaFactoryEvent):void
				{
					// Now let's play the video - mediaPlayer has autoPlay set to true by default,
					// so the playback starts as soon as the media is ready to be played.
					mediaPlayer.media = mediaElement;
				});
			
			// Load the plugin.
			mediaFactory.loadPlugin(pluginResource);
		}
		
		public function setDefault():void
		{
			state = !state;
			updateFace(selected);
		}
	}
}













