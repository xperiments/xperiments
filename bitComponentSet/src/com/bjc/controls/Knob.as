import mx.events.EventDispatcher;
import com.bjc.resizers.Resizer;
import mx.utils.Delegate;

[IconFile ("icons/Knob.png")]

[Event("change")]

[Event("focus")]

[Event("killFocus")]

[Event("tabFocus")]

/**
* A rotary knob for setting values
* <BR><BR>
* Events:
* <BR><BR>
* <B>change</B> - Fired whenever the user moves the mouse after pressing on the knob, changing the current value.
* <BR>
* <B>focus</B> - Fired whenever the component receives focus.
* <BR>
* <B>killFocus</B> - Fired whenever the component loses focus.
* <BR>
* <B>tabFocus</B> - Fired whenever the component receives focus by pressing the TAB key.
* @author Beam Jive Consulting - www.beamjive.com
*/
class com.bjc.controls.Knob extends com.bjc.core.BJCComponent {
 	private var clipParameters:Object = {maximum:1, minimum:1, value:1, mode:1, sensitivity:1};
 	
 	
	private var __background:MovieClip;
	private var __handle:MovieClip;
	private var __keyListener:Object;
	private var __maximum:Number = 100;
	private var __minimum:Number = 0;
	private var __mode:String = "vertical";
	private var __sensitivity:Number = 5;
	private var __startValue:Number;
	private var __startX:Number;
	private var __startY:Number;
	private var __value:Number = 0;
	
	/**
	* Can be used to choose whetever the event handler will be called when the value has been set by code. This variable is set to true by default.
	* @usage <pre>myKnob.eventOnValue = false;
	* myKnob.value = 0xFF0000;</pre>
	*/
	public var eventOnValue:Boolean = true;
	
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
	* @usage <pre>myKnob.changeHandler = function(){
	* 	trace("I was changed.");
	* }</pre>
	*/
	public var changeHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myKnob.focusHandler = function(){
	* 	trace("Set focus.");
	* }</pre>
	*/
	public var focusHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myKnob.killFocusHandler = function(){
	* 	trace("Kill focus.");
	* }</pre>
	*/
	public var killFocusHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myKnob.tabFocusHandler = function(){
	* 	trace("Tab focus.");
	* }</pre>
	*/
	public var tabFocusHandler:Function;
	private var dispatchEvent:Function;
	private var dispatchQueue:Function;
	
