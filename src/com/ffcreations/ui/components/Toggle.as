package com.ffcreations.ui.components
{
	import com.ffcreations.ui.mouse.MouseInputEvent;
	
	import flash.events.MouseEvent;
	
	/**
	 * A GUIComponent that have its <code>selected</code> property inverted each time it is pressed.
	 * @author Kleber Lopes da Silva (kleber.swf)
	 */
	public class Toggle extends GUIComponent
	{
		
		
		//==========================================================
		//   Functions 
		//==========================================================
		
		internal function group():void
		{
			_eventDispatcher.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		/**
		 * @inheritDoc
		 */
		protected override function onAdd():void
		{
			super.onAdd();
			_eventDispatcher.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
		}
		
		/**
		 * @inheritDoc
		 */
		protected override function onRemove():void
		{
			_eventDispatcher.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			super.onRemove();
		}
		
		//--------------------------------------
		//   Event handlers 
		//--------------------------------------
		
		private function onMouseUp(data:MouseInputEvent):void
		{
			if (_enabled)
			{
				selected = !_selected;
			}
		}
	}
}
