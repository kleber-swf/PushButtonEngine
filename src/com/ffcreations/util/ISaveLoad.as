package com.ffcreations.util
{
	
	public interface ISaveLoad
	{
		function get canSave():Boolean;
		function get hasSavedState():Boolean;
		
		function reset():void;
		
		function set(key:String, value:*, sectionName:String=null, flush:Boolean=true):void;
		
		function get(key:String, section:String=null, defaultValue:*=null):*;
		
		function flush():void;
		
		function getSection(section:String):Object;
	}
}
