package com.ffcreations.util
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	
	public class DelegateContainer
	{
		
		
		//==========================================================
		//   Fields 
		//==========================================================
		
		private var _delegates:Dictionary;
		
		
		//==========================================================
		//   Constructor 
		//==========================================================
		
		public function DelegateContainer()
		{
			_delegates = new Dictionary();
		}
		
		
		//==========================================================
		//   Functions 
		//==========================================================
		public function addDelegateCallback(type:String, callback:Function):void
		{
			if (!_delegates.hasOwnProperty(type))
			{
				_delegates[type] = new Delegate();
			}
			_delegates[type].install(callback);
		}
		
		public function removeDelegateCallback(type:String, callback:Function):void
		{
			if (!_delegates.hasOwnProperty(type))
			{
				return;
			}
			_delegates[type].uninstall(callback);
			if (_delegates.length == 0)
			{
				delete _delegates[type];
			}
		}
		
		public function hasDelegateCallback(type:String):Boolean
		{
			return _delegates.hasOwnProperty(type);
		}
		
		public function callDelegate(data:Event):*
		{
			if (!_delegates.hasOwnProperty(data.type))
			{
				return;
			}
			return _delegates[data.type].call(data);
		}
	}
}
