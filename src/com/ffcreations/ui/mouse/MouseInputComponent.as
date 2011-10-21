package com.ffcreations.ui.mouse
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.components.TickedComponent;
	import com.pblabs.engine.entity.PropertyReference;
	import com.pblabs.rendering2D.DisplayObjectRenderer;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * Default <code>IMouseInpuComponent</code> implementation.
	 * Automatically registers/unregister itself in <code>MouseInpuManager</code>.
	 * @author Kleber Lopes da Silva (kleber.swf)
	 */
	public class MouseInputComponent extends TickedComponent implements IMouseInputComponent
	{
		
		
		//==========================================================
		//   Fields 
		//==========================================================
		
		protected var _sceneBounds:Rectangle = new Rectangle();
		protected var _position:Point = new Point();
		protected var _positionOffset:Point = new Point();
		protected var _size:Point = new Point();
		protected var _draggable:Boolean;
		protected var _dragging:Boolean;
		protected var _acceptDrop:Boolean;
		protected var _dirty:Boolean;
		protected var _renderer:DisplayObjectRenderer;
		protected var _eventDispatcher:IEventDispatcher = new EventDispatcher();
		protected var _priority:int = 0;
		protected var _enabled:Boolean = true;
		protected var _container:IMouseInputComponent;
		
		/**
		 * If set, size is determined by this property every frame.
		 */
		public var sizeProperty:PropertyReference;
		
		/**
		 * If set, position is determined by this property every frame.
		 */
		public var positionProperty:PropertyReference;
		
		/**
		 * If set, positionOffset is determined by this property every frame.
		 */
		public var positionOffsetProperty:PropertyReference;
		
		
		//==========================================================
		//   Properties 
		//==========================================================
		
		/**
		 * @inheritDoc
		 */
		public function get acceptDrop():Boolean
		{
			return _acceptDrop;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set acceptDrop(value:Boolean):void
		{
			_acceptDrop = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get container():IMouseInputComponent
		{
			return _container;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set container(value:IMouseInputComponent):void
		{
			_container = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get draggable():Boolean
		{
			return _draggable;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set draggable(value:Boolean):void
		{
			_draggable = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get dragging():Boolean
		{
			return _dragging;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set dragging(value:Boolean):void
		{
			_dragging = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set enabled(value:Boolean):void
		{
			_enabled = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get eventDispatcher():IEventDispatcher
		{
			return _eventDispatcher;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get position():Point
		{
			return _position;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set position(value:Point):void
		{
			_position = value;
			_dirty = true;
		}
		
		/**
		 * The point that offsets the position
		 */
		public function get positionOffset():Point
		{
			return _positionOffset;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set positionOffset(value:Point):void
		{
			_positionOffset = value;
			_dirty = true;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get priority():int
		{
			return _priority;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set priority(value:int):void
		{
			_priority = value;
			if (isRegistered)
			{
				PBE.mouseInputManager.updatePriority(this);
			}
		}
		
		/**
		 * <code>DisplayObjectRenderer</code> to verifies if the mouse is inside.
		 */
		public function get renderer():DisplayObjectRenderer
		{
			return _renderer;
		}
		
		/**
		 * @private
		 */
		public function set renderer(value:DisplayObjectRenderer):void
		{
			_renderer = value;
			if (isRegistered)
			{
				_renderer.positionProperty = new PropertyReference("#" + owner.name + "." + name + ".position");
				_renderer.positionOffsetProperty = new PropertyReference("#" + owner.name + "." + name + ".positionOffset");
			}
			//			_position = value.position;
			//			positionProperty = value.positionProperty;
			//			_positionOffset = value.positionOffset;
			//			positionOffsetProperty = value.positionOffsetProperty;
			//			sizeProperty = null;
		
		
		}
		
		/**
		 * Gets the bounds of this component (in scene coordinates).
		 */
		public function get sceneBounds():Rectangle
		{
			return _sceneBounds;
		}
		
		/**
		 * Size of this component.
		 */
		public function get size():Point
		{
			return _size;
		}
		
		/**
		 * @private
		 */
		public function set size(value:Point):void
		{
			_size = value;
			_dirty = true;
		}
		
		
		//==========================================================
		//   Functions 
		//==========================================================
		
		/**
		 * @inheritDoc
		 */
		protected override function onAdd():void
		{
			super.onAdd();
			PBE.mouseInputManager.addComponent(this);
			if (_renderer)
			{
				_renderer.positionProperty = new PropertyReference("#" + owner.name + "." + name + ".position");
				_renderer.positionOffsetProperty = new PropertyReference("#" + owner.name + "." + name + ".positionOffset");
			}
		}
		
		/**
		 * @inheritDoc
		 */
		protected override function onRemove():void
		{
			_sceneBounds = null;
			_position = null;
			_positionOffset = null;
			_size = null;
			_renderer = null;
			_container = null;
			_eventDispatcher = null;
			sizeProperty = null;
			positionProperty = null;
			positionOffsetProperty = null;
			PBE.mouseInputManager.removeComponent(this);
			super.onRemove();
		}
		
		private function updateBounds():void
		{
			if (_renderer)
			{
				_sceneBounds = _renderer.sceneBounds;
				if (!_sceneBounds)
				{
					return;
				}
				_sceneBounds.x = _position.x + _positionOffset.x - _sceneBounds.width * 0.5;
				_sceneBounds.y = _position.y + _positionOffset.y - _sceneBounds.height * 0.5;
			}
			else
			{
				_sceneBounds.x = _position.x + _positionOffset.x - _size.x * 0.5;
				_sceneBounds.y = _position.y + _positionOffset.y - _size.y * 0.5;
				_sceneBounds.width = _size.x;
				_sceneBounds.height = _size.y;
			}
			_dirty = false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function contains(point:Point):Boolean
		{
			return _renderer ? _renderer.pointOccupied(point, null) : _sceneBounds.containsPoint(point);
		}
		
		/**
		 * @inheritDoc
		 */
		public override function onTick(deltaTime:Number):void
		{
			super.onTick(deltaTime);
			updateProperties();
			if (_dirty)
			{
				updateBounds();
			}
		}
		
		/**
		 * Updates the *Properties fields.
		 */
		protected function updateProperties():void
		{
			if (sizeProperty)
			{
				var s:Point = owner.getProperty(sizeProperty, _size);
				if (s.x != _size.x || s.y != _size.y)
				{
					size = s;
				}
			}
			
			if (positionProperty)
			{
				var p:Point = owner.getProperty(positionProperty, _position);
				if (p.x != _position.x || p.y != _position.y)
				{
					position = p;
				}
			}
			
			if (positionOffsetProperty)
			{
				var o:Point = owner.getProperty(positionOffsetProperty, _positionOffset);
				if (o.x != _positionOffset.x || o.y != _positionOffset.y)
				{
					positionOffset = o;
				}
			}
		}
		
		/**
		 * If this component accepts drop, this method is called when a <code>IMouseInputComponent</code>
		 * is about to be dropped inside it.
		 * @param component	The <code>IMouseInputComponent</code> that is dropped inside this component.
		 * @return <code>True</code> if the given <code>IMouseInputComponent</code> can be dropped inside
		 * this component or <code>false</code> otherwise.
		 * @default The value in <code>acceptDrop</code> field.
		 */
		public function canDrop(component:IMouseInputComponent):Boolean
		{
			return _acceptDrop;
		}
		
		/**
		 * Whether this component can be draggad at the moment that the drag starts.
		 * @return <code>True</code> if can be dragged, or <code>false</code> otherwise.
		 * @default The value in <code>draggable</code> field.
		 */
		public function canDrag():Boolean
		{
			return _draggable;
		}
	}
}
