package com.ffcreations.ui.mouse
{
	import com.pblabs.engine.entity.IEntityComponent;
	
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	
	public interface IMouseInputComponent extends IEntityComponent
	{
		function get acceptDrop():Boolean;
		function set acceptDrop(value:Boolean):void;
		
		function get draggable():Boolean;
		function set draggable(value:Boolean):void;
		
		function get enabled():Boolean;
		function set enabled(value:Boolean):void;
		
		function get eventDispatcher():IEventDispatcher;
		
		function get position():Point;
		function set position(value:Point):void;
		function get priority():int;
		function set priority(value:int):void;
		
		function contains(point:Point):Boolean;
		function canDrag(data:IMouseInputComponent):Boolean;
		function canDrop(data:IMouseInputComponent):Boolean;
	}
}
