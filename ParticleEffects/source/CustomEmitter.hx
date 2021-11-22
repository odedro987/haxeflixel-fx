package;

import Types.EmitterPath;
import Types.EmitterType;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil;

class CustomEmitter extends FlxEmitter
{
	private var type:EmitterType;
	private var pathType:EmitterPath;

	// Variables for emitting behaviors
	private var emitBehavior:Float->Void;
	private var maxSpread:Int;
	private var spinSpeed:Int;
	private var currEmitAngle:Float;
	private var isSpinning:Bool;
	private var emitterSpin:Float->Void;
	private var isMultiShoot:Bool;
	private var multiShootAngle:Float;
	private var emitterMultiShoot:Float->Void;

	// Variables for emitter paths
	private var emitterPath:Float->Void;
	private var originPos:FlxPoint;
	private var pathWalkSpeed:Int;
	private var pathPoints:Array<FlxPoint>;
	private var currPathPoint:Int;
	private var currPathAngle:Float;
	private var isRelativeParticles:Bool;

	public function new(x:Float, y:Float, size:Int)
	{
		super(x, y, size);
		originPos = FlxPoint.get();
		originPos.set(x, y);
		pathPoints = [];

		// Temporary paritcles
		makeParticles(4, 4);
	}

	public function emit(frequency:Float = 0.1)
	{
		start(false, frequency);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (isMultiShoot)
			emitterMultiShoot(elapsed);
		if (isSpinning)
			emitterSpin(elapsed);
		if (emitBehavior != null)
			emitBehavior(elapsed);
		if (emitterPath != null)
			emitterPath(elapsed);
	}

	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		emitBehavior = null;
		emitterPath = null;
		emitterMultiShoot = null;
		emitterSpin = null;

		FlxDestroyUtil.put(originPos);

