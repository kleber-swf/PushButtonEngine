package com.ffcreations.ui.components
{
	import com.ffcreations.ui.mouse.MouseInputData;
	import com.ffcreations.util.DelegateContainer;
	import com.pblabs.engine.components.TickedComponent;
	import com.pblabs.engine.entity.EntityComponent;
	import com.pblabs.engine.entity.PropertyReference;
	
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public class ToggleGroup extends TickedComponent
	{
		
		
		//==========================================================
		//   Static 
		//==========================================================
		
		public static const SELECTION_CHANGED:String = "selectionChanged";
		
		
		//==========================================================
		//   Fields 
		//==========================================================
		
		private var _options:Array;
		private var _maxSelection:int = -1;
		private var _selectedIndex:int = -1;
		private var _delegateContainer:DelegateContainer = new DelegateContainer();
		private var _layerIndex:int = 0;
		private var _position:Point = new Point();
		private var _pos:Point = new Point();
		public var positionOffset:Point = new Point();
		public var positionProperty:PropertyReference;
		
		
		//==========================================================
		//   Properties 
		//==========================================================
		
		public function get layerIndex():int
		{
			return _layerIndex;
		}
		
		public function set layerIndex(value:int):void
		{
			if (_layerIndex == value)
			{
				return;
			}
			_layerIndex = value;
			for each (var opt:Toggle in _options)
			{
				opt.layerIndex = value;
			}
		}
		
		public function set options(value:Array):void
		{
			var i:int;
			var length:int;
			if (_options != null)
			{
				for (i = 0, length = _options.length; i < length; i++)
				{
					_options.pop().delegateContainer.removeDelegateCallback(MouseEvent.MOUSE_UP, onSelect);
				}
				_options = null;
			}
			
			if (value == null)
			{
				_options = null;
				return;
			}
			length = value.length;
			_options = new Array(length);
			var opt:Toggle;
			for (i = 0; i < length; i++)
			{
				opt = value[i];
				opt.delegateContainer.addCallback(MouseEvent.MOUSE_UP, onSelect);
				opt.group();
				_options[i] = opt;
			}
		}
		
		public function get position():Point
		{
			return _position;
		}
		
		public function set position(value:Point):void
		{
			_pos = value;
		}
		
		public function get selectedIndex():int
		{
			return _selectedIndex;
		}
		
		public function set selectedIndex(value:int):void
		{
			if (_selectedIndex == value)
			{
				return;
			}
			for (var i:int = 0; i < _options.length; i++)
			{
				_options[i].selected = i == value;
			}
			_selectedIndex = value;
			_delegateContainer.call(SELECTION_CHANGED, value);
		}
		
		
		//==========================================================
		//   Functions 
		//==========================================================
		
		protected override function onRemove():void
		{
			for (var i:int = 0, length:int = _options.length; i < length; i++)
			{
				_options.pop().delegateContainer.removeDelegateCallback(MouseEvent.MOUSE_UP, onSelect);
			}
			_options = null;
			_delegateContainer.clear();
			_delegateContainer = null;
			super.onRemove();
		}
		
		private function onSelect(data:MouseInputData):void
		{
			selectedIndex = _options.indexOf(data.component);
		}
		
		public override function onTick(deltaTime:Number):void
		{
			super.onTick(deltaTime);
			updateProperties();
		}
		
		protected function updateProperties():void
		{
			if (positionProperty)
			{
				var pos:Point = owner.getProperty(positionProperty, _pos);
				if (pos.x != _pos.x && pos.y != _pos.y)
				{
					_position = pos.add(positionOffset);
				}
			}
		}
	}
}
