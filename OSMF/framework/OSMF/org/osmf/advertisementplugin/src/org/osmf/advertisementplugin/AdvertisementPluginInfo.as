/*****************************************************
 *  
 *  Copyright 2009 Adobe Systems Incorporated.  All Rights Reserved.
 *  
 *****************************************************
 *  The contents of this file are subject to the Mozilla Public License
 *  Version 1.1 (the "License"); you may not use this file except in
 *  compliance with the License. You may obtain a copy of the License at
 *  http://www.mozilla.org/MPL/
 *   
 *  Software distributed under the License is distributed on an "AS IS"
 *  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 *  License for the specific language governing rights and limitations
 *  under the License.
 *   
 *  
 *  The Initial Developer of the Original Code is Adobe Systems Incorporated.
 *  Portions created by Adobe Systems Incorporated are Copyright (C) 2009 Adobe Systems 
 *  Incorporated. All Rights Reserved. 
 *  
 *****************************************************/

package org.osmf.advertisementplugin.src.org.osmf.advertisementplugin
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import mx.collections.ArrayList;
	
	import org.osmf.containers.MediaContainer;
	import org.osmf.events.AudioEvent;
	import org.osmf.events.BufferEvent;
	import org.osmf.events.ContainerChangeEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.layout.ScaleMode;
	import org.osmf.logging.Log;
	import org.osmf.logging.Logger;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfo;
	import org.osmf.media.URLResource;
	import org.osmf.net.httpstreaming.HTTPDownloadManager;

	/**
	 * The AdvertisementPluginInfo class provides the reference implementation for ad insertions.
	 */
	public class AdvertisementPluginInfo extends PluginInfo
	{	
		//##### CHANGED BY PROJECT GROUP 9 ####
		private static var adMediaPlayer:MediaPlayer;
		//private var adMediaPlayer:MediaPlayer;
		
		//######### ADDED BY PROJECT GROUP 9 #####
		private var list:ArrayList = new ArrayList();
		
		public function AdvertisementPluginInfo()
		{
			super();
			
			// Register the external interface callback functions which we'll use in our interactive demo.			
			if (ExternalInterface.available)
			{
				ExternalInterface.addCallback("displayNonLinearAd", displayNonLinearAd);
				ExternalInterface.addCallback("displayLinearAd", displayLinearAd);
			}
			fileDown = HTTPDownloadManager.getInstance(); //#### ADDED #### This isn't a very good idea, look at the cleanliness on the ctr...
		}
		
		//##### ADDED BY PROJECT GROUP 9 ####
		public static function getMediaPlayer():MediaPlayer
		{
			return adMediaPlayer;
		}
		
		/**
		 * Initialize the plugin.
		 */ 
		override public function initializePlugin(resource:MediaResourceBase):void
		{
			trace("initialize the Plugin");
			// Read the plugin configuration. Use string literals for simplicity/readability reasons.
			mediaPlayer = resource.getMetadataValue("MediaPlayer") as MediaPlayer;
			mediaContainer = resource.getMetadataValue("MediaContainer") as MediaContainer;
			mediaFactory = resource.getMetadataValue(PluginInfo.PLUGIN_MEDIAFACTORY_NAMESPACE) as MediaFactory;
						
			prerollURL = resource.getMetadataValue("preroll") as String;
			postrollURL = resource.getMetadataValue("postroll") as String;
			midrollURL = resource.getMetadataValue("midroll") as String;		
			midrollTime = int(resource.getMetadataValue("midrollTime"));
			overlayURL = resource.getMetadataValue("overlay") as String;
			overlayTime = int(resource.getMetadataValue("overlayTime"));
						
			trace("TIME: "+ overlayTime);
			// Expose so that we can disable the seek WORKAROUND for http://bugs.adobe.com/jira/browse/ST-397 
			// GPU Decoding issue on stagevideo: Win7, Flash Player version WIN 10,2,152,26 (debug)
			seekWorkaround = resource.getMetadataValue("seekWorkaround") != "false";
			
			if (prerollURL)
			{
				// NOTE: For progressive video the pause will not take effect immediately after playback has started.
				// So we need to pause the main media before it starts playing. To do this, we handle the 
				// BufferEvent.BUFFERING_CHANGE event, instead of PlayEvent.PLAY_STATE_CHANGE.
				// mediaPlayer.addEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);
				
				mediaPlayer.addEventListener(BufferEvent.BUFFERING_CHANGE, onBufferChange);
			}
			
			if (postrollURL)
			{
				// TODO: Prebuffer the preroll before the playback completes.
				// The current implementation will likely change in future.
				mediaPlayer.addEventListener(TimeEvent.COMPLETE, onComplete);
			}			
			
			//##### COMMENTED OUT BY PROJECT GROUP 9 ######
			/*if (midrollURL && midrollTime > 0)
			{
				mediaPlayer.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, onMidrollCurrentTimeChange);
			}*/
			
			//##### ADDED Project Group 9 #####
			if(midrollURL)
			{
				trace("midrollURL: " + midrollURL);
				displayLinearAd(midrollURL);
			}
			
			if (overlayURL && overlayTime > 0)
			{
				mediaPlayer.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, onOverlayCurrentTimeChange);
			}
			
			// Propagate the muted and volume changes from the video player to the advertisements.
			mediaPlayer.addEventListener(AudioEvent.MUTED_CHANGE, function(event:Event):void {
				for (var adPlayer:* in adPlayers)
				{
					trace("propagate the mute "+ mediaPlayer.muted);
					adPlayer.muted = mediaPlayer.muted;
				}
			});
			
			mediaPlayer.addEventListener(AudioEvent.VOLUME_CHANGE, function(event:Event):void {
				for (var adPlayer:* in adPlayers)
				{
					trace("propagate the volume " + mediaPlayer.volume);
					adPlayer.volume = mediaPlayer.volume;
				}
			});
		}
		
		/**
		* Displays a linear advertisement. 
		* 
		* The method does not check if an ad is currently being played or not.
		* This is up to the caller to check. 
		* 
		* The ad will use the same layout as the main media.
		* 
		* @param url - the path to the ad media to be displayed.
		* @resumePlaybackAfterAd - indicates if the playback of the main media should resume after the playback of the ad.
		*/
		public function displayLinearAd(url:String, resumePlaybackAfterAd:Boolean = false):void
		{
			trace("DisplayLinearAd");
			displayAd(url, true, resumePlaybackAfterAd, true, null);
		}
		
		/**
		 * Displays a non-linear (overlay) advertisement. 
		 * If another ad is already being played, the new ad is added on top.
		 * 
		 * @param url - the path to the media
		 * @param layoutMetadata - information about the ad layout
		 */ 
		public function displayNonLinearAd(url:String, layoutInfo:Object):void
		{
			trace("DisplayNonLinearAd");
			displayAd(url, false, false, true, layoutInfo);
		}	
		
		// Internals
		
		/**
		 * Utility function which plays an ad.
		 *  
		 * @param url - the path to the ad media to display.
		 * @param pauseMainMediaWhilePlayingAd - indicates if the main media needs to be paused while playing the ad.
		 * @param resumePlaybackAfterAd - indicates if the playback of the main media should resume after the playback of the ad.
		 * @param preBufferAd - indicates if we need to prebuffer the ad before playing it.
		 * @param layoutInfo - optional LayoutMetadata.
		 */ 
		private function displayAd(url:String, 
								   pauseMainMediaWhilePlayingAd:Boolean = true, 
								   /*resumePlayBackAfterAd:Boolean = true,*/
								   resumePlaybackAfterAd:Boolean = false, 
								   preBufferAd:Boolean = true,
								   layoutInfo:Object = null):void
		{
			// Set up the ad 
			var adMediaElement:MediaElement = mediaFactory.createMediaElement(new URLResource(url));
			
			
			CONFIG::LOGGING
				{
					logger.debug("ad manager");
				}
			
			// Set the layout metadata, if present				
			if (layoutInfo != null)
			{
				var layoutMetadata:LayoutMetadata = new LayoutMetadata();
				for (var key:String in layoutInfo)
				{
					layoutMetadata[key] = layoutInfo[key];
				}		
				
				if (!layoutInfo.hasOwnProperty("index"))
				{
					// Make sure we add the last ad on top of any others
					layoutMetadata.index = adPlayerCount + 100;
				}
				
				adMediaElement.metadata.addValue(LayoutMetadata.LAYOUT_NAMESPACE, layoutMetadata);	
			}
			
			
			//######## ADDED PROJECT GROUP 9 ########
			if(adMediaPlayer != null && mediaContainer.containsMediaElement(adMediaPlayer.media)){
				fileDown.prevMediaPlayer = adMediaPlayer;
				adMediaPlaying = adMediaPlayer.playing;
			}else if(mediaContainer.containsMediaElement(mediaPlayer.media)){
				adMediaPlaying = mediaPlayer.playing;
			}
			trace("Create new MediaPlayer");
			adMediaPlayer =  new MediaPlayer();	
			adMediaPlayer.media = adMediaElement;
			
			
			// Save the reference to the ad player, so that we can adjust the volume/mute of all the ads
			// whenever the volume or mute values change in the video player.
			adPlayers[adMediaPlayer] = true;
			adPlayerCount++;
			
			//###### COMMENTED OUT PROJECT GROUP 9 ##########
			//adMediaPlayer.addEventListener(TimeEvent.COMPLETE, onAdComplete);
			fileDown.list.addItem("1:"+(getTimer() - HTTPDownloadManager.timeClick).toString()+" ");
			HTTPDownloadManager.timeLoad = getTimer();
			if (preBufferAd)
			{
				trace("Is preBuffering the ad");
				// Wait until the ad fills the buffer and is ready to be played.
				adMediaPlayer.muted = true;
				adMediaPlayer.addEventListener(BufferEvent.BUFFERING_CHANGE, onBufferingChange);
				
				function onBufferingChange(event:BufferEvent):void
				{
					if (event.buffering == false)
					{
						adMediaPlayer.removeEventListener(BufferEvent.BUFFERING_CHANGE, onBufferingChange);	
						//##### ADDED PROJECT GROUP 9 #####
						logger.debug("known time "+knownTime);
						if(fileDown.prevMediaPlayer != null){
							knownTime = fileDown.prevMediaPlayer.currentTime;
						}else{
							knownTime = mediaPlayer.currentTime;
						}
						
						//##### ADDED PROJECT GROUP 9 #####
						var checkIfSeekAvailableTimer:Timer = new Timer(10, 0); //checks every 50 ms if seek is available
						checkIfSeekAvailableTimer.addEventListener(TimerEvent.TIMER, checkIfseekAvailable);
						checkIfSeekAvailableTimer.start();
						var hasSeeked:Boolean = false;
						function checkIfseekAvailable():void
						{
							if(adMediaPlayer.canSeekTo(knownTime) && !hasSeeked){
								adMediaPlayer.seek(knownTime);
								hasSeeked = true;
							}
							if(hasSeeked || adMediaPlayer.duration < knownTime){
								checkIfSeekAvailableTimer.stop();
								checkIfSeekAvailableTimer.removeEventListener(TimerEvent.TIMER, checkIfseekAvailable);
							}
						}
						
						trace("PlayAD");
						fileDown.list.addItem("2:"+(getTimer() - HTTPDownloadManager.timeLoad).toString()+" ");
						HTTPDownloadManager.timePlay = getTimer();
						playAd();
					}
				}		
			}
			else
			{
				trace("else: PlayAD");
				playAd();
			}
			
			function playAd():void
			{		
				// Copy the player's current volume values
				adMediaPlayer.volume = mediaPlayer.volume;
				adMediaPlayer.muted = mediaPlayer.muted;
				
			if (pauseMainMediaWhilePlayingAd)
				{
					trace("Pause Main Media!");
					// Indicates to the player that we currently are playing an ad,
					// so the player can adjust its UI.
					mediaPlayer.media.metadata.addValue("Advertisement", url);
					
					// TODO: We assume that playback pauses immediately,
					// but this is not the case for all types of content.
					// The linear ads should be inserted only after the player state becomes 'paused'.
					
					//##### ADDED BY PROJECT GROUP 9 #####
					if(fileDown.prevMediaPlayer != null){
						fileDown.prevMediaPlayer.pause();
					}
					
					mediaPlayer.pause();
					
					// If we are playing a linear ad, we need to remove it from the media container.
					if (mediaContainer.containsMediaElement(mediaPlayer.media))
					{
						trace("remove main video from media container");
						mediaContainer.removeMediaElement(mediaPlayer.media);
					}
					else
					{
						// Wait until the media gets added to the container, so that we can remove it
						// immediately afterwards.
						mediaPlayer.media.addEventListener(ContainerChangeEvent.CONTAINER_CHANGE, onContainerChange);
						function onContainerChange(event:ContainerChangeEvent):void
						{	
							if (mediaContainer.containsMediaElement(mediaPlayer.media))
							{
								mediaPlayer.media.removeEventListener(ContainerChangeEvent.CONTAINER_CHANGE, onContainerChange);
								mediaContainer.removeMediaElement(mediaPlayer.media);
							}
						}
					}					
				}
				
				//######### ADDED PROJECT GROUP 9 ###############
				if(fileDown.prevMediaPlayer != null && mediaContainer.containsMediaElement(fileDown.prevMediaPlayer.media)){ 
					mediaContainer.removeMediaElement(fileDown.prevMediaPlayer.media);
					adPlayerCount--;
					delete adPlayers[fileDown.prevMediaPlayer];		
				}
				
				// Add the ad to the container
				trace("Add the ad to the container");
				mediaContainer.addMediaElement(adMediaElement);
				
				fileDown.list.addItem("3:"+(getTimer() - HTTPDownloadManager.timePlay).toString()+" ");
				fileDown.list.addItem("4:"+(getTimer() - HTTPDownloadManager.timeStart).toString()+"\n");
				trace("TimeListStart: \n"+fileDown.list);
				
				//######### ADDED PROJECT GROUP 9 ###############
				if(adMediaPlaying){
					adMediaPlayer.play();
				}else{
					adMediaPlayer.pause();
				}
			}
			
			function onAdComplete(event:Event):void
			{
				var adMediaPlayer:MediaPlayer = event.target as MediaPlayer;
				adMediaPlayer.removeEventListener(TimeEvent.COMPLETE, onAdComplete);
				
				// Romove the ad from the media container
				mediaContainer.removeMediaElement(adMediaPlayer.media);

				// Remove the saved references
				adPlayerCount--;
				delete adPlayers[adMediaPlayer];					
				
				if (pauseMainMediaWhilePlayingAd)
				{					
					// Remove the metadata that indicates that we are playing a linear ad. 
					mediaPlayer.media.metadata.removeValue("Advertisement");
					
					// Add the main video back to the container.
					mediaContainer.addMediaElement(mediaPlayer.media);
				}
				
				if (pauseMainMediaWhilePlayingAd && resumePlaybackAfterAd)
				{	
					// WORKAROUND: http://bugs.adobe.com/jira/browse/ST-397 - GPU Decoding issue on stagevideo: Win7, Flash Player version WIN 10,2,152,26 (debug)
					if (seekWorkaround && mediaPlayer.canSeek)
					{
						mediaPlayer.seek(mediaPlayer.currentTime);
					}
					
					// Resume playback
					mediaPlayer.play();
				}
			}
		}
		
		// Non-linear ad insertion
		
		/**
		 * Sample Non-Linear ad code. Uses the flash vars configuration
		 */ 
		private function onOverlayCurrentTimeChange(event:TimeEvent):void
		{			
			if (mediaPlayer.currentTime > overlayTime)
			{
				mediaPlayer.removeEventListener(TimeEvent.CURRENT_TIME_CHANGE, onOverlayCurrentTimeChange);
			
				// Hard-coded, for sample purposes. 
				var overlayMetadata:Object = {
					right: 10,
					bottom: 10,
					width: 200,
					height: 140,
					scaleMode: ScaleMode.STRETCH
				};
				
				displayNonLinearAd(overlayURL, overlayMetadata);
			}	
		}
		
		// Linear ad insertion
		
		/**
		 * Display the pre-roll advertisement.
		 */ 		
		private function onBufferChange(event:BufferEvent):void
		{
			if (event.buffering)
			{
				mediaPlayer.removeEventListener(BufferEvent.BUFFERING_CHANGE, onBufferChange);
				
				// Do not pre-buffer the ad if playing a pre-roll ad.
				// Let the main content pre-buffer while the ad is playing instead.
				displayAd(prerollURL, true, true, false, null);				
			}
		}
		
		/**
		 * Display the mid-roll ad.
		 */ 
		private function onMidrollCurrentTimeChange(event:TimeEvent):void
		{	
			if (mediaPlayer.currentTime > midrollTime)
			{	
				trace("mid-roll ad");
				mediaPlayer.removeEventListener(TimeEvent.CURRENT_TIME_CHANGE, onMidrollCurrentTimeChange);
				
				displayLinearAd(midrollURL);
			}	
		}	
		
		/**
		 * Display the post-roll ad.
		 */ 
		private function onComplete(event:Event):void
		{
			mediaPlayer.removeEventListener(TimeEvent.COMPLETE, onComplete);
			
			// Resume the playback after the ad only if loop is set to true
			//displayLinearAd(postrollURL, mediaPlayer.loop);
		}
		
		//##### ADDED BY PROJECT GROUP 9 ####
		private var adMediaPlaying:Boolean;
		
		private var mediaPlayer:MediaPlayer;
		private var mediaContainer:MediaContainer;
		private var mediaFactory:MediaFactory;
		
		private var adPlayerCount:int = 0;
		
		// Weak references for the currently playing ads
		private var adPlayers:Dictionary = new Dictionary(true);
		
		private var prerollURL:String;
		private var postrollURL:String;
		private var midrollURL:String;
		private var newmidrollURL:String;
		
		private var midrollTime:int;
		private var knownTime:Number=0;
		
		private var overlayURL:String;
		private var overlayTime:int;
		private var seekWorkaround:Boolean = true;
		private static const logger:org.osmf.logging.Logger = org.osmf.logging.Log.getLogger("org.osmf.AdvertisementPluginInfo");
		private var fileDown:HTTPDownloadManager = null;
	}
}
