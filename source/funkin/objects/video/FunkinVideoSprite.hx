package funkin.objects.video;

#if VIDEOS_ALLOWED
import hxvlc.flixel.FlxVideoSprite;
import hxvlc.util.Location;

// with hxvlcs improvements this is less needed but still has its values

/**
 * Handles video playback as a `FlxSprite`. Has additional features for ease
 * 
 * If used in `PlayState`, will autopause when the game is paused too
 * 
 * General Usage:
 * ```haxe
 * 	var video = new FunkinVideoSprite(x,y);
 * 	add(video);
 * 	video.onFormat(()->{
 * 		video.setGraphicSize(0,FlxG.height);
 * 		video.updateHitbox();
 * 		video.screenCenter(FlxAxes.X);
 * 
 * 	});
 * 	if (video.load(Paths.video('pathToVideo')))
 * 	{
 *		video.delayAndStart();
 * 	}
 * ```
 */
class FunkinVideoSprite extends FlxVideoSprite
{
	/**
	 * Video loading argument to make the video loop
	 * 
	 * Usage:
	 * ```haxe
	 * video.load(Paths.video(''),[FunkinVideoSprite.looping]);
	 * ```
	 */
	public static final looping:String = ':input-repeat=65535';
	
	/**
	 * Video loading argument to make the video muted
	 * Use if your video doesnt require audio
	 * 
	 * Usage:
	 * ```haxe
	 * video.load(Paths.video(''),[FunkinVideoSprite.muted]);
	 * ```
	 */
	public static final muted:String = ':no-audio';
	
	/**
	 * Manually initiates the Libvlc instance
	 */
	public static function init()
	{
		hxvlc.util.Handle.init();
	}
	

	/**
	 * Bool that decides if `this` should be affected by states
	 * 
	 * Disable this if you dont want your video to pause when paused in `PlayState`
	 */
	public var isStateAffected:Bool = true;

	/**
	 * Creates a new FunkinVideoSprite
	 * @param x `x` position
	 * @param y `y` position
	 * @param oneTimeUse if `true` on video complete, the video will self destroy
	 */
	public function new(x:Float = 0, y:Float = 0, oneTimeUse:Bool = true)
	{
		super(x, y);
		
		if (oneTimeUse) bitmap.onEndReached.add(this.destroy, true);
	}
	
	/**
	 * Starts the video but sets a delay before starting
	 * 
	 * Recommended over `this.play`
	 * @param delay The delay before the video starts. default is next update call
	 */
	public function delayAndStart(delay:Float = 0)
	{
		FlxTimer.wait(delay, play);
	}

	/**
	 * Adds a event to be dispatched when the video reaches its end
	 * @param func the event to be called
	 * @param once if this event should be dispatched once, or every time the video ends.
	 */
	public function onEnd(func:Void->Void, once:Bool = false)
	{
		bitmap.onEndReached.add(func, once);
	}
	
	/**
	 * Adds a event to be dispatched when the video starts
	 * @param func the event to be called
	 * @param once if this event should be dispatched once, or every time the video ends.
	 */
	public function onStart(func:Void->Void, once:Bool = false)
	{
		bitmap.onOpening.add(func, once);
	}
	
	/**
	 * Adds a event to be dispatched when the video has formatted itself 
	 * 
	 * Recommended to setup ur video during this event
	 * example: 
	 * ```haxe
	 * 	onFormat(()->{
	 * 		this.scale.set(3,3);
	 * 		this.updateHitbox();
	 * 		this.cameras = [camera];
	 * 	});
	 * ```
	 * @param func the event to be called
	 * @param once if this event should be dispatched once, or every time the video ends.
	 */
	public function onFormat(func:Void->Void, once:Bool = false)
	{
		bitmap.onFormatSetup.add(func, once);
	}
	
	@:deprecated('use onEnd,onFormat,onStart or access the bitmap for more functions instead.')
	public function addCallback(vidCallBack:String, func:Void->Void, once:Bool = false)
	{
		switch (vidCallBack)
		{
			case 'onEnd':
				bitmap.onEndReached.add(func, once);
			case 'onStart':
				bitmap.onOpening.add(func, once);
			case 'onFormat':
				bitmap.onFormatSetup.add(func, once);
		}
	}
	
	public static function cacheVid(path:String)
	{
		var video = new FunkinVideoSprite(0, 0, false);
		video.onStart(video.destroy);
		if (video.load(path, [muted])) video.delayAndStart();
	}
	
	override function destroy()
	{
		if (bitmap != null)
		{
			bitmap.stop();
			
			if (FlxG.signals.focusGained.has(bitmap.resume)) FlxG.signals.focusGained.remove(bitmap.resume);
			if (FlxG.signals.focusLost.has(bitmap.pause)) FlxG.signals.focusLost.remove(bitmap.pause);
		}
		
		super.destroy();
	}
}

#end

