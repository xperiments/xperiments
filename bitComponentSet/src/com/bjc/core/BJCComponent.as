import mx.utils.Delegate;
/**
*   Base class for all BJC Bit Components.
*	@author Beam Jive Consulting - www.beamjive.com
*/
class com.bjc.core.BJCComponent extends MovieClip {
	
	public var version:String = "1.3.0";
 	private var clipParameters:Object;
	
	private var __alphaDisabled:Number = 50;
	private var __boundingbox:MovieClip;
	private var __enabled:Boolean = true;
	private var __focus:MovieClip;
	private var __focusInterval:Number;
	private var __focusLimit:Number = 2000;
	private var __focusTime:Number;
	private var __focusTimer:Number;
	private var __invalidateClip:MovieClip;
	private var __doLaterQueue:Array;
	private var __keyEnabled:Boolean = true;
	private var __width:Number;
	private var __height:Number;
	
	//public static var globalStyle:Object;
	
	public function BJCComponent(Void) {
		init();
	}
	
	
	private function init(Void):Void {
		_root._focusrect = false;
		focusEnabled = true;
		__width = _width;
		__height = _height;
		_xscale = 100;
		_yscale = 100;
		__boundingbox._width = 0;
		__boundingbox._height = 0;
		__boundingbox._visible = false;
		initFromClipParameters();
		createChildren();
	}
	
	
	private function createChildren(Void):Void {
	}
	

	/**
		Forces an immediate redraw of the component, though generally invalidate() is preferred.
	
		@return nothing
		@example
		<pre>
		myComponent.draw();
		</pre>
	*/
	public function draw(Void):Void {
	}
	
	
	private function size(Void):Void {
	}
	
	
	/**
		Places the component at the specified x/y position.
	
		@param x the position on the x axis to place the component.
		@param y the position on the y axis to place the component.
		@return nothing
		@example
		<pre>
		myComponent.move(100, 100);
		</pre>
	*/
	public function move(x:Number, y:Number):Void {
		_x = x;
		_y = y;
	}
	
	
	private function doInvalidation(Void):Void {
		var tempQueue:Array = __doLaterQueue.slice(0);
		__doLaterQueue = new Array();
		while(tempQueue.length > 0){
			var obj:Object = Function(tempQueue.shift());
			obj.func.apply(obj.obj);
		}
		draw();
		delete __invalidateClip.onEnterFrame;
	}
	
	
	private function doLater(obj:Object, func:Function):Void {
		if(__doLaterQueue == undefined){
			__doLaterQueue = new Array();
		}
		var numFuncs:Number = __doLaterQueue.length;
		var alreadyQueued:Boolean = false;
		for(var i=0;i<numFuncs;i++){
			if(__doLaterQueue[i].func == func && __doLaterQueue[i].obj == obj){
				alreadyQueued = true;
			}
		}
		if(!alreadyQueued){
			__doLaterQueue.push({obj:obj, func:func});
		}
		invalidate();
	}
	
	
	private function initFromClipParameters(Void):Void {
		var found:Boolean = false;

		for (var prop in clipParameters){
			if (this.hasOwnProperty(prop)){
				found = true;
				this["def_" + prop] = this[prop];
				delete this[prop];
			}
		}
		if (found){
			for(prop in clipParameters){
				var val = this["def_" + prop];
				if (val != undefined){
					this[prop] = val;
				}
			}
		}
	}
	
	
	private function hideFocus(Void):Void {
		__focusTimer = 0;
		clearInterval(__focusInterval);
		__focus._visible = false;
	}
	
	private function showFocus(Void):Void {
		if(_global.bitFocusTime != undefined) __focusLimit = _global.bitFocusTime;
		if(__focusTime != undefined) __focusLimit = __focusTime;
		__focusTimer = 0;
		if(__focusLimit >= 100 && tabIndex != undefined){
			clearInterval(__focusInterval);
			__focus._visible = true;
			__focusInterval = setInterval(this, "checkFocus", 100);
		}
	}
	
	private function checkFocus(Void):Void {
		__focusTimer += 100;
		if(__focusTimer > __focusLimit){
			hideFocus();
		}
	}
	

