package com.ffcreations.action
{
	
	/**
	 * Event dispatched as parameter of the Action callback.
	 * @author Kleber
	 */
	public class ActionEvent
	{
		
		
		//==========================================================
		//   Fields 
		//==========================================================
		
		private var _action:Action;
		
		
		//==========================================================
		//   Properties 
		//==========================================================
		
		/**
		 * The executed Action.
		 */
		public function get action():Action
		{
			return _action;
		}
		
		
		//==========================================================
		//   Constructor 
		//==========================================================
		
		public function ActionEvent(action:Action)
		{
			_action = action;
		}
	}
}
