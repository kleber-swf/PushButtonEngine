

package com.ffcreations.ui.mouse
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.engine.entity.EntityComponent;
	import com.pblabs.engine.entity.PropertyReference;
	import com.pblabs.rendering2D.DisplayObjectRenderer;
	
	import flash.events.MouseEvent;
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
		 * Called when the mouse is just pressed.
		 * Set this to make a specific mouse down behaviour without extending <code>MouseInputComponent</code> class.
		 */
		public var mouseDownFunction:Function;
		
		/**
		 * Called when the mouse is just released.
		 * Set this to make a specific mouse up behaviour without extending <code>MouseInputComponent</code> class.
		 */
		public var mouseUpFunction:Function;
		
		
		//==========================================================
		//   Properties 
		//==========================================================
		
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
				Logger.error(this, "onAdd", "Mouse component on [" + owner.name + " -> " + this.name + "] without place for check. Set renderer, sizeProperty or size on this component.");
				throw new Error();
			}
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
		
		//--------------------------------------
		//   Event handlers 
		//--------------------------------------
		
		internal function mouseDown(event:MouseEvent):Boolean
		{
			var f:Boolean = mouseDownFunction != null ? mouseDownFunction(event) : true;
			return onMouseDown(event) && f;
		}
		
		internal function mouseUp(event:MouseEvent):Boolean
		{
			var f:Boolean = mouseUpFunction != null ? mouseUpFunction(event) : true;
			return onMouseUp(event) && f;
		}
		
		/**
		 * Called when the mouse is just pressed. Overrite it to make specific implementations.
		 * @param event The Flash Mouse Event (MouseEvent.MOUSE_DOWN);
		 * @return Whether the event flow should pass through this component after its execution.
		 * @see MouseInputManager
		 */
		public function onMouseDown(event:MouseEvent):Boolean
		{
			return true;
		}
		
		/**
		 * Called when the mouse is just released. Overrite it to make specific implementations.
		 * @param event The Flash Mouse Event (MouseEvent.MOUSE_UP);
		 * @return Whether the event flow should pass through this component after its execution.
		 * @see MouseInputManager
		 */
		public function onMouseUp(event:MouseEvent):Boolean
		{
			return true;
		}
	}
}