	/**
		Marks the component to be redrawn on the next frame.
	
		@return nothing
		@example
		<pre>
		myComponent.invalidate();
		</pre>
	*/
	public function invalidate(Void):Void {
		if(__invalidateClip == undefined){
			createEmptyMovieClip("__invalidateClip", -1);
		}
		__invalidateClip.onEnterFrame = Delegate.create(this, doInvalidation);
	}
	
	
	private static function mergeClipParameters(subParams:Object, superParams:Object):Boolean {
		for (var param in superParams){
			subParams[param] = superParams[param];
		}
		return true;
	}
	
	
	/**
		Removes component from stage. Handles any depth issues first that would prevent the component from being removed and then calls removeMovieClip.
		
		@return nothing
		@example
		<pre>
		myComponent.remove();
		</pre>
	*/
	public function remove(Void):Void {
		if(this.getDepth() > 1048575){
			this.swapDepths(1048575);
		}
		if(this.getDepth() < 0){
			this.swapDepths(0);
		}
		this.removeMovieClip();
	}
	
	
	/**
		Sizes the component to the measurements specified.
	
		@param w the new width of the component.
		@param h the new height of the component.
		@return nothing
		@example
		<pre>
		myComponent.setSize(100, 100);
		</pre>
	*/
	public function setSize(w:Number, h:Number):Void {
		if(w != undefined){
			__width = w;
		}
		if(h != undefined){
			__height = h;
		}
		_xscale = 100;
		_yscale = 100;
		size();
	}
	
	
	
	/**
		Sets the alpha value of the disabled component.
	
		@example
		<pre>
		myComponent.disabledAlpha = 50;
		</pre>
	*/
	public function set disabledAlpha(a:Number) {
		__alphaDisabled = a;
		invalidate();
	}
	/**
		Retrieves the alpha value of the disabled component.
	
		@example
		<pre>
		myVar = myComponent.disabledAlpha;
		</pre>
	*/
	public function get disabledAlpha():Number {
		return __alphaDisabled;
	}


	
	/**
		If true, component will function normally; if false, component will appear grayed out and will not respond to user input.
	
		@example
		<pre>
		myComponent.enabled = false;
		</pre>
	*/
	public function set enabled(b:Boolean) {
		__enabled = b;
		invalidate();
	}
	/**
		Receives component availability.
	
		@example
		<pre>
		myVar = myComponent.enabled;
		</pre>
	*/
	public function get enabled():Boolean {
		return __enabled;
	}
	
	/**
		Sets the time (in milliseconds) the focus of the component remains visible. The variable _global.bitFocusTime applies to all bit components. If focusTime is set, it will override the global variable.
	
		@example
		<pre>
		myComponent.focusTime = 500;
		// or
		_global.bitFocusTime = 1000;
		</pre>
	*/
	public function set focusTime(t:Number) {
		__focusTime = t;
	}
	/**
		Gets the time (in milliseconds) the focus of the component remains visible. 
		
		@example
		<pre>
		myVar = myComponent.focusTime;
		</pre>
	*/
	public function get focusTime():Number {
		return __focusTime;
	}
	
	
	/**
		Sets the height of the component.
	
		@example
		<pre>
		myComponent.height = 100;
		</pre>
	*/
	public function set height(h:Number) {
		setSize(__width, h);
	}
	/**
		Retrieves the height of the component.
	
		@example
		<pre>
		myVar = myComponent.height;
		</pre>
	*/
	public function get height():Number {
		return __height;
	}
	
	/**
		Sets the keyEnabled mode of the component. If set to true, the component will accept key events.
	
		@example
		<pre>
		myComponent.keyEnabled = false;
		</pre>
	*/
	public function set keyEnabled(b:Boolean) {
		__keyEnabled = b;
		invalidate();
	}
	/**
		Gets the keyEnabled mode of the component.
	
		@example
		<pre>
		myVar = myComponent.keyEnabled;
		</pre>
	*/
	public function get keyEnabled():Boolean {
		return __keyEnabled;
	}
	

	/**
		Used to pass a set of styles to the component. Any properties of the object passed to the style member will be applied to the component.
		
		@example
		<pre>
		myStyle = {fontSize:20, fontColor:0xff0000};
		myButton.style = myStyle;
		</pre>
	*/
	public function set style(s:Object) {
		for(var prop in s){
			if(this[prop] != undefined && this[prop] != null){
				this[prop] = s[prop];
			}
		}
	}


	/**
		Sets the width of the component.
	
		@example
		<pre>
		myComponent.width = 100;
		</pre>
	*/
	public function set width(w:Number) {
		setSize(w, __height);
	}
	/**
		Retrieves the width of the component.
	
		@example
		<pre>
		myVar = myComponent.width;
		</pre>
	*/
	public function get width():Number {
		return __width;
	}
}