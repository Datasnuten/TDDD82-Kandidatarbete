/*****************************************************
 *  
 *  Jonathan Sjölund and Andreas Nordberg
 *  
 *****************************************************/

package org.osmf.player.chrome.widgets
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.NetConnection;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import org.osmf.advertisementplugin.src.AdvertisementPlugin;
	import org.osmf.advertisementplugin.src.org.osmf.advertisementplugin.AdvertisementPluginInfo;
	import org.osmf.containers.MediaContainer;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfoResource;
	import org.osmf.media.URLResource;
	import org.osmf.net.NetClient;
	import org.osmf.net.httpstreaming.HTTPDownloadManager;
	import org.osmf.net.httpstreaming.HTTPNetStream;
	import org.osmf.net.httpstreaming.HTTPStreamingFactory;
	import org.osmf.net.httpstreaming.f4f.HTTPStreamingF4FFactory;
	import org.osmf.player.chrome.assets.AssetIDs;
	import org.osmf.player.chrome.assets.AssetsManager;


	public class GeoMapObject extends Widget
	{
		private var positionX:int;
		private var positionY:int;
		private var xCoordinate:Number;
		private var yCoordinate:Number;
		private var direction:Number = 0;
		private var text:TextField;
		
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
		
		public var smp:StrobeMediaPlayback
		public var mediaContainer:MediaContainer;
		public var mediaFactory:MediaFactory;
		public var mediaPlayer:MediaPlayer;
		
		
		/**
		 * Creates a DisplayObject in form of an arrow pointing in a specific direction.
		 * 
		 * Give this object an URL in-order to display it in the MediaContainer.
		 */
		public function GeoMapObject(context:GeoMapSprite,positionX:int,positionY:int,assetManager:AssetsManager,smp:StrobeMediaPlayback,mediaContainer:MediaContainer,mediaFactory:MediaFactory,mediaPlayer:MediaPlayer)
		{
			super();
				
			this.positionY = positionY;
			this.positionX = positionX;
			this.context = context;
			
			normal = assetManager.getDisplayObject(normalFace);
			selected = assetManager.getDisplayObject(selectedFace);
			
			text = new TextField();
			
			normal.x = this.positionX;
			normal.y = this.positionY;
			
			selected.x = this.positionX;
			selected.y = this.positionY;
			
			this.smp = smp;
			this.mediaContainer = mediaContainer;
			this.mediaFactory = mediaFactory;
			this.mediaPlayer = mediaPlayer;
			
			
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
					}
				}
			updateFace(selected);
			loadURL();
			highlighted = true;

			}else{
				updateFace(normal);
				highlighted = false;
			}
			
			}
		}
		
		public function onMouseMove(event:MouseEvent):void
		{
			if(mouseY < positionY+selected.height && mouseY > positionY && mouseX < positionX+selected.width && mouseX > positionX){
				Mouse.cursor = flash.ui.MouseCursor.BUTTON;
				holdingOver = true;
				
				text.text = "x-Coordinate: " + getXcoordinate + "\n" + "y-Coordinate: " + getYcoordinate + "\n" + "Angle: " + getDirection;
				text.wordWrap = true;
				text.scaleX = 1.1;
				
				text.x = this.getPositionX+25;
				text.y = this.getPositionY-25;
				
				this.graphics.lineStyle(1,0x000000);
				this.graphics.beginFill(0xffffff,1);
				this.graphics.drawRect(this.getPositionX+25,this.getPositionY-25,text.width,text.height/2);
				this.graphics.endFill();
				
				this.addChild(text);
				
				
				
			}else{
				holdingOver = false;
				this.graphics.clear();
				if (text) {
					text.text = " ";
				}
			}	
		}
		
		/**
		 * Sets the x-coordinate of the GeoMapObject relative to real life.
		 * 
		 * NOTE!
		 * This is not the position of the GeoMapObject, it's only an coordinate.
		 */
		public function setXcoordinate(xCoordinate:Number):void
		{
			this.xCoordinate = xCoordinate;
		}
		
		/**
		 * Gets the x-coordinate of the GeoMapObject relative to real life.
		 * 
		 * NOTE!
		 * This is not the position of the GeoMapObject, it's only an coordinate.
		 */
		public function get getXcoordinate():Number
		{
			return xCoordinate;
		}
		
		/**
		 * Sets the y-coordinate of the GeoMapObject relative to real life.
		 * 
		 * NOTE!
		 * This is not the position of the GeoMapObject, it's only an coordinate.
		 */
		public function setYcoordinate(yCoordinate:Number):void
		{
			this.yCoordinate = yCoordinate;
		}
		
		/**
		 * Gets the y-coordinate of the GeoMapObject relative to real life.
		 * 
		 * NOTE!
		 * This is not the position of the GeoMapObject, it's only an coordinate.
		 */
		public function get getYcoordinate():Number
		{
			return yCoordinate;
		}
		
		/**
		 * Sets the direction in which the GeoMapObject should be facing.
		 * If this is not set the GeoMapObject will point upwards as default.
		 */
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
		
		/**
		 * Sets the x-position of the GeoMapObject.
		 */
		public function setPositionX(positionX:int):void
		{
			this.positionX = positionX;
			normal.x = positionX;
			selected.x = positionX;
		}
		
		/**
		 * Returns an Integer of the position in x-axis of the GeoMapObject. 
		 */
		public function get getPositionX():int
		{
			return positionX;
		}
		
		/**
		 * Sets the y-position of the GeoMapObject.
		 */
		public function setPositionY(positionY:int):void
		{
			this.positionY = positionY;
			normal.y = positionY;
			selected.y = positionY;
		}
		
		/**
		 * Returns an Integer of the position in y-axis of the GeoMapObject. 
		 */
		public function get getPositionY():int
		{
			return positionY;
		}
		
		/**
		 * Returns current face of the DisplayObject.
		 */
		public function get getCurrentFace():DisplayObject
		{
			return currentFace;
		}
		
		/**
		 * Resets the face to normal (non-selected) face.
		 */
		public function resetFace():void
		{
			updateFace(normal);
		}
		
		/**
		 * Returns true if holding the mouse over the object.
		 */
		public function get getIfHoldingOver():Boolean
		{
			return holdingOver;
		}
		
		/**
		 * Gets the state in which the GeoMapObject is in.
		 * Returns true if the object can be selected, false if it is already selected.
		 */
		public function get getState():Boolean
		{
			return state;
		}
		
		/**
		 * Sets the URL to the GeoMapObject.
		 * This URL will be displayed in the MediaContainer.
		 * 
		 * @param url The url that will be displayed when clicking the GeoMapObject.
		 */
		public function setURL(url:String):void
		{
			this.url = url;
		}
		
		/**
		 * Sets the object to default selected and loads the URL to the MediaContainer.
		 */
		public function setDefault():void
		{
			updateFace(selected);
			state = !state;
			highlighted = true;
			smp.player.volume = 50;
			loadURL();
		}
		
		private  function loadURL():void
		{
			if(url != null){
				var resource:URLResource = new URLResource(url);
				var mediaElement:MediaElement = mediaFactory.createMediaElement(resource);
				media = mediaElement;
				
				// Load the plugin statically
				var pluginResource:MediaResourceBase = new PluginInfoResource(new AdvertisementPluginInfo);
				
				// You can load it as a dynamic plugin as well
				// var pluginResource:MediaResourceBase = new URLResource("http://localhost/AdvertisementPlugin/bin/AdvertisementPlugin.swf");
				
				// Pass the references to the MediaPlayer and the MediaContainer instances to the plug-in.
				pluginResource.addMetadataValue("MediaPlayer", smp.player);
				pluginResource.addMetadataValue("MediaContainer", smp.mediaContainer);
				
				// Configure the plugin with the ad information
				// The following configuration instructs the plugin to play a mid-roll ad after 1 seconds
				pluginResource.addMetadataValue("midroll", url);
				pluginResource.addMetadataValue("midrollTime", 1);
				
				netStreamLoad(resource);
				
				// Load the plugin.
				mediaFactory.loadPlugin(pluginResource);
			}
		}
		
		private function netStreamLoad(resource:URLResource):void
		{
			var connection:NetConnection = new NetConnection();
			connection.client = new NetClient();
			connection.connect(null);
			var factory:HTTPStreamingFactory = new HTTPStreamingF4FFactory();
			var httpNetStream:HTTPNetStream = new HTTPNetStream(connection, factory, resource);
			HTTPDownloadManager.passNetstream(httpNetStream);
		}
	}
}












