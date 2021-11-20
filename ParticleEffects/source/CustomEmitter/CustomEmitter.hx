package customEmitter;

import flixel.effects.particles.FlxEmitter;

class CustomEmitter extends FlxEmitter
{
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
}
