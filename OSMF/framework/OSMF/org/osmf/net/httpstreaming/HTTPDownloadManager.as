/*****************************************************
 *  
 *  Patrik Bergström and Vengatanathan Krishnamoorthi
 *  
*	Note: If you use our datafiles and/or software in your research, please include a reference to our ACM MM 2014 paper in your work.

*   V. Krishnamoorthi, N. Carlsson, D. Eager, A. Mahanti, and N. Shahmehri "Quality-adaptive Prefetching for Interactive Branched Video using HTTP-based Adaptive Streaming", Proc. ACM Multimedia, Orlando, FL, Nov. 2014.
 *****************************************************/

//This class contains most of the non-linear multipath functionality, viz. parsing metafiles, configuration files, tracking player status, branch handling, scheduling downloads, prefetching and rate estimation  

package org.osmf.net.httpstreaming
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.system.Capabilities;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	
	import org.osmf.events.HTTPStreamingEvent;
	import org.osmf.logging.Logger;
	import org.osmf.media.MediaPlayer;
	import org.osmf.net.httpstreaming.DefaultHTTPStreamingSwitchManager;
	import org.osmf.net.httpstreaming.HTTPNetStream;
	import org.osmf.net.httpstreaming.HTTPStreamDownloader;
	
	[Event(name="downloadComplete", type="org.osmf.events.HTTPStreamingEvent")]
	[Event(name="DVRStreamInfo", type="org.osmf.events.DVRStreamInfoEvent")]	
	[Event(name="runAlgorithm", type="org.osmf.events.HTTPStreamingEvent")]
	[Event(name="qosUpdate", type="org.osmf.events.QoSInfoEvent")]
	[Event(name="showAlert", type="flash.events.Event")]
	[Event(name="closeAlert", type="flash.events.Event")]
	
	
	public class HTTPDownloadManager extends EventDispatcher
	{
		public var Buffer:Number=0;
		private var DesiredMax:int=0;
		private var qSwitcher:Boolean=false;
		private var DesiredMin:int=0;
		private var storedtime:int=0;
		private var seeking:Boolean=false;
		private var to_move:int=0;
		public var downloader_rate:Number=0;
		private var missed_fragments:Array=new Array;
		private var missed_quality:Array=new Array;
		private var match_array:Array= new Array;
		private var branchArray:Array=new Array;
		private var possibles_connection:Array=new Array;
		private var possibles_quality:Array=new Array;
		public var normal_running:uint = 0;
		private var qmax_saveq:int=0;
		private var qmax_savec:int=0;
		private var firsttime:int=0;
		private var par_complete:Boolean=false;
		private var blocker1:Boolean = false;
		private var blocker:Boolean = false;
		private var next_dec:int=0;
		private var parallel_frag:Array = new Array;
		private var parallel_pending:Boolean=false;
		private var parallel_quality:Array = new Array;
		private var to_downloadlist:Array=new Array;
		private var to_qualitylist:Array=new Array;
		public var quality_array:Array = [250,500,850,1300];
		public var fragmentQ:Dictionary=new Dictionary;
		public var downloadedlist:Array=new Array;
		public var streamdownloadedlist:Array=new Array;
		public var resumedownloadlist:Array=new Array;
		public var stream_downloaded:int = 0;
		private var maxinParallel:int=0;
		public var alpha:Number = 0;
		public var mode:String="";
		private var buf_min:int=0;
		private var buf_margin:int=0;
		public var URL:String="";
		private var minus_calc:int=0;
		public var global_avg:Number = 0;
		public var current_est:Number = 0;
		private var parallelpipe_on:Boolean = false;
		private var parallelpipeexc_on:Boolean = false;
		private var parallelpipe_on_alt:Boolean = false;
		private var parallelpipe_on_alt1:Boolean = false;
		
		static private var instance:HTTPDownloadManager = null;
		private var dloadTimerbegin1:Number = 0;
		private var dloadTimerend1:Number = 0;
		private var dloadTimerbeginest:Number = 0;
		private var dloadTimerendest:Number = 0;
		private var dloadTimerbeginest_exc:Number = 0;
		private var dloadTimerendest_exc:Number = 0;
		private var dloadTimerbeginest_alt:Number = 0;
		private var dloadTimerbeginest_alt1:Number = 0;
		private var dloadTimerendest_alt:Number = 0;
		private var dloadTimerendest_alt1:Number = 0;
		private var BufferStatus:String="download";
		private var previouslyLogged:String="download";
		private var dloadTimerbegin2:Number = 0;
		private var dloadTimerend2:Number = 0;
		private var dloadTimerbegin3:Number = 0;
		private var dloadTimerend3:Number = 0;
		private var dloadTimerbegin4:Number = 0;
		private var dloadTimerend4:Number = 0;
		private var prefQ1:Number = 0;
		private var prefQ2:Number = 0;
		private var prefQ3:Number = 0;
		private var prefQ4:Number = 0;
		private var prefestF1:Number = 0;
		private var prefestQ1:Number = 0;
		private var prevfrag:int=0;
		private var prefestF1_exc:Number = 0;
		private var prefestQ1_exc:Number = 0;
		private var prefestF1_alt:Number = 0;
		private var prefestQ1_alt:Number = 0;
		private var prefestF1_alt1:Number = 0;
		private var prefestQ1_alt1:Number = 0;
		private var prefF1:Number = 0;
		private var prefF2:Number = 0;
		private var prefF3:Number = 0;
		private var prefF4:Number = 0;
		private var request:URLRequest;
		private var loader:URLLoader;
		private var loader1:URLLoader;
		private var request1:URLRequest;
		private var request2:URLRequest;
		private var loader2:URLLoader;
		private var request3:URLRequest;
		private var request4:URLRequest;
		private var request5:URLRequest;
		private var loader3:URLLoader;
		private var loader4:URLLoader;
		private var loader5:URLLoader;
		private var streamingEvent:HTTPStreamingEvent;
		
		private static const logger:org.osmf.logging.Logger = org.osmf.logging.Log.getLogger("org.osmf.net.httpstreaming.HTTPDownloadManager");
		private var fileContent:String;
		private var fileContent1:String;
		private var fileContent2:String;
		private var fileContent3:String;
		private var fileContent4:String;
		private var fileContent5:String;
		public var jumpTime:Array=new Array;
		public var pushButton:Array=new Array;		
		public var frag_deadline:Array=new Array;
		public var decPoints:Vector.<Number> = new Vector.<Number>;
		public var landPoints:Vector.<Number> = new Vector.<Number>;
		public var firstlandPoints:Vector.<Number> = new Vector.<Number>;
		public var nolandPoints:Vector.<Number> = new Vector.<Number>;
		public var fragments:Dictionary = new Dictionary();
		public var time_download:Dictionary = new Dictionary();
		public var quality_download:Dictionary = new Dictionary();
		public var fragmentsquality:Dictionary = new Dictionary();		
		private var prefetchPath:Array = new Array;
		private var AltprefetchPath:Array = new Array;
		private var branch_prefetchPath:Array = new Array;
		private var branch_Path:Array = new Array;
		private var branch_prefetchPathShifted:Array = new Array;
		private var treeStructure:String;
		private var message:String = "My very own message!";
		private var messages:Vector.<String> = new Vector.<String>;
		private var branchLengths:Vector.<Number> = new Vector.<Number>;
		private var branchLeft:Boolean = true;
		private var branchNum:uint = 0;
		private var lastChecked:Number = 0;
		private var currentFrag:Number = -1;
		private var netStream:HTTPNetStream = null;
		
		private static var Downloader:HTTPStreamDownloader = new HTTPStreamDownloader();
		private var checkCounter:int = 0;
		private var jumpCount:int = 0;
		public var timePass:int = 0;
		public var minus:int = 0;
		public var previousCounter:uint = 0;
		public var anotherpreviousCounter:uint = 0;
		public var availablepaths:Array = new Array;
		private var numberinParallel:int=1;
		public var all_jump_paths:Array = new Array;
		public var playerpath:String = "";
		public var extrapolatedplayerpath:String = "";
		public var playerpath_alt:String = "";
		public var futurepath:String = "";
		private var anotherdummy:String;
		public var lastfragment:String = "";
		public var lastquality:String = "";
		private var prevFrag:String = "";
		public var landNumber:uint = 0;
		public var jump_array:Array = new Array;
		
		private static var netStream1:HTTPNetStream;
		private var qualityinbytes:uint = 0;
		private var exportbranchNum:int = 0;
		private var receivedCount:Number = 0;
		private var secBranchnum:uint = 0;
		private var donePath:Array = new Array;
		public var donot_add:uint = 0;
		private var lastpath:String = "";
		private var playpath1:String = "";
		private var setpath:String = "";
		private var x:uint = 0;
		private var subtract:uint = 0;
		private var carryfragnum:uint = 0;
		private var prefetchingquality:Number=0;
		private var split:Array = new Array;
		public var runtable:Array = new Array; 
		public var estimate:uint = 0;
		public var fragRate:uint = 0;
		public var alt_set:Boolean = false;
		public var sizearray_250:Array = new Array;
		public var sizearray_500:Array = new Array;
		public var sizearray_850:Array = new Array;
		public var sizearray_1300:Array = new Array;
		
		private var lineBreakOS:String;
		
		public var prevMediaPlayer:MediaPlayer;
		
		CONFIG::LOGGING
		{
			private var numBytes:Number = 0;
			private var doneOnce:Boolean = false;
		}
		
		//		Emulates a singleton
		static public function getInstance():HTTPDownloadManager
		{
			if(instance == null)
				instance = new HTTPDownloadManager();
			return instance;
		}
		
		static public function passNetstream(netStream_passed:HTTPNetStream):void
		{
			netStream1=netStream_passed;
		}
		
		public function getfragcount(count:Number):void
		{
			receivedCount = count
		}
		
		public function passTime():int
		{
			return netStream1.time;
		}
		
		public function HTTPDownloadManager()
		{
			
			//####### ADDED BY PROJECT GROUP 9 ########
			if (Capabilities.os.search("Mac") == 0) {
				lineBreakOS = "\n";
			} else {
				lineBreakOS = "\r\n";
			}
			
			//This is the text file from which we are reading the video structure. Should be placed in StrobeMediaPlayback\bin. File to be placed on the server for real environment.
			request = new URLRequest("test.txt");		
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, processFile);
			try
			{
				loader.load(request);
			}
			catch(error:Error)
			{
				trace("loader");
				trace("Some error occured: " + error.message);
			}
			
			//This text file configures the prefetch mode. Used in the FhMN 2013 paper, not used in the MM 2014 paper.
			request1 = new URLRequest("input.txt");
			loader1 = new URLLoader();
			loader1.addEventListener(Event.COMPLETE, processInputFile);
			try
			{
				loader1.load(request1);
			}
			catch(error:Error)
			{
				trace("loader1");
				trace("Some error occured: " + error.message);
			}
			//			
			var myTimer1:Timer = new Timer(50, 0); // 50ms timer, checks current playpoint and initiates seek if necessary
			myTimer1.addEventListener(TimerEvent.TIMER, onCanSeekChange1);
			myTimer1.start();
			
			var myTimer3:Timer = new Timer(250, 0); // 250ms timer, initiates scheduling algorithm
			myTimer3.addEventListener(TimerEvent.TIMER, dummy);
			myTimer3.start();
			
			
			var myTimer2:Timer = new Timer(1000, 0); // 1s timer, used for logging purposes
			myTimer2.addEventListener(TimerEvent.TIMER, displaytime);
			myTimer2.start();
			
			//This text file configures the prefetch mode. Used in the FhMN 2013 paper, not used in the MMSYS 2014 paper.			
			request2 = new URLRequest("input1.txt");
			loader2 = new URLLoader();
			loader2.addEventListener(Event.COMPLETE, processInputFile1);
			try
			{
				loader2.load(request2);
			}
			catch(error:Error)
			{
				trace("loader2");
				trace("Some error occured: " + error.message);
			}
			//			Old file from which video structure was read. 
			request3 = new URLRequest("pathfile.txt");
			loader3 = new URLLoader();
			loader3.addEventListener(Event.COMPLETE, processpathFile); // We cannot garantee the program will let us load the text file first, so we will signal when it is ready for processing
			try
			{
				loader3.load(request3);
			}
			catch(error:Error)
			{
				trace("loader3");
				trace("Some error occured: " + error.message);
			}
			
			//This text file configures max connections in parallel, alpha value for rate estimate, sets the download policy and buffer size
			request4 = new URLRequest("workahead.txt");
			loader4 = new URLLoader();
			loader4.addEventListener(Event.COMPLETE, processInputFile2);
			try
			{
				loader4.load(request4);
			}
			catch(error:Error)
			{
				trace("loader4");
				trace("Some error occured: " + error.message);
			}
			//			This text file automates user choice
			request5 = new URLRequest("automator.txt");		
			loader5 = new URLLoader();
			loader5.addEventListener(Event.COMPLETE, processAutomatorFile);
			try
			{
				loader5.load(request5);
			}
			catch(error:Error)
			{
				trace("loader5");
				trace("Some error occured: " + error.message);
			}
		}
		
		
		//		Functions to process all files above
		
		private function processpathFile(event:Event):void
		{
			trace("processpathFile");
			var loader:URLLoader = URLLoader(event.target);
			fileContent3 = loader.data;
			var startTree:Number = fileContent3.indexOf("begin ");
			var endTree:Number = fileContent3.indexOf("end" + lineBreakOS, startTree);
			var tempStr:String = fileContent3.substring(startTree+6, endTree);
			split = tempStr.split(lineBreakOS);
			logger.debug("path file "+ split);
			//			REMOVE THIS BIT FOR NO PREFETCHING
			if(split[0]==""){
				for(var j:uint=0; j<70;j++){
					split[j]=j;
				}
			}
		}
		
		private function processInputFile1(event:Event):void
		{
			var loader:URLLoader = URLLoader(event.target);
			fileContent2 = loader.data;
			logger.debug("Input file2 "+ fileContent2);
		}
		
		private function processAutomatorFile(event:Event):void
		{
			var loader:URLLoader = URLLoader(event.target);
			fileContent5 = loader.data;
			logger.debug("Automator data "+ fileContent5);
			var tempStr:Array = fileContent5.split(lineBreakOS);
			for(var i:uint=0;i<tempStr.length;i++){
				var temp:Array=tempStr[i].split(" ");
				jumpTime.push(temp[0]);
				pushButton.push(temp[1])
			}
			
		}
		
		private function processInputFile2(event:Event):void
		{
			var loader:URLLoader = URLLoader(event.target);
			fileContent4 = loader.data;
			logger.debug("Input file3 "+ fileContent4);
			var tempStr:Array = fileContent4.split(lineBreakOS);
			var start1:Number = tempStr[0].indexOf(":");
			var start2:Number = tempStr[1].indexOf(":");
			var start3:Number = tempStr[2].indexOf(":");
			var start4:Number = tempStr[3].indexOf(":");
			var start5:Number = tempStr[4].indexOf(":");
			var start6:Number = tempStr[5].indexOf(":");
			var start7:Number = tempStr[6].indexOf(":");
			maxinParallel= tempStr[1].substring((start2 + 1));
			alpha= tempStr[2].substring((start3 + 1));
			mode= tempStr[3].substring((start4+2));
			buf_min = tempStr[4].substring((start5+2));
			buf_margin= tempStr[5].substring((start6+2));
			URL=tempStr[6].substring((start7+2));
		}
		
		private function processInputFile(event:Event):void
		{
			var loader:URLLoader = URLLoader(event.target);
			fileContent1 = loader.data;
			logger.debug("Input file "+ fileContent1);
		}
		
		public function checkprefetchpath(num:uint):Boolean
		{
			logger.debug("checked for "+num);
			for(var y:uint=0;y<AltprefetchPath.length;y++){
				if(num == AltprefetchPath[y]){
					return true;
				}
			}
			return false;
		}
		
		private function pathcheck(number:uint):Boolean
		{
			for(var i:uint=0;i<split.length;i++){
				if(number == int(split[i]))
					return true;
			}
			return false;
		}
		
		public function returnBranch():uint
		{
			logger.debug("branchnumber "+secBranchnum);
			return secBranchnum;
		}
		
		public function setsecbranchnum():void
		{
			secBranchnum = 0;
			return;
		}
		
		//		Used only for binary tree case. 
		public function setBranch(val:uint):void
		{
			branchNum = val;
			secBranchnum = val;
			logger.debug("branchnumber return branch "+secBranchnum);
		}
		
		public function returnBranchnum():int{
			return exportbranchNum;
		}
		
		//		This function initiates the NetStream.seek method whenever conditions are satisfied to initiate transition to a new branch. 
		public function onCanSeekChange1(event:TimerEvent):void 
		{
			try
			{
				timePass = netStream1.time;
			}
			catch(error:Error)
			{
				//trace("Some error occured: " + error.message);
			}
			
			if (branchNum != 0 && jump_array[branchNum-1] != null && checkavail(playerpath) == true){
				if(compareFraginSec(netStream1.time) == false){
					setpath = playerpath;
				}
			}
			if (branchNum != 0 && jump_array[branchNum-1] != null && checkavail(setpath) == true && checkdonepath(setpath) == false){
				if(compareFraginSec(netStream1.time) == true ){
					seeking=true;
					var a:Number = ((jump_array[branchNum-1])*4)-4; //4 is the playtime of a fragment. Try -3 if 4 doesn't work 
					//						a=a+0.5;
					donot_add = Math.round(a/4);
					bufferTimeChangeStart(0.5); //resets buffertime value
					netStream1.seek(a);
					playerpath_adhoc(a);
					donePath[x] = setpath;
					x++;
					//						logger.debug("another seek afterseek "+ branchNum+ " "+a + " "+ setpath+ " "+netStream1.bufferLength);
					exportbranchNum = branchNum;
					branchNum = 0;
					checkCounter = 0;
					playerpath = setpath;
					branch_prefetchPath = new Array;
					branch_prefetchPathShifted = new Array;
					firsttime=0;
					seeking=false;
					Buffer=0;
				}
			}	
			else{
			}		
		}
		
		private function playerpath_adhoc(num:Number):void
		{
			var hold:String = (Math.round(num/4)).toString();
			var concatdummy:String = " ";		
			var concattemp:String = concatdummy.concat(hold);
			playerpath = playerpath.concat(concattemp);
		}
		
		private function bufferTimeChangeStart(newTime:Number):void
		{
			netStream1.bufferTime = newTime;
			var myTimer1:Timer = new Timer(4000, 1); // reset to original value 
			myTimer1.addEventListener(TimerEvent.TIMER, resetbufferTime);
			myTimer1.start();
		}
		
		private function resetbufferTime(event:TimerEvent):void
		{
			netStream1.bufferTime = 4;
		}
		
		public function displaytime(event:TimerEvent):void
		{
			try
			{
				var tid:Number=Math.floor(netStream1.time);
				logger.debug("current time "+tid);
			}
			catch(error:Error)
			{
			}
		}
		
