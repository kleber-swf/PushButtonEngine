package com.ffcreations.util {
	import com.pblabs.engine.PBE;
	
	/**
	 * This function will help to create a set of global entities, templates and groups.
	 * Adds all xmls to the PBE.templateManager to instantiate now or later.
	 *
	 * @param xml			XML file where to get entities, templates and groups.
	 * @param groupNames	Group names that must be instantiated. If empty, no group is instantiated.
	 */
	public function setupGlobals(xml:XML, ... groupNames):void {
		var it:XML;
		for each (it in xml.entity)
			PBE.templateManager.addXML(it, it.@name.toString() + "_xml", 1);
		
		for each (it in xml.template)
			PBE.templateManager.addXML(it, it.@name.toString() + "_xml", 1);
		
		for each (it in xml.group)
			PBE.templateManager.addXML(it, it.@name.toString() + "_xml", 1);
		
		for each (var group:String in groupNames)
			PBE.templateManager.instantiateGroup(group);
	}
}
