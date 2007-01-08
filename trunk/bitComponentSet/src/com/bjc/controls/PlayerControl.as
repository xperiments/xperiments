import com.bjc.controls.IconButton;
import mx.utils.Delegate;


[IconFile ("icons/PlayerControl.png")]

/**
* A simple play/pause and rewind button container that can be targeted to and used to control a VideoPlayer component.
* @author Beam Jive Consulting - www.beamjive.com
*/
class com.bjc.controls.PlayerControl extends com.bjc.core.BJCComponent {
 	private var clipParameters:Object = {target:1};

	private var __buttonWidth:Number = 22;
	private var __playBtn:com.bjc.controls.IconButton;
	private var __rewindBtn:com.bjc.controls.IconButton;
	private var __target:Object;


	public function PlayerControl(Void) {
	}
	
	
	private function init(Void):Void {
		super.init();
		__playBtn.toggle = true;
		
		__rewindBtn.addEventListener("click", Delegate.create(this, onRewind));
		__playBtn.addEventListener("click", Delegate.create(this, onPlay));
		
		var temp:MovieClip = attachMovie("playerControlPlaySkin", "temp", 99);
		__buttonWidth = temp._width;
		temp.removeMovieClip();
		
		draw();
	}
	
	
	private function createChildren(Void):Void {
		attachMovie("IconButton", "__rewindBtn", 0);
		__rewindBtn.upIcon = "playerControlRewindUpSkin";
		__rewindBtn.downIcon = "playerControlRewindDownSkin";
		__rewindBtn.overIcon = "playerControlRewindOverSkin";
		
		attachMovie("IconButton", "__playBtn", 1);
		__playBtn.upIcon = "playerControlPlaySkin";
		__playBtn.downIcon = "playerControlPauseSkin";
		__playBtn.overIcon = "playerControlOverSkin";
		
	}
	
	
	/**
		@exclude
	*/
	public function draw(Void):Void {
		size();
	}
	
	
	private function size(Void):Void {
 		__playBtn.move(__width - __buttonWidth, 0);
	}
	
	
	/**
		Static method used to create an instance of a PlayerControl on stage at run time.
				
		@param target the movie clip to which the player control will be attached.
		@param id the instance name given to the new player control attached.
		@param depth the depth at which to attach the new player control.
		@param initObj (optional) an object containing any properties you want to assign to the component when it is created
		@return a reference to the new player control attached.
		@example
		<pre>
		import com.bjc.controls.PlayerControl;
		var newPlayerControl:PlayerControl = PlayerControl.create(_root, "myPlayerControl", 0);
		</pre>
	*/
	public static function create(target:MovieClip, id:String, depth:Number, initObj:Object):PlayerControl {
		return PlayerControl(target.attachMovie("PlayerControl", id, depth, initObj));
	}
		
	

	
	
	
	
	private function onRewind(evtObj:Object):Void {
		__target.rewind();
		__playBtn.selected = false;
	}
	
	
	private function onPlay(evtObj:Object):Void {
		if(__playBtn.selected){
			__target.play();
		} else {
			__target.pause();
		}
	}
	
	
	/**
		A reference to a VideoPlayer component that this component will control.
	
		@example
		<pre>
		myPlayerControl.target = myVideoPlayer;
		</pre>
	*/
	[Inspectable]
	public function set target(targ:Object) {
		__target = eval(targ);
	}
	/**
		A reference to a VideoPlayer component that this component will control.
	
		@example
		<pre>
		myVar = myPlayerControl.target;
		</pre>
	*/
	public function get target():Object {
		return __target;
	}
	
}