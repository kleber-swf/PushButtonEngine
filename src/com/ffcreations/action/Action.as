package com.ffcreations.action
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.core.InputKey;
	import com.pblabs.engine.entity.EntityComponent;
	
	/**
	 * An Action that executes a callback that can be executed by a shortcut.
	 * @author Kleber
	 */
	public class Action extends EntityComponent
	{
		
		
		//==========================================================
		//   Fields 
		//==========================================================
		
		private var _id:String;
		private var _callback:Function;
		private var _shortcutCode:int;
		private var _enabled:Boolean = true;
		
		
		//==========================================================
		//   Properties 
		//==========================================================
		
		/**
		 * Callback called when the action is executed.
		 * Signature: function (event:ActionEvent):void
		 */
		public function set callback(value:Function):void
		{
			_callback = value;
		}
		
		/**
		 * Whether the action is enabled.
		 */
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		/**
		 * @private
		 */
		public function set enabled(value:Boolean):void
		{
			_enabled = value;
		}
		
		/**
		 * Tha action id. Action only work if id is set.
		 */
		public function get id():String
		{
			return _id;
		}
		
		/**
		 * @private
		 */
		public function set id(value:String):void
		{
			if (_id)
			{
				PBE.actionCenter.removeAction(_id);
			}
			_id = value;
			PBE.actionCenter.registerAction(this);
		}
		
		/**
		 * The InputKey shortcut that executes this action.
		 * @see com.pblabs.engine.core.InputKey
		 */
		public function set shortcut(value:String):void
		{
			_shortcutCode = InputKey.stringToKey(value).keyCode;
		}
		
		/**
		 * The shortcut key code.
		 */
		public function get shortcutCode():int
		{
			return _shortcutCode;
		}
		
		
		//==========================================================
		//   Functions 
		//==========================================================
		
		/**
		 * Executes the action.
		 */
		public function execute():void
		{
			if (enabled && _callback != null)
			{
				_callback.call(this, new ActionEvent(this));
			}
		}
	}
}
