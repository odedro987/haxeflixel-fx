package;

import Types.EmitterPath;
import Types.EmitterType;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.math.FlxPoint;

class CustomEmitter extends FlxEmitter
{
	private var type:EmitterType;
	private var pathType:EmitterPath;
	private var emitBehavior:Float->Void;
	private var emitterPath:Float->Void;
	private var isRelativeParticles:Bool;

	// Variables for emitting behaviors
	private var startAngle:Float;
	private var maxSpread:Int;
	private var spinSpeed:Int;
	private var currAngle:Float;

	// Variables for emitter paths
	private var originPos:FlxPoint;
	private var pathWalkSpeed:Int;
	private var pathPoints:Array<FlxPoint>;
	private var currPathPoint:Int;

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
		if (emitBehavior != null)
			emitBehavior(elapsed);
		if (emitterPath != null)
			emitterPath(elapsed);
	}

	/**	
	 * Builder functions for adding emitting behaviors
	**/
	public function addStraightEmit(StartAngle:Float = 0, MaxSpread:Int = 0):CustomEmitter
	{
		type = EmitterType.STRAIGHT;
		startAngle = StartAngle;
		maxSpread = MaxSpread;
		launchAngle.set(startAngle - maxSpread, startAngle + maxSpread);
		return this;
	}

	public function addSpiralEmit(SpinSpeed:Int = 1, StartAngle:Float = 0):CustomEmitter
	{
		type = EmitterType.SPIRAL;
		spinSpeed = SpinSpeed;
		currAngle = StartAngle;
		emitBehavior = function(elapsed:Float)
		{
			currAngle += spinSpeed * elapsed;

			if (currAngle > 360)
				currAngle = 0;

			launchAngle.set(currAngle, currAngle);
		}
		return this;
	}

	/**	
	 * Builder functions for adding emitter paths
	**/
	public function setRelativeParticles(Flag:Bool = true):CustomEmitter
	{
		isRelativeParticles = Flag;
		return this;
	}

	public function addLinePath(X:Float, Y:Float, Speed:Int):CustomEmitter
	{
		pathType = EmitterPath.LINE;
		pathPoints.push(originPos);
		pathPoints.push(FlxPoint.get());
		pathPoints[1].set(originPos.x + X, originPos.y + Y);
		currPathPoint = 0;
		pathWalkSpeed = Speed;
		emitterPath = function(elapsed:Float)
		{
			goToNextPoint(elapsed);
		}
		return this;
	}

	public function addTrianglePath(PointB:FlxPoint, PointC:FlxPoint, Speed:Int):CustomEmitter
	{
		pathType = EmitterPath.TRIANGLE;
		pathPoints.push(originPos);
		pathPoints.push(PointB);
		pathPoints.push(PointC);
		currPathPoint = 0;
		pathWalkSpeed = Speed;
		emitterPath = function(elapsed:Float)
		{
			goToNextPoint(elapsed);
		}
		return this;
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
