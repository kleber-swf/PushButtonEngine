package com.ffcreations.action
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.core.InputKey;
	import com.pblabs.engine.entity.EntityComponent;
	
	public class Action extends EntityComponent
	{
		
		
		//==========================================================
		//   Fields 
		//==========================================================
		
		private var _callback:Function;
		private var _shortcutCode:int;
		private var _enabled:Boolean = true;
		
		private var _id:String;
		
		
		//==========================================================
		//   Properties 
		//==========================================================
		
		public function set callback(value:Function):void
		{
			_callback = value;
		}
		
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		public function set enabled(value:Boolean):void
		{
			_enabled = value;
		}
		
		public function get id():String
		{
			return _id;
		}
		
		public function set id(value:String):void
		{
			if (_id)
			{
				PBE.actionCenter.removeAction(_id);
			}
			_id = value;
			PBE.actionCenter.addAction(this);
		}
		
		public function set shortcut(value:String):void
		{
			_shortcutCode = InputKey.stringToKey(value).keyCode;
		}
		
		public function get shortcutCode():int
		{
			return _shortcutCode;
		}
		
		
		//==========================================================
		//   Functions 
		//==========================================================
		
		public function execute():void
		{
			if (enabled && _callback != null)
			{
				_callback.call(this);
			}
		}
	}
}
