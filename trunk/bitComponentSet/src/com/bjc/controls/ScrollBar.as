import com.bjc.controls.IconButton;
import mx.events.EventDispatcher;
import mx.utils.Delegate;


[Event("change")]

[Event("focus")]

[Event("rollOver")]

[Event("rollOut")]

[Event("releaseOutside")]


/**
* Base class for HorizScrollBar and VertScrollBar.
* <BR><BR>
* Events:
* <BR><BR>
* <B>change</B> - Fired when the user changes the value of the scroll bar by clicking on the up or down button, the track area of the scroll bar or by moving the thumb.
* <BR>
* <B>focus</B> - Fired when the component receives focus, usually by the user interacting with it.
* <BR>
* <B>releaseOutside</B> - Fired whenever the user presses and releases the mouse outside the component.
* <BR>
* <B>rollOver</B> - Fired whenever the mouse moves over the component.
* <BR>
* <B>rollOut</B> - Fired whenever the mouse leaves the component.
* @author Beam Jive Consulting - www.beamjive.com
*/
class com.bjc.controls.ScrollBar extends com.bjc.core.BJCComponent {
 	private var clipParameters:Object = {lineScroll:1, maximum:1, minimum:1, value:1};

	
	private var __back:MovieClip;
	private var __btnADown:MovieClip;
	private var __btnAUp:MovieClip;
	private var __btnBDown:MovieClip;
	private var __btnBUp:MovieClip;
	private var __isOver:Boolean = false;
	private var __limitA:Number = 16;
	private var __limitB:Number;
	private var __lineScroll:Number = 1;
	private var __maximum:Number = 100;
	private var __minimum:Number = 0;
	private var __pageSize:Number;
	private var __scrollInterval:Number;
	private var __thumb;
	private var __thumbScale:Number;
	private var __value:Number = 0;
	
	
	/**
		See the EventDispatcher Class in Flash Help
	*/
	public var addEventListener:Function;
	/**
		See the EventDispatcher Class in Flash Help
	*/
	public var removeEventListener:Function;
	private var dispatchEvent:Function;
	private var dispatchQueue:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myScrollBar.changeHandler = function(){
	* 	trace("I was changed.");
	* }</pre>
	*/
	public var changeHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myScrollBar.focusHandler = function(){
	* 	trace("Set focus.");
	* }</pre>
	*/
	public var focusHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myScrollBar.releaseOutsideHandler = function(){
	* 	trace("Release outside.");
	* }</pre>
	*/
	public var releaseOutsideHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myScrollBar.rollOverHandler = function(){
	* 	trace("Roll over.");
	* }</pre>
	*/
	public var rollOverHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myScrollBar.rollOutHandler = function(){
	* 	trace("Roll out.");
	* }</pre>
	*/
	public var rollOutHandler:Function;



	// these will all be set by extending class:
	private var __backSkin:String;
	private var __btnADownSkin:String;
	private var __btnAUpSkin:String;
	private var __btnBDownSkin:String;
	private var __btnBUpSkin:String;
	private var __resizerType:String;
	private var __thumbSkin:String;
	
	private var thumbSize:Number;
	private var thumbPos:Number;
	private var mousePos:Number;
	private var setThumbMargins:Function;
	
	
	
