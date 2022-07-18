package oded.flixel.utils.shaders;

import flixel.FlxG;
import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;
import haxe.ds.Vector;

typedef LightSource =
{
	var x:Float;
	var y:Float;
	var intensity:Float;
	var radius:Int;
	var color:FlxColor;
}

class LightShader extends FlxShader
{
	@:glFragmentSource("
        #pragma header

        uniform mat4 sources1;
		uniform mat4 sources2;
		uniform mat4 sources3;
		uniform mat4 sources4;

		uniform mat4 colors1;
		uniform mat4 colors2;
		uniform mat4 colors3;
		uniform mat4 colors4;

        uniform int cutoff;
		
		void main(void) {
            float ratio = openfl_TextureSize.x / openfl_TextureSize.y;
            
            vec2 uv = openfl_TextureCoordv;
            uv.x *= ratio;
            
            vec4 color = texture2D(bitmap, openfl_TextureCoordv);

            if (color.rgb == vec3(0.))
                discard;

			int total = 0;

            for (int i = 0; i < 4; i++){
				if (total >= cutoff)
					break;

				vec2 sourceUV = sources1[i].xy;
				sourceUV.x *= ratio;
				sourceUV /= openfl_TextureSize.xy;

				float dist = distance(uv, sourceUV);
				
				if (dist > sources1[i].w)
					continue;
				
				float addition = (1. - dist) * sources1[i].z;
				
				color.rgb *= vec3(1.) + colors1[i].rgb * addition;
				total++;
			}

			for (int i = 0; i < 4; i++){
				if (total >= cutoff)
					break;

				vec2 sourceUV = sources2[i].xy;
				sourceUV.x *= ratio;
				sourceUV /= openfl_TextureSize.xy;

				float dist = distance(uv, sourceUV);
				
				if (dist > sources2[i].w)
					continue;
				
				float addition = (1. - dist) * sources2[i].z;
				
				color.rgb *= vec3(1.) + colors2[i].rgb * addition;
				total++;
			}

			for (int i = 0; i < 4; i++){
				if (total >= cutoff)
					break;

				vec2 sourceUV = sources3[i].xy;
				sourceUV.x *= ratio;
				sourceUV /= openfl_TextureSize.xy;

				float dist = distance(uv, sourceUV);
				
				if (dist > sources3[i].w)
					continue;
				
				float addition = (1. - dist) * sources3[i].z;
				
				color.rgb *= vec3(1.) + colors3[i].rgb * addition;
				total++;
			}

			for (int i = 0; i < 4; i++){
				if (total >= cutoff)
					break;

				vec2 sourceUV = sources4[i].xy;
				sourceUV.x *= ratio;
				sourceUV /= openfl_TextureSize.xy;

				float dist = distance(uv, sourceUV);
				
				if (dist > sources4[i].w)
					continue;
				
				float addition = (1. - dist) * sources4[i].z;
				
				color.rgb *= vec3(1.) + colors4[i].rgb * addition;
				total++;
			}
            
            gl_FragColor = color;
		}")
	public function new(sources:Array<LightSource>)
	{
		super();

		this.cutoff.value = [sources.length];

		this.sources1.value = lightSourcesToFloatArray(sources.slice(0, 4));
		this.sources2.value = lightSourcesToFloatArray(sources.slice(4, 8));
		this.sources3.value = lightSourcesToFloatArray(sources.slice(8, 12));
		this.sources4.value = lightSourcesToFloatArray(sources.slice(12, 16));

		this.colors1.value = colorsToFloatArray(sources.slice(0, 4));
		this.colors2.value = colorsToFloatArray(sources.slice(4, 8));
		this.colors3.value = colorsToFloatArray(sources.slice(8, 12));
		this.colors4.value = colorsToFloatArray(sources.slice(12, 16));
	}

	private function normalizeDistance(distance:Int)
	{
		return distance / FlxG.width;
	}

	private function lightSourcesToFloatArray(lightSources:Array<LightSource>):Array<Float>
	{
		var array:Array<Float> = [];

		for (i in 0...lightSources.length)
		{
			array.push(lightSources[i].x);
			array.push(lightSources[i].y);
			array.push(lightSources[i].intensity);
			array.push(normalizeDistance(lightSources[i].radius));
		}

		for (_ in 0...4 - lightSources.length)
		{
			array.push(0);
			array.push(0);
			array.push(0);
			array.push(0);
		}

		return array;
	}

	private function colorsToFloatArray(lightSources:Array<LightSource>):Array<Float>
	{
		var array:Array<Float> = [];

		for (i in 0...lightSources.length)
		{
			array.push(lightSources[i].color.redFloat);
			array.push(lightSources[i].color.greenFloat);
			array.push(lightSources[i].color.blueFloat);
			array.push(lightSources[i].color.alphaFloat);
		}

		for (_ in 0...4 - lightSources.length)
		{
			array.push(0);
			array.push(0);
			array.push(0);
			array.push(0);
		}

		return array;
	}

	public function update()
	{
		this.sources1.value[0] = FlxG.mouse.x;
		this.sources1.value[1] = FlxG.mouse.y;
	}
}
