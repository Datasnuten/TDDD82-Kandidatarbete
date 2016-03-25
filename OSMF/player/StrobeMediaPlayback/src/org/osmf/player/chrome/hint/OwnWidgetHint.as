/*****************************************************
 *  
 *  Jonathan Sjölund and Andreas Nordberg
 *  
 *****************************************************/

package org.osmf.player.chrome.hint
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import org.osmf.player.chrome.widgets.FadingLayoutTargetSprite;
	import org.osmf.player.chrome.widgets.Widget;
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.VerticalAlign;
	
	/**
	 * WidgetHint is able to display Widgets as hints, not just text.
	 */ 
	public class OwnWidgetHint extends EventDispatcher
	{
		
		// Constructor 
		//	
		public function OwnWidgetHint(lock:Class)
		{
			if (lock != ConstructorLock)
			{
				throw new IllegalOperationError("WidgetHint is a singleton. Please use the getInstance method");
			}		
			
			view = new FadingLayoutTargetSprite();
			view.fadeSteps = 4;
			view.mouseChildren = false;
			view.mouseEnabled = false;
		}
		
		public function get widget():Widget
		{
			return _widget;
		}
		
		public function set widget(value:Widget):void
		{
			var parentContainer:DisplayObjectContainer = addToStage ? parent.stage : parent;
			if (value != null)
			{
				if (value != _widget)
				{
					if (parentContainer && !parentContainer.contains(view))
					{
						if (widget != null && view.contains(widget))
						{
							view.removeChild(widget);
						}
						_widget = value;
						view.addChild(_widget);
						view.height = _widget.height;
						parentContainer.addChild(view);
					}
					view.measure();
					
				}
				updatePosition();
			}
			else 
			{
				hide();
			}
		}
		
		public function hide():void
		{
			var parentContainer:DisplayObjectContainer = addToStage ? parent.stage : parent;
			if (parentContainer && parentContainer.contains(view))
			{
				if (widget != null && view.contains(widget))
				{
					view.removeChild(widget);
				}
				view.parent.removeChild(view);
				_widget = null;
			}
		}
		
		public function updatePosition():void
		{
			var parentWidth:int 
			= isNaN(parent.width) 
				? ((parent is Widget) ? (parent as Widget).layoutMetadata.width : NaN)
				: parent.width;
			var parentPosition:Point = parent.localToGlobal(new Point(parent.x, parent.y));
			//var parent:Point = parent.localToGlobal(new Point(parent.mouseX, parent.mouseY));
			
			view.y = (addToStage ? parentPosition.y - parent.height : 0) - view.height;
			
			switch (horizontalAlign)
			{
				case HorizontalAlign.LEFT: 
					view.x = addToStage ? parentPosition.x : 0;
					break;
				case HorizontalAlign.RIGHT:
					view.x = (addToStage ? parentPosition.x : 0) + parentWidth - view.width;
					break;
				case HorizontalAlign.CENTER:
					
					view.x = (addToStage ? parentPosition.x : 0) + (parentWidth - view.width)/2;
					break;
				default:
					//view.x = (addToStage ? parentMouse.x : parent.mouseX) - view.width/2;					
			}
		}		
		
		public static function getInstance(parent:Widget, addToStage:Boolean = false):OwnWidgetHint
		{
			if (parent == null)
			{
				throw new ArgumentError("parent cannot be null");
			}
			
			if (_instance == null)
			{
				_instance = new OwnWidgetHint(ConstructorLock);
			}
			
			if (_instance.parent != parent)
			{
				// Different parent, reset alignment
				_instance.horizontalAlign = null;
			}
			
			_instance.parent = parent;
			_instance.addToStage = addToStage;
			
			if (addToStage)
			{
				parent.stage.addEventListener(MouseEvent.MOUSE_OUT, onStageMouseOut);
				function onStageMouseOut(event:MouseEvent):void
				{
					if (event.relatedObject == null)
					{
						// The swf has lost focus
						//_instance.hide();	
					};
				}
				
			}
			return _instance;
		}
		
		public var horizontalAlign:String;
		
		// Internals
		//
		
		private static var _instance:OwnWidgetHint;
		
		private var face:DisplayObject;
		private var parent:Widget;
		private var addToStage:Boolean;
		private var _widget:Widget;
		private var view:FadingLayoutTargetSprite;
	}
}

class ConstructorLock
{
}