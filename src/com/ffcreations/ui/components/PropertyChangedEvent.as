package com.ffcreations.ui.components
{
	import flash.events.Event;
	
	public class PropertyChangedEvent extends Event
	{
		
		
		//==========================================================
		//   Static 
		//==========================================================
		
		/**
		 * Event type dispatched when a selected index of a <code>ToggleGroup</code> changes.
		 */
		public static const SELECTION_CHANGED:String = "selectionChanged";
		
		/**
		* Event type called when the selected state of a component changed.
		*/
		public static var SELECTED:String = "selected";
		
		
		//==========================================================
		//   Fields 
		//==========================================================
		
		public var value:*;
		
		
		//==========================================================
		//   Constructor 
		//==========================================================
		
		public function PropertyChangedEvent(type:String, value:*, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.value = value;
		}
	}
}
