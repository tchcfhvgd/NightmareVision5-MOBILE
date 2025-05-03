package funkin.utils;

import flixel.addons.transition.FlxTransitionableState;
import flixel.math.FlxPoint;
import flixel.FlxG;
import openfl.utils.Assets;
import haxe.ds.StringMap;
/**
	General Utility class for more one off functions
**/
class CoolUtil
{
	/**
	 * Remaps a value from a range to a new range
	 * 
	 * Akin to `FlxMath.remapToRange`
	 * @param x Input value
	 * @param l1 Low bound of range 1
	 * @param h1 High bound of range 1
	 * @param l2 Low bound of range 2
	 * @param h2 High bound of range 2
	 * @return Input value remapped to range 2
	 */
	inline public static function scale(x:Float, l1:Float, h1:Float, l2:Float, h2:Float):Float
		return ((x - l1) * (h2 - l2) / (h1 - l1) + l2);

	/**
	 * Clamps/Bounds a value between a range that it cannot go below or over
	 * 
	 * Akin to `FlxMath.bound`
	 * @param n Input value
	 * @param l Low boundary
	 * @param h High Boundary
	 * @return Clamped value
	 */
	inline public static function clamp(n:Float, l:Float, h:Float)
	{
		if (n > h)
			n = h;
		if (n < l)
			n = l;
		return n;
	}

	/**
	 * Creates or uses a provided point and rotates it around a given `x` and `y` by radians
	 * 
	 * Akin to `new FlxPoint(x,y).radians += angle`
	 * @param x 
	 * @param y 
	 * @param angle 
	 * @param point 
	 * @return A rotated FlxPoint
	 */
	public static function rotate(x:Float, y:Float, angle:Float, ?point:FlxPoint):FlxPoint
	{
		var p = point == null ? FlxPoint.weak() : point;
		p.set((x * Math.cos(angle)) - (y * Math.sin(angle)), (x * Math.sin(angle)) + (y * Math.cos(angle)));
		return p;
	}

	inline public static function quantizeAlpha(f:Float, interval:Float)
	{
		return Std.int((f + interval / 2) / interval) * interval;
	}

	inline public static function quantize(f:Float, interval:Float)
	{
		return Std.int((f + interval / 2) / interval) * interval;
	}

	//-----------------------------------------------------------------//

	inline public static function sortByZ(order:Int, a:FlxBasic, b:FlxBasic):Int
	{
		if (a == null || b == null)
			return 0;
		return flixel.util.FlxSort.byValues(order, a.zIndex, b.zIndex);
	}

	/**
		capitalizes the first letter of a given `String`
	**/
	inline public static function capitalize(text:String):String
		return text.charAt(0).toUpperCase() + text.substr(1).toLowerCase();

