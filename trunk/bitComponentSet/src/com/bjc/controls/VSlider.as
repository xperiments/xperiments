import com.bjc.resizers.HResizer;
import com.bjc.resizers.Resizer;
import mx.events.EventDispatcher;
import mx.utils.Delegate;

[IconFile ("icons/VSlider.png")]

[Event("change")]

[Event("focus")]

[Event("killFocus")]

[Event("tabFocus")]

/**
* Vertical Slider component for choosing values.
* <BR><BR>
* Events:
* <BR><BR>
* <B>change</B> - Fired whenever the user moves the slider thumb, changing the value.
* <BR>
* <B>focus</B> - Fired whenever the component receives focus.
* <BR>
* <B>killFocus</B> - Fired whenever the component loses focus.
* <BR>
* <B>tabFocus</B> - Fired whenever the component receives focus by pressing the TAB key.
* @author Beam Jive Consulting - www.beamjive.com
*/
class com.bjc.controls.VSlider extends com.bjc.core.BJCComponent {
 	private var clipParameters:Object = {maximum:1, minimum:1, value:1};

	
	private var __back:Resizer;
	private var __backWidth:Number = 4;
	private var __keyListener:Object;
	private var __maximum:Number = 100;
	private var __minimum:Number = 0;
	private var __range:Number = 80;
	private var __thumb:HResizer;
	private var __thumbOver:HResizer;
	private var __value:Number;
	
	/**
	* Can be used to choose whetever the event handler will be called when the value has been set by code. This variable is set to true by default.
	* @usage <pre>mySlider.eventOnValue = false;
	* mySlider.value = 0xFF0000;</pre>
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
	* @usage <pre>mySlider.changeHandler = function(){
	* 	trace("I was changed.");
	* }</pre>
	*/
	public var changeHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>mySlider.focusHandler = function(){
	* 	trace("Set focus.");
	* }</pre>
	*/
	public var focusHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>mySlider.killFocusHandler = function(){
	* 	trace("Kill focus.");
	* }</pre>
	*/
	public var killFocusHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>mySlider.tabFocusHandler = function(){
	* 	trace("Tab focus.");
	* }</pre>
	*/
	public var tabFocusHandler:Function;
	private var dispatchEvent:Function;
	private var dispatchQueue:Function;
	
	
	
	public function VSlider(Void) {
	}
	
	
	private function init(Void):Void {
		super.init();
		EventDispatcher.initialize(this);
		Mouse.addListener(this);
		
		__back.skin = "vSliderBackSkin";
		var temp:MovieClip = attachMovie("vSliderBackSkin", "temp", 99);
		__backWidth = temp._width;
		temp.removeMovieClip();
		
		__thumbOver.onRollOver = Delegate.create(this, onOver);
		__thumbOver.onRollOut = Delegate.create(this, onOut);
		__thumbOver.onPress = Delegate.create(this, onDrag);
		__thumbOver.onRelease = __thumbOver.onReleaseOutside = Delegate.create(this, onDrop);
		__back.onPress = Delegate.create(this, onTrack);
		__back.useHandCursor = false;
		
		draw();
	}
	
	
	private function createChildren(Void):Void {
		attachMovie("Resizer", "__back", 0);
		attachMovie("HResizer", "__thumbOver", 2);
		attachMovie("HResizer", "__thumb", 3);
		__thumb.skin = "vSliderThumbSkin";
		__thumbOver.skin = "vSliderThumbOverSkin";
		__thumb.margin = 5;
		__thumbOver.margin = 5;
		__back.leftMargin = __back.rightMargin = 2;
		__back.topMargin = __back.bottomMargin = 4;
		
		attachMovie("Resizer", "__focus", 1);
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
		__range = Math.round(__height - __thumb._height);
		
		__thumb._y = __range - __range * (__value - __minimum) / (__maximum - __minimum);
		__thumb.setSize(__width, 10);
		
		__thumbOver._y = __range - __range * (__value - __minimum) / (__maximum - __minimum);
		__thumbOver.setSize(__width, 10);
		
		__back.setSize(__backWidth, __height);
		__back._x = __width / 2 - __back.width / 2;
	}
	
	
	/**
		Static method used to create an instance of a VSlider on stage at run time.
				
		@param target the movie clip to which the slider will be attached.
		@param id the instance name given to the new slider attached.
		@param depth the depth at which to attach the new slider.
		@param initObj (optional) an object containing any properties you want to assign to the component when it is created
		@return a reference to the new slider attached.
		@example
		<pre>
		import com.bjc.controls.VSlider;
		var newVSlider:VSlider = VSlider.create(_root, "myVSlider", 0);
		</pre>
	*/
	public static function create(target:MovieClip, id:String, depth:Number, initObj:Object):VSlider {
		return VSlider(target.attachMovie("VSlider", id, depth, initObj));
	}
		
