package com.ffcreations.rendering2D {
	import com.pblabs.engine.entity.EntityComponent;
	
	import flash.geom.Point;
	
	public class SimplestSpatialComponent extends EntityComponent {
		/**
		 * Component position.
		 */
		public var position:Point = new Point();
		
		/**
		 * Component size.
		 */
		public var size:Point = new Point(100, 100);
	}
}