	/**
		Helper Function to Fix Save Files for Flixel 5

		-- EDIT: [November 29, 2023] --

		this function is used to get the save path, period.
		since newer flixel versions are being enforced anyways.
		@crowplexus
	**/
	@:access(flixel.util.FlxSave.validate)
	inline public static function getSavePath():String
	{
		return '${FlxG.stage.application.meta.get('company')}/${flixel.util.FlxSave.validate(FlxG.stage.application.meta.get('file'))}';
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = [];
		#if sys
		if (FileSystem.exists(path))
			daList = File.getContent(path).trim().split('\n');
		else
		#end
		if (Assets.exists(path))
			daList = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function colorFromString(color:String):FlxColor
	{
		var hideChars = ~/[\t\n\r]/;
		var color:String = hideChars.split(color).join('').trim();
		if(color.startsWith('0x')) color = color.substring(color.length - 6);

		var colorNum:Null<FlxColor> = FlxColor.fromString(color);
		if(colorNum == null) colorNum = FlxColor.fromString('#$color');
		return colorNum != null ? colorNum : FlxColor.WHITE;
	}
	
	public static function listFromString(string:String):Array<String>
	{
		var daList:Array<String> = [];
		daList = string.trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	/**
		Finds the most used Color on a given sprite by culling pixel by pixel

		should be used lightly as its very performance heavy
	**/
	public static function dominantColor(sprite:flixel.FlxSprite):Int
	{
		var countByColor:Map<Int, Int> = [];
		for (col in 0...sprite.frameWidth)
		{
			for (row in 0...sprite.frameHeight)
			{
				var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
				if (colorOfThisPixel != 0)
				{
					if (countByColor.exists(colorOfThisPixel))
					{
						countByColor[colorOfThisPixel] = countByColor[colorOfThisPixel] + 1;
					}
					else if (countByColor[colorOfThisPixel] != 13520687 - (2 * 13520687))
					{
						countByColor[colorOfThisPixel] = 1;
					}
				}
			}
		}
		var maxCount = 0;
		var maxKey:Int = 0; // after the loop this will store the max color
		countByColor[flixel.util.FlxColor.BLACK] = 0;
		for (key in countByColor.keys())
		{
			if (countByColor[key] >= maxCount)
			{
				maxCount = countByColor[key];
				maxKey = key;
			}
		}
		return maxKey;
	}

	public static function browserLoad(site:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}

	inline public static function openFolder(folder:String, absolute:Bool = false)
	{
		#if sys
		if (!absolute)
			folder = Sys.getCwd() + '$folder';

		folder = folder.replace('/', '\\');
		if (folder.endsWith('/'))
			folder.substr(0, folder.length - 1);

		#if linux
		var command:String = '/usr/bin/xdg-open';
		#else
		var command:String = 'explorer.exe';
		#end
		Sys.command(command, [folder]);
		trace('$command $folder');
		#else
		FlxG.error("Platform is not supported for CoolUtil.openFolder");
		#end
	}

	public static function showPopUp(message:String, title:String):Void
	{
		//#if android
		//android.Tools.showAlertDialog(title, message, {name: "OK", func: null}, null);
		//#else
		FlxG.stage.window.alert(message, title);
		//#end
	}

	/**
		helper to quickly set transSkips
	**/
	public static inline function setTransSkip(into:Bool = true, outof:Bool = true)
	{
		FlxTransitionableState.skipNextTransIn = into;
		FlxTransitionableState.skipNextTransOut = outof;
	}

	/**
	 * Copies Map information from one map to another
	 * @param from The Map we are copying from
	 * @param to The Map we are copying to
	 */
	public static function copyMapValues<K, V>(from:Map<K, V>, to:Map<K, V>)
	{
		for (k => v in from)
		{
			to.set(k, v);
		}
	}

	/**
	 * Opens a windows alert
	 */
	public static function doPopUp(title:String, description:String)
	{
		FlxG.stage.window.alert(description, title);
		trace(description);
	}


	public static final eases:StringMap<EaseFunction> = [
		"quadin" => FlxEase.quadIn,
		"quadout" => FlxEase.quadOut,
		"quadinout" => FlxEase.quadInOut,
		"cubein" => FlxEase.cubeIn,
		"cubeout" => FlxEase.cubeOut,
		"cubeinout" => FlxEase.cubeInOut,
		"quartin" => FlxEase.quartIn,
		"quartout" => FlxEase.quartOut,
		"quartinout" => FlxEase.quartInOut,
		"quintin" => FlxEase.quintIn,
		"quintout" => FlxEase.quintOut,
		"quintinout" => FlxEase.quintInOut,
		"expoin" => FlxEase.expoIn,
		"expoout" => FlxEase.expoOut,
		"expoinout" => FlxEase.expoInOut,
		"sinein" => FlxEase.sineIn,
		"sineout" => FlxEase.sineOut,
		"sineinout" => FlxEase.sineInOut,
		"circin" => FlxEase.circIn,
		"circout" => FlxEase.circOut,
		"circinout" => FlxEase.circInOut,
		"smoothstepin" => FlxEase.smoothStepIn,
		"smoothstepout" => FlxEase.smoothStepOut,
		"smoothstepinout" => FlxEase.smoothStepInOut,
		"smootherstepin" => FlxEase.smootherStepIn,
		"smootherstepout" => FlxEase.smootherStepOut,
		"smootherstepinout" => FlxEase.smootherStepInOut,
		"backin" => FlxEase.backIn,
		"backout" => FlxEase.backOut,
		"backinout" => FlxEase.backInOut,
		"bouncein" => FlxEase.bounceIn,
		"bounceout" => FlxEase.bounceOut,
		"bounceinout" => FlxEase.bounceInOut,
		"elasticin" => FlxEase.elasticIn,
		"elasticout" => FlxEase.elasticOut,
		"elasticinout" => FlxEase.elasticInOut,
		"linear" => FlxEase.linear
	];
	
	public static function getEase(?name:String):EaseFunction 
	{
		if (name == null) 
		{
			return FlxEase.linear;
		}
		
		return eases.get(name.toLowerCase()) ?? FlxEase.linear;
	}


}
