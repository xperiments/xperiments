import com.bjc.resizers.Resizer;
import mx.events.EventDispatcher;
import mx.utils.Delegate;


[IconFile("icons/VideoPlayer.png")]

[Event("complete")]

/**
* A very basic flv video playback component. Flash Player version 7 is required.
* <BR><BR>
* Events:
* <BR><BR>
* <B>complete</B> - Fired when the playback reaches the end of the video.
* @author Beam Jive Consulting - www.beamjive.com
*/
class com.bjc.controls.VideoPlayer extends com.bjc.core.BJCComponent {
	
	private var __background:Resizer;
	private var __buffer:Number = 3;
	private var __maintainRatio:Boolean = true;
	private var __nc:NetConnection;
	private var __ns:NetStream;
	private var __started:Boolean = false;
	private var __url:String;
	private var __video:Video;
	private var __videoHolder:MovieClip;
	private var buffer_interval:Number;
	
	/**
		See the EventDispatcher Class in Flash Help
	*/
	public var addEventListener:Function;
	/**
		See the EventDispatcher Class in Flash Help
	*/
	public var removeEventListener:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myVideoPlayer.completeHandler = function(){
	* 	trace("The end.");
	* }</pre>
	*/
	public var completeHandler:Function;
	private var dispatchEvent:Function;
	private var dispatchQueue:Function;

	
	public function VideoPlayer(Void) {
	}
	
	private function init(Void):Void {
		super.init();
		EventDispatcher.initialize(this);
		
		__nc = new NetConnection();
		__nc.connect(null);
		__ns = new NetStream(__nc);
		__ns.onStatus = Delegate.create(this, onNsStatus);
		__ns.setBufferTime(__buffer);
		__video = __videoHolder.video;
		__video.attachVideo(__ns);
		
		draw();
	}
	
	
	private function createChildren(Void):Void {
		attachMovie("Resizer", "__background", 0);
		__background.skin = "videoPlayerSkin";
 		attachMovie("VideoHolder", "__videoHolder", 1);
	}
	
	
	/**
		@exclude
		this is documented in BJCComponent, not changed here.
	*/
	public function draw(Void):Void {
		if(__enabled){
			_alpha = 100;
		} else {
			_alpha = __alphaDisabled;
		}
		__ns.setBufferTime(__buffer);
		size();
	}
	
	
	private function size(Void):Void {
		__videoHolder._visible = false;
		__videoHolder._x = 2;
		__videoHolder._y = 2;
		
		var vHolderW:Number = __videoHolder._width = __width - 4;
		var vHolderH:Number = __videoHolder._height = __height - 4;

		__background.move(0, 0);
		__background.setSize(__width, __height);
		
		var vidW:Number = __video.width;
		var vidH:Number = __video.height;
		
		if(vidW > 0 && vidH > 0){
			if(__maintainRatio){
				var wRatio = vHolderW / vidW;
				var hRatio = vHolderH / vidH;
				var ratio = Math.min(wRatio, hRatio);
				__videoHolder._width = (__video.width - 4) * ratio;
				__videoHolder._height = (__video.height - 4) * ratio;
				__videoHolder._x = __width / 2 - __videoHolder._width / 2;
				__videoHolder._y = __height / 2 - __videoHolder._height / 2;
			}
			clearInterval(buffer_interval);
			__videoHolder._visible = true;
		}
	}
	