//		Decreases the calculated buffer occupancy by 1 fragment when playback of a fragment is initiated 
		public function decreaseBuffer(frag:Number):void
		{
			if(prevfrag!=frag){
				Buffer-=(runtable[frag-1]/1000);
				logger.debug("adding buffer removing "+Buffer+ " "+frag);
				prevfrag=frag
			}
		}
		
		public function gettime():Number
		{
			var now:Date = new Date();
			var epoch:Number = Math.round(now.valueOf()/1000);
			var epoch1:Number = (now.valueOf());
			return epoch1;
		}
		
		private function checkdonepath(path:String):Boolean
		{
			for(var i:uint=0; i<donePath.length;i++){
				if(donePath[i] == path){
					return true;
				}
			}
			return false;
		}
		
		private function checkavail(path:String):Boolean
		{
			for(var i:uint=0; i<availablepaths.length;i++){
				if(availablepaths[i] == path){
					return true;
				}
			}
			return false;
		}
		
		public function receiveFraginfo(fragDet:String,lastQuality:String):void
		{
			var max:int = fragDet.indexOf("Frag");
			lastfragment = fragDet.substring(max+4);
			lastquality = lastQuality;
		}
		
		public function receiveFraginfoalt(fragDet:Number):void
		{
			lastfragment = fragDet.toString();
		}
		
