package com.ffcreations.util
{
	
	/**
	 * A set of functions to be called like events, but immediately.
	 * @author Kleber Lopes da Silva (kleber.swf)
	 */
	public final class Delegate
	{
		
		
		//==========================================================
		//   Fields 
		//==========================================================
		
		private var _functions:Array = new Array();
		
		
		//==========================================================
		//   Properties 
		//==========================================================
		
		public function get length():int
		{
			return _functions.length;
		}
		
		
		//==========================================================
		//   Functions 
		//==========================================================
		
		/**
		 * Removes all installed functions.
		 */
		public function clear():void
		{
			_functions.length = 0;
		}
		
		/**
		 * Installs a function to be called.
		 * @param func The function with the predefined signature.
		 */
		public function install(func:Function):void
		{
			_functions.push(func);
		}
		
		/**
		 * Uninstalls a function from call.
		 * @param func The function to be removed.
		 */
		public function uninstall(func:Function):void
		{
			var index:int = _functions.indexOf(func);
			if (index < 0)
			{
				return;
			}
			_functions.splice(index, 1);
		}
		
		/**
		 * Calls all installed function in order that was intalled.
		 * @param params Params to pass directly to the functions. Attempt to the signature.
		 * @see Function#call
		 */
		public function call(... params):*
		{
			if (_functions.length == 0)
			{
				return;
			}
			var funcs:Array = _functions.slice();
			for each (var f:Function in funcs)
			{
				var r:* = f.apply(null, params);
				if (r)
				{
					return r;
				}
			}
			return null;
		}
		
		/**
		 * Calls all installed function in order that was intalled.
		 * Call this method when you hava an array of arguments.
		 * @param params Params to pass directly to the functions. Attempt to the signature.
		 * @see Function#apply
		 */
		public function apply(params:Array):*
		{
			if (_functions.length == 0)
			{
				return;
			}
			var funcs:Array = _functions.slice();
			for each (var f:Function in funcs)
			{
				var r:* = f.apply(null, params);
				if (r)
				{
					return r;
				}
			}
			return null;
		}
	}
}