		for (point in pathPoints)
		{
			FlxDestroyUtil.put(point);
		}
	}

	//-- Builder functions for adding emitting behaviors --//

	/**
	 * This function gives the emitter a constant spin.
	 *
	 * @param spinSpeed 	How many degrees to spin every second.
	 *						`360` means one full revolution per second.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	**/
	public function setEmitterSpin(spinSpeed:Int):CustomEmitter
	{
		if (type != null)
		{
			isSpinning = true;
			this.spinSpeed = spinSpeed;
			emitterSpin = function(elapsed:Float)
			{
				currEmitAngle += spinSpeed * elapsed;

				if (currEmitAngle > 360)
					currEmitAngle = currEmitAngle % 360;
			}
		}

		return this;
	}

	/**
	 * This function gives the illusion of shooting from different angles.
	 * In reality each update tick it adds to the launch angle proportionatly
	 * to the number of given directions.
	 *
	 * **NOTE:** Works nicer with high frequency emits and fast speeds.
	 *
	 * @param directionNumber 	How many directions should the emitter shoot from.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	**/
	public function setMultiShoot(directionNumber:Int):CustomEmitter
	{
		if (type != null)
		{
			isMultiShoot = true;
			multiShootAngle = 360 / directionNumber;
			emitterMultiShoot = function(elapsed:Float)
			{
				currEmitAngle += multiShootAngle;

				if (currEmitAngle > 360)
					currEmitAngle = currEmitAngle % 360;
			}
		}
		return this;
	}

	/**
	 * This function sets a basic emitter behavior. Emits at a straight line with an optional given `startAngle` 
	 * with an optional `maxSpread`.
	 *
	 * @param startAngle 	Starting angle for the emitter.
	 * 						Default value is `0` = right.
	 *						Can be paired with 
	 * @param maxSpread 	How far can the particles spread. 
	 * 						Used evenly from `-maxSpread` to `maxSpread`.
	 *						Default value sets at `0` for no spread.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	 * @see Types#EmitterAngle
	**/
	public function addStraightEmit(startAngle:Float = 0, maxSpread:Int = 0):CustomEmitter
	{
		type = EmitterType.STRAIGHT;
		currEmitAngle = startAngle;
		this.maxSpread = maxSpread;
		emitBehavior = function(elapsed:Float)
		{
			launchAngle.set(currEmitAngle - maxSpread, currEmitAngle + maxSpread);
		}
		return this;
	}

	//-- Builder functions for adding emitter paths --//s

	/**
	 * This function makes the particles' position relative to the emitter's position 
	 *
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	**/
	public function setRelativeParticles():CustomEmitter
	{
		isRelativeParticles = true;
		return this;
	}

	/**
	 * This function sets a path made of an array of points for the emitter to loop through.
	 *
	 * @param points 	Array of `FlxPoint` to loop through.
	 * @param speed 	How fast should the emitter go through the path.
	 *					Proportional to `update` funciton's 'elapsed`.
	 * @param type 		Used internally for differentiating.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	**/
	private function addPolygonPath(points:Array<FlxPoint>, speed:Int, type:EmitterPath = EmitterPath.POLYGON):CustomEmitter
	{
		pathType = type;
		pathPoints.push(originPos);
		for (point in points)
		{
			pathPoints.push(point);
		}
		currPathPoint = 0;
		pathWalkSpeed = speed;
		emitterPath = function(elapsed:Float)
		{
			goToNextPoint(elapsed);
		}
		return this;
	}

	/**
	 * This function sets a path made of an array of points for the emitter to loop through.
	 *
	 * @param points 	Array of `FlxPoint` to loop through.
	 * @param speed 	How fast should the emitter go through the path.
	 *					Proportional to `update` funciton's 'elapsed`.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	**/
	public function addPolygonalPath(points:Array<FlxPoint>, speed:Int):CustomEmitter
	{
		return addPolygonPath(points, speed);
	}

	/**
	 * This function sets a line path for the emitter to loop through.
	 *
	 * @param x 		Distance in the x-axis relative to emitter's position.
	 * @param y 		Distance in the y-axis relative to emitter's position.
	 * @param speed 	How fast should the emitter go through the path.
	 *					Proportional to `update` funciton's 'elapsed`.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	**/
	public function addLinePath(x:Float, y:Float, speed:Int):CustomEmitter
	{
		return addPolygonPath([FlxPoint.get(originPos.x + x, originPos.y + y)], speed, EmitterPath.LINE);
	}

	/**
	 * This function sets a triangular path for the emitter to loop through.
	 * Starts at the emitter's original position.
	 *
	 * @param pointB 	The 2nd point of the triangle. Coordinations are absolute, not relative. 
	 * @param pointC 	The 3rd point of the triangle. Coordinations are absolute, not relative.
	 * @param speed 	How fast should the emitter go through the path.
	 *					Proportional to `update` funciton's 'elapsed`.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	**/
	public function addTrianglePath(pointB:FlxPoint, pointC:FlxPoint, speed:Int):CustomEmitter
	{
		return addPolygonPath([pointB, pointC], speed, EmitterPath.TRIANGLE);
	}

	/**
	 * This function sets a rectangular path for the emitter to loop through.
	 *
	 * @param width 	Distance in the x-axis relative to emitter's position.
	 * @param height 	Distance in the y-axis relative to emitter's position.
	 * @param speed 	How fast should the emitter go through the path.
	 *					Proportional to `update` funciton's 'elapsed`.
	 * @param type 		Used internally for differentiating.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	**/
	private function addRectanglePath(width:Float, height:Float, speed:Int, type:EmitterPath = EmitterPath.RECTANGLE):CustomEmitter
	{
		return addPolygonPath([
			FlxPoint.get(originPos.x + width, originPos.y),
			FlxPoint.get(originPos.x + width, originPos.y + height),
			FlxPoint.get(originPos.x, originPos.y + height)
		], speed, type);
	}

	/**
	 * This function sets a rectangular path for the emitter to loop through.
	 *
	 * @param width 	Distance in the x-axis relative to emitter's position.
	 * @param height 	Distance in the y-axis relative to emitter's position.
	 * @param speed 	How fast should the emitter go through the path.
	 *					Proportional to `update` funciton's 'elapsed`.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	**/
	public function addRectangularPath(width:Float, height:Float, speed:Int):CustomEmitter
	{
		return addRectanglePath(width, height, speed);
	}

	/**
	 * This function sets a square path for the emitter to loop through.
	 *
	 * @param length 	Distance in the x-axis and y-axis relative to emitter's position.
	 * @param speed 	How fast should the emitter go through the path.
	 *					Proportional to `update` funciton's 'elapsed`.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	**/
	public function addSquarePath(length:Float, speed:Int):CustomEmitter
	{
		return addRectanglePath(length, length, speed, EmitterPath.SQUARE);
	}

	/**
	 * This function sets a elliptical path for the emitter to loop through.
	 * The ellipse is relative to the emitter's original position.
	 *
	 * @param width 	Radius of the major axis.
	 * @param height 	Radius of the minor axis.
	 * @param speed 	How fast should the emitter go through the path.
	 *					Proportional to `update` funciton's 'elapsed`.
	 * @param type 		Used internally for differentiating.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	**/
	private function addEllipsePath(width:Float, height:Float, speed:Int, type:EmitterPath = EmitterPath.ELLIPSE):CustomEmitter
	{
		pathType = type;
		var center = FlxPoint.get(originPos.x + width, originPos.y);
		currPathAngle = 0;
		emitterPath = function(elapsed:Float)
		{
			currPathAngle += elapsed * speed;
			if (currPathAngle > 360)
				currPathAngle = 0;

			var newX = (center.x + Math.cos(currPathAngle) * width) - x;
			var newY = (center.y + Math.sin(currPathAngle) * height) - y;
			x += newX;
			y += newY;

			if (isRelativeParticles)
			{
				moveParticles(newX, newY);
			}
		}
		return this;
	}

	/**
	 * This function sets a elliptical path for the emitter to loop through.
	 * The ellipse is relative to the emitter's original position.
	 *
	 * @param width 	Radius of the major axis.
	 * @param height 	Radius of the minor axis.
	 * @param speed 	How fast should the emitter go through the path.
	 *					Proportional to `update` funciton's 'elapsed`.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	**/
	public function addEllipticalPath(width:Float, height:Float, speed:Int):CustomEmitter
	{
		return addEllipsePath(width, height, speed, EmitterPath.ELLIPSE);
	}

	/**
	 * This function sets a circular path for the emitter to loop through.
	 * The circle is relative to the emitter's original position.
	 *
	 * @param radius 	Radius of circle.
	 * @param speed 	How fast should the emitter go through the path.
	 *					Proportional to `update` funciton's 'elapsed`.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	**/
	public function addCirclePath(radius:Int, speed:Int):CustomEmitter
	{
		return addEllipsePath(radius, radius, speed, EmitterPath.CIRCLE);
	}

	/**	
	 * Helper functions
	**/
	private function goToNextPoint(elapsed:Float)
	{
		var nextPoint = currPathPoint < pathPoints.length - 1 ? currPathPoint + 1 : 0;
		var dx = pathPoints[nextPoint].x - pathPoints[currPathPoint].x;
		var dy = pathPoints[nextPoint].y - pathPoints[currPathPoint].y;
		var angle = Math.atan2(dy, dx);
		var newX = pathWalkSpeed * elapsed * Math.cos(angle);
		var newY = pathWalkSpeed * elapsed * Math.sin(angle);
		x += newX;
		y += newY;

		if (isRelativeParticles)
		{
			moveParticles(newX, newY);
		}

		if (distanceTo(pathPoints[nextPoint]) <= 1)
		{
			currPathPoint = nextPoint;
		}
	}

	private function moveParticles(x:Float, y:Float)
	{
		forEachAlive(function(particle:FlxParticle)
		{
			particle.x += x;
			particle.y += y;
		});
	}

	private function getDir(start:Float, end:Float):Int
	{
		if (start < end)
			return 1;
		if (start == end)
			return 0;
		return -1;
	}

	private function distanceTo(destination:FlxPoint):Float
	{
		return Math.sqrt(Math.pow((x - destination.x), 2) + Math.pow((y - destination.y), 2));
	}
}
