package;

import Types.EmitterType;
import flixel.effects.particles.FlxEmitter;

class CustomEmitter extends FlxEmitter
{
	private var type:EmitterType;
	private var emitBehavior:Float->Void;

	// Variables for emitting behaviors
	private var startAngle:Float;
	private var maxSpread:Int;
	private var spinSpeed:Int;
	private var currAngle:Float;


	public function new(X:Float, Y:Float, Size:Int)
	{
		super(X, Y, Size);

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
	}

	/**	
	 * Builder functions for adding emitting behaviors
	**/
	public function addStraightEmit(StartAngle:Float = 0, MaxSpread:Int = 0):CustomEmitter
	{
		type = EmitterType.LINE;
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
	}
