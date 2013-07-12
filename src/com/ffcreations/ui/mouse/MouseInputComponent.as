package com.ffcreations.ui.mouse {
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
	public class MouseInputComponent extends TickedComponent implements IMouseInputComponent {
		
		protected var _sceneBounds:Rectangle = new Rectangle();
		protected var _position:Point = new Point();
		protected var _positionOffset:Point = new Point();
		protected var _size:Point = null;
		protected var _draggable:Boolean;
		protected var _dragging:Boolean;
		protected var _acceptDrop:Boolean;
		protected var _dirty:Boolean;
		protected var _renderer:DisplayObjectRenderer;
		protected var _eventDispatcher:IEventDispatcher = new EventDispatcher();
		protected var _priority:int = 0;
		protected var _enabled:Boolean = true;
		protected var _container:IMouseInputComponent;
		protected var _pixelPrecise:Boolean = true;
		protected var _lockCenter:Boolean;
		protected var _canDrop:Boolean = true;
		protected var _inputBounds:Rectangle;
		protected var _copyRendererPosition:Boolean;
		
		/** If set, <code>size</code> is determined by this property every frame. */
		public var sizeProperty:PropertyReference;
		
		/** If set, <code>position</code> is determined by this property every frame. */
		public var positionProperty:PropertyReference;
		
		/** If set, <code>positionOffset</code> is determined by this property every frame. */
		public var positionOffsetProperty:PropertyReference;
		
		/** If set, <code>enabled</code> is determined by this property every frame. */
		public var enabledProperty:PropertyReference;
		
		/** @inheritDoc */
		public function get acceptDrop():Boolean { return _acceptDrop; }
		
		/** @inheritDoc */
		public function set acceptDrop(value:Boolean):void { _acceptDrop = value; }
		
		/** @inheritDoc */
		public function get canDrop():Boolean { return _canDrop; }
		
		/** @inheritDoc */
		public function set canDrop(value:Boolean):void { _canDrop = value; }
		
		/** @inheritDoc */
		public function get container():IMouseInputComponent { return _container; }
		
		/** @inheritDoc */
		public function set container(value:IMouseInputComponent):void { _container = value; }
		
		/**
		 * When setting <code>renderer</code> property, the <code>position</code> and
		 * <code>positionProperty</code> should be copied from or to this component.
		 * When this property is <code>false</code>, the component copies its
		 * <code>position</code> and <code>positionOffset</code> to the
		 * <code>renderer</code>. If <code>true</code>, the <code>renderer</code>
		 * copies its <code>position</code> and <code>positionOffset</code> to this
		 * component.
		 * @default false
		 * @see #renderer
		 */
		public function get copyRendererPosition():Boolean { return _copyRendererPosition; }
		
		/** @private */
		public function set copyRendererPosition(value:Boolean):void {
			_copyRendererPosition = value;
			if (isRegistered)
				setupRenderer();
		}
		
		/** @inheritDoc */
		public function get draggable():Boolean { return _draggable; }
		
		/** @inheritDoc */
		public function set draggable(value:Boolean):void { _draggable = value; }
		
		/** @inheritDoc */
		public function get dragging():Boolean { return _dragging; }
		
		/** @inheritDoc */
		public function set dragging(value:Boolean):void { _dragging = value; }
		
		/** @inheritDoc */
		public function get enabled():Boolean { return _enabled; }
		
		/** @inheritDoc */
		public function set enabled(value:Boolean):void { _enabled = value; }
		
		/** @inheritDoc */
		public function get eventDispatcher():IEventDispatcher { return _eventDispatcher; }
		
		/** @inheritDoc */
		public function get inputBounds():Rectangle { return _inputBounds; }
		
		/** @inheritDoc */
		public function set inputBounds(value:Rectangle):void {
			_inputBounds = value;
			pixelPrecise = value == null
		}
		
		/** @inheritDoc */
		public function get lockCenter():Boolean { return _lockCenter; }
		
		/** @inheritDoc */
		public function set lockCenter(value:Boolean):void { _lockCenter = value; }
		
		/** @inheritDoc */
		public function get pixelPrecise():Boolean { return _pixelPrecise; }
		
		/** @inheritDoc */
		public function set pixelPrecise(value:Boolean):void {
			_pixelPrecise = value;
			_dirty = true;
		}
		
		/** @inheritDoc */
		public function get position():Point { return _position; }
		
		/** @inheritDoc */
		public function set position(value:Point):void {
			_position = value;
			_dirty = true;
		}
		
		/** The point that offsets the position */
		public function get positionOffset():Point { return _positionOffset; }
		
		/** @inheritDoc */
		public function set positionOffset(value:Point):void {
			_positionOffset = value;
			_dirty = true;
		}
		
		/** @inheritDoc */
		public function get priority():int { return _priority; }
		
		/** @inheritDoc */
		public function set priority(value:int):void {
			_priority = value;
			if (isRegistered)
				PBE.mouseInputManager.updatePriority(this);
		}
		
		/**
		 * <code>DisplayObjectRenderer</code> to verifies if the mouse is inside.
		 * When setting this property, check the <code>copyRendererPosition</code>
		 * to see if the <code>position</code> and <code>positionOffset</code> will
		 * be copied from or to the <code>DisplayObjectRenderer</code>.
		 * @see #copyRendererPosition
		 */
		public function get renderer():DisplayObjectRenderer { return _renderer; }
		
		/** @private */
		public function set renderer(value:DisplayObjectRenderer):void {
			_renderer = value;
			if (isRegistered)
				setupRenderer()
			//			_position = value.position;
			//			positionProperty = value.positionProperty;
			//			_positionOffset = value.positionOffset;
			//			positionOffsetProperty = value.positionOffsetProperty;
			//			sizeProperty = null;
		}
		
		/** Gets the bounds of this component (in scene coordinates). */
		public function get sceneBounds():Rectangle { return _sceneBounds; }
		
		/** Size of this component. */
		public function get size():Point { return _size; }
		
		/** @private */
		public function set size(value:Point):void {
			_size = value;
			_dirty = true;
		}
		
		private function setupRenderer():void {
			if (_copyRendererPosition) {
				positionProperty = new PropertyReference("#" + _renderer.owner.name + "." + _renderer.name + ".position");
				positionOffsetProperty = new PropertyReference("#" + _renderer.owner.name + "." + _renderer.name + ".positionOffset");
			} else {
				_renderer.positionProperty = new PropertyReference("#" + owner.name + "." + name + ".position");
				_renderer.positionOffsetProperty = new PropertyReference("#" + owner.name + "." + name + ".positionOffset");
			}
		}
		
		/** @inheritDoc */
		protected override function onAdd():void {
			super.onAdd();
			PBE.mouseInputManager.addComponent(this);
			if (_renderer)
				setupRenderer();
		}
		
		/** @inheritDoc */
		protected override function onRemove():void {
			_sceneBounds = null;
			_position = null;
			_positionOffset = null;
			_size = null;
			_renderer = null;
			_container = null;
			//_eventDispatcher = null;
			sizeProperty = null;
			positionProperty = null;
			positionOffsetProperty = null;
			PBE.mouseInputManager.removeComponent(this);
			super.onRemove();
		}
		
		protected function updateBounds():void {
			if (_inputBounds) {
				var pos:Point = _position.add(_positionOffset);
				_sceneBounds.x = pos.x + _inputBounds.x;
				_sceneBounds.y = pos.y + _inputBounds.y;
				_sceneBounds.width = _inputBounds.width;
				_sceneBounds.height = _inputBounds.height;
				_dirty = false;
				return;
			}
			if (_pixelPrecise && _renderer) {
				_sceneBounds = _renderer.sceneBounds;
				if (!_sceneBounds)
					return;
				_sceneBounds.width *= _renderer.scale.x;
				_sceneBounds.height *= _renderer.scale.y;
				_sceneBounds.x = _position.x + _positionOffset.x - _sceneBounds.width * 0.5;
				_sceneBounds.y = _position.y + _positionOffset.y - _sceneBounds.height * 0.5;
			} else {
				var s:Point;
				if (_size && _size.x > 0 && _size.y > 0)
					s = _size;
				else if (_renderer) {
					if (_renderer.size)
						s = _renderer.size;
					else if (_renderer.displayObject)
						s = new Point(_renderer.displayObject.width, _renderer.displayObject.height);
					else
						return;
				} else
					return;
				_sceneBounds.x = _position.x + _positionOffset.x - s.x * 0.5;
				_sceneBounds.y = _position.y + _positionOffset.y - s.y * 0.5;
				_sceneBounds.width = s.x;
				_sceneBounds.height = s.y;
				
			}
			_dirty = false;
		}
		
		/** @inheritDoc */
		public function contains(point:Point):Boolean {
			return _pixelPrecise && _renderer ? _renderer.pointOccupied(point, null) : _sceneBounds.containsPoint(point);
		}
		
		/** @inheritDoc */
		public override function onTick(deltaTime:Number):void {
			updateProperties();
			if (_dirty)
				updateBounds();
		}
		
		/** Updates the *Properties fields. */
		protected function updateProperties():void {
			if (sizeProperty) {
				var s:Point = owner.getProperty(sizeProperty);
				if (s)
					size = s;
			}
			
			if (positionProperty) {
				var p:Point = owner.getProperty(positionProperty);
				if (p)
					position = p;
			}
			
			if (positionOffsetProperty) {
				var o:Point = owner.getProperty(positionOffsetProperty);
				if (o)
					positionOffset = o;
			}
			
			if (enabledProperty) {
				var e:Boolean = owner.getProperty(enabledProperty);
				if (e != _enabled)
					enabled = e;
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
		public function canDropItem(component:IMouseInputComponent):Boolean {
			return _acceptDrop;
		}
		
		/**
		 * Whether this component can be draggad at the moment that the drag starts.
		 * @return <code>True</code> if can be dragged, or <code>false</code> otherwise.
		 * @default The value in <code>draggable</code> field.
		 */
		public function canDrag():Boolean {
			return _draggable;
		}
		
		/** @inheritDoc */
		public function cancelInput():void {
		
		}
	}
}
