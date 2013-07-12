package com.ffcreations.ui.components {
	import com.ffcreations.action.Action;
	import com.ffcreations.ui.mouse.MouseInputEvent;
	import com.pblabs.engine.entity.PropertyReference;
	
	public class ActionButton extends GUIComponent {
		
		private var _action:Action;
		
		public function get action():Action { return _action; }
		
		public function set action(value:Action):void { _action = value; }
		
		public override function onFrame(elapsed:Number):void {
			if (action && action.enabled != enabled)
				enabled = action.enabled;
			super.onFrame(elapsed);
		}
		
		protected override function onMouseInput(data:MouseInputEvent):void {
			super.onMouseInput(data);
			if (enabled) {
				if (data.type == MouseInputEvent.MOUSE_UP) {
					if (action)
						action.execute(this);
				}
			}
		}
	}
}
