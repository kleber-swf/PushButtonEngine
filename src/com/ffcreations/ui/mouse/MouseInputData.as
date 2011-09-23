package com.ffcreations.ui.mouse
{
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public class MouseInputData
	{
		
		
		//==========================================================
		//   Static 
		//==========================================================
		
		public static const MOUSE_UP:int = 0;
		public static const MOUSE_DOWN:int = 1;
		public static const MOUSE_DRAG:int = 2;
		
		
		//==========================================================
		//   Fields 
		//==========================================================
		
		internal var _event:MouseEvent;
		internal var _scenePos:Point;
		internal var _component:MouseInputComponent;
		internal var _action:int;
		internal var lockCenter:Boolean;
		
		
		//==========================================================
		//   Properties 
		//==========================================================
		
		public function get action():int
		{
			return _action;
		}
		
		public function get component():MouseInputComponent
		{
			return _component;
		}
		
		public function get event():MouseEvent
		{
			return _event;
		}
		
		public function get scenePos():Point
		{
			return _scenePos;
		}
		
		
		//==========================================================
		//   Functions 
		//==========================================================
		
		public function toString():String
		{
			return "EventType:" + _event.type + ", ScenePos:" + _scenePos.toString() + ", Component:" + _component.name + ", Action:" + _action + ", LockCenter:" + lockCenter;
		}
	}
}
