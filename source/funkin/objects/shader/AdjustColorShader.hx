package funkin.objects.shader;
// stolen from BASE GAME, with tweaks

class AdjustColorShader
{
	public var shader:AdjustColorShaderShader = new AdjustColorShaderShader();
	public var hue(default, set):Float = 0;
	public var saturation(default, set):Float = 0;
	public var brightness(default, set):Float = 0;
	public var contrast(default, set):Float = 0;

	private function set_hue(value:Float)
	{
		shader.hue.value[0] = value;
		return hue = value;
	}

	private function set_saturation(value:Float)
	{
		shader.saturation.value[0] = value;
		return saturation = value;
	}

	private function set_brightness(value:Float)
	{
		shader.brightness.value[0] = value;
		return brightness = value;
	}

	private function set_contrast(value:Float)
	{
		shader.contrast.value[0] = value;
		return contrast = value;
	}

	public function new(hue:Float = 0, sat:Float = 0, brt:Float = 0, cont:Float = 0)
	{
		this.hue = hue;
		this.saturation = sat;
		this.brightness = brt;
		this.contrast = cont;
	}
}

class AdjustColorShaderShader extends flixel.system.FlxAssets.FlxShader 
{ // now this is an excellent name.
	@:glFragmentSource('
		#pragma header

		uniform float hue;
		uniform float saturation;
		uniform float brightness;
		uniform float contrast;

		const vec3 grayscaleValues = vec3(0.3098039215686275, 0.607843137254902, 0.0823529411764706);
		const float e = 2.718281828459045;

		vec3 applyHueRotate(vec3 aColor, float aHue){
			float angle = radians(aHue);

			mat3 m1 = mat3(0.213, 0.213, 0.213, 0.715, 0.715, 0.715, 0.072, 0.072, 0.072);
			mat3 m2 = mat3(0.787, -0.213, -0.213, -0.715, 0.285, -0.715, -0.072, -0.072, 0.928);
			mat3 m3 = mat3(-0.213, 0.143, -0.787, -0.715, 0.140, 0.715, 0.928, -0.283, 0.072);
			mat3 m = m1 + cos(angle) * m2 + sin(angle) * m3;

			return m * aColor;
		}

		vec3 applySaturation(vec3 aColor, float value){
			if(value > 0.0){ value = value * 3.0; }
			value = (1.0 + (value / 100.0));
			vec3 grayscale = vec3(dot(aColor, grayscaleValues));
			return clamp(mix(grayscale, aColor, value), 0.0, 1.0);
		}

		vec3 applyContrast(vec3 aColor, float value){
			value = (1.0 + (value / 100.0));
				if(value > 1.0){
					value = (((0.00852259 * pow(e, 4.76454 * (value - 1.0))) * 1.01) - 0.0086078159) * 10.0; //Just roll with it...
					value += 1.0;
				}
			return clamp((aColor - 0.25) * value + 0.25, 0.0, 1.0);
		}

		vec3 applyHSBCEffect(vec3 color) {
			color = color + brightness / 255.;
		    color = applyHueRotate(color, hue);
		    color = applyContrast(color, contrast);
		    color = applySaturation(color, saturation);
		    
		    return color;
		}

		vec4 applyColorTransform(vec4 color) {
			if (color.a == 0.) {
				return vec4(0.);
			}
			if (!hasTransform) {
				return color;
			}
			if (!hasColorTransform) {
				return color * openfl_Alphav;
			}
			
			color = vec4(color.rgb / color.a, color.a);
			color = clamp(openfl_ColorOffsetv + color * openfl_ColorMultiplierv, 0., 1.);

			if (color.a > 0.) {
				return vec4(color.rgb * color.a * openfl_Alphav, color.a * openfl_Alphav);
			}
			return vec4(0.);
		}

		void main() {
			vec4 textureColor = texture2D(bitmap, openfl_TextureCoordv);

			vec3 hsbcEffect = applyHSBCEffect(textureColor.rgb);
			vec4 outColor = vec4(hsbcEffect, textureColor.a);
			gl_FragColor = applyColorTransform(outColor);
		}
	')
	
	public function new()
	{
		super();
		hue.value = [0];
		saturation.value = [0];
		brightness.value = [0];
		contrast.value = [0];
	}
}