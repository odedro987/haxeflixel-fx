package oded.flixel.utils.shaders;

import flixel.FlxG;
import flixel.system.FlxAssets.FlxShader;
import openfl.display.ShaderParameter;

class WavyGrassShader extends FlxShader
{
	@:glFragmentSource("
        #pragma header
		
		void main(void) {
			gl_FragColor = texture2D(bitmap, openfl_TextureCoordv);
		}")
	@:glVertexSource("
		#pragma header
		
		uniform float time;
		uniform float delay;

		float sine(float amplitude, float frequency) {
            return amplitude * sin((time + delay) * frequency);
		}
		
		void main(void) {
			#pragma body

			vec2 uv = openfl_Position.xy;
            
			// if vertex is one of the top 2 vertices
			if(openfl_TextureCoord.y == 0.){
				float u_time = time + delay;
				uv.x += sine(6.5, 1.) + sine(13., 2.) + sine(2.5, 0.6);
				uv.y += sine(1.5, 1.) + sine(2., 2.) + sine(0.5, 0.6);
			}
			
			gl_Position = openfl_Matrix * vec4(uv, openfl_Position.zw);
		}")
	public function new(delay:Float = 0)
	{
		super();
		this.alpha = new ShaderParameter();
		this.time.value = [0.0];
		this.delay.value = [delay];
	}
}