	private function onOver(Void):Void {
		if(__enabled){
			__thumb._visible = false;
		}
	}

	private function onOut(Void):Void {
		if(__enabled){
			if((_ymouse <= __thumbOver._y) || (_ymouse >= __thumbOver._y + 10) || (_xmouse <= 0) || (_xmouse >= __width)){
				__thumb._y = __thumbOver._y;
				__thumb._visible = true;
			}
		}
	}

	
	
	private function onTrack(Void):Void {
		if(__enabled){
			if(_ymouse > __range){
				__thumbOver._y = __range;
			}else{
				__thumbOver._y = _ymouse;
			}
			update();
			if(Selection.getFocus() != "" + this) Selection.setFocus(this);
		}
	}
	
	
	
	private function onDrag(Void):Void {
		if(__enabled){
			__thumbOver.startDrag(false, 0, 0, 0, __range);
			onMouseMove = update;
		}
	}
	
	
	private function onDrop(Void):Void {
		__thumb.stopDrag();
		onMouseMove = checkHit;
		if(Selection.getFocus() != "" + this) Selection.setFocus(this);
	}
	
	private function checkHit(Void):Void {
		if((_ymouse < __thumbOver._y) || (_ymouse > __thumbOver._y + 10) || (_xmouse < 0) || (_xmouse > __width)){
			__thumb._y = __thumbOver._y;
			__thumb._visible = true;
			delete onMouseMove;
		}
	}
	
	private function onMouseWheel(delta:Number):Void {
		if(__enabled && (_xmouse > 0) && (_xmouse < __width) && (_ymouse > 0) && (_ymouse < __height)){
			value += delta;
			dispatchEvent({type:"change", target:this});
		}
	}
			
	private function onKeyPressed(Void):Void {
		if((Selection.getFocus() == "" + this) && __enabled && __keyEnabled){
			if(Key.getCode() == Key.UP){
				value ++;
			} else if(Key.getCode() == Key.DOWN){
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
	
	private function update(Void):Void {
		__value = (__range - __thumbOver._y) / __range * (__maximum - __minimum) + __minimum;
		__thumb._y = __thumbOver._y;
		dispatchEvent({type:"change", target:this});
	}
	
	
	
	/**
		Sets the maximum possible value on the slider. Note, it is possible to make a "backwards" slider by making maximum lower than minimum.
				
		@example
		<pre>
		mySlider.maximum = 100;
		</pre>
	*/
	[Inspectable (defaultValue=100)]
	public function set maximum(max:Number) {
		__maximum = max;
		invalidate();
	}
	/**
		Gets the maximum possible value on the slider. 
				
		@example
		<pre>
		myVar = mySlider.maximum;
		</pre>
	*/
	public function get maximum():Number {
		return __maximum;
	}
	
	
	/**
		Sets the minimum possible value on the slider. Note, it is possible to make a "backwards" slider by making maximum lower than minimum.
				
		@example
		<pre>
		mySlider.minimum = 0;
		</pre>
	*/
	[Inspectable (defaultValue=0)]
	public function set minimum(min:Number) {
		__minimum = min;
		invalidate();
	}
	/**
		Gets the minimum possible value on the slider. 
				
		@example
		<pre>
		myVar = mySlider.minimum;
		</pre>
	*/
	public function get minimum():Number {
		return __minimum;
	}
	
	
	/**
		Sets the hand cursor mode on the slider track.
				
		@example
		<pre>
		mySlider.useHandCursorOnTrack = true;
		</pre>
	*/
	public function set useHandCursorOnTrack(mod:Boolean) {
		__back.useHandCursor = mod;
	}
	
	
	/**
		Sets the current value of the slider. This will fire the change event if the eventOnValue is set to true (changed in version 1.3).
				
		@example
		<pre>
		mySlider.value = 50;
		</pre>
	*/
	[Inspectable (defaultValue=50)]
	public function set value(v:Number) {
		__value = v;
		__value = Math.max(__value, __minimum);
		__value = Math.min(__value, __maximum);
		invalidate();
		if(eventOnValue) dispatchEvent({type:"change", target:this});
	}
	[Bindable]
	[ChangeEvent ("change")]
	/**
		Gets the current value of the slider.
				
		@example
		<pre>
		myVar = mySlider.value;
		</pre>
	*/
	public function get value():Number {
		return __value;
	}
}