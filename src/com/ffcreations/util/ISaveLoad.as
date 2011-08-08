package com.ffcreations.util
{
	
	/**
	 * Interface to implement when want to handle with save/load preferences and game status.
	 *
	 * @author Kleber Lopes da Silva (kleber.swf)
	 */
	public interface ISaveLoad
	{
		/**
		 * Whether the game is able to save.
		 */
		function get canSave():Boolean;
		
		/**
		 * Whether the game has already a saved state to load.
		 */
		function get hasSavedState():Boolean;
		
		/**
		 * Resets entire data.
		 */
		function reset():void;
		
		/**
		 * Sets a variable.
		 * @param key			Key name. If no exists, a new one is created.
		 * @param value			Value to set.
		 * @param sectionName	Optional. Section name. If no name is given, puts the variable on the global scope.
		 * @param flush			Optional. Whether to flush the value.
		 */
		function set(key:String, value:*, sectionName:String=null, flush:Boolean=true):void;
		
		/**
		 * Gets a variable value.
		 * @param key			Key name. If no exists, <code>defaultValue</code> is returned.
		 * @param section		Section where the <code>key</code> is. If no section name is given, searches on global scope.
		 * @param defaultValue	Value to return if key was not found.
		 * @return The value for the key or defaultValue.
		 */
		function get(key:String, section:String=null, defaultValue:*=null):*;
		
		/**
		 * Flushes the configuration file.
		 */
		function flush():void;
		
		/**
		 * Gets an entire section and its variables.
		 * @param section Section name.
		 * @return The section.
		 */
		function getSection(section:String):Object;
	}
}
