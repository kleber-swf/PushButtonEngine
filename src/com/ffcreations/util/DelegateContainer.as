package com.ffcreations.util
{
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
		
		public function addCallback(type:String, callback:Function):void
		{
			if (!_delegates.hasOwnProperty(type))
			{
				_delegates[type] = new Vector.<Function>();
			}
			_delegates[type].push(callback);
		}
		
		public function removeCallback(type:String, callback:Function):void
		{
			if (!_delegates.hasOwnProperty(type))
			{
				return;
			}
			var index:int = _delegates[type].indexOf(callback);
			if (index < 0)
			{
				return;
			}
			_delegates[type].splice(index, 1);
			if (_delegates[type].length == 0)
			{
				delete _delegates[type];
			}
		}
		
		public function hasCallback(type:String):Boolean
		{
			return _delegates.hasOwnProperty(type);
		}
		
		public function call(type:String, ... params):void
		{
			if (!_delegates.hasOwnProperty(type))
			{
				return;
			}
			var functions:Vector.<Function> = _delegates[type].slice();
			if (functions.length == 0)
			{
				return;
			}
			for each (var f:Function in functions)
			{
				f.apply(null, params);
			}
		}
		
		public function clear():void
		{
			for (var s:String in _delegates)
			{
				_delegates[s].length = 0;
				delete _delegates[s];
			}
		}
	}
}
