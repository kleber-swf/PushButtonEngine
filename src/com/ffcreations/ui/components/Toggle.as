package com.ffcreations.ui.components
{
	import com.ffcreations.ui.mouse.MouseInputEvent;
	
	/**
	 * A GUIComponent that have its <code>selected</code> property inverted each time it is pressed.
	 * @author Kleber Lopes da Silva (kleber.swf)
	 */
	public class Toggle extends GUIComponent
	{
		
		
		//==========================================================
		//   Fields 
		//==========================================================
		
		private var _groupped:Boolean;
		
		/**
		 * Value associated to this Toggle instance.
		 * This is usefull for <code>ToogleGroups</code> and is returned by <code>PropertyChangedEvent</code> when this instance is selected.
		 * @see com.ffcreations.ui.components.ToggleGroup
		 * @see com.ffcreations.ui.components.PropertyChangedEvent
		 */
		public var value:*;
		
		
		//==========================================================
		//   Functions 
		//==========================================================
		
		internal function group():void
		{
			if (_groupped)
			{
				return;
			}
			_groupped = true;
			_eventDispatcher.removeEventListener(MouseInputEvent.MOUSE_UP, onMouseUp);
		}
		
		/**
		 * @inheritDoc
		 */
		protected override function onAdd():void
		{
			super.onAdd();
			if (!_groupped)
			{
				_eventDispatcher.addEventListener(MouseInputEvent.MOUSE_UP, onMouseUp, false, 0, true);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		protected override function onRemove():void
		{
			_eventDispatcher.removeEventListener(MouseInputEvent.MOUSE_UP, onMouseUp);
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
