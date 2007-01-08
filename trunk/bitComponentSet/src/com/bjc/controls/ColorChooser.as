import mx.events.EventDispatcher;
import com.bjc.resizers.Resizer;
import mx.utils.Delegate;

[IconFile ("icons/ColorChooser.png")]

[Event("change")]

[Event("focus")]

[Event("killFocus")]

[Event("tabFocus")]

/**
* A component for selecting colors 
* <BR><BR>
* Events:
* <BR><BR>
* <B>change</B> - Fired whenever the active color is changed by the user, either by clicking on a color square or pressing enter after changing the value in the text box.
* <BR>
* <B>focus</B> - Fired whenever the component receives focus.
* <BR>
* <B>killFocus</B> - Fired whenever the component loses focus.
* <BR>
* <B>tabFocus</B> - Fired whenever the component receives focus by pressing the TAB key.
* @author Beam Jive Consulting - www.beamjive.com
*/
class com.bjc.controls.ColorChooser extends com.bjc.core.BJCComponent {
 	private var clipParameters:Object = {value:1};

	
	private var __buttonCol:Color;
	private var __depth:Number = 0;
	private var __display:TextField;
	private var __position:String = "bottomRight";
	private var __button:MovieClip;
	private var __keyListener:Object;
	private var __oldDepth:Number;
	private var __sample:MovieClip;
	private var __sampleCol:Color;
	private var __value:Number = 0xff0000;
	private var __window:MovieClip;
	
	/**
	* Can be used to choose whetever the event handler will be called when the value has been set by code. This variable is set to true by default.
	* @usage <pre>myColorChooser.eventOnValue = false;
	* myColorChooser.value = 0xFF0000;</pre>
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
	private var dispatchEvent:Function;
	private var dispatchQueue:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myColorChooser.changeHandler = function(){
	* 	trace("I was changed.");
	* }</pre>
	*/
	public var changeHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myColorChooser.focusHandler = function(){
	* 	trace("Set focus.");
	* }</pre>
	*/
	public var focusHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myColorChooser.killFocusHandler = function(){
	* 	trace("Kill focus.");
	* }</pre>
	*/
	public var killFocusHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myColorChooser.tabFocusHandler = function(){
	* 	trace("Tab focus.");
	* }</pre>
	*/
	public var tabFocusHandler:Function;

	public function ColorChooser(Void) {
	}
	
	
	private function init(Void):Void {
		super.init();
		EventDispatcher.initialize(this);
		__buttonCol = new Color(__button.block);
		__button.onRelease = Delegate.create(this, openWindow);
		draw();
	}
	
	
	private function createChildren(Void):Void {
		attachMovie("colorChooserButton", "__button", 0);
		attachMovie("Resizer", "__focus", 1);
		__focus.skin = "focusSkin";
		__focus.margin = 5;
		__focus._visible = false;
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
		__buttonCol.setRGB(__value);
		size();
	}
	
	
	private function size(Void):Void {
		__focus.setSize(__width, __height);
	}
	
	
	/**
		Static method used to create an instance of a ColorChooser on stage at run time.
				
		@param target the movie clip to which the color chooser will be attached.
		@param id the instance name given to the new color chooser attached.
		@param depth the depth at which to attach the new color chooser.
		@param initObj (optional) an object containing any properties you want to assign to the component when it is created
		@return a reference to the new color chooser attached.
		@example
		<pre>
		import com.bjc.controls.ColorChooser;
		var newColorChooser:ColorChooser = ColorChooser.create(_root, "myColorChooser", 0);
		</pre>
	*/
	public static function create(target:MovieClip, id:String, depth:Number, initObj:Object):ColorChooser {
		return ColorChooser(target.attachMovie("ColorChooser", id, depth, initObj));
	}
		
	

	
	
	
	
