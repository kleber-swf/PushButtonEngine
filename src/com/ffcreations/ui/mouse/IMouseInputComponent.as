package com.ffcreations.ui.mouse
{
	import com.pblabs.engine.entity.IEntityComponent;
	
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * Interface that must be implemented to handle with mouse inputs.
	 * When implementing this interface, you should add the component to
	 * <code>PBE.mouseInputManager</code> to make it renpond to mouse events
	 * and remove it from the same class when it's not used anymore.
	 * When updating its priority, the <code>MouseInputManager</code> must
	 * be informed too.
	 *
	 * @see com.ffcreations.ui.mouse.MouseInputManager#addComponent
	 * @see com.ffcreations.ui.mouse.MouseInputManager#removeComponent
	 * @see com.ffcreations.ui.mouse.MouseInputManager#updatePriority
	 *
	 * @author Kleber Lopes da Silva (kleber.swf)
	 */
	public interface IMouseInputComponent extends IEntityComponent
	{
		/** Whether the component should accept drop of other <code>IMouseInputComponent</code>'s. */
		function get acceptDrop():Boolean;
		/** @private */
		function set acceptDrop(value:Boolean):void;
		
		/** Whether the component can be dragged. */
		function get draggable():Boolean;
		/** @private */
		function set draggable(value:Boolean):void;
		
		/** Whether the component is dragging. */
		function get dragging():Boolean;
		/** @private */
		function set dragging(value:Boolean):void;
		
		/** Whether the component is enabledand respond to mouse inputs. */
		function get enabled():Boolean;
		/** @private */
		function set enabled(value:Boolean):void;
		
		/** EventDispatcher where the mouse events are dispatched. */
		function get eventDispatcher():IEventDispatcher;
		
		/** Position of the component. */
		function get position():Point;
		/** @private */
		function set position(value:Point):void;
		
		/** Scene bounds of the component. */
		function get sceneBounds():Rectangle;
		
		/** Mouse component that contains this component (drag and drop). */
		function get container():IMouseInputComponent;
		/** @private */
		function set container(value:IMouseInputComponent):void;

		/**
		 * Priority of the component. If two or more components are ready to respond to a
		 * mouse event, the one with the highest priority will do it first.
		 */
		function get priority():int;
		/** @private */
		function set priority(value:int):void;
		
		/**
		 * Whether this component contains the given point.
		 * @param point	The point to check.
		 * @return <code>True</code> if the component contains the <code>point</code> or <code>false</code> if not.
		 */
		function contains(point:Point):Boolean;
		
		/**
		 * Whether this component can be draggad at the moment that the drag starts.
		 * @return <code>True</code> if can be dragged, or <code>false</code> otherwise.
		 */
		function canDrag():Boolean;
		
		/**
		 * If this component accepts drop, this method is called when a <code>IMouseInputComponent</code>
		 * is about to be dropped inside it.
		 * @param component	The <code>IMouseInputComponent</code> that is dropped inside this component.
		 * @return <code>True</code> if the given <code>IMouseInputComponent</code> can be dropped inside
		 * this component or <code>false</code> otherwise.
		 */
		function canDrop(component:IMouseInputComponent):Boolean;
	}
}
