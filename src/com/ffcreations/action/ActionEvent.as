package com.ffcreations.action {
	
	/**
	 * Event dispatched as parameter of the Action callback.
	 * @author Kleber
	 */
	public class ActionEvent {
		
		private var _action:Action;
		private var _obj:Object;
		
		/** The executed Action. */
		public function get action():Action { return _action; }
		
		/** The object that triggered the action. */
		public function get object():Object { return _obj; }
		
		public function ActionEvent(action:Action, obj:Object) {
			_action = action;
			_obj = obj;
		}
	}
}
