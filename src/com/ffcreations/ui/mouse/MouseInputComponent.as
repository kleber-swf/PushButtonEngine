

package com.ffcreations.ui.mouse
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.engine.entity.EntityComponent;
	import com.pblabs.engine.entity.PropertyReference;
	import com.pblabs.rendering2D.DisplayObjectRenderer;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * Basic mouse input component. Allows the <code>MouseInputManager</code> to handle with it.
	 * @author	Kleber Lopes da Silva (kleber.swf)
	 */
	public class MouseInputComponent extends EntityComponent
	{
		
		
		//==========================================================
		//   Fields 
		//==========================================================
		
		protected var _visible:Boolean = true;
		
		protected var _enabled:Boolean = true;
		
		/**
		 * Higher values makes the component handle the mouse event before another components under the same mouse position.
		 */
		public var layerIndex:int = 0;
		
		/**
		 * Renderer which boundaries are verified on events. If set, ignores <code>position</code>, <code>positionProperty</code>, <code>positionOffset</code>, <code>positionOffsetProperty</code>, <code>size</code> and <code>sizeProperty</code> for contains checks.
		 */
		public var renderer:DisplayObjectRenderer;
		
		/**
		 * Component position. Ignored when <code>renderer</code> is set.
		 * @default (0,0)
		 */
		public var position:Point = new Point();
		
		/**
		 * Property where to get the position. Ignored when <code>renderer</code> is set.
		 */
		public var positionProperty:PropertyReference;
		
		/**
		 * Point to sum to position to get the real position. Ignored when <code>renderer</code> is set.
		 */
		public var positionOffset:Point;
		
		/**
		 * Property where to get the position offset. Ignored when <code>renderer</code> is set.
		 */
		public var positionOffsetProperty:PropertyReference;
		
		/**
		 * Size of the component. Ignored when <code>renderer</code> is set.
		 */
		public var size:Point;
		
		/**
		 * Property where to get the size. Ignored when <code>renderer</code> is set.
		 */
		public var sizeProperty:PropertyReference;
		
		/**
		 * A function that will be called when the mouse is just pressed.
		 * This is special for cases when you don't want to extend the MouseInputComponent class.
		 * The signature for the function must be function(data:MouseInputData):Boolean
		 * @see MouseInputData
		 */
		public var mouseDownFunction:Function;
		
		/**
		 * A function that will be called when the mouse is just pressed.
		 * This is special for cases when you don't want to extend the MouseInputComponent class.
		 * The signature for the function must be function(data:MouseInputData):Boolean
		 * @see MouseInputData
		 */
		public var mouseUpFunction:Function;
		
		
		//==========================================================
		//   Properties 
		//==========================================================
		
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		public function set enabled(value:Boolean):void
		{
			_enabled = value;
		}
		
		private function get scenePlace():Rectangle
		{
			var pos:Point = scenePosition;
			var size:Point = owner.getProperty(sizeProperty, size) as Point;
			return new Rectangle(pos.x - (size.x * 0.5), pos.y - (size.y * 0.5), size.x, size.y);
		}
		
		/**
		 * Gets the position of this component relative to the scene.
		 */
		public function get scenePosition():Point
		{
			if (renderer)
			{
				return renderer.position;
			}
			var pos:Point = owner.getProperty(positionProperty, position) as Point;
			var offset:Point = owner.getProperty(positionOffsetProperty, positionOffset) as Point;
			if (offset)
			{
				pos = pos.add(offset);
			}
			return pos;
		}
		
		public function get visible():Boolean
		{
			return renderer && renderer.displayObject ? renderer.displayObject.visible : _visible;
		}
		
		public function set visible(value:Boolean):void
		{
			_visible = value;
			if (renderer)
			{
				renderer.alpha = value ? 1 : 0;
			}
		}
		
		
		//==========================================================
		//   Functions 
		//==========================================================
		
		protected override function onAdd():void
		{
			if (isRegistered)
			{
				return;
			}
			PBE.mouseInputManager.addComponent(this);
			if (!(renderer || sizeProperty || size))
			{
				Logger.fatal(this, "onAdd", "Mouse component on [" + owner.name + " -> " + this.name + "] without place for check. Set renderer, sizeProperty or size on this component.");
			}
		}
		
		protected override function onRemove():void
		{
			super.onRemove();
			PBE.mouseInputManager.removeComponent(this);
			renderer = null;
		}
		
		/**
		 * Verifies whether this component contains the given point.
		 * @param scenePoint Point on the scene to verify.
		 * @return Whether this component contains <code>scenePoint</code>.
		 */
		public function contains(scenePoint:Point):Boolean
		{
			if (renderer)
			{
				return renderer.pointOccupied(scenePoint, null);
			}
			return scenePlace.contains(scenePoint.x, scenePoint.y);
		}
		
		internal function mouseDown(data:MouseInputData):Boolean
		{
			var a:Boolean = mouseDownFunction != null ? (mouseDownFunction(data)) : true;
			var b:Boolean = onMouseDown(data);
			return a && b;
		}
		
		internal function mouseUp(data:MouseInputData):Boolean
		{
			var a:Boolean = mouseUpFunction != null ? (mouseUpFunction(data)) : true;
			var b:Boolean = onMouseUp(data);
			return a && b;
		}
		
		/**
		 * Called when the mouse is just pressed. Overrite it to make specific implementations.
		 * @param data	Mouse data for this event.
		 * @return Whether the event flow should pass through this component after its execution.
		 * @see MouseInputManager
		 */
		protected function onMouseDown(data:MouseInputData):Boolean
		{
			return true;
		}
		
		/**
		 * Called when the mouse is just released. Overrite it to make specific implementations.
		 * @param data	Mouse data for this event.
		 * @return Whether the event flow should pass through this component after its execution.
		 * @see MouseInputManager
		 */
		protected function onMouseUp(data:MouseInputData):Boolean
		{
			return true;
		}
	}
}
