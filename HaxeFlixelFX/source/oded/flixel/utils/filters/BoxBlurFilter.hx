package oded.flixel.utils.filters;

import oded.flixel.utils.shaders.BoxBlurShader;
import openfl.display.BitmapData;
import openfl.display.DisplayObjectRenderer;
import openfl.display.Shader;
import openfl.filters.BitmapFilter;

class BoxBlurFilter extends BitmapFilter
{
	private var boxBlurShader:BoxBlurShader;

	public function new(blurSize:Float = 0.01, blurPasses:Int = 2)
	{
		super();

		boxBlurShader = new BoxBlurShader(blurSize);

		// Round up to the next even number.
		__numShaderPasses = makePassesEven(blurPasses);
	}

	@:noCompletion private override function __initShader(renderer:DisplayObjectRenderer, pass:Int, sourceBitmapData:BitmapData):Shader
	{
		// Flip horizontal and vertical blur each pass.
		boxBlurShader.isVertictal.value[0] = pass % 2 == 0;
		return boxBlurShader;
	}

	private function makePassesEven(passesNum:Int):Int
	{
		if (passesNum <= 0)
			return 0;

		return passesNum % 2 == 0 ? passesNum : passesNum + 1;
	}
}
