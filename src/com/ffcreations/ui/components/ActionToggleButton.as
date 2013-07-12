package com.ffcreations.ui.components {
	import com.ffcreations.action.Action;
	import com.ffcreations.ui.mouse.MouseInputEvent;
	
	public class ActionToggleButton extends Toggle {
		
		private var _action:Action;
		
		public function get action():Action { return _action; }
		
		public function set action(value:Action):void { _action = value; }
		
		public override function onFrame(elapsed:Number):void {
			if (action && action.enabled != enabled)
				enabled = action.enabled;
			super.onFrame(elapsed);
		}
		
		protected override function onMouseUp(data:MouseInputEvent):void {
			super.onMouseUp(data);
			if (enabled) {
				if (data.type == MouseInputEvent.MOUSE_UP) {
					if (action)
						action.execute(this);
				}
			}
		}
	}
}