//		Checks playtime to seek
		public function compareFraginSec(fragNum1:Number):Boolean
		{
			checkCounter = 0;
			if( fragNum1 >= (decPoints[jumpCount]*4))
			{ 
				return true;
			}
			if(((decPoints[jumpCount]*4) - fragNum1 <= 0.5)) // <= value needs tuning at times
			{
				checkCounter++;
				return true;
			}
			return false;
		}
		
		public function receiveInfo(path:String):void{
			playpath1= path;
		}
			
		public function wheretoJump(playTime:int):void
		{
			for(var loop:uint=0; loop < availablepaths.length; loop++){
				if(availablepaths[loop] == playerpath){
					jumpCount = loop;
					var min:uint = 500000;
					var holding:Array = new Array;
					var indexofholding:uint = 0;
					for(var i:uint=0; i < all_jump_paths.length; i++){
						if(all_jump_paths[i].indexOf(playerpath) >= 0){
							var temp:String = all_jump_paths[i].substring(1);
							var current_value:Array = temp.split(" ");
							var lenof:int= current_value.length;
							if(lenof == min){
								indexofholding++;
								holding[indexofholding] = i;
							}
							if(lenof < min){
								min = lenof;
								holding[0] = i;
							}
						}
					}
					jump_array = new Array;
					for(var r:uint=0; r <= indexofholding; r++){
						var anothertemp:String = all_jump_paths[holding[r]].substring(1);
						var onemore:Array = anothertemp.split(" ");
						jump_array[r] = onemore[onemore.length-1];
					}
				}
			}
		}
		
		public function getBranch():Boolean
		{
			timePass = netStream1.time;
			return branchLeft;	
		}
			
		public function checkfragmentsdict(number:uint):Boolean
		{
			if(fragments[number] == null){
				return false;
			}
			return true;
		}
		
		public function returnPlayerpath():String
		{
			return playerpath;
		}
		
//		Includes both used and unused fuctionality
		public function setCurrentFrag(num:Number):void
		{
			subtract = 0;
//			logger.info("last frag " + lastfragment + "num "+ num);
			CONFIG::LOGGING
			{
				doneOnce = false;
			}
			if(num != donot_add){
				var concatdummy:String = " ";
				concatdummy = concatdummy.concat(num);
				playerpath = playerpath.concat(concatdummy);
				concatdummy = " ";
				logger.debug("playerpath"+ playerpath);	
				prevFrag = lastfragment;
				wheretoJump(num);
			}
			currentFrag = Number(num);
//			popup alert to indicate upcoming branch..incomplete functionality
			for(var cnt:uint = 0; cnt < decPoints.length; cnt++)
			{
				if(currentFrag == decPoints[cnt])
				{
					var event:Event = new Event("showAlert");
					dispatchEvent(event);
				}
			}
			var futureOnefrag:int = (currentFrag+1);
			var futureTwofrag:int = (currentFrag+2);
			var dummy:String = " ";
			var intermediate:String = playerpath.concat(dummy);
			var intermediate1:String = intermediate.concat(futureOnefrag.toString());
			var intermediate2:String = intermediate1.concat(dummy);
			futurepath = intermediate2.concat(futureTwofrag.toString());
			{
				var current_estimate:uint = (DefaultHTTPStreamingSwitchManager.givebitRate())/1024;
				qualityinbytes = Number(lastquality);
				var whichq1:Number = checkparallelquality();			
				var prefetch:Array = compareFragalternate(currentFrag.toString());
				if(prefetch[0] != null && prefetchPath.indexOf(prefetch[0]) < 0 && pathcheck(prefetch[0]) == true){
					subtract = subtract+(whichq1*1000);
					prefetchPath.push(prefetch[0]);
					branch_prefetchPath.push(Number(prefetch[0]));
					dloadTimerbegin3 = gettime();
					if(whichq1 == 0.25)
						prefQ3 = 0;
					else if(whichq1 == 0.5)
						prefQ3 = 1;
					else if(whichq1 == 0.85)
						prefQ3 = 2;
					else if(whichq1 == 1.3)
						prefQ3 = 3;
					prefF3 = prefetch[0];
					parallel_frag.push(prefetch[0]);
					parallel_quality.push(whichq1);
				}
			}		
			var whichq:Number = checkparallelquality();
			if(prefetch.length > 1){
				subtract = subtract+(whichq*1000);
				for(var i:uint=1; i < prefetch.length; i++){
					if(prefetchPath.indexOf(prefetch[i]) < 0 && pathcheck(prefetch[i]) == true){
						prefetchPath.push(prefetch[i]);
						branch_prefetchPath.push(Number(prefetch[i]));
						dloadTimerbegin4 = gettime();
						if(whichq == 0.25)
							prefQ4 = 0;
						else if(whichq == 0.5)
							prefQ4 = 1;
						else if(whichq == 0.85)
							prefQ4 = 2;
						else if(whichq == 1.3)
							prefQ4 = 3;
						prefF4 = prefetch[i];
						parallel_frag.push(prefetch[i]);
						parallel_quality.push(whichq);
					}
				}
			}
		}
		
		public function subtractreturn():uint
		{
			return subtract;
		}
		
		public function requestotherBranchfrag(req:URLRequest, num:Number):void
		{
			var strReq1:HTTPStreamRequest = new HTTPStreamRequest(HTTPStreamRequestKind.DOWNLOAD, req.url);
			var urlReq1:URLStream = new URLStream();
			urlReq1.addEventListener(Event.COMPLETE, onComplete);
			urlReq1.load(strReq1.urlRequest);
			fragments[num] = urlReq1;
		}
		
		public function returnPrefetchpath():Array
		{
			return prefetchPath;
		}
			
		public function calculatefragSize():void
		{
			for(var i:uint=1;i<runtable.length;i++){
				sizearray_250[i] = ((runtable[i-1]/1000)*250);
				sizearray_500[i] = ((runtable[i-1]/1000)*500);
				sizearray_850[i] = ((runtable[i-1]/1000)*850);
				sizearray_1300[i] = ((runtable[i-1]/1000)*1300);
			}
		}
		
		public function pushtoStreamdownloader(Estimate:uint,FragRate:uint):void
		{
			estimate = Estimate;
			fragRate = FragRate;
		}
		
		public function receiveEstimateforStreamdownloader():int
		{
			return estimate;
		}
		
		public function receiveglobalAvgforStreamdownloader():Number
		{
			return global_avg;
		}
		
		public function receiveFragrateforStreamdownloader():int
		{
			return fragRate;
		}
		
		public function receiveRuntableforStreamdownloader():Array
		{
			return runtable;
			
		}
		
		public function receiveTimeStreamdownloader():Number
		{
			return netStream1.time;
		}
		
//		sets quality based on configuration..Unused now
		public function checkparallelquality():Number
		{
			if(fileContent1 == "0.25"){
				return 0.25;
			}
			if(fileContent1 == "0.5"){
				return 0.5;
			}
			if(fileContent1 == "0.85"){
				return 0.85;
			}
			if(fileContent1 == "1.3"){
				return 1.3;
			}
			if(fileContent1 == "dynamic"){
				if(prefetchingquality == 0)
					prefetchingquality = 0.25;
				return prefetchingquality;
			}
			if(fileContent1 == "dynamic-1"){
				if(prefetchingquality == 0.25)
					return 0.25;
				if(prefetchingquality == 0.5)
					return 0.25;
				if(prefetchingquality == 0.85)
					return 0.5;
				if(prefetchingquality == 1.3)
					return 0.85;
			}
			if(fileContent1 == "lastq"){
				return Number(lastquality);
			}
			return prefetchingquality;
		}
		
		public function setprefetchquality(quality:Number):void
		{
			prefetchingquality = quality;
		}
		
		
		public function findLandpoint():void
		{
			for(var loop:uint=0; loop < availablepaths.length; loop++){
				if(availablepaths[loop] == futurepath){
					landNumber = loop;
				}	
			}			
		}
		
		// Iterates through all decision points to find the message corresponding to
		// the fragment being downloaded. Must be extended to provide more intuitive messages before the branch point
		public function getMessage():String
		{
			var cnt:uint = 0;
			while(cnt < messages.length)
			{
				if(decPoints[cnt] == currentFrag)
					break;
				cnt++;
			}
			return "Message";
		}
		
		// Returns a fragment from the vector of prefetched fragments. 
		public function getFragment(id:int):URLStream
		{
			if(fragments[id] != null)
			{
				return fragments[id];
			}
			return null;
		}
		
