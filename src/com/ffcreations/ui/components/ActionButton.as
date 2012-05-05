package com.ffcreations.ui.components
{
	import com.ffcreations.action.Action;
	import com.ffcreations.ui.mouse.MouseInputEvent;
	import com.pblabs.engine.PBE;
	
	public class ActionButton extends GUIComponent
	{
		
		
		//==========================================================
		//   Static 
		//==========================================================
		
		public static const SOUND_CATEGORY:String = "gui";
		
		
		//==========================================================
		//   Fields 
		//==========================================================
		
		private var _action:Action;
		public var clickSound:String;
		
		
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
					if (clickSound)
					{
						PBE.soundManager.play(clickSound, SOUND_CATEGORY);
					}
				}
				
				if (data.type == MouseInputEvent.MOUSE_UP)
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
