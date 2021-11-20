package customEmitter;

import Types.EmitterType;

class SpiralEmitter extends CustomEmitter
{
	private var spinSpeed:Int;
	private var currAngle:Float;

	public function new(X:Float, Y:Float, Size:Int, SpinSpeed:Int = 1, StartAngle:Float = 0)
	{
		super(X, Y, Size, EmitterType.SPIRAL);
		spinSpeed = SpinSpeed;
		currAngle = StartAngle;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		currAngle += spinSpeed * elapsed;

		if (currAngle > 360)
			currAngle = 0;

		launchAngle.set(currAngle, currAngle);
	}
}
