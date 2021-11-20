package customEmitter;

import Types.EmitterType;
import flixel.effects.particles.FlxEmitter;

class CustomEmitter extends FlxEmitter
{
	private var type:EmitterType;

	public function new(X:Float, Y:Float, Size:Int, Type:EmitterType)
	{
		super(X, Y, Size);
		this.type = Type;
		// Temporary paritcles
		makeParticles(4, 4);
	}

	public function emit(Frequency:Float = 0.1)
	{
		start(false, Frequency);
	}
}
