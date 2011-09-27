package com.ffcreations.ui.mouse
{
	import flash.geom.Point;
	
	public final class MouseInputData
	{
		
		
		//==========================================================
		//   Fields 
		//==========================================================
		
		public var type:String;
		//public var event:MouseEvent;
		public var scenePosition:Point;
		public var localPosition:Point;
		public var component:IMouseInputComponent;
		
		
		//==========================================================
		//   Functions 
		//==========================================================
		
		public function toString():String
		{
			return "type:" + type + ", scenePosition:" + scenePosition.toString() + ", localPosition:" + localPosition.toString() + ", component:" + (component ? component.name : "null");
		}
	}
}
