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
	
	public class MouseInputComponent extends TickedComponent implements IMouseInputComponent
	{
		
		
		//==========================================================
		//   Fields 
		//==========================================================
		
		private var _sceneBounds:Rectangle = new Rectangle();
		private var _position:Point = new Point();
		private var _positionOffset:Point = new Point();
		private var _size:Point = new Point();
		private var _draggable:Boolean = false;
		private var _acceptDrop:Boolean = false;
		
		private var _dirty:Boolean;
		private var _renderer:DisplayObjectRenderer;
		protected var _eventDispatcher:IEventDispatcher = new EventDispatcher();
		
		protected var _priority:int = 0;
		protected var _enabled:Boolean = true;
		
		/** TEST */
		public var fc:uint;
		public var sizeProperty:PropertyReference;
		public var positionProperty:PropertyReference;
		public var positionOffsetProperty:PropertyReference;
		
		
		//==========================================================
		//   Properties 
		//==========================================================
		
		public function get acceptDrop():Boolean
		{
			return _acceptDrop;
		}
		
		public function set acceptDrop(value:Boolean):void
		{
			_acceptDrop = value;
		}
		
		public function get draggable():Boolean
		{
			return _draggable;
		}
		
		public function set draggable(value:Boolean):void
		{
			_draggable = value;
		}
		
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		public function set enabled(value:Boolean):void
		{
			_enabled = value;
		}
		
		public function get eventDispatcher():IEventDispatcher
		{
			return _eventDispatcher;
		}
		
		public function get position():Point
		{
			return _position;
		}
		
		public function set position(value:Point):void
		{
			_position = value;
			_dirty = true;
		}
		
		public function get positionOffset():Point
		{
			return _positionOffset;
		}
		
		public function set positionOffset(value:Point):void
		{
			_positionOffset = value;
			_dirty = true;
		}
		
		public function get priority():int
		{
			return _priority;
		}
		
		public function set priority(value:int):void
		{
			_priority = value;
		}
		
		public function set renderer(value:DisplayObjectRenderer):void
		{
			_renderer = value;
			_position = value.position;
			positionProperty = value.positionProperty;
			_positionOffset = value.positionOffset;
			positionOffsetProperty = value.positionOffsetProperty;
			sizeProperty = null;
		}
		
		public function get sceneBounds():Rectangle
		{
			return _sceneBounds;
		}
		
		public function get size():Point
		{
			return _size;
		}
		
		public function set size(value:Point):void
		{
			_size = value;
			_dirty = true;
		}
		
		
		//==========================================================
		//   Functions 
		//==========================================================
		
		protected override function onAdd():void
		{
			super.onAdd();
			PBE.mouseInputManager.addComponent(this);
		}
		
		protected override function onRemove():void
		{
			super.onRemove();
			_sceneBounds = null;
			_position = null;
			_size = null;
			_renderer = null;
			PBE.mouseInputManager.removeComponent(this);
		}
		
		private function updateBounds():void
		{
			_sceneBounds.x = _position.x + _positionOffset.x - _size.x * 0.5;
			_sceneBounds.y = _position.y + _positionOffset.y - _size.y * 0.5;
			_sceneBounds.width = _size.x;
			_sceneBounds.height = _size.y;
			//PBE.mouseInputManager.redraw();
			_dirty = false;
		}
		
		public function contains(point:Point):Boolean
		{
			return _renderer ? _renderer.pointOccupied(point, null) : _sceneBounds.containsPoint(point);
		}
		
		public override function onTick(deltaTime:Number):void
		{
			super.onTick(deltaTime);
			updateProperties();
			if (_dirty)
			{
				updateBounds();
			}
		}
		
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
		
		public function canDrop(data:IMouseInputComponent):Boolean
		{
			return _acceptDrop;
		}
		
		public function canDrag(data:IMouseInputComponent):Boolean
		{
			return _draggable;
		}
	}
}