	private function closeWindow(){
		__window.removeMovieClip();
		this.swapDepths(__oldDepth);
		dispatchEvent({type:"change", target:this});
		invalidate();
	}
	
	
	private function makeColorSwatches(Void):Void {
		var ypos:Number = 20;
		var xpos:Number = 15;
		for(var r:Number = 0; r < 6; r++) {
			for(var b:Number = 0; b < 6; b++) {
				for(var g:Number = 0; g < 6; g++) {
 					var swatch:MovieClip = __window.attachMovie("colorSwatch", "swatch" + __depth, __depth++);
					swatch.col = r * 0x330000 + g * 0x3300 + b * 0x33;
					swatch.val = rgbToHex(swatch.col);
					var sCol:Color = new Color(swatch.block);
					sCol.setRGB(swatch.col);
					swatch._x = xpos + b * 10;
					swatch._y = ypos + g * 10;
					swatch.useHandCursor = false;
					var comp:ColorChooser = this;
					swatch.onRollOver = function() {
						comp.__display.text = this.val;
						comp.__sampleCol.setRGB(this.col);
					};
					swatch.onRelease = function(){
						comp.__value = this.col;
						comp.closeWindow();
					}
				}
			}
			if ((xpos += 60) > 149) {
				xpos = 15;
				ypos += 60;
			}
		}
	}
	
	
	private function makeGraySwatches(Void):Void {
		var ypos:Number = 20;
		
		for(var shade:Number = 0; shade < 6; shade++) {
			var swatch:MovieClip = __window.attachMovie("colorSwatch", "swatch"+ __depth, __depth++);
			var s:Number = shade * 0x33;
			swatch.col = s << 16 | s << 8 | s;
			swatch.val = rgbToHex(swatch.col);
			swatch._x = 2;
			swatch._y = ypos + shade * 10;
			swatch.useHandCursor = false;
			var sCol:Color = new Color(swatch.block);
			sCol.setRGB(swatch.col);
			var comp:ColorChooser = this;
			swatch.onRollOver = function() {
				comp.__display.text = this.val;
				comp.__sampleCol.setRGB(this.col);
			};
			swatch.onRelease = function(){
				comp.__value = this.col;
				comp.closeWindow();
			}
		}
	}
	
	
	private function makePrimarySwatches(Void):Void {
		var ypos:Number = 80;
		var red:Number = 255;
		var green:Number = 0;
		var blue:Number = 0;
		for (var count:Number = 0; count < 6; count++) {
			var swatch:MovieClip = __window.attachMovie("colorSwatch", "swatch" + __depth, __depth++);
			swatch.col = red << 16 | green << 8 | blue;;
			swatch.val = rgbToHex(swatch.col);
			swatch._x = 2;
			swatch._y = ypos + 10 * count;
			swatch.useHandCursor = false;
			var sCol:Color = new Color(swatch.block);
			sCol.setRGB(swatch.col);
			var comp:ColorChooser = this;
			swatch.onRollOver = function() {
				comp.__display.text = this.val;
				comp.__sampleCol.setRGB(this.col);
			};
			swatch.onRelease = function(){
				comp.__value = this.col;
				comp.closeWindow();
			}
			if ((red += 255) > 255) {
				red = 0;
				if ((green += 255) > 255) {
					green = 0;
					if ((blue += 255) > 255) {
						blue = 0;
					}
				}
			}
		}
	}
	
	
	private function onClick(Void):Void {
		if(__position.indexOf("Right") != -1){
			if(_xmouse < 0 || _xmouse > __window._width){
				closeWindow();
			}
		} else if(_xmouse < -__window._width || _xmouse > __button._width){
			closeWindow();
		}
		if(__position.indexOf("bottom") != -1){
			if(_ymouse < 0 || _ymouse > __window._height){
				closeWindow();
			}
		} else if(_ymouse < -__window._height || _ymouse > __button._height){
			closeWindow();
		}
	}
	
	
	private function onDisplayChange(){
		if(__display.text.charAt(0) != "#"){
			__display.maxChars = 6;
			if(__display.text.length == 6){
				__display.col = parseInt(__display.text, 16);
				__sampleCol.setRGB(__display.col);
			}
		} else {
			__display.maxChars = 7;
			if(__display.text.length == 7){
				__display.col = parseInt(__display.text.substring(1), 16);
				__sampleCol.setRGB(__display.col);
			}
		}
	}
	
	
	private function onDisplayFocus(){
		Key.addListener(__display);
		__display.onKeyDown = Delegate.create(this, onEnterPressed);
	}
	
	
	private function onDisplayKillFocus(){
		Key.removeListener(__display);
		delete __display.onKeyDown;
	}
	
	
	private function onEnterPressed(){
		if((Selection.getFocus() != "" + this) && Key.getCode() == Key.ENTER){
			if(__display.text.charAt(0) == "#" && __display.text.length == 7){
				onDisplayChange();
				__value = __display.col;
				closeWindow();
			} else if(__display.length == 6){
				onDisplayChange();
				__value = __display.col;
				closeWindow();
			}
		}
	}
	
	
	private function onEscape(){
		if(Key.getCode() == Key.ESCAPE){
			Key.removeListener(this);
			closeWindow();
		}
	}
	