//		Helper function for fragment scheduling
		public function compareFragExtrapolate():Array
		{
			var splitString:String = "";		
			var returnthis:Array = extrapolatepath();
			return returnthis;
		}
		
		private function extrapolatepath():Array
		{
			var holding:Array = new Array;
			for(var index:uint=0; index < all_jump_paths.length; index++){
				if(all_jump_paths[index].indexOf(playerpath) >= 0){
					holding.push(all_jump_paths[index]);
				}
			}
			var bestPrefetch:Array= findnearest(holding);
			return bestPrefetch;
		}
		
		private function findnearest(hold:Array):Array
		{
			var x:Array=new Array;
			var min:uint=9999;
			var min1:uint=9999;
			var y:Array=new Array;
			for(var i:uint;i<hold.length;i++){
				var temp:Array= hold[i].split(" ");
				if(temp.length <= min){
					x.push(hold[i]);
					min = temp.length;
				}
			}
			for(var j:uint=0;j<x.length;j++){
				var temp1:Array=x[j].split(" ");
				y.push(Number(temp1[temp1.length-1]));
			}
			return y;
		}
		
//		Doesn't impact MM 2014 paper, this is overriden further downstream
		public function compareFragalternate(fragNum:String):Array
		{
			var splitString:String = "";
			var compare:Array = new Array;
			var indexofcompare:uint = 0;
			carryfragnum = Number(fragNum)+1; 		//sets the variable for switch manager routines
			for(var index:uint=0; index < all_jump_paths.length; index++){
				if(all_jump_paths[index].indexOf(playerpath) >= 0){ // DISABLES PREFETCHING FROM OTHER BRANCHES
					var a:Array = all_jump_paths[index].split(" ");
					splitString = a[a.length-int(fileContent2)];// CONTROLS NUMBER PREFETCH BEFORE 4 or 5
					if(splitString == fragNum)
					{
						compare[indexofcompare] = a[a.length-1];
						indexofcompare++
					}
				}
			}
			return compare;
		}
		
		public function retcurrfrag():Number
		{
			return carryfragnum;
		}
			
		
		// Parses the text file downloaded in the constructor
		private function processFile(event:Event):void
		{
			
			var loader:URLLoader = URLLoader(event.target);
			fileContent = loader.data;
			var tempStr:String = fileContent.substr(0, fileContent.indexOf(lineBreakOS));
			var start:Number = fileContent.indexOf("length:");
			tempStr = fileContent.substring((start + 8), fileContent.indexOf(lineBreakOS, start));
			var nums:Array = new Array;
			nums = tempStr.split(" ");
			for(var numNums:uint = 1; numNums < nums.length; numNums++)
			{
				branchLengths.push(nums[numNums]);
			}
			var fragof:Array = new Array;
			var prevVal:uint = 1;
			var concat1:String = "";
			var concatdummy:String = " ";
			for(var k:uint=0; k < branchLengths.length; k++){
				for(var g:uint=prevVal; g<branchLengths[k]+prevVal; g++){
					var h:String = g.toString();
					concatdummy = concatdummy.concat(h);
					concat1 = concat1.concat(concatdummy);
					concatdummy = " ";
				}
				prevVal = g;
				fragof.push(concat1);
				concat1 = "";
			}
			var startTree:Number = fileContent.indexOf("begin ");
			var endTree:Number = fileContent.indexOf("end" + lineBreakOS, startTree);		
			var dec:Number = 0;
			var dec1:Number = 0;
			tempStr = fileContent.substring(startTree+6, endTree);
			var split:Array = new Array;
			split = tempStr.split(lineBreakOS);			
			var pathsofar:String = "";
			var branchPars:Array = new Array;
			for(var treeNum:uint=0; treeNum < split.length; treeNum++)
			{
				var temp1:String = split[treeNum].toString();
				for(var splitNum:uint=0; splitNum <= temp1.length; splitNum++)
				{
					if(temp1.charAt(splitNum) == ",")
					{
						var cnt:int = splitNum + 1;
						while(!isNaN(Number(temp1.charAt((cnt)))) && cnt < temp1.length && temp1.charAt(cnt) != " ")
						{
							cnt++;
						}
						var land:uint = 0;
						var parsNum:Number = Number(temp1.substring(splitNum+1, cnt));
						for(var sumCnt1:uint = 0; sumCnt1 < (parsNum-1); sumCnt1++)
						{
							land += branchLengths[sumCnt1];
							var a:uint = land+1;
						}
						if(land != 0)
							landPoints.push(land+1);
					}
					if(temp1.charAt(splitNum) == "," && temp1.charAt(splitNum-2) == "(")
					{
						var cnt1:int = splitNum - 1;
						while(!isNaN(Number(temp1.charAt((cnt1)))) && cnt1 < temp1.length && temp1.charAt(cnt1) != " ")
						{
							cnt1++;
						}
						var noland:uint = 0;
						var parsNum1:Number = Number(temp1.substring(splitNum-1, cnt1));
						for(var sumCnt2:uint = 0; sumCnt2 < parsNum1 -1; sumCnt2++)
						{
							noland += branchLengths[sumCnt2];
						}
						if(noland != 0)
							nolandPoints.push(noland+1); 
					}
					if(temp1.charAt(splitNum) == "("){
						var cnt2:int = splitNum - 1;
						while(!isNaN(Number(temp1.charAt((cnt2)))) && cnt2 < temp1.length && temp1.charAt(cnt2) != " ")
						{
							cnt2++;
						}
						var branch:uint = 0;
						land =0;
						var parsNum2:String = temp1.substring(0, cnt2);
						branchPars.push(parsNum2);
						var cnt3:int=splitNum+1;						
						while(!isNaN(Number(temp1.charAt((cnt3)))) && cnt3 < temp1.length && temp1.charAt(cnt3) != " ")
						{
							cnt3++;
						}					
						var parsNum4:Number = Number(temp1.substring(splitNum+1, cnt3));
						for(var sumCnt4:uint = 0; sumCnt4 < (parsNum4-1); sumCnt4++)
						{
							land += branchLengths[sumCnt4];						
							var b:uint = land+1;
						}
						if(land != 0)
							firstlandPoints.push(land+1);
						
					}
				}
							
				for(var outervar:uint = 0; outervar <= temp1.length; outervar++)
				{
					if(temp1.charAt(outervar) == "(" && !isNaN(Number(temp1.charAt(outervar-1))) && outervar != 0){
						dec = Number(temp1.charAt(outervar-1));					
						for(var sumCnt:uint = 0; sumCnt <= dec-1; sumCnt++)
						{
							dec1 += branchLengths[sumCnt];
						}
						decPoints.push(Number(dec1));
						dec1=0;
					}
					
					if(temp1.charAt(outervar) == "(" && temp1.charAt(outervar-1)=="*" && outervar != 0){
						var star:int=(outervar-4);
						dec = Number(temp1.substring((star+1),(outervar-1)));					
						for(var sumCnt3:uint = 0; sumCnt3 <= dec-1; sumCnt3++)
						{
							dec1 += branchLengths[sumCnt3];
						}
						decPoints.push(Number(dec1));
						dec1=0;	
					}
				}
			}
			for(var j:uint=0; j < branchPars.length; j++){
				var upper:uint=1;
				var inter:String = branchPars[j].toString();
				for(var u:uint=0; u < inter.length; u++){
					if(inter.charAt(u)!="*" && inter.charAt(u-1)!="*" && inter.charAt(u-2)!="*"){
						var parsNum3:String = inter.substring(u, upper);
					}
					if(inter.charAt(u)=="*"){
						var temp:int=(u+1);
						var parsNum3:String = inter.substr(temp, 2);
						u++;
						u++;
					}
					pathsofar = pathsofar.concat(fragof[Number(parsNum3)-1]);
					upper++;
				}
				availablepaths.push(pathsofar);
				pathsofar = "";
			}
			
			for(var counter:uint=0; counter < split.length; counter++){
				var holding:String = split[counter].toString();
				for(var innercount:uint=0; innercount < holding.length; innercount++){
					if(holding.charAt(innercount) == "("){
						var openlocation:uint = innercount;						
					}					
					if(holding.charAt(innercount) == ")"){
						var closelocation:uint = innercount;
					}
				}
				var split_bracket:String = holding.substring(openlocation,closelocation+1);
				var only_branches:String = split_bracket.substring(1,split_bracket.length-1);
				if(only_branches.length > 1){
					var sub_only_branches:Array = only_branches.split(",");
					for(var aalt:uint=0; aalt < sub_only_branches.length; aalt++){
						var tempo1:Array = fragof[sub_only_branches[aalt]-1].split(" ");
						var blank1:String = " ";
						var firstAfterjump1:String = blank1.concat(tempo1[1]);
						var another_concat:String = availablepaths[counter].concat(firstAfterjump1);//fragof[sub_only_branches[a]-1]
						all_jump_paths.push(another_concat);
						another_concat = "";
					}
				}
				if(only_branches.length == 1){
					var tempo:Array = fragof[Number(only_branches)-1].split(" ");
					var blank:String = " ";
					var firstAfterjump:String = blank.concat(tempo[1]);
					var another_concat1:String = availablepaths[counter].concat(firstAfterjump);//fragof[Number(only_branches)-1]
					all_jump_paths.push(another_concat1);
					another_concat1 = "";
				}
			}
		
			var offset:int = 0;
			tempStr = fileContent.substr(fileContent.indexOf("r:"));
			while(offset < tempStr.length)
			{
				var num:Number = tempStr.substr(offset).indexOf(lineBreakOS);
				var msgStr:String = tempStr.substring(offset, offset + num);
				offset += msgStr.length + 3;
				message = msgStr.substring((msgStr.indexOf("r:") + 2), msgStr.indexOf("::"));
				message += ("\n" + msgStr.substring((msgStr.indexOf("l:") + 2)));
				messages.push(message);
			}
			var ev:Event = new Event(Event.COMPLETE);
			dispatchEvent(ev);
		}
		