	public function ScrollBar(Void) {
	}
	
	
	private function init(Void):Void {
		super.init();
		EventDispatcher.initialize(this);
		
		__back.onRelease = Delegate.create(this, onBackPress);
		__back.useHandCursor = false;
		
		__btnAUp.onPress = Delegate.create(this, onScrollA);
		__btnAUp.onRelease = __btnAUp.onReleaseOutside = Delegate.create(this, stopScroll);
		__btnAUp.onRollOver = __btnADown.onRollOver = Delegate.create(this, rolledOver);
		__btnAUp.onRollOut = __btnADown.onRollOut = Delegate.create(this, rolledOut);
		__btnAUp.useHandCursor = false;
		__btnADown._visible = false;
		
		__btnBUp.onPress = Delegate.create(this, onScrollB);
		__btnBUp.onRelease = __btnBUp.onReleaseOutside = Delegate.create(this, stopScroll);
		__btnBUp.onRollOver = __btnBDown.onRollOver = Delegate.create(this, rolledOver);
		__btnBUp.onRollOut = __btnBDown.onRollOut = Delegate.create(this, rolledOut);
		__btnBUp.useHandCursor = false;
		__btnBDown._visible = false;
		
		__thumb.skin = __thumbSkin;
		__thumb.onPress = Delegate.create(this, onStartDrag);
		__thumb.onRelease = __thumb.onReleaseOutside = Delegate.create(this, onEndDrag);
		__thumb.onRollOver = __back.onRollOver = Delegate.create(this, rolledOver);
		__thumb.onRollOut = __back.onRollOut = Delegate.create(this, rolledOut);
		__thumb.useHandCursor = false;
		setThumbMargins();
		__thumb._visible = false;

		draw();
	}
	
	
	private function createChildren(Void):Void {
		attachMovie(__btnAUpSkin, "__btnAUp", 2);
		attachMovie(__btnADownSkin, "__btnADown", 3);
		                 
		attachMovie(__btnBUpSkin, "__btnBUp", 4);
		attachMovie(__btnBDownSkin, "__btnBDown", 5);

		attachMovie(__resizerType, "__thumb", 1);
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
		__back.setSize(__width, __height);
		setThumbPos();
	}
	
	
	
	
	
	
	private function correctValues(Void):Void {
		if(isInverted()){
			__value = Math.min(__value, __minimum);
			__value = Math.max(__value, __maximum);
		} else {
			__value = Math.max(__value, __minimum);
			__value = Math.min(__value, __maximum);
		}
	}		
	
	
	private function doScroll(amt:Number):Void {
		if(isInverted()){
			amt *= -1;
		}
		__value -= amt;
		correctValues();
		setThumbPos();
		dispatchEvent({type:"change", target:this});
	}
	
	
	private function getRatio(Void):Number {
		var thumbRange:Number = Math.round(__limitB - __limitA - thumbSize);
		var valueRange:Number = __maximum - __minimum;
		return valueRange / thumbRange;
	}		
	
	
	private function isInverted(Void):Boolean {
		return __minimum > __maximum;
	}
	
	
	private function onBackPress(Void):Void {
		if(__enabled){
			if(__pageSize == undefined) {
				if(mousePos > thumbPos){
	 				thumbPos += thumbSize;
	 				thumbPos = Math.min(thumbPos, __limitB - thumbSize);
				} else {
	 				thumbPos -= thumbSize;
	 				thumbPos = Math.max(thumbPos, __limitA);
				} 
	 			update();
	 		}
	 		else
	 		{
				if(mousePos > thumbPos){
		 			value += __pageSize;
				} else {
		 			value -= __pageSize;
		 		}
	 			dispatchEvent({type:"change", target:this});
	 		}
			dispatchEvent({type:"focus", target:this});
		}
	}
	
	private function rolledOver(Void):Void {
		if(!__isOver){
			__isOver = true;
			dispatchEvent({type:"rollOver", target:this});
		}
	}
	
