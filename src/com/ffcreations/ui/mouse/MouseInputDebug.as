package com.ffcreations.ui.mouse
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.components.TickedComponent;
	import com.pblabs.rendering2D.DisplayObjectRenderer;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public final class MouseInputDebug extends DisplayObjectRenderer
	{
		
		
		//==========================================================
		//   Fields 
		//==========================================================
		
		private var _manager:MouseInputManager;
		private var _graphics:Graphics;
		
		
		//==========================================================
		//   Functions 
		//==========================================================
		
		protected override function onAdd():void
		{
			super.onAdd();
			_manager = PBE.mouseInputManager;
			displayObject = new Sprite();
			_graphics = Sprite(displayObject).graphics;
		}
		
		public override function onFrame(elapsed:Number):void
		{
			super.onFrame(elapsed);
			if (!_displayObject)
			{
				return;
			}
			_graphics.clear();
			
			var bounds:Rectangle;
			var components:Array = _manager.getComponents();
			var color:uint;
			for each (var component:IMouseInputComponent in components)
			{
				if (!component.enabled)
				{
					continue;
				}
				bounds = component.sceneBounds;
				if (!bounds)
				{
					continue;
				}
				
				if (component.draggable)
				{
					color = 0x00FF00;
				}
				else if (component.acceptDrop)
				{
					color = 0x0000FF;
				}
				else
				{
					color = 0xFF0000;
				}
				
				_graphics.lineStyle(1, color, 0.5);
				_graphics.beginFill(color, 0.3);
				_graphics.drawRect(bounds.x, bounds.y, bounds.width, bounds.height);
				_graphics.endFill();
				
			}
		}
	}
}