//		Handles prefetching and fragment downloading..copies of parallel_pipe use different instances of URLStream to download in parallel.
		//##### COMMENTED OUT BY PROJECT GROUP 9 ######
		/*public function parallel_pipe_alt(frag:uint,rate:Number):void
		{
			trace("parallel_pipe_alt");
			if(parallelpipe_on_alt == false && downloadedlist[frag]==null){
				numberinParallel++;
				downloadedlist[frag]=frag;
				if(rate == 250)
					rate = 0.25;
				if(rate == 500)
					rate = 0.5;
				if(rate == 850)
					rate = 0.85;
				if(rate == 1300)
					rate = 1.3;
				var strReq2:HTTPStreamRequest = new HTTPStreamRequest(HTTPStreamRequestKind.DOWNLOAD, "http://"+URL+"final_"+rate+"Seg1-Frag" + (frag));
				var urlReq2:URLStream = new URLStream();
				prefestF1_alt = (frag);
				prefestQ1_alt = (rate*1000);
				fragmentQ[frag] =(rate*1000);
				urlReq2.addEventListener(Event.COMPLETE, onCompleteEst_alt);
				urlReq2.load(strReq2.urlRequest);  
				dloadTimerbeginest_alt = gettime();
				parallelpipe_on_alt = true;
				fragments[prefestF1_alt] = urlReq2;
			}
			else (parallel_pipe_alt1(frag,rate));
		}*/
		//######## COMMENTED OUT BY PROJECT GROUP 9 ##########
		/*public function parallel_pipe_alt1(frag:uint,rate:Number):void
		{
			trace("parallel_pipe_alt1");
			if(parallelpipe_on_alt1 == false && downloadedlist[frag]==null){
				numberinParallel++;
				downloadedlist[frag]=frag;
				if(rate == 250)
					rate = 0.25;
				if(rate == 500)
					rate = 0.5;
				if(rate == 850)
					rate = 0.85;
				if(rate == 1300)
					rate = 1.3;
				var strReq2:HTTPStreamRequest = new HTTPStreamRequest(HTTPStreamRequestKind.DOWNLOAD, "http://"+URL+"final_"+rate+"Seg1-Frag" + (frag));
				var urlReq2:URLStream = new URLStream();
				prefestF1_alt1 = (frag);
				prefestQ1_alt1 = (rate*1000);
				fragmentQ[frag] =(rate*1000);
				urlReq2.addEventListener(Event.COMPLETE, onCompleteEst_alt1);
				urlReq2.load(strReq2.urlRequest);  
				dloadTimerbeginest_alt1 = gettime();
				parallelpipe_on_alt1 = true;			
				fragments[prefestF1_alt1] = urlReq2;
			}else{
				parallel_pipe_exc(frag,rate);
			}
		}*/
		
		//###### COMMENTED OUT BY PROJECT GROUP 9 #########
		/*public function parallel_pipe_exc(frag:uint,rate:Number):void
		{
			trace("parallel_pipe_exc");
			if(parallelpipeexc_on == false && downloadedlist[frag]==null){
				parallelpipeexc_on = true;
				numberinParallel++;
				downloadedlist[frag]=frag;
				if(rate == 250)
					rate = 0.25;
				if(rate == 500)
					rate = 0.25;
				if(rate == 850)
					rate = 0.5;
				if(rate == 1300)
					rate = 0.85;
				var strReq2:HTTPStreamRequest = new HTTPStreamRequest(HTTPStreamRequestKind.DOWNLOAD, "http://"+URL+"final_"+rate+"Seg1-Frag" + (frag));
				var urlReq2:URLStream = new URLStream();
				prefestF1_exc = (frag);
				prefestQ1_exc = (rate*1000);
				fragmentQ[frag] =(rate*1000); 
				urlReq2.addEventListener(Event.COMPLETE, onCompleteEst_exc);
				urlReq2.load(strReq2.urlRequest);
				dloadTimerbeginest_exc = gettime();
				fragments[prefestF1_exc] = urlReq2;
			}
			else if(downloadedlist[frag]==null){
				logger.debug("Missed this "+ frag);
				missed_fragments.push(frag);
				missed_quality.push(rate);
				parallel_pending=true;
			}
		}*/
		
		public function onCompleteEst_exc(event:Event):void
		{
			dloadTimerendest_exc = gettime();
			parallelpipeexc_on = false;
			time_download[prefestF1_exc] = (dloadTimerendest_exc-dloadTimerbeginest_exc)/1000;
			quality_download[prefestF1_exc] = prefestQ1_exc;
			logger.debug("download info "+ time_download[prefestF1_exc]+ " "+ quality_download[prefestF1_exc]+ " "+prefestF1_exc);
			numberinParallel--;
			var estimate:Number = (((fragments[prefestF1_exc].bytesAvailable)*8/1000)/((dloadTimerendest_exc-dloadTimerbeginest_exc)/1000));
			Buffer+=(runtable[prefestF1_exc-1]/1000);
			if(numberinParallel!=0)
				estimate=estimate*numberinParallel;
			calculate_avg(estimate);			
			if(seeking==false)
				checkandschedule(global_avg,maxinParallel);
		}
		
		private function dummy(event:TimerEvent):void
		{
			/*trace("parallelpipe_on (false): " + parallelpipe_on);*/
			//netStream1.seek(prevMediaPlayer.currentTime);
			//##### Hard coded BY PROJECT GROUP 9 #############
			if(estimate == 0){
				estimate = 1300;
			}
			
			try
			{
				//##### COMMENTED OUT "&& netStream1.time>2 && estimate != 0"  BY PROJECT GROUP 9 #####
				if(parallelpipe_on_alt == false && parallelpipe_on_alt1 == false && parallelpipe_on == false && parallelpipeexc_on == false && netStream1.time>2 && estimate != 0 && seeking==false){
					if(global_avg!=0){
						trace("checkandschedule(global_avg,maxinParallel)");
						checkandschedule(global_avg,maxinParallel);
					}else{
						trace("checkandschedule(estimate,maxinParallel)");
						checkandschedule(estimate,maxinParallel);
					}
				}
			}
			catch(error:Error)
			{
				trace("dummy");
				trace("Some error occured: " + error.message);
			}
		}
		
		public function parallel_pipe(frag:uint,rate:Number):void
		{
			if(parallelpipe_on == false && downloadedlist[frag]==null){
				numberinParallel++;
				downloadedlist[frag]=frag;
				if(rate == 250)
					rate = 0.25;
				if(rate == 500)
					rate = 0.5;
				if(rate == 850)
					rate = 0.85;
				if(rate == 1300)
					rate = 1.3;
				
				var strReq2:HTTPStreamRequest = new HTTPStreamRequest(HTTPStreamRequestKind.DOWNLOAD, "http://"+URL+"final_"+rate+"Seg1-Frag" + (frag));
				trace("http://"+URL+"final_"+rate+"Seg1-Frag" + (frag));
				var urlReq2:URLStream = new URLStream();
				prefestF1 = (frag);
				prefestQ1 = (rate*1000);
				fragmentQ[frag] =(rate*1000); 
				urlReq2.addEventListener(Event.COMPLETE, onCompleteEst);
				urlReq2.load(strReq2.urlRequest);  
				dloadTimerbeginest = gettime();
				parallelpipe_on = true;
				fragments[prefestF1] = urlReq2;
			}
			//##### COMMENTED OUT BY PROJECT GROUP 9 #####
			/*else (parallel_pipe_alt(frag,rate));*/
		}
		
		
		
		public function calculate_avg(est:Number):void
		{
			if((global_avg != 0 || current_est != 0) && est != Infinity){				
				global_avg = (alpha*current_est)+((1-alpha)*est);
				current_est = global_avg;
				logger.debug("Rolling avg :1 "+ global_avg);
			}		
			if(global_avg == 0 || current_est == 0){
				current_est = est;
				global_avg = current_est;
				logger.debug("Rolling avg :2 "+ global_avg);
			}
			if(est == Infinity){
				logger.debug("Rolling avg :3 "+ global_avg);
			}
		}
		
		public function onCompleteEst(event:Event):void
		{
			dloadTimerendest = gettime();
			parallelpipe_on = false;
			time_download[prefestF1] = (dloadTimerendest-dloadTimerbeginest)/1000;
			quality_download[prefestF1] = prefestQ1;
			logger.debug("download info "+ time_download[prefestF1]+ " "+ quality_download[prefestF1]+ " "+prefestF1);
			numberinParallel--;
			var estimate:Number = (((fragments[prefestF1].bytesAvailable)*8/1000)/((dloadTimerendest-dloadTimerbeginest)/1000));
			Buffer+=(runtable[prefestF1-1]/1000);
			if(numberinParallel!=0)
				estimate=estimate*numberinParallel;
			calculate_avg(estimate);			
			if(seeking==false)
				checkandschedule(global_avg,maxinParallel);
		}
		
		public function checkfirstlandpoint(number:uint):Boolean
		{
			for(var i:uint=0;i<firstlandPoints.length;i++){
				
				if(number==firstlandPoints[i]){
					return true;
				}
			}
			return false;
		}
		