	public function Knob(Void) {
	}
	
	
	private function init(Void):Void {
		super.init();
		EventDispatcher.initialize(this);
		Mouse.addListener(this);
		__handle.onPress = Delegate.create(this, pressed);
		__handle.onRelease = Delegate.create(this, released);
		__handle.onReleaseOutside = Delegate.create(this, releasedOutside);
		__background.onPress = __handle.onPress;
		__background.onRelease = __handle.onRelease;
		__background.onReleaseOutside = __handle.onReleaseOutside;
		if(__mode == "angular") __background.useHandCursor = false;
		draw();
	}
	
	
	private function createChildren(Void):Void {
		attachMovie("knobSkin", "__background", 0);
		attachMovie("knobHandle", "__handle", 1);
		attachMovie("Resizer", "__focus", 2);
		__focus.skin = "focusSkin";
		__focus.margin = 5;
		__focus._visible = false;
	}
	
	
	/**
		@exclude
	*/
	public function draw(Void):Void {
		if(__enabled){
			_alpha = 100;
		} else {
			_alpha = __alphaDisabled;
		}
		size();
	}
	
	
	private function size(Void):Void {
		__focus.setSize(__width, __height);
		__background._width = __width;
		__background._height = __height;
		__background._x = __width / 2;
		__background._y = __height / 2;
		setKnob();
	}
	
	
	/**
		Static method used to create an instance of a Knob on stage at run time.
				
		@param target the movie clip to which the knob will be attached.
		@param id the instance name given to the new knob attached.
		@param depth the depth at which to attach the new knob.
		@param initObj (optional) an object containing any properties you want to assign to the component when it is created
		@return a reference to the new knob attached.
		@example
		<pre>
		import com.bjc.controls.Knob;
		var newKnob:Knob = Knob.create(_root, "myKnob", 0);
		</pre>
	*/
	public static function create(target:MovieClip, id:String, depth:Number, initObj:Object):Knob {
		return Knob(target.attachMovie("Knob", id, depth, initObj));
	}
	
	

	
	private function angular(Void):Void {
		var t2:Number = Math.atan2(_ymouse-__height/2, _xmouse-__width/2);
		var dx:Number = (t2 / (Math.PI/180) + 240) / 3;
		if(dx > 110){
			var dx:Number = (t2 / (Math.PI/180) - 120) / 3;
		}
		dx = __minimum + dx * (__maximum - __minimum) / 100;
		__startValue = 0;
		var pv:Number = 1;
		if(__maximum > __minimum){
			if(dx < (__maximum - __minimum)/2 && __value > (__maximum - __minimum)*.75){
				pv = 0;
			}
			if(dx > (__maximum - __minimum)/2 && __value < (__maximum - __minimum)*.25){
				pv = 0;
			} 
		} else {
			if(dx < (__maximum - __minimum)/2 && __value > (__maximum - __minimum)*.25){
				pv = 0;
			}
			if(dx > (__maximum - __minimum)/2 && __value < (__maximum - __minimum)*.75){
				pv = 0;
			}
		}
		if(__maximum < __minimum) dx *= -1;
		
		if(pv == 1)	rotate(dx);

	}
	
	
	
	
	private function horizontal(Void):Void {
		var dx:Number = (_xmouse - __startX) * __sensitivity / 10;
		rotate(dx);
	}
	
	
	private function onMouseWheel(delta:Number):Void {
		if((Selection.getFocus() == "" + this) && __enabled && (_xmouse > 0) && (_xmouse < __width) && (_ymouse > 0) && (_ymouse < __height)){
			value += delta;
			dispatchEvent({type:"change", target:this});
		}
	}
	
	private function onKeyPressed(Void):Void {
		if((Selection.getFocus() == "" + this) && __enabled && __keyEnabled){
			if(Key.getCode() == Key.RIGHT || Key.getCode() == Key.UP){
				value ++;
			} else if(Key.getCode() == Key.LEFT || Key.getCode() == Key.DOWN){
				value --;
			}
		}
	}
	
	
	private function onKillFocus(newFocus:Object):Void {
		Key.removeListener(__keyListener);
		__keyListener = null;
		hideFocus();
		dispatchEvent({type:"killFocus", target:this, newfocus:newFocus});
	}
	
	
	private function onSetFocus(oldFocus:Object):Void {
		if(__keyListener == null || __keyListener == undefined){
			__keyListener = new Object();
			__keyListener.onKeyDown = Delegate.create(this, onKeyPressed);
			Key.addListener(__keyListener);
		}
		dispatchEvent({type:"focus", target:this, oldfocus:oldFocus});
		if(Key.isDown(9)){
			showFocus();
			dispatchEvent({type:"tabFocus", target:this, oldfocus:oldFocus});
		}
	}
	
