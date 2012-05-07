package com.ffcreations.action
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.core.ITickedObject;
	import com.pblabs.engine.core.InputManager;
	import com.pblabs.engine.debug.Logger;
	
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
		
		public function ActionCenter(inputManager:InputManager)
		{
			_inputManager = inputManager;
			PBE.processManager.addTickedObject(this, 0);
		}
		
		
		//==========================================================
		//   Functions 
		//==========================================================
		
		public function addAction(action:Action):void
		{
			_actions[action.id] = action;
		}
		
		public function executeAction(id:String):void
		{
			if (_actions.hasOwnProperty(id))
			{
				_actions[id].execute();
			}
		}
		
		//		public function createAction(id:String):Action
		//		{
		//			if (_actions.hasOwnProperty(id))
		//			{
		//				return _actions[id];
		//			}
		//			_actions[id] = new Action(id);
		//			return _actions[id];
		//		}
		
		public function removeAction(id:String):void
		{
			if (_actions.hasOwnProperty(id))
			{
				delete _actions[id];
			}
		}
		
		public function getAction(id:String):Action
		{
			return _actions[id];
		}
		
		public function setActionCallback(id:String, callback:Function):void
		{
			if (_actions.hasOwnProperty(id))
			{
				_actions[id].setCallback(callback);
			}
			Logger.warn(this, "setActionCallback", "There is no action with id " + id);
		}
		
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