//		The following are the policy names used in the codes and the names with which they appear in the paper.
//		enhancebandwidth=>Greedy bandwidth
//		newoptimize=>Optimized non-increasing quality
//		enhanceq=>Optimized maintainable quality
		private function enhanceBandwidth(connection:Array,quality:Array):int
		{
			var nettBw:Array=new Array;
			for(var bwLoop:int=0; bwLoop<connection.length-1;bwLoop++){
				nettBw[bwLoop] = connection[bwLoop]*quality[bwLoop];
			}
			return findmax(nettBw);
			
		}
		
		private function newoptimize(connection:Array,quality:Array):int
		{
			return 0;
		}
		
		private function enhanceQ(connection:Array,quality:Array):int
		{
			var maxVal:Number = 0;
			var maxValIndex:Array = new Array;
			var maxConn:Number=0;
			var holding:Number=0;			
			for(var i:Number = 0; i < quality.length; i++){
				if(quality[i] > maxVal){
					maxVal = quality[i];
				}
			}			
			for(var j:Number = 0; j < quality.length; j++){
				if(quality[j] == maxVal)
					maxValIndex.push(j);
			}
			for(var k:Number=0; k< maxValIndex.length;k++){
				var x:int=maxValIndex[k];
				if(connection[x] > maxConn){
					maxConn=connection[x];
					holding = x;
				}
			}			
			if(qmax_saveq!=0 && (qmax_saveq-maxVal)>=2 && numberinParallel>1){
				return 100;
			}		
			qmax_saveq=maxVal;
			qmax_savec=maxConn;
			return holding;
		}
		
		private function findmax(est:Array):int
		{
			var max:int=0;
			var index:int=0;
			for(var i:uint=0;i<est.length;i++){
				if(est[i]>max){
					max = est[i];
					index = i;
				}
			}
			return index;
		}
		
		
		private function findmax_alt(est:Array):int
		{
			var max:int=0;
			var index:int=0;
			for(var i:uint=0;i<est.length;i++){
				if(est[i]>=max){
					max = est[i];
					index = i;
				}
			}
			return index;
		}
		
		//######### COMMENTED OUT BY PROJECT GROUP 9 ############
	/*	private function calculateBranchfrags(decpoint:int):void
		{
			branchArray=new Array;
			for(var i:uint=0;i<all_jump_paths.length;i++){
				var temp:Array=all_jump_paths[i].split(" ");
				if(temp[temp.length-2]==decpoint){
					match_array=new Array;
					for(var j:uint=1;j<temp.length-1;j++){
						match_array.push(temp[j]);
					}
					if(branchArray.indexOf(temp[temp.length-1])<0)
						branchArray.push(temp[temp.length-1]);					
				}			
			}	
		}*/
		
//		Calculate completion times based on current bandwidth
		public function calcexpectedcompletion_alt(size:uint,esti:Number,frag_num:uint):Number
		{
			var comp_time:Number = size/esti;
			storedtime+=comp_time;
			return storedtime;
		}
		
		private function calculateparams():void
		{
			var B:int=branchArray.length;
			DesiredMin= (buf_min*B);
			DesiredMax=((buf_min*B)+buf_margin);
		}
				
		private function checkconstraint(curs:Array):Boolean
		{
			for(var i:uint=0;i<curs.length-1;i++){
				if(curs[i]>=curs[i+1]){
					//					trace("ok");
				}else{
					return false;
				}
			}
			return true;
		}
		
		public function subsetFill(values:Array, cursor:Array, result:Array, length:uint):void {
			if (cursor.length > length) {
				return;
			}
			if (cursor.length == length) {
				if(checkconstraint(cursor)==true)
					result.push(cursor.slice());
			}
			
			var i:uint, len:uint = values.length;
			
			for (i; i < len; ++i) {
				cursor.push(values[i]);
				subsetFill(values, cursor.slice(), result, length);
				cursor.length = cursor.length - 1;
			}
		}
		
		//Auxiliary method for tracing 
		public function prettyPrint(list:Array):void {
			var i:uint, len:uint = list.length;	
			for (i; i < len; ++i) {
				trace(list[i]);
			}
		}
		
		public function calculate_bytes(inparray:Array,doarray:Array,bw:Number):Number
		{
			var file:Array=new Array;
			var bytes:int=0;
			for(var i:uint=0;i<inparray.length;i++){
				if(inparray[i]==1300)
					file = sizearray_1300;
				else if(inparray[i]==850)
					file = sizearray_850;
				else if(inparray[i]==500)
					file = sizearray_500;
				else if(inparray[i]==250)
					file = sizearray_250;
				
				bytes = bytes+(file[doarray[i]]);
			}
			var tempo:Number=bytes/(bw);
			return tempo;
		}
		
		public function remove(array:Array,length1:int,length2:int):Boolean
		{
			for(var i:uint=length1;i<length2;i++){
				if(array[i]==250){
					//trace("ok")
				}else{
					return false;
				}
			}
			return true;
		}
		
		
		public function purgearray(combo:Array,branch:Array,todo:Array):Array
		{
			var purged:Array=new Array;
			for(var sub_index:uint=0;sub_index<combo.length;sub_index++){
				var combi:Array=combo[sub_index];
				if(remove(combi,todo.length-branch.length,todo.length)==true){
					purged.push(combi);
				}
			}
			return purged;
		}
		
		public function calculatesum(input:Array,todo:Array,branchlength:Array):Number
		{
			var sum:Number=0;
			var value:int=0;			
			for(var i:uint=0;i<input.length;i++){
				var weight:Number=1;
				if(input[i]==1300)
					value=4
				if(input[i]==850)
					value=3
				if(input[i]==500)
					value=2
				if(input[i]==250)
					value=1
				if(i >= (todo.length-branchlength.length))
					weight=(value/branchlength.length);				
				sum = sum+(value*weight);
			}
			return sum;
		}
		
		public function calculatebest(input:Array,todo:Array,branchlength:Array):int
		{
			var sumarray:Array=new Array;
			for(var sub_index:uint=0;sub_index<input.length;sub_index++){
				var combi:Array=input[sub_index];
				sumarray.push(calculatesum(combi,todo,branchlength));				
			}
			var index:int=findmax_alt(sumarray);
			return index;
		}
		
		public function calculatebest_alt(index1:int,index2:int,input1:Array,input2:Array,todo:Array,branchlength:Array):int
		{
			var sumarray:Array=new Array;			
			var array1:Array=input1[index1];
			var array2:Array=input1[index2];			
			var sum1:Number=calculatesum(array1,todo,branchlength);
			var sum2:Number=calculatesum(array2,todo,branchlength);
			if(sum1>=sum2){
				return 1;				
			}else{
				return 0;
			}
			return 1;
		}
		
		private function anotherFill(arr:Array,len:int,subsetTest:Array)
		{
			var quality:int=0;
			var qVect:Array=new Array
			for(var i:uint=0;i<=len;i++){
				for(var j:uint=i;j<=len;j++){
					for(var k:uint=j;k<=len;k++){
						for(var index:uint=1; index<=len; index++){
							quality = 1300;
							if(index<=i ){
								quality = 1300;
							}else if(index<=j ){
								quality = 850;
							}else if(index<=k ){
								quality = 500;
							}else{
								quality = 250;
							}
							qVect.push(quality)
						}
						subsetTest.push(qVect);
						qVect=new Array;
					}
				}
			}
		}
		
		
