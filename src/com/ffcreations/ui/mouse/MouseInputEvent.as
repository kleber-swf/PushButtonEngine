package com.ffcreations.ui.mouse
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	/**
	 * Event that is dispatched when a mouse input event ocurrs.
	 * @see com.ffcreations.ui.mouse.MouseInputManager
	 * @author Kleber Lopes da Silva (kleber.swf)
	 */
	public final class MouseInputEvent extends Event
	{
		
		
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
				this.localPosition = scenePosition.subtract(component.position);
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