	private function onKeyPressed(Void):Void {
		if((Selection.getFocus() == "" + this) && __enabled && __keyEnabled){
			if(Key.getCode() == Key.ENTER && __window == undefined){
				openWindow();
			}
		}
	}
	
	private function onKillFocus(newFocus:Object):Void {
		if(newFocus != __window && newFocus != __window.display){
			Key.removeListener(__keyListener);
			__keyListener = null;
			hideFocus();
			dispatchEvent({type:"killFocus", target:this, newfocus:newFocus});
		}
	}
	
	private function onSetFocus(oldFocus:Object):Void {
		if(__keyListener == null || __keyListener == undefined){
			__keyListener = new Object();
			__keyListener.onKeyDown = Delegate.create(this, onKeyPressed);
			Key.addListener(__keyListener);
		}
		if(oldFocus != __window.display){
			dispatchEvent({type:"focus", target:this, oldfocus:oldFocus});
			if(Key.isDown(9)){
				showFocus();
				dispatchEvent({type:"tabFocus", target:this, oldfocus:oldFocus});
			}
		}
	}
	
	
	private function openWindow(){
		if(__enabled){
			__oldDepth = this.getDepth();
			if(_parent.getNextHighestDepth() != undefined){ 
				this.swapDepths(_parent.getNextHighestDepth());
			} else {
				this.swapDepths(1048575);
			}
			attachMovie("colorChooserWindow", "__window", 2);
			__window.attachMovie("colorChooserSkin", "skin", 0);
			__window.skin.swapDepths(-16384);
			
			if(__position.indexOf("bottom") != -1){
				__window._y = 0;
			} else {
				__window._y = __button._width - __window._height;
			}
			if(__position.indexOf("Right") != -1){
				__window._x = 0;
			} else {
				__window._x = __button._height - __window._width;
			}
			
			Key.addListener(__window);
			__window.onKeyDown = Delegate.create(this, onEscape);
			__window.onMouseDown = Delegate.create(this, onClick);
			
			__display = __window.display;
			__display.restrict = "#0123456789abcdefABCDEF";
			__display.text = rgbToHex(__value);
			__display.col = __value;
			__display.onChanged = Delegate.create(this, onDisplayChange);
			__display.onSetFocus = Delegate.create(this, onDisplayFocus);
			__display.onKillFocus = Delegate.create(this, onDisplayKillFocus);
			
			__sample = __window.sample;
			__sampleCol = new Color(__sample);
			__sampleCol.setRGB(__value);
			__sample.onPress = Delegate.create(this, closeWindow);
			
			makeColorSwatches();
			makeGraySwatches();
			makePrimarySwatches();
			if(Selection.getFocus() != "" + this) Selection.setFocus(this);
		}
	}
	
	
	private function rgbToHex(rgb:Number):String {
		var str:String = rgb.toString(16).toUpperCase();
		var padding:Number = 6 - str.length;
		for(var i=0;i<padding;i++){
			str = "0" + str;
		}
		str = "#" + str;
		return str;
	}		
	
	
	
	
	
	
	/**
		Sets the position where the color chooser will open.
	
		@example
		<pre>
		myColorChooser.position = "topRight";
		</pre>
	*/
	[Inspectable (type="String", defaultValue="bottomRight", enumeration="topLeft,topRight,bottomLeft,bottomRight")]
	public function set position(pos:String) {
		__position = pos;
	}
	/**
		Gets the position where the color chooser will open.
	
		@example
		<pre>
		myVar = myColorChooser.position;
		</pre>
	*/
	public function get position():String {
		return __position;
	}
	
	
	/**
		Sets the color in the color chooser. This will fire the change event if the eventOnValue is set to true (changed in version 1.3).
	
		@example
		<pre>
		myColorChooser.value = 0xFF0000;
		</pre>
	*/
	[Inspectable (type="Color", defaultValue="#FF0000")]
	public function set value(v:Number) {
		__value = v;
		if(eventOnValue) dispatchEvent({type:"change", target:this});
		invalidate();
	}
	/**
		Retrieves the currently set color in the color chooser.
	
		@example
		<pre>
		myVar = myColorChooser.value;
		</pre>
	*/
	public function get value():Number {
		return __value;
	}
}