//		Function responsible for downloading and prefetching. Reads configuration parameter from a file on hard disk and calls other functions based on configuration. 
//		Also regulates ON and OFF states based on buffer occupancy
		public function checkandschedule(avg:Number, max:int):void
		{		
			trace("checkandschedule");
			//next_dec=calculate_decisionpoint(netStream1.time);
			//calculateBranchfrags(next_dec);
			calculateparams();
			switch(BufferStatus){
				case "download":			
					if(to_downloadlist.length == 0 )
					{
						var numberRemaining:uint = maxinParallel - (numberinParallel-1);
						if((DesiredMin-Buffer)<buf_margin){
							numberRemaining=1;
						}
						var fragment:uint = (streamdownloadedlist[streamdownloadedlist.length-1]+1);
						if(downloadedlist.indexOf(fragment)>=0)
							fragment = (downloadedlist[downloadedlist.length-1]+1);
						var file:Array=new Array;
//						newenhance=>Optimized non-increasing quality
						if(mode == "new_enhance"){
							var to_do_alt:Array=new Array;	
							var branch_len:Array=new Array;
							var count:uint=0;
							if(match_array.indexOf(fragment.toString()) >= 0)
								var remaining_frags:int=match_array.length-match_array.indexOf(fragment.toString());
							for(var k:uint=match_array.indexOf(fragment.toString());k<match_array.length;k++){
								to_do_alt.push(match_array[k]);
								count++;
							}
							if(count!=0){
								var remaining_branch:int=(branchArray.length);				
								for(var j:uint=0;j<branchArray.length;j++){
									to_do_alt.push(branchArray[j]);
									branch_len.push(branchArray[j]);
								}
							}
							if(to_do_alt.length>0){
								var subsetTest:Array = [];
								anotherFill(quality_array,to_do_alt.length,subsetTest);
								var purgedarray:Array=subsetTest;
								var possibleArray1:Array=new Array;
								var possibleArray2:Array=new Array;								
								for(var sub_index:uint=0;sub_index<purgedarray.length;sub_index++){
									var combi:Array=purgedarray[sub_index];
									for(var loop2:uint=1; loop2<=Math.min(2,numberRemaining); loop2++){
										var a1:Number=calculate_bytes(combi,to_do_alt,(avg/loop2));
										var b1:Number=(frag_deadline[match_array[match_array.length-1]]/1000);
										if((netStream1.time+a1) < (b1)){
											if(loop2==1)
												possibleArray1.push(combi);
											if(loop2==2)
												possibleArray2.push(combi);
										}
									}
								}
								var index1:int = calculatebest(possibleArray1,to_do_alt,branch_len);
								var index2:int = calculatebest(possibleArray2,to_do_alt,branch_len);								
								var choice:int=calculatebest_alt(index1,index2,possibleArray1,possibleArray2,to_do_alt,branch_len);								
								if(choice==1){
									var qual:uint=possibleArray1[index1][0];
									var num:uint=1;
									qSwitcher=false;
								}
								if(choice==0){
									var qual:uint=possibleArray2[index2][0];
									var qual_alt:uint=possibleArray2[index2][1];
									var num:uint=2
									qSwitcher=true;
								}				
								logger.debug("CHOICE "+quali+ " "+num);
							}
						}
						if(mode != "new_enhance"){
							for(var quality:uint=quality_array.length;quality>0;quality--){
								storedtime=0;
								if(quality==4)
									file = sizearray_1300;
								else if(quality==3)
									file = sizearray_850;
								else if(quality==2)
									file = sizearray_500;
								else if(quality==1)
									file = sizearray_250;
								
//								allow increasing by number of active connections by 1 only
								for(var loop:uint=1; loop<=Math.min(2,numberRemaining); loop++){
									var a:Number=(calcexpectedcompletion(file,(avg/loop),(fragment+loop-1),loop,quality));
									var b:Number=(frag_deadline[match_array[match_array.length-1]]/1000);
									if((netStream1.time+a) < (b-minus_calc)){
										if((netStream1.time+(calcexpectedcompletion_alt(file[(fragment+loop-1)],avg/loop,(fragment+loop-1)))) < ((frag_deadline[fragment+loop-1]/1000)-minus_calc) && ((avg/loop)>quality_array[quality-1]))
										{
											possibles_connection.push(loop);
											possibles_quality.push(quality)
											logger.debug("result "+(netStream1.time+a)+" "+ b+ " "+avg);
										}
									}
								}
							}
						}
//						bw_enhance=>Greedy bandwidth						
						if(mode == "bw_enhance"){
							var index_var:int = enhanceBandwidth(possibles_connection,possibles_quality);
						}
//						q_enhance=>Optimized maintainable quality
						if(mode == "q_enhance"){
							var index_var:int = enhanceQ(possibles_connection,possibles_quality);
						}
						if(mode != "new_enhance"){
							var num:uint = possibles_connection[index_var];
							var qual:uint = quality_array[possibles_quality[index_var]-1];
							possibles_connection=new Array;
							possibles_quality=new Array;
						}
						logger.debug("decision "+ num + " "+ qual+ " "+fragment + " "+avg+ " "+numberinParallel);
						if(num==0 && (match_array.indexOf((fragment+1).toString()) < 0))
							num=1;					
						if(num!=0)
						{
							for(var i:uint=0;i<num;i++){
								if(qual==0)
									qual=250;
								if(qSwitcher==true && i>1)
									qual=qual_alt;
								if(next_dec >= ((fragment+i)))
								{
									var holding:uint = Math.round(netStream1.time/4);
									{
										if(fragmentQ[(fragment+i)] == null){
											to_downloadlist.push((fragment+i));
											to_qualitylist.push(qual);
											if(streamdownloadedlist.indexOf((fragment+i))<0)
												streamdownloadedlist.push((fragment+i))
										}
										else if(fragmentQ[(fragment+i)] != null && checkfirstlandpoint(fragment+i+1)!= true){
											to_downloadlist.push((fragment+i+1));
											to_qualitylist.push(qual);
											if(streamdownloadedlist.indexOf((fragment+i))<0)
												streamdownloadedlist.push((fragment+i))
										}
										blocker = true; 
									}
								}
								branch_prefetchPath = compareFragExtrapolate();
								if(next_dec < (fragment+i) && stream_downloaded < branch_prefetchPath[0]){
									if(branch_prefetchPathShifted.length > 0 && (branch_prefetchPathShifted.length == branch_prefetchPath.length))
										branch_prefetchPath = branch_prefetchPathShifted;
									{
										for(var x:uint=0; x<branch_prefetchPath.length;x++){
											if(isNaN(branch_prefetchPath[x]))
												branch_prefetchPath.splice(x,1);
										}
									}
									var quali:uint = calculate_prefetch_quality(qual,branch_prefetchPath[0]);
									if(quali != 0){
										qual = quali;
									}							
									for(var index:uint=0;index<Math.min(2,numberRemaining);index++){
										to_move++;
										if(fragmentQ[branch_prefetchPath[index]] == null){
											to_downloadlist.push(((branch_prefetchPath[index])));
											AltprefetchPath.push(branch_prefetchPath[index]);
											if(fragmentsquality[branch_prefetchPath[index]] != undefined){
												to_qualitylist.push(qual);
												fragmentsquality[branch_prefetchPath[index]] = qual/1000;
											}
											if(fragmentsquality[branch_prefetchPath[index]] == undefined){
												var whichq1:Number = checkparallelquality();
												to_qualitylist.push(qual);
												fragmentsquality[branch_prefetchPath[index]] = qual/1000;
											}
										}
										branch_prefetchPath[index]=(((branch_prefetchPath[index])+1));
									}
									if(branch_prefetchPath.length >1){
										for(var m:uint=0;m<to_move;m++){
											var hold:Number = branch_prefetchPath.shift();
											branch_prefetchPath.push(hold);
											branch_prefetchPathShifted=branch_prefetchPath;
										}
										to_move=0;
									}
								}
							}
//							if fragments have been scheduled to be downloaded previously and have not been downloaded since pipes have been full, they are downloaded before the new set of fragments
							if(parallel_pending=true){
								for(var m:uint=0;m<missed_fragments.length;m++){
									var w:uint=missed_fragments.splice(m,1);
									var c:Number=missed_quality.splice(m,1);
									parallel_pipe(w,c);
									if(missed_fragments.length==0)
										parallel_pending=false;
								}
							}
							for(var k:uint=0;k<to_downloadlist.length;k++){
								parallel_pipe((to_downloadlist[k]),to_qualitylist[k]);
								logger.debug("Downloading these: "+to_downloadlist[k]+" "+to_qualitylist[k]);
							}
							to_downloadlist = new Array;
							to_qualitylist = new Array;
						}
//						Set OFF state if DesiredMax has been reached
						if(Buffer > DesiredMax){
							setState("wait");
						}
						break;
					}
				/*case "roundrobin_bundle":
					Buffer = choseBuffer(currentStream);
					if(Buffer < workahead){
						setState("donwload");
						logger.debug("BUFFER SIZE IS " + Buffer + " " + currentStream + " " + BufferStatus + " RRB");
						break;
					}else{
						if(donwloadBlocker == false){
							prefdownloadedlist=chosedonwloadlist(prefetchStream);
							off_duration=((Buffer-workahead));
							if(parallel_pending==true && ttd((missed_quality[0]*1.5))<off_duration && parallelpipe_on==false){
								for(var adm:uint=0;adm<missed_fragments.length;adm++){
									var adw:uint=missed_fragments.splice(adm,1);
									var adc:Number=missed_quality.splice(adm,1);
									var ads:Number=missed_stream.splice(adm,1);
									{
										parallel_pipe(adw,adc,ads,"prefetch_missed");
									}
									if(admissed_fragments.length==0){
										parallel_pending=false;
									}
								}
							}
							else if(parallel_pending==false){
								var actualstream:int=0;
								if(prefetchStream>6){
									prefetchStream=0;
								}
								var qchoice:Number = 0;
								if(prefetchStream == currentStream){
									prefetchStream++;
									lastFrag++;
								}
								if(prefetchStream!=currentStream){
									qchoice=chosequality(avg,fragment);
								}
								
								if((ttd((qchoice*1.5))<off.duration)){
									if(to_downloadlist.indexOf(lastFrag)<0){
										to_downloadlist.push(lastFrag);
									}
									else if(to_downloadlist.indexOf(lastFrag)>0{
										to_downloadlist.push(todownloadlist[to_downloadlist.length-1]+1);
									}
										parallel_pipe(to_downloadlist.splice([to_downloadlist.length-1],[to_downloadlist.length]),qchoice,prefetchStream,"prefetch_regular_a");
										prefetchStream++;
										if(currentStream==prefetchStream){
											lastFrag++;
										}
								}
								else{
									setState("download");
									logger.debug("RRB1");
									break;
								}if(Buffer<workahead){
									//setCprime("le_tmin_bundle");
									setState("download");
									logger.debug("BUFFER SIZE IS "+Buffer+" "+currentStream+" "+BufferStatus+" RRB");
									break;
								}
							}
							break;
						}
						break;
					}
					*/
					
				case "wait":
//					set ON state if buffer is smaller than DesiredMin
					if(Buffer < DesiredMin){
						setState("download");
					}
					break;
			}
		}
		
		private function setState(value:String):void
		{
			BufferStatus = value;
			logger.debug("Setting buffer state "+BufferStatus);
			previouslyLogged = value;
		}
		
		
		public function getfragq():Dictionary
		{
			return fragmentsquality;
		}
		
		public function calculate_prefetch_quality(chosenq:uint,fragnum:uint):int
		{
			if(fragnum == 0)
				return quality_array[0];
			var distance:uint = calculate_distance_from_landpoint(fragnum);
			var x:Number=0;			
			if(distance > 0){
								var ideal:Number=global_avg/numberinParallel;
								if(ideal > 1300)
									return 1300;
								if(ideal < 1300 && ideal > 850)
									return 850;
								if(ideal <850 && ideal > 500)
									return 500;
								if(ideal < 500)
									return 250;
			}
			return 0;
		}
		
		private function calculate_distance_from_landpoint(frag:uint):int
		{
			var holding:Array=new Array;
			for(var i:uint=0;i<landPoints.length;i++){
				if(frag>landPoints[i]){
					holding.push(frag-landPoints[i]);
				}
				if(frag < landPoints[i]){
				}
				if(frag == landPoints[i]){
					holding.push(0);
				}
				for(var j:uint=0;j<firstlandPoints.length;j++){
					
					if(frag>firstlandPoints[j]){
						holding.push(frag-firstlandPoints[j]);
					}
					if(frag < firstlandPoints[j]){
					}
					if(frag== firstlandPoints[j]){
						holding.push(0);
					}
				}
			}
			return findMin(holding);
		}
		
		//##### COMMENTED OUT PROJECT GROUP 9 #####
		/*public function calculate_decisionpoint(time:Number):int
		{
			netStream1.setpath(time);
			var match_array:Array = new Array;
			var final_array:Array= new Array;
			var length_array:Array= new Array;
			for(var i:uint=0;i<all_jump_paths.length;i++)
			{
				if(all_jump_paths[i].indexOf(playerpath) >= 0 && all_jump_paths[i] != playerpath){
					match_array.push(all_jump_paths[i]);
					length_array.push(all_jump_paths[i].length);
				}			
			}
			var min_len:int = findMin(length_array);
			
			for(var k:uint=0;k<match_array.length;k++){
				if(match_array[k].length == min_len){
					final_array.push(match_array[k]);
				}
				var branchpoint:int=find_dec(final_array);
			}			
			return branchpoint;
		}
		
		private function find_dec(array:Array):int
		{
			var branch_pt:Array = new Array;
			var holding:Array = new Array;
			for(var i:uint=0;i<array.length;i++){
				var hold:Array = array[i].split(" ");
				holding[i]= hold[hold.length-2];
			}
			var min:uint=Number(holding[0]);
			for(var k:uint=0; k< holding.length; k++){
				if(Number(holding[i])<min)
					min=Number(holding[i]);
			}
			return min;
		}*/
		
		private function findMin(array:Array):Number {
			var min:int= array[0];
			for (var i:uint = 0; i < array.length; i++) {
				if (array[i] < min) {
					min = array[i];
				}
			}
			return min;
		}
		
		public function calc_next_decpoint(frag:uint):int
		{
			for(var i:uint=0;i<decPoints.length;i++){
				if(frag<decPoints[i]){
					return decPoints[i];
					break;
				}
			}
			return decPoints[decPoints.length-1];
		}
		
		public function calcexpectedcompletion(size:Array,esti:Number,frag_num:uint,connxn:uint,q:uint):Number
		{
			var originalsize:Array=size;
			var p_q:uint=0;
			var count:uint=0;
			var to_do:Array=new Array;
			var bytes:int=0;
			if(match_array.indexOf(frag_num.toString()) >= 0)
				var remaining_frags:int=match_array.length-match_array.indexOf(frag_num.toString());
			for(var k:uint=match_array.indexOf(frag_num.toString());k<match_array.length;k++){
				to_do.push(match_array[k]);
				count++;
			}
			if(count!=0){
				var remaining_branch:int=(branchArray.length);
				
				for(var j:uint=0;j<branchArray.length;j++){
					to_do.push(branchArray[j]);
				}
				for(var m:uint=0;m<count;m++){
					bytes = bytes+(size[to_do[m]]);
				}				
				for(var n:uint=0;n<branchArray.length;n++){
					p_q=calculate_prefetch_quality(q,branchArray[n]);
					if(p_q==250)
						size=sizearray_250;
					if(p_q==500)
						size=sizearray_500;
					if(p_q==850)
						size=sizearray_850;
					if(p_q==1300)
						size=sizearray_1300;
					if(p_q==0)
						size=originalsize;
					bytes = bytes+(size[branchArray[n]]);
				}
				if(numberinParallel!=0){
					esti=esti/numberinParallel;
				}
				if(normal_running>0){
					esti=(esti-(downloader_rate*1000))
				}
				var tempo:Number=bytes/(esti);
				return tempo;
			}
			return 1000;
		}
		
		public function chosequality(bw:Number):int
		{
			if(bw < 250)
				return 250;
			if(bw > 250 && bw < 500)
				return 500;
			if(bw > 500 && bw < 850)
				return 850;
			if(bw > 850 && bw < 1300)
				return 1300;
			if(bw > 1300)
				return 1300;
			return 250;
		}
		