	private function pressed(Void):Void {
		if(__enabled){
			if(__mode != "angular"){ 
				__startX = _xmouse;
				__startY = _ymouse;
				__startValue = __value;
				onEnterFrame = this[__mode];
			} else if(__mode == "angular" && (_xmouse >= __handle._x-__handle._width/2) && (_xmouse <= __handle._x+__handle._width/2) && (_ymouse >= __handle._y-__handle._height/2) && (_ymouse <= __handle._y+__handle._height/2)){
				onEnterFrame = this[__mode];
			}
		}
	}
	
	
	private function released(Void):Void {
		delete onEnterFrame;
		if(Selection.getFocus() != "" + this) Selection.setFocus(this);
	}
	
	
	private function releasedOutside(Void):Void {
		delete onEnterFrame;
	}
	
	
	private function rotate(amt:Number):Void {
		if(__maximum > __minimum){
			__value = __startValue + amt;
			__value = Math.max(__minimum, __value);
			__value = Math.min(__maximum, __value);
		} else {
			__value = __startValue - amt;
			__value = Math.min(__minimum, __value);
			__value = Math.max(__maximum, __value);
		}
		dispatchEvent({type:"change", target:this});
		setKnob();
		
	}
	
	
	private function setKnob(Void):Void {
		var valueRange:Number  = __maximum - __minimum;
		var knobRange:Number = 300;
		var ratio:Number = knobRange / valueRange;
		var angle:Number = (120 + (__value - __minimum) * ratio) * Math.PI / 180;
		__handle._x = __width / 2 + Math.cos(angle) * (__width / 2 - __handle._width);
		__handle._y = __height / 2 + Math.sin(angle) * (__height / 2 - __handle._width);
	}
	
	
	private function vertical(Void):Void {
		var dy:Number = (__startY - _ymouse) * __sensitivity / 10;
		__value = __startValue + dy;
		__value = Math.max(__minimum, __value);
		__value = Math.min(__maximum, __value);
		rotate(dy);
	}
	
	
	
	
	/**
		Sets the maximum possible value on the knob. Note, it is possible to make a "backwards" knob by making maximum lower than minimum.
				
		@example
		<pre>
		myKnob.maximum = 100;
		</pre>
	*/
	[Inspectable (defaultValue=100)]
	public function set maximum(max:Number) {
		__maximum = max;
		setKnob();
	}
	/**
		Gets the maximum possible value on the knob.
				
		@example
		<pre>
		myVar = myKnob.maximum;
		</pre>
	*/
	public function get maximum():Number {
		return __maximum;
	}
	
	
	/**
		Sets the minimum possible value on the knob. Note, it is possible to make a "backwards" knob by making maximum lower than minimum.
				
		@example
		<pre>
		myKnob.minimum = 0;
		</pre>
	*/
	[Inspectable (defaultValue=0)]
	public function set minimum(min:Number) {
		__minimum = min;
		setKnob();
	}
	/**
		Gets the minimum possible value on the knob.
				
		@example
		<pre>
		myVar = myKnob.minimum;
		</pre>
	*/
	public function get minimum():Number {
		return __minimum;
	}
	
	
	/**
		Determines what type of mouse movement will be used to change the knob's value. Vertical means that after clicking on the knob, dragging up will increase its value, dragging down will decrease it. For horizontal, dragging right and left will increase or decrease the value, respectively. In the angular mode the knob value will be set by the mouse position (added in version 1.2). 
				
		@example
		<pre>
		myKnob.mode = "vertical";
		</pre>
	*/
	[Inspectable (type="List", defaultValue="vertical", enumeration="vertical,horizontal,angular")]
	public function set mode(m:String) {
		__mode = m;
		if(__mode == "angular"){
			__background.useHandCursor = false;
		} else {
			__background.useHandCursor = true;
		}
	}
	/**
		Gets the mode the knob.
				
		@example
		<pre>
		myVar = myKnob.mode;
		</pre>
	*/
	public function get mode():String {
		return __mode;
	}
	
	
	/**
		Determines how much mouse movement is needed to make a given amount of change of value in the knob. A higher value for sensitivity will mean that less mouse movement is required to cycle through the full range of values.
				
		@example
		<pre>
		myKnob.sensitivity = 10;
		</pre>
	*/
	[Inspectable (defaultValue=10)]
	public function set sensitivity(sen:Number) {
		__sensitivity = sen;
		__sensitivity = Math.max(1, __sensitivity);
		__sensitivity = Math.min(10, __sensitivity);
	}
	/**
		Gets the the knob sensitivity.
				
		@example
		<pre>
		myVar = myKnob.sensitivity;
		</pre>
	*/
	public function get sensitivity():Number {
		return __sensitivity;
	}

		
	/**
		Sets the value of the knob. This will fire the change event if the eventOnValue is set to true (changed in version 1.3).
				
		@example
		<pre>
		myKnob.value = 50;
		</pre>
	*/
	[Inspectable (defaultValue=0)]
	public function set value(val:Number) {
		__value = val;
		__value = Math.max(__value, __minimum);
		__value = Math.min(__value, __maximum);
		setKnob();
		if(eventOnValue) dispatchEvent({type:"change", target:this});
	}
	[Bindable]
	[ChangeEvent ("change")]
	/**
		Gets the value of the knob.
				
		@example
		<pre>
		myVar = myKnob.value;
		</pre>
	*/
	public function get value():Number {
		return __value;
	}
}