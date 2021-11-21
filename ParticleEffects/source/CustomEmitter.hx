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
	private var currEmitAngle:Float;

	// Variables for emitter paths
	private var originPos:FlxPoint;
	private var pathWalkSpeed:Int;
	private var pathPoints:Array<FlxPoint>;
	private var currPathPoint:Int;
	private var currPathAngle:Float;

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
		currEmitAngle = StartAngle;
		emitBehavior = function(elapsed:Float)
		{
			currEmitAngle += spinSpeed * elapsed;

			if (currEmitAngle > 360)
				currEmitAngle = 0;

			launchAngle.set(currEmitAngle, currEmitAngle);
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

	public function addPolygonPath(Points:Array<FlxPoint>, Speed:Int, Type:EmitterPath = EmitterPath.POLYGON):CustomEmitter
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

	public function addLinePath(X:Float, Y:Float, Speed:Int):CustomEmitter
	{
		return addPolygonPath([new FlxPoint(originPos.x + X, originPos.y + Y)], Speed, EmitterPath.LINE);
	}

	public function addTrianglePath(PointB:FlxPoint, PointC:FlxPoint, Speed:Int):CustomEmitter
	{
		return addPolygonPath([PointB, PointC], Speed, EmitterPath.TRIANGLE);
	}

	public function addEllipsePath(Width:Float, Height:Float, Speed:Int, Type:EmitterPath = EmitterPath.ELLIPSE):CustomEmitter
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