//		Run on completion of downloaded. Multiple copies..can be merged and call different instances.
		public function onCompleteEst_alt(event:Event):void
		{
			dloadTimerendest_alt = gettime();
			parallelpipe_on_alt = false;
			time_download[prefestF1_alt] = (dloadTimerendest_alt-dloadTimerbeginest_alt)/1000;
			quality_download[prefestF1_alt] = prefestQ1_alt;
			numberinParallel--;
			logger.debug("download info "+ time_download[prefestF1_alt]+ " "+ quality_download[prefestF1_alt]+ " "+prefestF1_alt);
			var estimate:Number = (((fragments[prefestF1_alt].bytesAvailable)*8/1000)/((dloadTimerendest_alt-dloadTimerbeginest_alt)/1000));			
			Buffer+=(runtable[prefestF1_alt-1]/1000);
			if(numberinParallel!=0)
				estimate=estimate*numberinParallel;
			logger.debug("PATTEX Downloaded frag info est 1: " + estimate);
			calculate_avg(estimate);
			if(seeking==false)
				checkandschedule(global_avg,maxinParallel);
		}
		
		public function onCompleteEst_alt1(event:Event):void
		{
			dloadTimerendest_alt1 = gettime();
			parallelpipe_on_alt1 = false;
			time_download[prefestF1_alt1] = (dloadTimerendest_alt1-dloadTimerbeginest_alt1)/1000;
			quality_download[prefestF1_alt1] = prefestQ1_alt1;
			numberinParallel--;
			logger.debug("download info "+ time_download[prefestF1_alt1]+ " "+ quality_download[prefestF1_alt1]+ " "+prefestF1_alt1);
			var estimate:Number = (((fragments[prefestF1_alt1].bytesAvailable)*8/1000)/((dloadTimerendest_alt1-dloadTimerbeginest_alt1)/1000));
			Buffer+=(runtable[prefestF1_alt1-1]/1000);
			if(numberinParallel!=0)
				estimate=estimate*numberinParallel;
			logger.debug("PATTEX Downloaded frag info est 2: " + estimate);
			calculate_avg(estimate);
			if(seeking==false)
				checkandschedule(global_avg,maxinParallel);
		}
		
		public function onComplete(event:Event):void
		{
			dloadTimerend1 = gettime();
			var urlTemp:URLStream = URLStream(event.target);
			CONFIG::LOGGING
			{
				numBytes += urlTemp.bytesAvailable;
			}
		}
		private function onComplete1(event:Event):void
		{
			dloadTimerend2 = gettime();
			var urlTemp:URLStream = URLStream(event.target);
			CONFIG::LOGGING
			{
				numBytes += urlTemp.bytesAvailable;
			}
		}
		public function onComplete2(event:Event):void
		{
			dloadTimerend3 = gettime();	
			var urlTemp:URLStream = URLStream(event.target);
			time_download[prefF3] = (dloadTimerend3-dloadTimerbegin3)/1000;
			quality_download[prefF3] = fragmentsquality[prefF3];
			logger.debug("download info 16 "+ time_download[prefF3]+ " "+ quality_download[prefF3]+ " "+prefF3);	
			if(time_download[prefF3] < 10){				
				var estimate:Number = (((fragments[prefF3].bytesAvailable)*8/1000)/((dloadTimerend3-dloadTimerbegin3)/1000));
				if(parallelpipe_on == true && parallelpipe_on_alt == false)
					estimate = estimate*2;
				if(parallelpipe_on == false && parallelpipe_on_alt == true)
					estimate = estimate*2;
				if(parallelpipe_on == true && parallelpipe_on_alt == true)
					estimate = estimate*3;
				calculate_avg(estimate);
			}
			CONFIG::LOGGING
			{
				numBytes += urlTemp.bytesAvailable;
			}
		}
		public function onComplete3(event:Event):void
		{
			dloadTimerend4 = gettime();
			var urlTemp:URLStream = URLStream(event.target);
			
			time_download[prefF4] = (dloadTimerend4-dloadTimerbegin4)/1000;
			quality_download[prefF4] = fragmentsquality[prefF4];
			logger.debug("download info 16 "+ time_download[prefF4]+ " "+ quality_download[prefF4]+ " "+prefF4);			
			if(time_download[prefF4] < 10){				
				var estimate:Number = (((fragments[prefF4].bytesAvailable)*8/1000)/((dloadTimerend4-dloadTimerbegin4)/1000));
				calculate_avg(estimate);
			}
			CONFIG::LOGGING
			{
				numBytes += urlTemp.bytesAvailable;
			}
		}
	}
}