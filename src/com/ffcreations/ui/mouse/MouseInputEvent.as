package com.ffcreations.ui.mouse
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public final class MouseInputEvent extends Event
	{
		
		
		//==========================================================
		//   Fields 
		//==========================================================
		
		internal var _propagationStopped:Boolean;
		
		public var event:MouseEvent;
		public var scenePosition:Point;
		public var localPosition:Point;
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
		
		public override function stopImmediatePropagation():void
		{
			super.stopImmediatePropagation();
			_propagationStopped = true;
		}
	}
}