	private function rolledOut(Void):Void {
		if(__isOver && (_xmouse < 2 || _xmouse > __width-2 || _ymouse < 2 || _ymouse > __height-2)){
			__isOver = false;
			dispatchEvent({type:"rollOut", target:this});
		}
	}
	
	
	private function onEndDrag(Void):Void {
		__thumb.stopDrag();		
		delete onMouseMove;
		if(__isOver && (_xmouse < 0 || _xmouse > __width || _ymouse < 0 || _ymouse > __height)){
			__isOver = false;
			dispatchEvent({type:"releaseOutside", target:this});
		}
		dispatchEvent({type:"focus", target:this});
	}
	
	
	private function onScrollA(evtObj:Object):Void {
		if(__enabled){
			__btnADown._visible = true;
			__scrollInterval = setInterval(this, "doScroll", 50, __lineScroll);
		}
	}
	
	
	private function onScrollB(evtObj:Object):Void {
		if(__enabled){
			__btnBDown._visible = true;
			__scrollInterval = setInterval(this, "doScroll", 50, - __lineScroll);
		}
	}
	
	
	private function onStartDrag(Void):Void {
	}
	
	
	private function stopScroll(Void):Void {
		__btnADown._visible = false;
		__btnBDown._visible = false;
		clearInterval(__scrollInterval);
		if(__isOver && (_xmouse < 0 || _xmouse > __width || _ymouse < 0 || _ymouse > __height)){
			__isOver = false;
			dispatchEvent({type:"releaseOutside", target:this});
		}
		dispatchEvent({type:"focus", target:this});
	}
	
	
	private function setThumbPos(Void):Void {
		thumbPos = Math.round((__value - __minimum) / getRatio()) + __limitA;
	}
	
	
	private function update(Void):Void {
		var oldValue:Number = __value;
		__value = (thumbPos - __limitA) * getRatio() + __minimum;
		if(oldValue != __value){
			dispatchEvent({type:"change", target:this});
		}
		updateAfterEvent();
	}
	
	




	
	/**
		Determines how much the scrollbar's value will change when one of the arrow buttons is clicked. If the scrollbar is being used to control something like a text area, this should probably be set to one, to cause the text to scroll one line. If it is scrolling a picture or movie clip, it should probably be set to a larger amount.
	
		@example
		<pre>
		myScrollBar.lineScroll = 20;
		</pre>
	*/
	[Inspectable (defaultValue=1)]
	public function set lineScroll(val:Number) {
		__lineScroll = val;
	}
	/**
		Gets the scroll value changed when one of the arrow buttons is clicked.
	
		@example
		<pre>
		myVar = myScrollBar.lineScroll;
		</pre>
	*/
	public function get lineScroll():Number {
		return __lineScroll;
	}
	
	
	/**
		Sets the maximum value of the scrollbar. In a vertical bar, this will be the value when the thumb is all the way to the bottom of the bar; in a horizontal one, when the thumb is to the far right. You can invert the bar by making minimum higher than maximum.
	
		@example
		<pre>
		myScrollBar.maximum = 100;
		</pre>
	*/
	[Inspectable (defaultValue=100)]
	public function set maximum(max:Number) {
		__maximum = max;
		correctValues();
		invalidate();
	}
	/**
		Gets the maximum value of the scrollbar.
	
		@example
		<pre>
		myVar = myScrollBar.maximum;
		</pre>
	*/
	public function get maximum():Number {
		return __maximum;
	}
	
	
	/**
		Sets the minimum value of the scrollbar. In a vertical bar, this will be the value when the thumb is all the way to the top of the bar; in a horizontal one, when the thumb is to the far left. You can invert the bar by making minimum higher than maximum.
	
		@example
		<pre>
		myScrollBar.minimum = 0;
		</pre>
	*/
	[Inspectable (defaultValue=0)]
	public function set minimum(min:Number) {
		__minimum = min;
		correctValues();
		invalidate();
	}
	/**
		Gets the minimum value of the scrollbar.
	
		@example
		<pre>
		myVar = myScrollBar.minimum;
		</pre>
	*/
	public function get minimum():Number {
		return __minimum;
	}
	
	/**
		Sets the amount the value will change if the user clicks above or below the thumb. If not defined, the thumb will move the distance of its width/height and the value will be computed based on how much it moved.
	
		@example
		<pre>
		myScrollBar.pageSize = 10;
		</pre>
	*/
	public function set pageSize(ps:Number)
	{
		__pageSize = ps;
	}
	/**
		Gets the amount the value will change if the user clicks above or below the thumb. 
	
		@example
		<pre>
		myVar = myScrollBar.pageSize;
		</pre>
	*/
	public function get pageSize():Number
	{
		return __pageSize;
	}
	
	/**
		Sets the percentage of the available space that the thumb will take up. A value from 0 to 1. This is generally computed in a component as a percentage of visible content to total content.
	
		@example
		<pre>
		myScrollBar.thumbScale = myWindow._height / myContent._height;
		</pre>
	*/
	public function set thumbScale(ts:Number) {
		__thumbScale = ts;
		if(__thumbScale >= 1){
			__thumbScale = 1;
			__thumb._visible = false;
		} else {
			__thumb._visible = true;
			thumbSize = Math.ceil((__limitB - __limitA) * __thumbScale);
		}
		setThumbPos();
	}
	/**
		Gets the percentage of the available space that the thumb will take up. 
	
		@example
		<pre>
		myVar = myScrollBar.thumbScale;
		</pre>
	*/
	public function get thumbScale():Number {
		return __thumbScale;
	}
	
	
	/**
		Sets the current value of the scroll bar, between minimum and maximum.
		
		@example
		<pre>
		myScrollbar.value = 30;
		</pre>
	*/
	[Inspectable (defaultValue=0)]
	public function set value(val:Number) {
		__value = val;
		correctValues();
		setThumbPos();
	}
	/**
		Gets the current value of the scroll bar, between minimum and maximum.
		
		@example
		<pre>
		myVar = myScrollbar.value;
		</pre>
	*/
	public function get value():Number {
		return __value;
	}
	
	
}