====================================================
READ ME FIRST
====================================================
Note: If you use our datafiles and/or software in your research, please include a reference to our ACM MM 2014 paper in your work.

   V. Krishnamoorthi, N. Carlsson, D. Eager, A. Mahanti, and N. Shahmehri "Quality-adaptive Prefetching for Interactive Branched Video using HTTP-based Adaptive Streaming", Proc. ACM Multimedia, Orlando, FL, Nov. 2014.

====================================================

This package was developed under a Windows environment and steps mentioned are for a Windows system unless mentioned otherwise. 
Setting up all packages and tools mentioned in this walkthrough might take around 5GB of storage space.

Step 1: Download OSMF 2.0 and Strobe Media Playback (SMP) libraries from http://sourceforge.net/projects/osmf.adobe/files/

Step 2: Download and install Flash builder, this is the preferred IDE and is very similar to Eclipse. You might also have to install flex and ANT SDK to compile and build code.

Step 3: Extract the OSMF zip folder and replace the framework and player folders with the folders provided.

Step 4: Import both OSMF and Strobe Media Playback projects into Flash builder. Use Ctrl+B shortcut after importing, this will build all projects in the IDE. Any errors shown during this build phase must be addressed. The codes that we ship will build without errors, sources of potential errors might be in installing and referencing OSMF and other SDKs within Eclipse.

Step 5: Once the build succeeds, it is required to modify the manifest URL in the StrobeMediaPlayback.html file located in player/StrobeMediaPlayback/bin. Change the 'src:' tag's property to the location and name of your video. You must provide the name of the '.f4m' (manifest) file associated with the video here.

====================================================
Configuring Metafiles and configuration files:
====================================================

Metafiles are simple text files which we use to provide additional information the player, mainly concerning the multipath structure, branch points and branch options. While configuration files are used to set runtime parameters in the player. One metafile and two configuration files have been provided with the source codes and can be found in player/StrobeMediaPlayback/bin. 

The metafile test.txt contains all information about the video's multipath structure. The first field "length:" provides the number of in-order fragments that each segment consists of. For eg. as seen in the file, segment 1 consists of fragments 1-5, segment 2 consists of fragments 6-10 and so forth. The lines between 'begin' and 'end' tag denote different paths and branch options available at different points in the video. Segment numbers with two or more digits are enclosed within '*', a group of numbers will be interpreted digit by digit as individual segments. An '(' represents presence of a branch point. The digit immediately before '(' is the segment number, at the end of which the branch point is available. Other digits preceding the digit before '(' indicate the path that must have been taken by the player in order to offer a branch point at the end of that segment. Digits following '(' are the segment numbers that must be played back based on user choice. Multiple branch options are separated by ','. 

The configuration file workahead.txt aids in configuring parameters such as number of concurrent connections allowed, buffer sizing and prefetching policy. The first field 'workahead:' is not used. The field 'maxinparallel:' imposes a limit on the maximum number of concurrent connections that the player can open to the server. The parameter 'alpha:' determines the weight applied  when calculating estimated bandwidth using EWMA. There are three modes of prefetching that the player supports. The accepted values in this field are newenhance, bw_enhance and q_enhance which correspond to Optimized non-increasing quality, greedy bandwidth and optimized maintainable quality respectively in the paper. 'min:' and 'margin:' correspond to Tsingle and delta in the paper. The last field 'url:' contains the server's ip and the directory in which the video is available.

The file automator.txt was used to automate user branch choice at specific time instants. The first column is the time at which a choice is made and the second columnn is the actual choice made by the user. 

====================================================
Browser configuration:
====================================================

Our system design relies on using the browser cache to store prefetched data. It is important to turn on the browser cache, either the disk or RAM cache. It is recommended to have a cache size large enough in relation to the highest encoding rate, number of branch options at each branch point, the number of fragments that would be prefetched based on the available bandwidth and buffer size. If the volume of prefetched data exceeds that of the cache, fragments would be replaced and would have to be downloaded again from the server.

====================================================
Handling multipath video:
====================================================

The player relies on information from the manifest file, user input and playpath tracking to perform multipath streaming. Transitions from one segment to another are performed by calling NetStream.Seek(time) function with the time at which the new segment begins. The mapping between segment numbers and relative play point in the video is performed using information from the metafile. The first few fragments of the new segment would already have been prefetched if the available bandwidth is not too low. When NetStream.Seek calculates the fragment id and its quality, our modified procedures make sure that the requested quality is the same as the quality at which the fragment was prefetched, hence resulting in a cache hit of the prefetched fragment. The function checkandschedule() handles downloading of fragments based on the policy it is configured with. The function onCanSeekChange1() controls the transition between one segment to another. These two functions call many other functions to perform small tasks involved in this process. Both these functions are located in the HTTPDownloadManager class.

====================================================
Handling video URL:
====================================================

The source code generates fragment URLs based on the video available on our server. Our URLs have the following pattern 'http://ip_address/vod/final_1.3Seg1Frag1'. The number 1.3 in the URL corresponds to 1300Kb/s encoding rate. Other values that we used were 850, 500 and 250Kb/s. The IP address and directory of the video can be controlled using the configuration parameter 'URL:' in the configuration file workahead.txt. As for the video filename and encodings, modifications have to be made in the source code to match the video on your server.

====================================================
Additional information: 
====================================================

Classes which handle HTTP-based Adaptive Streaming (HAS) are located in org/osmf/net/httpstreaming directory. The HTTPDownloadManager class is central to our implementation and controls download scheduling, parsing metafiles, player-path tracking, handling transition between segments, rate-estimation and buffer-size monitoring. Other classes that have been modified include HTTPStreamDownloader, HTTPStreamSource, HTTPNetStream and StrobeMediaPlayback. Additions to the SMP libraries include graphics to indicate chosen path and additional classes to handle this functionality as well.

====================================================