package com.ffcreations.ui.components
{
	import com.ffcreations.ui.mouse.MouseInputEvent;
	
	import flash.events.MouseEvent;
	
	public class Toggle extends GUIComponent
	{
		
		
		//==========================================================
		//   Functions 
		//==========================================================
		
		internal function group():void
		{
			_eventDispatcher.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		protected override function onAdd():void
		{
			super.onAdd();
			_eventDispatcher.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
		}
		
		protected override function onRemove():void
		{
			_eventDispatcher.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			super.onRemove();
		}
		
		private function onMouseUp(data:MouseInputEvent):void
		{
			if (_enabled)
			{
				selected = !_selected;
			}
		}
	}
}
