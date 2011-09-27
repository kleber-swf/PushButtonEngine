package com.ffcreations.ui.components
{
	import com.ffcreations.ui.mouse.MouseInputData;
	
	import flash.events.MouseEvent;
	
	public class Toggle extends GUIComponent
	{
		
		
		//==========================================================
		//   Functions 
		//==========================================================
		
		internal function group():void
		{
			_delegateContainer.removeDelegateCallback(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		protected override function onAdd():void
		{
			super.onAdd();
			_delegateContainer.addDelegateCallback(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		protected override function onRemove():void
		{
			_delegateContainer.removeDelegateCallback(MouseEvent.MOUSE_UP, onMouseUp);
			_delegateContainer = null;
		}
		
		private function onMouseUp(data:MouseInputData):void
		{
			if (_enabled)
			{
				selected = !_selected;
			}
		}
	}
}
