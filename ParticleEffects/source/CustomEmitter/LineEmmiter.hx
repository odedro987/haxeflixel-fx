package customEmitter;

import Types.EmitterType;

class LineEmitter extends CustomEmitter
{
	private var startAngle:Float;
	private var maxSpread:Int;

	public function new(X:Float, Y:Float, Size:Int, StartAngle:Float = 0, MaxSpread:Int = 0)
	{
		super(X, Y, Size, EmitterType.LINE);
		startAngle = StartAngle;
		maxSpread = MaxSpread;
		launchAngle.set(startAngle - maxSpread, startAngle + maxSpread);
	}
}
