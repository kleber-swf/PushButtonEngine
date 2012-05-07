package com.ffcreations.ui.components
{
	import com.ffcreations.action.Action;
	import com.ffcreations.ui.mouse.MouseInputEvent;
	import com.pblabs.engine.PBE;
	
	public class ActionButton extends GUIComponent
	{
		
		
		//==========================================================
		//   Fields 
		//==========================================================
		
		private var _action:Action;
		
		
		//==========================================================
		//   Properties 
		//==========================================================
		
		public function get action():Action
		{
			return _action;
		}
		
		public function set action(value:Action):void
		{
			_action = value;
		}
		
		
		//==========================================================
		//   Functions 
		//==========================================================
		
		public override function onFrame(elapsed:Number):void
		{
			if (action && action.enabled != enabled)
			{
				enabled = action.enabled;
			}
			super.onFrame(elapsed);
		}
		
		//--------------------------------------
		//   Event handlers 
		//--------------------------------------
		
		protected override function onMouseInput(data:MouseInputEvent):void
		{
			super.onMouseInput(data);
			if (enabled)
			{
				if (data.type == MouseInputEvent.MOUSE_DOWN)
				{
					if (action)
					{
						action.execute();
					}
				}
			}
		}
	}
}
