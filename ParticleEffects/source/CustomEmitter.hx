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

	public function new(X:Float, Y:Float, Size:Int)
	{
		super(X, Y, Size);
		originPos = FlxPoint.get();
		originPos.set(X, Y);
		pathPoints = [];

		// Temporary paritcles
		makeParticles(4, 4);
	}

	public function emit(Frequency:Float = 0.1)
	{
		start(false, Frequency);
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
	 * @param SpinSpeed 	How many degrees to spin every second.
	 *						`360` means one full revolution per second.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	**/
	public function setEmitterSpin(SpinSpeed:Int):CustomEmitter
	{
		if (type != null)
		{
			isSpinning = true;
			spinSpeed = SpinSpeed;
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
	 * @param DirectionNumber 	How many directions should the emitter shoot from.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	**/
	public function setMultiShoot(DirectionNumber:Int):CustomEmitter
	{
		if (type != null)
		{
			isMultiShoot = true;
			multiShootAngle = 360 / DirectionNumber;
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
	 * This function sets a basic emitter behavior. Emits at a straight line with an optional given `StartAngle` 
	 * with an optional `MaxSpread`.
	 *
	 * @param StartAngle 	Starting angle for the emitter.
	 * 						Default value is `0` = right.
	 *						Can be paired with 
	 * @param MaxSpread 	How far can the particles spread. 
	 * 						Used evenly from `-MaxSpread` to `MaxSpread`.
	 *						Default value sets at `0` for no spread.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	 * @see Types#EmitterAngle
	**/
	public function addStraightEmit(StartAngle:Float = 0, MaxSpread:Int = 0):CustomEmitter
	{
		type = EmitterType.STRAIGHT;
		currEmitAngle = StartAngle;
		maxSpread = MaxSpread;
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
	 * @param Points 	Array of `FlxPoint` to loop through.
	 * @param Speed 	How fast should the emitter go through the path.
	 *					Proportional to `update` funciton's 'elapsed`.
	 * @param Type 		Used internally for differentiating.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	**/
	private function addPolygonPath(Points:Array<FlxPoint>, Speed:Int, Type:EmitterPath = EmitterPath.POLYGON):CustomEmitter
	{
		pathType = Type;
		pathPoints.push(originPos);
		for (point in Points)
		{
			pathPoints.push(point);
		}
		currPathPoint = 0;
		pathWalkSpeed = Speed;
		emitterPath = function(elapsed:Float)
		{
			goToNextPoint(elapsed);
		}
		return this;
	}

	/**
	 * This function sets a path made of an array of points for the emitter to loop through.
	 *
	 * @param Points 	Array of `FlxPoint` to loop through.
	 * @param Speed 	How fast should the emitter go through the path.
	 *					Proportional to `update` funciton's 'elapsed`.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	**/
	public function addPolygonalPath(Points:Array<FlxPoint>, Speed:Int):CustomEmitter
	{
		return addPolygonPath(Points, Speed);
	}

	/**
	 * This function sets a line path for the emitter to loop through.
	 *
	 * @param X 		Distance in the x-axis relative to emitter's position.
	 * @param Y 		Distance in the y-axis relative to emitter's position.
	 * @param Speed 	How fast should the emitter go through the path.
	 *					Proportional to `update` funciton's 'elapsed`.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	**/
	public function addLinePath(X:Float, Y:Float, Speed:Int):CustomEmitter
	{
		return addPolygonPath([new FlxPoint(originPos.x + X, originPos.y + Y)], Speed, EmitterPath.LINE);
	}

	/**
	 * This function sets a triangular path for the emitter to loop through.
	 * Starts at the emitter's original position.
	 *
	 * @param PointB 	The 2nd point of the triangle. Coordinations are absolute, not relative. 
	 * @param PointC 	The 3rd point of the triangle. Coordinations are absolute, not relative.
	 * @param Speed 	How fast should the emitter go through the path.
	 *					Proportional to `update` funciton's 'elapsed`.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	**/
	public function addTrianglePath(PointB:FlxPoint, PointC:FlxPoint, Speed:Int):CustomEmitter
	{
		return addPolygonPath([PointB, PointC], Speed, EmitterPath.TRIANGLE);
	}

	/**
	 * This function sets a rectangular path for the emitter to loop through.
	 *
	 * @param Width 	Distance in the x-axis relative to emitter's position.
	 * @param Height 	Distance in the y-axis relative to emitter's position.
	 * @param Speed 	How fast should the emitter go through the path.
	 *					Proportional to `update` funciton's 'elapsed`.
	 * @param Type 		Used internally for differentiating.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	**/
	private function addRectanglePath(Width:Float, Height:Float, Speed:Int, Type:EmitterPath = EmitterPath.RECTANGLE):CustomEmitter
	{
		return addPolygonPath([
			new FlxPoint(originPos.x + Width, originPos.y),
			new FlxPoint(originPos.x + Width, originPos.y + Height),
			new FlxPoint(originPos.x, originPos.y + Height)
		], Speed, Type);
	}

	/**
	 * This function sets a rectangular path for the emitter to loop through.
	 *
	 * @param Width 	Distance in the x-axis relative to emitter's position.
	 * @param Height 	Distance in the y-axis relative to emitter's position.
	 * @param Speed 	How fast should the emitter go through the path.
	 *					Proportional to `update` funciton's 'elapsed`.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	**/
	public function addRectangularPath(Width:Float, Height:Float, Speed:Int):CustomEmitter
	{
		return addRectanglePath(Width, Height, Speed);
	}

	/**
	 * This function sets a square path for the emitter to loop through.
	 *
	 * @param Length 	Distance in the x-axis and y-axis relative to emitter's position.
	 * @param Speed 	How fast should the emitter go through the path.
	 *					Proportional to `update` funciton's 'elapsed`.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	**/
	public function addSquarePath(Length:Float, Speed:Int):CustomEmitter
	{
		return addRectanglePath(Length, Length, Speed, EmitterPath.SQUARE);
	}

	/**
	 * This function sets a elliptical path for the emitter to loop through.
	 * The ellipse is relative to the emitter's original position.
	 *
	 * @param Width 	Radius of the major axis.
	 * @param Height 	Radius of the minor axis.
	 * @param Speed 	How fast should the emitter go through the path.
	 *					Proportional to `update` funciton's 'elapsed`.
	 * @param Type 		Used internally for differentiating.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	**/
	private function addEllipsePath(Width:Float, Height:Float, Speed:Int, Type:EmitterPath = EmitterPath.ELLIPSE):CustomEmitter
	{
		pathType = Type;
		var center = FlxPoint.get();
		center.set(originPos.x + Width, originPos.y);
		currPathAngle = 0;
		emitterPath = function(elapsed:Float)
		{
			currPathAngle += elapsed * Speed;
			if (currPathAngle > 360)
				currPathAngle = 0;

			var newX = (center.x + Math.cos(currPathAngle) * Width) - x;
			var newY = (center.y + Math.sin(currPathAngle) * Height) - y;
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
	 * @param Width 	Radius of the major axis.
	 * @param Height 	Radius of the minor axis.
	 * @param Speed 	How fast should the emitter go through the path.
	 *					Proportional to `update` funciton's 'elapsed`.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	**/
	public function addEllipticalPath(Radius:Int, Speed:Int):CustomEmitter
	{
		return addEllipsePath(Radius, Radius, Speed, EmitterPath.ELLIPSE);
	}

	/**
	 * This function sets a circular path for the emitter to loop through.
	 * The circle is relative to the emitter's original position.
	 *
	 * @param Radius 	Radius of circle.
	 * @param Speed 	How fast should the emitter go through the path.
	 *					Proportional to `update` funciton's 'elapsed`.
	 * @return  This `CustomEmitter` instance (nice for chaining stuff together).
	**/
	public function addCirclePath(Radius:Int, Speed:Int):CustomEmitter
	{
		return addEllipsePath(Radius, Radius, Speed, EmitterPath.CIRCLE);
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

	private function moveParticles(X:Float, Y:Float)
	{
		forEachAlive(function(particle:FlxParticle)
		{
			particle.x += X;
			particle.y += Y;
		});
	}

	private function getDir(Start:Float, End:Float):Int
	{
		if (Start < End)
			return 1;
		if (Start == End)
			return 0;
		return -1;
	}

	private function distanceTo(Destination:FlxPoint):Float
	{
		return Math.sqrt(Math.pow((x - Destination.x), 2) + Math.pow((y - Destination.y), 2));
	}
}
