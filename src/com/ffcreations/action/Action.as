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
		
		private var id:String;
		
		private var _callback:Function;
		private var _shortcutCode:int;
		private var _enabled:Boolean = true;
		
		
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
		
		public function set shortcut(value:InputKey):void
		{
			_shortcutCode = value.keyCode;
		}
		
		public function get shortcutCode():int
		{
			return _shortcutCode;
		}
		
		
		//==========================================================
		//   Functions 
		//==========================================================
		
		protected override function onAdd():void
		{
			super.onAdd();
			PBE.actionCenter.addAction(this);
		}
		
		public function execute():void
		{
			if (enabled && _callback != null)
			{
				_callback.call(this);
			}
		}
	}
}
