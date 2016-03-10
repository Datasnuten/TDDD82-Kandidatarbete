/*****************************************************
 *  
 *  Patrik Bergström and Vengatanathan Krishnamoorthi
 *  
 *****************************************************/
// This class handles the case of binary tree where there is an arrow mark pointing to either the left of the right branch to be taken.
package org.osmf.player.chrome.widgets
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	
	import org.osmf.media.*;
	import org.osmf.media.MediaPlayer;
	import org.osmf.net.httpstreaming.HTTPDownloadManager;
	import org.osmf.player.chrome.assets.AssetIDs;

	
	CONFIG::LOGGING
	{
		import org.osmf.logging.Log;
		import org.osmf.logging.Logger;
	}
	
	public class JumpButton extends ButtonWidget
	{
		private var showRight:Boolean = false;
		private var downManager:HTTPDownloadManager = HTTPDownloadManager.getInstance();
		private static const logger:org.osmf.logging.Logger = org.osmf.logging.Log.getLogger("org.osmf.net.httpstreaming.JumpButton");

		public function JumpButton()
		{
			super();
			upFace = AssetIDs.JUMP_BUTTON_LEFT;
			downFace = AssetIDs.JUMP_BUTTON_RIGHT;
			overFace = AssetIDs.PLAY_BUTTON_OVER;
			}

		override protected function onMouseClick(event:MouseEvent):void
		{
			showRight = !showRight;
			if(showRight){
				setFace(down);
			}
			else
				setFace(up);
		}
				
		// These functions might need some functionality or logic
		override protected function onMouseOver(event:MouseEvent):void
		{
			mouseOver = true;
		}
		override protected function onMouseOut(event:MouseEvent):void
		{
			mouseOver = false;
		}
	}
}