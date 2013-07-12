/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.box2D {
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.V2;
	import Box2DAS.Common.b2Vec2;
	import Box2DAS.Dynamics.b2FixtureDef;
	
	import flash.geom.Point;
	
	public class CircleCollisionShape extends CollisionShape {
		
		[EditorData(defaultValue="1")]
		public function get radius():Number { return _radius; }
		
		public function set radius(value:Number):void {
			_radius = value;
			
			if (_parent)
				_parent.buildCollisionShapes();
		}
		
		public function get position():Point { return _position; }
		
		public function set position(value:Point):void {
			_position = value;
			
			if (_parent)
				_parent.buildCollisionShapes();
		}
		
		override protected function doCreateShape():b2FixtureDef {
			var scale:Number = (_parent.spatialManager as Box2DManagerComponent).inverseScale;
			
			var fixture:b2FixtureDef = super.doCreateShape();
			var shape:b2CircleShape = new b2CircleShape();
			shape.m_radius = _radius * scale;
			shape.m_p.x = _position.x * scale;
			shape.m_p.y = _position.y * scale;
			fixture.shape = shape;
			
			return fixture;
		}
		
		private var _radius:Number = 20.0;
		private var _position:Point = new Point(0, 0);
	}
}
