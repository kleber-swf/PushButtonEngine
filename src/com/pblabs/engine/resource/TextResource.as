package com.pblabs.engine.resource
{
	import flash.events.Event;
	
	/**
	 * Simple resource to handle with text.
	 * @author Kleber Lopes da Silva (kleber.swf)
	 */
	public class TextResource extends Resource
	{
		
		
		//==========================================================
		//   Fields 
		//==========================================================
		
		private var _data:String;
		
		
		//==========================================================
		//   Properties 
		//==========================================================
		
		/**
		 * Resource data.
		 */
		public function get data():String
		{
			return _data;
		}
		
		
		//==========================================================
		//   Functions 
		//==========================================================
		
		/**
		 * @inheritDoc
		 */
		public override function initialize(data:*):void
		{
			_data = data;
			onLoadComplete();
		}
		
		/**
		 * @inheritDoc
		 */
		protected override function onContentReady(content:*):Boolean
		{
			return (content is String) ? true : _data != null;
		}
	}
}
