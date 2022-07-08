package oded.flixel.utils.shaders;

import flixel.math.FlxPoint;

typedef CRTOptions =
{
	var ?showHorizontalLines:Bool;
	var ?showVerticalLines:Bool;
	var ?showVignette:Bool;
	var ?showCurvature:Bool;
	var ?curvature:FlxPoint;
	var ?scanLineOpacity:Float;
	var ?vignetteOpacity:Float;
	var ?vignetteRoundness:Float;
	var ?brightness:Float;
}
