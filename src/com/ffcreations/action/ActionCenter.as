package com.ffcreations.action
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.core.ITickedObject;
	import com.pblabs.engine.core.InputManager;
	import com.pblabs.engine.debug.Logger;
	
	/**
	 * Centralized place to register and execute Actions.
	 * @see com.ffcreations.action.Action
	 * @author Kleber
	 */
	public final class ActionCenter implements ITickedObject
	{
		
		
		//==========================================================
		//   Fields 
		//==========================================================
		
		private var _actions:Object = new Object();
		private var _inputManager:InputManager;
		
		
		//==========================================================
		//   Constructor 
		//==========================================================
		
		/**
		 * Creates an Action Center instance.
		 * @param inputManager	The InputManager to check for keyboard events.
		 * @see com.pblabs.engine.core.InputManager
		 */
		public function ActionCenter(inputManager:InputManager)
		{
			_inputManager = inputManager;
			PBE.processManager.addTickedObject(this, 0);
		}
		
		
		//==========================================================
		//   Functions 
		//==========================================================
		
		/**
		 * Register the given Action to the actions list.
		 * @param action	The Action to register.
		 */
		public function registerAction(action:Action):void
		{
			_actions[action.id] = action;
		}
		
		/**
		 * Executes the Action with given id.
		 * @param id	The Action id to execute.
		 */
		public function executeAction(id:String):void
		{
			if (_actions.hasOwnProperty(id))
			{
				_actions[id].execute();
			}
		}
		
		/**
		 * Removes the Action with given id.
		 * @param id	The id of the Action to remove.
		 */
		public function removeAction(id:String):void
		{
			if (_actions.hasOwnProperty(id))
			{
				delete _actions[id];
			}
		}
		
		/**
		 * Returns the Action with given id
		 * @param id	The Action id.
		 * @return The Action with given id.
		 */
		public function getAction(id:String):Action
		{
			return _actions[id];
		}
		
		/**
		 * Sets the callback to the Action with given id.
		 * @param id		The Action id.
		 * @param callback	The callback.
		 * @see com.ffcreations.action.Action#callback
		 */
		public function setActionCallback(id:String, callback:Function):void
		{
			if (_actions.hasOwnProperty(id))
			{
				_actions[id].setCallback(callback);
			}
			Logger.warn(this, "setActionCallback", "There is no action with id " + id);
		}
		
		/**
		 * @inheritDoc
		 */
		public function onTick(deltaTime:Number):void
		{
			for (var a:String in _actions)
			{
				if (_inputManager.keyJustPressed(_actions[a].shortcutCode))
				{
					_actions[a].execute();
				}
			}
		}
	}
}
