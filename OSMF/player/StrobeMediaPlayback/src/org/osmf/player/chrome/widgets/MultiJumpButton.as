/*****************************************************
 *  
 *  Patrik Bergström and Vengatanathan Krishnamoorthi
 *  
 *****************************************************/

// This class handles the case user choice selection. Upto 10 branch options can be provided in each branch point. User presses a button on his/her keyboard to chose a branch option.

package org.osmf.player.chrome.widgets
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import org.osmf.net.httpstreaming.HTTPDownloadManager;
	import org.osmf.player.chrome.assets.AssetIDs;
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.TimeTrait;
	
	public class MultiJumpButton extends ButtonWidget
	{
		private var count:Number= 1;
		private var downManager:HTTPDownloadManager = HTTPDownloadManager.getInstance();
		protected var one:DisplayObject;
		protected var two:DisplayObject;
		protected var three:DisplayObject;
		protected var four:DisplayObject;
		protected var five:DisplayObject;
		protected var six:DisplayObject;
		protected var seven:DisplayObject;
		protected var eight:DisplayObject;
		protected var nine:DisplayObject;
		protected var zero:DisplayObject;
		private static var instance:MultiJumpButton = null;
		
		public function MultiJumpButton()
		{
			super();
		}
		public static function getInstance():MultiJumpButton
		{
			if(!instance)
				instance = new MultiJumpButton();
			return instance;
		}
		
		public function processKey(num:Number):void
		{
			if(num >= 48 && num <= 57)
			{
				count = (num-48)%10;
				decideFace();
			}
		}
		
		override public function configure(xml:XML, assetManager:AssetsManager):void
		{	
			super.configure(xml, assetManager);
			one =  assetManager.getDisplayObject(AssetIDs.JUMP_BUTTON_1);
			two =  assetManager.getDisplayObject(AssetIDs.JUMP_BUTTON_2);
			three =  assetManager.getDisplayObject(AssetIDs.JUMP_BUTTON_3);
			four =  assetManager.getDisplayObject(AssetIDs.JUMP_BUTTON_4);
			five =  assetManager.getDisplayObject(AssetIDs.JUMP_BUTTON_5);
			six =  assetManager.getDisplayObject(AssetIDs.JUMP_BUTTON_6);
			seven =  assetManager.getDisplayObject(AssetIDs.JUMP_BUTTON_7);
			eight =  assetManager.getDisplayObject(AssetIDs.JUMP_BUTTON_8);
			nine =  assetManager.getDisplayObject(AssetIDs.JUMP_BUTTON_9);
			zero =  assetManager.getDisplayObject(AssetIDs.JUMP_BUTTON_0);
			setFace(one);
		}
		
//		Set button face based on choice
		private function decideFace():void
		{
			switch(count)
			{
				case 1:
				{
					setFace(one);
					downManager.setBranch(1);
					break;
				}
				case 2:
				{
					setFace(two);
					downManager.setBranch(2);
					break;
				}
				case 3:
				{
					setFace(three);
					downManager.setBranch(3);
					break;
				}
				case 4:
				{
					setFace(four);
					downManager.setBranch(4);
					break;
				}
				case 5:
				{
					setFace(five);
					downManager.setBranch(5);
					break;
				}
				case 6:
				{
					setFace(six);
					downManager.setBranch(6);
					break;
				}
				case 7:
				{
					setFace(seven);
					downManager.setBranch(7);
					break;
				}
				case 8:
				{
					setFace(eight);
					downManager.setBranch(8);
					break;
				}
				case 9:
				{
					setFace(nine);
					downManager.setBranch(9);
					break;
				}
				case 0:
				{
					setFace(zero);
					downManager.setBranch(10);
					break;
				}
			}
		}
		
		override protected function onMouseClick(event:MouseEvent):void
		{
			count = (count % 9) + 1;
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
		override protected function onMouseDown(event:MouseEvent):void
		{
			mouseOver = false;
		}
	}
}