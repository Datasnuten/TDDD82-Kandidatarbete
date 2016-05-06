/*****************************************************
 *  
 *  Copyright 2011 Adobe Systems Incorporated.  All Rights Reserved.
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
 *  Portions created by Adobe Systems Incorporated are Copyright (C) 2011 Adobe Systems 
 *  Incorporated. All Rights Reserved. 
 *  
 *****************************************************/
package org.osmf.net.httpstreaming
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.IDataInput;
	import flash.utils.Timer;
	
	import mx.collections.ArrayList;
	import mx.messaging.channels.StreamingAMFChannel;
	
	import org.osmf.events.HTTPStreamingEvent;
	import org.osmf.events.HTTPStreamingEventReason;
	import org.osmf.net.httpstreaming.HTTPDownloadManager;
	import org.osmf.net.httpstreaming.flv.FLVTagScriptDataMode;
	import org.osmf.utils.OSMFSettings;
	
	CONFIG::LOGGING
	{
		import org.osmf.logging.Logger;
	}
	
	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * HTTPStreamDownloader is an utility class which is responsable for
	 * downloading and local buffering HDS streams.
	 * 
	 * @langversion 3.0
	 * @playerversion Flash 10.1
	 * @playerversion AIR 1.5
	 * @productversion OSMF 1.6
	 */
	public class HTTPStreamDownloader
	{
		/**
		 * Default constructor.
		 * 
		 * @param dispatcher A dispatcher object used by HTTPStreamDownloader to
		 * 					 dispatch any event. 
		 **/
		public function HTTPStreamDownloader()
		{
			try{
				filedown = HTTPDownloadManager.getInstance();
			}catch(error:Error){}
		}

		/**
		 * Returns true if the HTTP stream source is open and false otherwise.
		 **/
		public function get isOpen():Boolean
		{
			return _isOpen;
		}
		
		/**
		 * Returns true if the HTTP stream source has been completly downloaded.
		 **/
		public function get isComplete():Boolean
		{
			return _isComplete;
		}
		
		/**
		 * Returns true if the HTTP stream source has data available for processing.
		 **/
		public function get hasData():Boolean
		{
			return _hasData;
		}
		
		/**
		 * Returns true if the HTTP stream source has not been found or has some errors.
		 */
		public function get hasErrors():Boolean
		{
			return _hasErrors;
		}
		
		/**
		 * Returns the duration of the last download in seconds.
		 */
		public function get downloadDuration():Number
		{
			return _downloadDuration;
		}
		
		/**
		 * Returns the bytes count for the last download.
		 */
		public function get downloadBytesCount():Number
		{
			return _downloadBytesCount;
		}
		
		protected static var fragCount:uint = 0;
		private var FragCount_alt:uint = 0;
		protected var inorderDownloadedBytes:Number = 0;
		protected var inCurrBytes:Number = 0;
		protected var inOldBytes:Number = 0;
		protected var parCurrBytes:Number = 0;
		protected var parOldBytes:Number = 0;
		protected var parallelDownloadedBytes:Number = 0;
		public var fragrate:uint=0;
		public var estimate:uint=0;
		public var globalavg:Number = 0;
		public var runtable:Array=new Array;
		public var sizeArray:Array = new Array;
		public var Deadline:Array = new Array;
		public var Time:Number = 0;
		
		public function getFragCount():uint
		{
			return fragCount;
		}
		protected var aFrag:ByteArray = new ByteArray();
		protected var downloadedSecBytes:uint = 0;
		
		 
		public function get bufferInfo():String
		{
			return ("In order megabytes: " + ((inorderDownloadedBytes + inCurrBytes)/1048576) + " parallel megabytes: " + ((parallelDownloadedBytes + parCurrBytes)/1048576)
				+ " total megabytes: " + ((inorderDownloadedBytes + inCurrBytes + parallelDownloadedBytes + parCurrBytes)/1048576));
		}
		
		public function checkprePrefetch(currentFrag:Number):Boolean
		{
			var path:String = filedown.returnPlayerpath();
			var avail:Array = filedown.availablepaths;
			for(var i:uint=0; i<avail.length;i++){
				if(path == avail[i] && landpointcheck(currentFrag) == true && filedown.returnBranch() != 0){
					return true;
				}
			}
			return false;			
		}
		
		public function landpointcheck(frag:Number):Boolean
		{
			for(var j:uint=0; j<filedown.jump_array.length;j++){
				if(frag == (filedown.jump_array[j]-1))
					return true;
			}
			return false;
		}
		
		private var lastNum:String;		// Used for finding the number of the fragment being downloaded
			
		/**
		 * Opens the HTTP stream source and start downloading the data 
		 * immediately. It will automatically close any previous opened
		 * HTTP stream source.
		 **/
//		Includes changes to download prefetched fragments from the cache
		public function open(request:URLRequest, dispatcher:IEventDispatcher, timeout:Number,id:uint):void
		{				
			var lengthOfReq:uint = request.url.length;
			trace("HTTPStreamDownloader");
			while(!isNaN(Number(request.url.charAt(lengthOfReq))))
			{
				if(isNaN(Number(request.url.charAt(lengthOfReq))))
					break;
				lengthOfReq--;
			}
			
			lastNum = request.url.substr(lengthOfReq+1);
			fragCount = Number(lastNum);			
			globalavg = filedown.receiveglobalAvgforStreamdownloader();
			estimate = filedown.receiveEstimateforStreamdownloader();
			fragrate = filedown.receiveFragrateforStreamdownloader();
			runtable = filedown.receiveRuntableforStreamdownloader();
			Time = filedown.receiveTimeStreamdownloader();
			sizeArray[fragCount] = ((runtable[fragCount-1]/1000)*fragrate);			
			if(catchvar==0){
				Deadline = calcdeadline();
				filedown.frag_deadline=Deadline;
				catchvar++;
			}
			
			//####### COMMENTED OUT PROJECT GROUP 9 ###### 
			//next_dec = filedown.calculate_decisionpoint(Time);
			
			//Dead code
			var time_left:Number = calculateTimetoDec(Time,next_dec,fragCount);
			
			{
				if (isOpen || (_urlStream != null && _urlStream.connected))
					close();
				
				if(request == null)
				{
					throw new ArgumentError("Null request in HTTPStreamDownloader open method."); 
				}
				
				CONFIG::LOGGING
				{
					inCurrBytes = 0;
				}				
				_isComplete = false;
				_hasData = false;
				_hasErrors = false;
				
				_dispatcher = dispatcher;
				if (_savedBytes == null)
				{
					_savedBytes = new ByteArray();
				}
				
				if (_urlStream == null)
				{
					_urlStream = new URLStream();
					_urlStream.addEventListener(Event.OPEN, onOpen);
					_urlStream.addEventListener(Event.COMPLETE, onComplete);
					_urlStream.addEventListener(ProgressEvent.PROGRESS, onProgress);
					_urlStream.addEventListener(IOErrorEvent.IO_ERROR, onError);
					_urlStream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
				}
				
				if (_timeoutTimer == null && timeout != -1)
				{
					_timeoutTimer = new Timer(timeout, 1);
					_timeoutTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimeout);
				}
				
				if (_urlStream != null)
				{
					_timeoutInterval = timeout;
					_request = request;
					CONFIG::LOGGING
					{
						logger.debug("Loading (timeout=" + _timeoutInterval + ", retry=" + _currentRetry + "):" + _request.url.toString());
					}
					
					_downloadBeginDate = null;
					_downloadBytesCount = 0;
					startTimeoutMonitor(_timeoutInterval);

					if(estimate != 0 || fragrate !=0 || sizeArray[fragCount]!=0){
						var returnvar:uint=filedown.calculate_prefetch_quality(1300,fragCount);
						if(returnvar==500){
							_request.url = ("http://"+filedown.URL+"final_"+0.5+"Seg1-Frag"+fragCount);
							filedown.downloader_rate=0.5;
						}
						_request = check_if_paralleled(fragCount,_request,fragrate); 
						filedown.downloader_rate=hold;
					}
					
					if (checklandpointDownload(fragCount) == true){
						_request.url = ("http://"+filedown.URL+"final_"+0.25+"Seg1-Frag"+fragCount);
						filedown.downloader_rate=0.25;
					}
										
					if( filedown.checkprefetchpath(fragCount)==true){
						var fragQ:Dictionary= filedown.getfragq();
						_request.url = ("http://"+filedown.URL+"final_"+fragQ[fragCount]+"Seg1-Frag"+fragCount);
						filedown.downloader_rate=fragQ[fragCount];
					}
					
					if(check_if_paralleled_alt(fragCount,_request,fragrate)==false || checklandpointDownload(fragCount) == true || checklandpointDownload(fragCount-1) == true || checklandpointDownload(fragCount-2) == true){
						dloadlist.push(fragCount);
					}
					
					var ori_req:String = _request.url;
					filedown.stream_downloaded = fragCount;
					FragCount_alt = fragCount;
					filedown.normal_running++;
					_urlStream.load(_request);
					var indexoffinal:int=_request.url.indexOf("final");
					var indexofseg:int=_request.url.indexOf("Seg1");
					var qrate:String=(_request.url.substring((indexoffinal+6),(indexofseg)));
					filedown.streamdownloadedlist.push(fragCount);
					filedown.alt_set==false;
				}
			}			
		}
		
		private function calculateTimetoDec(time:Number,dec:int,frag:int):Number
		{
			var nettTime:Number=0;
			for(var i:uint=0;i<dec;i++){
				nettTime = nettTime+runtable[i]
			}
			var remainingtime:Number= nettTime-(time*1000);
			return remainingtime;
		}
		
		private function check_if_paralleled(num:uint,req:URLRequest,frate:Number):URLRequest //NEEDS DEBUG HERE
		{
			var fragmentQ:Dictionary = filedown.fragmentQ;
			if(fragmentQ[num] != null){
				if(fragmentQ[num] == frate){
					return req;
				}
				if(fragmentQ[num] != frate){
					hold=0;
					if(fragmentQ[num]==250 || fragmentQ[num]==0.25)
						hold=0.25;
					if(fragmentQ[num]==500 || fragmentQ[num]==0.5)
						hold=0.5;
					if(fragmentQ[num]==850 || fragmentQ[num]==0.85)
						hold=0.85;
					if(fragmentQ[num]==1300 || fragmentQ[num]==1.3)
						hold=1.3;
					req.url = ("http://"+filedown.URL+"final_"+hold+"Seg1-Frag"+num);
					return req;
				}
			}
			return req;
		}
		
		private function check_if_paralleled_alt(num:uint,req:URLRequest,frate:Number):Boolean
		{
			var fragmentQ:Dictionary = filedown.fragmentQ;
			if(fragmentQ[num] != null){
					return true;
				}
			return false;
		}
		
		private function calcexpectedcompletion(size:uint,esti:uint):Number
		{
			var comp_time:Number = size/esti;
			return comp_time;
		}
		
		
		private function calcdeadline():Array
		{
			var deadlines:Array = new Array;
			var sum:int=0;
			for(var i:uint=0; i<runtable.length;i++)
			{
				for(var j:uint=0; j<=i;j++)
				{
					sum = (sum+runtable[j]); 
				}
				deadlines[i+1]=sum;
				sum=0;
			}
			return deadlines;
		}
			
		public function checkLastpath(currentFrag:uint):Boolean
		{
			var path:String = filedown.returnPlayerpath();
			var anotherpath:String = path.substr(1);
			var patharray:Array = anotherpath.split(" ");
			var lastpath:String = patharray[patharray.length-1];
			if(lastpath == currentFrag.toString())
				return false;
			return true
		}
		
		public function checklandpointDownload(fragno:uint):Boolean
		{
			var landPoint:Vector.<Number> = filedown.landPoints;
			for(var i:uint=0; i < landPoint.length; i++)
			{
				if(fragno == landPoint[i])
					return true;
			}
			return false;
		}
		
		public function landpointInCurrentpath(fragnum:uint):Boolean
		{
			var allpaths:Array = filedown.all_jump_paths;
			var path:String = filedown.returnPlayerpath();
			for(var i:uint=0; i<allpaths.length; i++){
				if(allpaths[i].indexOf(path) < 0){
					var anotherallpath:String = allpaths[i].substr(1);
					var allpatharray:Array = anotherallpath.split(" ");
					if(allpatharray[allpatharray.length-1] == fragnum){
						return true;
					}
				}
			}
			return false;
		}
		
		
		/**
		 * Closes the HTTP stream source. It closes any open connection
		 * and also clears any buffered data.
		 * 
		 * @param dispose Flag to indicate if the underlying objects should 
		 * 				  also be disposed. Defaults to <code>false</code>
		 * 				  as is recommended to reuse these objects. 
		 **/ 
		public function close(dispose:Boolean = false):void
		{
			CONFIG::LOGGING
			{
				if (_request != null)
				{
					logger.debug("Closing :" + _request.url.toString());
				}
			}
			
			stopTimeoutMonitor();
			
			_isOpen = false;
			_isComplete = false;
			_hasData = false;
			_hasErrors = false;
			_request = null;
			
			if (_timeoutTimer != null)
			{
				_timeoutTimer.stop();
				if (dispose)
				{
					_timeoutTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimeout);
					_timeoutTimer = null;
				}
			}
			
			if (_urlStream != null)
			{
				if (_urlStream.connected)
				{
					_urlStream.close();
				}
				if (dispose)
				{
					_urlStream.removeEventListener(Event.OPEN, onOpen);
					_urlStream.removeEventListener(Event.COMPLETE, onComplete);
					_urlStream.removeEventListener(ProgressEvent.PROGRESS, onProgress);
					_urlStream.removeEventListener(IOErrorEvent.IO_ERROR, onError);
					_urlStream.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
					_urlStream = null;
				}
			}
			
			if (_savedBytes != null)
			{
				_savedBytes.length = 0;
				if (dispose)
				{
					_savedBytes = null;
				}
			}
		}
		
		/**
		 * Return the total number of available bytes,
		 * includes both saved bytes and bytes in the underlying url stream
		 **/
		public function compareLandalternate(fragNum:Number):Boolean
		{
			var path:String = filedown.returnPlayerpath();
			var avail:Array = filedown.availablepaths;
			var pathedit1:String = path.substring(1);
			var pathedit2:Array = pathedit1.split(" ");
			var holding:String = ""
			var final:String = ""
			for(var i:uint=0; i<pathedit2.length-1;i++){
				var concat:String = " ";
				holding = concat.concat(pathedit2[i]);
				final = final.concat(holding);
			}
			for(var j:uint=0; j<avail.length;j++){
			 
				if(final == avail[j] && landpointcheck(fragNum) == true && (pathedit2[pathedit2.length-1]>fragNum)){
			
					return true;
				}
			}
			return false;			
		}
		
		public function get totalAvailableBytes():int
		{
			if (!isOpen)
			{
				return 0;
			}
			else
			{
				var lastNumconv:Number = parseInt(lastNum);
				return _savedBytes.bytesAvailable + _urlStream.bytesAvailable;
			}
		}
		
		/**
		 * Returns a buffer containing a specified number of bytes or null if 
		 * there are not enough bytes available.
		 * 
		 * @param numBytes The number of the bytes to be returned. 
		 **/
		public function getBytes(numBytes:int = 0):IDataInput
		{
			if ( !isOpen || numBytes < 0)
			{
				return null;
			}
			
			if (numBytes == 0)
			{
				numBytes = 1;
			}
			
			var totalAvailableBytes:int = this.totalAvailableBytes;
			if (totalAvailableBytes == 0)
			{
				_hasData = false;
			}
			
			if (totalAvailableBytes < numBytes)
			{
				return null;
			}
			
			// use first the previous saved bytes and complete as needed
			// with bytes from the actual stream.
			if (_savedBytes.bytesAvailable)
			{
				var needed:int = numBytes - _savedBytes.bytesAvailable;
				if (needed > 0)
				{
					_urlStream.readBytes(_savedBytes, _savedBytes.length, needed);
				}
				
				return _savedBytes;
			}
			
			// make sure that the saved bytes buffer is empty 
			// and return the actual stream.
			_savedBytes.length = 0;		
			var lastNumconv:Number = parseInt(lastNum);
			currenttime = filedown.passTime();
			return _urlStream;
		}
		
		/**
		 * Clears the saved bytes.
		 **/
		public function clearSavedBytes():void
		{
			if(_savedBytes == null)
			{
				// called after dispose
				return;
			}
			_savedBytes.length = 0;
			_savedBytes.position = 0;
		}
		
		/**
		 * Copies the specified number of bytes from source into the saved bytes.
		 **/
		public function appendToSavedBytes(source:IDataInput, count:uint):void
		{
			if(_savedBytes == null)
			{
				// called after dispose
				return;
			}
			source.readBytes(_savedBytes, _savedBytes.length, count);
			CONFIG::LOGGING
			{
				logger.debug("SAVED BYTES after append operation: " + _savedBytes.length);
			}
		}
		
		/**
		 * Saves all remaining bytes from the HTTP stream source to
		 * internal buffer to be available in the future.
		 **/
		public function saveRemainingBytes():void
		{
			if(_savedBytes == null)
			{
				// called after dispose
				return;
			}
			if (_urlStream != null && _urlStream.connected && _urlStream.bytesAvailable)
			{
				_urlStream.readBytes(_savedBytes, _savedBytes.length);
				CONFIG::LOGGING
				{
					logger.debug("SAVED BYTES after saving remaining bytes: " + _savedBytes.length);
				}
			}
			else
			{
				// no remaining bytes
			}
		}
		
		/**
		 * Returns a string representation of this object.
		 **/
		public function toString():String
		{
			// TODO : add request url to this string
			return "HTTPStreamSource";
		}
		
		/// Event handlers
		/**
		 * @private
		 * Called when the connection has been open.
		 **/
		private function onOpen(event:Event):void
		{
			_isOpen = true;
		}
		
		/**
		 * @private
		 * Called when all data has been downloaded.
		 **/
		private function onComplete(event:Event):void
		{
			filedown.normal_running--;
			if (_downloadBeginDate == null)
			{
				_downloadBeginDate = new Date();
			}
			inCurrBytes = 0;
			_downloadEndDate = new Date();
			_downloadDuration = (_downloadEndDate.valueOf() - _downloadBeginDate.valueOf())/1000.0;
			
			//  #############################################  Added  ##################################################
			// Saves the amount of data has been downloaded 
			CONFIG::LOGGING
			{
				inorderDownloadedBytes += _downloadBytesCount;
			}
			
			_isComplete = true;
			_hasErrors = false;
			
			CONFIG::LOGGING
			{
				logger.debug("Loading complete. It took " + _downloadDuration + " sec and " + _currentRetry + " retries to download " + _downloadBytesCount + " bytes.");	
			}
			
			if (_dispatcher != null)
			{
				var streamingEvent:HTTPStreamingEvent = new HTTPStreamingEvent(
					HTTPStreamingEvent.DOWNLOAD_COMPLETE,
					false, // bubbles
					false, // cancelable
					0, // fragment duration
					null, // scriptDataObject
					FLVTagScriptDataMode.NORMAL, // scriptDataMode
					_request.url, // urlString
					_downloadBytesCount, // bytesDownloaded
					HTTPStreamingEventReason.NORMAL, // reason
					this); // downloader
				_dispatcher.dispatchEvent(streamingEvent);
			}
			if(dloadlist.length > 0){
				filedown.Buffer+=(runtable[dloadlist.splice(0,1)-1]/1000);
			}
		}
		
		/**
		 * @private
		 * Called when additional data has been received.
		 **/
		private function onProgress(event:ProgressEvent):void
		{
			if (_downloadBeginDate == null)
			{
				_downloadBeginDate = new Date();
			}
			
			if (_downloadBytesCount == 0)
			{
				if (_timeoutTimer != null)
				{
					stopTimeoutMonitor();
				}
				_currentRetry = 0;
				
				_downloadBytesCount = event.bytesTotal;
				CONFIG::LOGGING
				{
					logger.debug("Loaded " + event.bytesLoaded + " bytes from " + _downloadBytesCount + " bytes.");
				}
			}
			inCurrBytes = event.bytesLoaded;
			_hasData = true;			
			
			if(_dispatcher != null)
			{
				var streamingEvent:HTTPStreamingEvent = new HTTPStreamingEvent(
					HTTPStreamingEvent.DOWNLOAD_PROGRESS,
					false, // bubbles
					false, // cancelable
					0, // fragment duration
					null, // scriptDataObject
					FLVTagScriptDataMode.NORMAL, // scriptDataMode
					_request.url, // urlString
					0, // bytesDownloaded
					HTTPStreamingEventReason.NORMAL, // reason
					this); // downloader
				_dispatcher.dispatchEvent(streamingEvent);
			}
			
		}	
		
		/**
		 * @private
		 * Called when an error occurred while downloading.
		 **/
		private function onError(event:Event):void
		{
			if (_timeoutTimer != null)
			{
				stopTimeoutMonitor();
			}
			
			if (_downloadBeginDate == null)
			{
				_downloadBeginDate = new Date();
			}
			_downloadEndDate = new Date();
			_downloadDuration = (_downloadEndDate.valueOf() - _downloadBeginDate.valueOf()) / 1000.0;
			
			_isComplete = false;
			_hasErrors = true;
			
			CONFIG::LOGGING
			{
				logger.error("Loading failed. It took " + _downloadDuration + " sec and " + _currentRetry + " retries to fail while downloading [" + _request.url + "].");
				logger.error("URLStream error event: " + event);
			}
			
			if (_dispatcher != null)
			{
				var reason:String = HTTPStreamingEventReason.NORMAL;
				if(event.type == Event.CANCEL)
				{
					reason = HTTPStreamingEventReason.TIMEOUT;
				}
				var streamingEvent:HTTPStreamingEvent = new HTTPStreamingEvent(
					HTTPStreamingEvent.DOWNLOAD_ERROR,
					false, // bubbles
					false, // cancelable
					0, // fragment duration
					null, // scriptDataObject
					FLVTagScriptDataMode.NORMAL, // scriptDataMode
					_request.url, // urlString
					0, // bytesDownloaded
					reason, // reason
					this); // downloader
				_dispatcher.dispatchEvent(streamingEvent);
			}
		}
		
		/**
		 * @private
		 * Starts the timeout monitor.
		 */
		private function startTimeoutMonitor(timeout:Number):void
		{
			if (_timeoutTimer != null)
			{
				if (timeout > 0)
				{
					_timeoutTimer.delay = timeout;
				}
				_timeoutTimer.reset();
				_timeoutTimer.start();
			}
		}
		
		/**
		 * @private
		 * Stops the timeout monitor.
		 */
		private function stopTimeoutMonitor():void
		{
			if (_timeoutTimer != null)
			{
				_timeoutTimer.stop();
			}
		}
		
		/**
		 * @private
		 * Event handler called when no data was received but the timeout interval passed.
		 */ 
		private function onTimeout(event:TimerEvent):void
		{
			CONFIG::LOGGING
			{
				logger.error("Timeout while trying to download [" + _request.url + "]");
				logger.error("Canceling and retrying the download.");
			}
			
			if (OSMFSettings.hdsMaximumRetries > -1)
			{
				_currentRetry++;
			}
			
			if (	
				OSMFSettings.hdsMaximumRetries == -1 
				||  (OSMFSettings.hdsMaximumRetries != -1 && _currentRetry < OSMFSettings.hdsMaximumRetries)
			)
			{					
				open(_request, _dispatcher, _timeoutInterval + OSMFSettings.hdsTimeoutAdjustmentOnRetry,3);
			}
			else
			{
				close();
				onError(new Event(Event.CANCEL));
			}
		}
		
		/// Internals + unused variables
		private var _isOpen:Boolean = false;
		private var _isComplete:Boolean = false;
		private var _hasData:Boolean = false;
		private var _hasErrors:Boolean = false;
		private var _savedBytes:ByteArray = null;
		private var _urlStream:URLStream = null;
		private var _request:URLRequest = null;
		private var _dispatcher:IEventDispatcher = null;
		
		private var _downloadBeginDate:Date = null;
		private var _downloadEndDate:Date = null;
		private var _downloadDuration:Number = 0;
		private var _downloadBytesCount:Number = 0;
		private var next_dec:int=0;
		private var _timeoutTimer:Timer = null;
		private var _timeoutInterval:Number = 1000;
		private var _currentRetry:Number = 0;
		private var _count:Number = 0;
		private var doneonce:Boolean = false;
		private var firsttime:uint = 0;
		private var currenttime:uint = 0;
		private var prefetchNumber:uint = 0;
		private var catchvar:uint =0;
		private var catchvar1:uint =0;
		private var all_sizes:Array = new Array;
		
		private var dummy_request:URLRequest;
		private var dummy_dispatcher:IEventDispatcher;
		private var dummy_timeout:Number;
		private var blocker:int =0;
		private var dummy_fragCount:uint=0;
		private var hold:Number=0;
		private var dloadlist:Array= new Array;
		private var filedown:HTTPDownloadManager = null;
		CONFIG::LOGGING
		{
			private static const logger:org.osmf.logging.Logger = org.osmf.logging.Log.getLogger("org.osmf.net.httpstreaming.HTTPStreamDownloader");
		}
	}
}
