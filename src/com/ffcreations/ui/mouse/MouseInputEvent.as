package com.ffcreations.ui.mouse
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * Event that is dispatched when a mouse input event ocurrs.
	 * @see com.ffcreations.ui.mouse.MouseInputManager
	 * @author Kleber Lopes da Silva (kleber.swf)
	 */
	public final class MouseInputEvent extends Event
	{
		
		
		//==========================================================
		//   Static 
		//==========================================================
		
		/**
		 * Event type dispatched when mouse is just released inside a component.
		 */
		public static const MOUSE_UP:String = MouseEvent.MOUSE_UP;
		
		/**
		 * Event type dispatched when mouse is just pressed inside a component.
		 */
		public static const MOUSE_DOWN:String = MouseEvent.MOUSE_DOWN;
		
		/**
		 * Event type dispatched when mouse is just over a component.
		 */
		public static const MOUSE_OVER:String = MouseEvent.MOUSE_OVER;
		
		/**
		 * Event type dispatched when mouse is just out of a component.
		 */
		public static const MOUSE_OUT:String = MouseEvent.MOUSE_OUT;
		
		/**
		 * Event type dispatched when mouse is moving inside a component.
		 */
		public static const MOUSE_MOVE:String = MouseEvent.MOUSE_MOVE;
		
		/**
		 * Event type dispatched when a drag action starts.
		 * Called on the dragged <code>IMouseInputComponent</code>.
		 */
		public static const DRAG_START:String = "dragStart";
		
		/**
		 * Event type dispatched when a drag action stops.
		 * Called on the dragged <code>IMouseInputComponent</code>.
		 */
		public static const DRAG_STOP:String = "dragStop";
		
		/**
		 * Event type dispatched when the <code>IMouseInputComponent</code> is being dragged.
		 * Called on the dragged <code>IMouseInputComponent</code>.
		 */
		public static const DRAG_MOVE:String = "dragMove";
		
		/**
		 * Event type dispatched when the <code>IMouseInputComponent</code> is dropped.
		 * Called on the <code>IMouseInputComponent</code> where the drop occured.
		 */
		public static const DROP:String = "drop";
		
		
		//==========================================================
		//   Fields 
		//==========================================================
		
		internal var _propagationStopped:Boolean;
		
		/**
		 * The flash MouseEvent associated.
		 */
		public var event:MouseEvent;
		
		/**
		 * Mouse position in scene coordinates.
		 */
		public var scenePosition:Point;
		
		/**
		 * Local position relative to the component registration point.
		 */
		public var localPosition:Point;
		
		/**
		 * The component related to this event.
		 */
		public var component:IMouseInputComponent;
		
		
		//==========================================================
		//   Constructor 
		//==========================================================
		
		public function MouseInputEvent(type:String, event:MouseEvent, component:IMouseInputComponent, scenePosition:Point):void
		{
			super(type, event.bubbles, event.cancelable);
			this.event = event;
			this.component = component;
			this.scenePosition = scenePosition;
			if (component && component.position)
			{
				var bounds:Rectangle = component.sceneBounds;
				this.localPosition = new Point(scenePosition.x - (bounds.x + bounds.width * 0.5), scenePosition.y - (bounds.y + bounds.height * 0.5));
			}
		}
		
		
		//==========================================================
		//   Functions 
		//==========================================================
		
		/**
		 * @inheritDoc
		 */
		public override function stopImmediatePropagation():void
		{
			super.stopImmediatePropagation();
			_propagationStopped = true;
		}
	}
}