	private function onNsStatus(status:Object):Void {
		var buffer_pct:Number = Math.round(__ns.bytesLoaded/__ns.bytesTotal*100);
		
		if(status.code == "NetStream.Buffer.Full"){
			size();
		} else if(status.code == "NetStream.Play.Start"){
			clearInterval(buffer_interval);
			buffer_interval = setInterval(this, "size", 50);
		} else if(status.code == "NetStream.Play.Stop" && buffer_pct >= 100){
			dispatchEvent({type:"complete", target:this});
		}
	}	
	
	
	/**
		Static method used to create an instance of a VideoPlayer on stage at run time.
				
		@param target the movie clip to which the video player will be attached.
		@param id the instance name given to the new video player attached.
		@param depth the depth at which to attach the new video player.
		@param initObj (optional) an object containing any properties you want to assign to the component when it is created
		@return a reference to the new video player attached.
		@example
		<pre>
		import com.bjc.controls.VideoPlayer;
		var newVideoPlayer:VideoPlayer = VideoPlayer.create(_root, "myVideoPlayer", 0);
		</pre>
	*/
	public static function create(target:MovieClip, id:String, depth:Number, initObj:Object):VideoPlayer {
		return VideoPlayer(target.attachMovie("VideoPlayer", id, depth, initObj));
	}
		
	

	
	
	
	
	
	/**
		Pauses the playback of the Video, if currently playing, without altering the currentl playhead time.
				
		@return nothing
		@example
		<pre>
		myVideoPlayer.pause();
		</pre>
	*/
	public function pause(Void):Void {
		__ns.pause(true);
	}
	
	
	/**
		Stops the playback of the Video, if currently playing, and returns the playhead to the beginning of the video.
				
		@return nothing
		@example
		<pre>
		myVideoPlayer.rewind();
		</pre>
	*/
	public function rewind(Void):Void {
		__ns.seek(0);
		__ns.pause(true);
	}
	
	
	/**
		If the video has not been played yet, will start the video playing from the beginning. Otherwise, if the video has been started and paused or rewinded, will play the video from the current playhead time.
				
		@return 
		@example
		<pre>
		myVideo.play();
		</pre>
	*/
	public function play(Void):Void {
		if(__started){
			__ns.pause(false);
		} else {
			__ns.play(__url);
			__started = true;
		}
	}
	
	
	

	/**
		Sets the amount in seconds that the video will be buffered.
	
		@example
		<pre>
		myVideoPlayer.buffer = 5;
		</pre>
	*/
	[Inspectable (defaultValue=3)]
	public function set buffer(buff:Number) {
		__buffer = buff;
		invalidate();
	}
	/**
		Gets the amount in seconds that the video will be buffered.
	
		@example
		<pre>
		myVar = myVideoPlayer.buffer;
		</pre>
	*/
	public function get buffer():Number {
		return __buffer;
	}
	
	/**
		Gets the amount of bytes loaded of the flv file.
	
		@example
		<pre>
		myVar = myVideoPlayer.bytesLoaded;
		</pre>
	*/
	public function get bytesLoaded():Number {
		return __ns.bytesLoaded;
	}	
	
	/**
		Gets the total amount of bytes of the flv file.
	
		@example
		<pre>
		myVar = myVideoPlayer.bytesTotal;
		</pre>
	*/
	public function get bytesTotal():Number {
		return __ns.bytesTotal;
	}	


	/**
		Sets the url pointing to the location of an flv file.
	
		@example
		<pre>
		myVideoPlayer.url = "http://www.beamjive.com/sample.flv";
		</pre>
	*/
	[Inspectable]
	public function set url(u:String) {
		__started = false;
		__url = u;
		draw();
		invalidate();
	}
	/**
		Gets the url pointing to the location of an flv file.
	
		@example
		<pre>
		myVar = myVideoPlayer.url;
		</pre>
	*/
	public function get url():String {
		return __url;
	}	
	
	/**
		Sets whether the video will scale to the correct aspect ratio once it is loaded.
	
		@example
		<pre>
		myVideoPlayer.maintainRatio = true;
		</pre>
	*/
	[Inspectable (type="Boolean", defaultValue=true)]
	public function set maintainRatio(b:Boolean) {
		__maintainRatio = b;
		invalidate();
	}
	/**
		Sets the video aspect ratio mode of the component.
	
		@example
		<pre>
		myVar = myVideoPlayer.maintainRatio;
		</pre>
	*/
	public function get maintainRatio():Boolean {
		return __maintainRatio;
	}
}