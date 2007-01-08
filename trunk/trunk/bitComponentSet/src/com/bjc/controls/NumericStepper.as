import com.bjc.controls.IconButton;
import com.bjc.core.LabelWrapper;
import com.bjc.resizers.Resizer;
import mx.utils.Delegate;
import mx.events.EventDispatcher;


[IconFile ("icons/NumericStepper.png")]

[Event("change")]

[Event("focus")]

[Event("killFocus")]

[Event("tabFocus")]

/**
* A basic numeric stepper for displaying and choosing numeric values
* <BR><BR>
* Events:
* <BR><BR>
* <B>change</B> - Fired whenever the user changes the value by clicking on the buttons or by typing in the textfield.
* <BR>
* <B>focus</B> - Fired whenever the internal text field or component receives focus.
* <BR>
* <B>killFocus</B> - Fired whenever the internal text field or component loses focus.
* <BR>
* <B>tabFocus</B> - Fired whenever the component receives focus by pressing the TAB key.
* @author Beam Jive Consulting - www.beamjive.com
*/
class com.bjc.controls.NumericStepper extends LabelWrapper {
 	private var clipParameters:Object = {decimals:1, maximum:1, minimum:1, stepSize:1, value:1};
	private static var mergedClipParameters:Boolean = com.bjc.core.BJCComponent.mergeClipParameters(NumericStepper.prototype.clipParameters, LabelWrapper.prototype.clipParameters);
	
	private var __background:Resizer;
	private var __btnDown:IconButton;
	private var __btnUp:IconButton;
	private var __format:TextFormat;
	private var __decimals:Number = 0;
	private var __keyListener:Object;
	private var __maximum:Number = 10;
	private var __minimum:Number = 0;
	private var __pressInterval:Number;
	private var __speed:Number = 100;
	private var __stepSize:Number = 1;
	private var __tf:TextField;
	private var __value:Number = 0;
	private var __onButton:Boolean = false;
	private var __onTF:Boolean = false;
	
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
	* @usage <pre>myNumericStepper.changeHandler = function(){
	* 	trace("I was changed.");
	* }</pre>
	*/
	public var changeHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myNumericStepper.focusHandler = function(){
	* 	trace("Set focus.");
	* }</pre>
	*/
	public var focusHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myNumericStepper.killFocusHandler = function(){
	* 	trace("Kill focus.");
	* }</pre>
	*/
	public var killFocusHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myNumericStepper.tabFocusHandler = function(){
	* 	trace("Tab focus.");
	* }</pre>
	*/
	public var tabFocusHandler:Function;
	
	
	public function NumericStepper(Void) {
	}


	private function init(Void):Void {
		super.init();
		EventDispatcher.initialize(this);
		Mouse.addListener(this);
		focusEnabled = true;
		
		__btnUp.clickHandler = Delegate.create(this, clickUp);
		__btnDown.clickHandler = Delegate.create(this, clickDown);
		__btnUp.killFocusHandler = Delegate.create(this, onClickKillFocus);
		__btnDown.killFocusHandler = Delegate.create(this, onClickKillFocus);
		
		__btnUp.rollOverHandler = Delegate.create(this, onRollOverFocus);
		__btnUp.rollOutHandler = Delegate.create(this, onRollOutFocus);
		__btnUp.releaseOutsideHandler = Delegate.create(this, onRollOutFocus);
		__btnDown.rollOverHandler = Delegate.create(this, onRollOverFocus);
		__btnDown.rollOutHandler = Delegate.create(this, onRollOutFocus);
		__btnDown.releaseOutsideHandler = Delegate.create(this, onRollOutFocus);
		
		__btnUp.disabledAlpha = 100;
		__btnDown.disabledAlpha = 100;
		
		__tf.type = "input";
		__tf.onSetFocus = Delegate.create(this, onTFFocus);
		__tf.onKillFocus = Delegate.create(this, onTFKillFocus);

		if(__maximum == undefined) __maximum = 10;
		
		if(__maximum <= __minimum){
			__maximum = __minimum;
			__value = __minimum;
		}
		
		draw();
	}


	private function createChildren(Void):Void {
		attachMovie("Resizer", "__background", 0);
		__background.skin = "numericStepperSkin";
		__background.margin = 2;
		
		attachMovie("IconButton", "__btnUp", 1);
		__btnUp.downIcon = "numericStepperUpDownSkin";
		__btnUp.overIcon = "numericStepperUpOverSkin";
		__btnUp.upIcon = "numericStepperUpUpSkin";
		
		attachMovie("IconButton", "__btnDown", 2);
		__btnDown.downIcon = "numericStepperDownDownSkin";
		__btnDown.overIcon = "numericStepperDownOverSkin";
		__btnDown.upIcon = "numericStepperDownUpSkin";
		
		createTextField("__tf", 3, 2, 1, 98, 20);
		
		attachMovie("Resizer", "__focus", 4);
		__focus.skin = "focusSkin";
		__focus.margin = 5;
		__focus._visible = false;
	}


	/**
		@exclude
		this is documented in BJCComponent, not changed here.
	*/
	public function draw(Void):Void {
		__btnUp.enabled = __enabled;
		__btnDown.enabled = __enabled;
		
		__format = new TextFormat(__fontFace, __fontSize, __fontColor);
		__format.align = __align;
		if(!__enabled){
			_alpha = __alphaDisabled;
			__format.color = __disabledColor;
			__tf.type = "dynamic";
			__tf.selectable = false;
		} else {
			_alpha = 100;
			__tf.type = "input";
			__tf.selectable = true;
		}
		if(!_global.isLivePreview){
			__tf.embedFont = __embedFont;
		}
		__tf.restrict = "0-9.\\-";
		__tf.html = false;
		if(!__disableStyles){
			__tf.setTextFormat(__format);
			__tf.setNewTextFormat(__format);
		}
		__tf.text = setDecimals(__value);
		
		size();
	}


	private function size(Void):Void {
		__focus.setSize(__width, __height);
		__background.setSize(__width, __height);
		
		__btnDown._x = __width - __btnDown.width - 1;
		__btnDown._y = Math.round(__height - __btnDown.height);
		
		__btnUp._x = __width - __btnUp.width - 1;
		
		__tf._width = __width - __btnUp.width - 2;
		__tf._height = __tf.textHeight + 4;
		__tf._y = Math.round(__height / 2 - __tf._height / 2);
	}
	
	
	/**
		Static method used to create an instance of a NumericStepper on stage at run time.
				
		@param target the movie clip to which the NumericStepper will be attached.
		@param id the instance name given to the new NumericStepper attached.
		@param depth the depth at which to attach the new NumericStepper.
		@param initObj (optional) an object containing any properties you want to assign to the component when it is created
		@return a reference to the new NumericStepper attached.
		@example
		<pre>
		import com.bjc.controls.NumericStepper;
		var newNumericStepper:NumericStepper = NumericStepper.create(_root, "myNumericStepper", 0);
		</pre>
	*/
	public static function create(target:MovieClip, id:String, depth:Number, initObj:Object):NumericStepper {
		return NumericStepper(target.attachMovie("NumericStepper", id, depth, initObj));
	}
	
	private function setDecimals(val:Number):String {
		if(__decimals > 0){
			var s:String = val.toString();
			var a:Array = s.split( "." );
		
			s = a[1];
			if(s != undefined){
				for(var i=s.length; i<__decimals; i++){
					s += "0";
				}
			} else {
				s = "";
				for(var i=0; i<__decimals; i++){
					s += "0";
				}
			}
			return a[0] + "." + s;
		} else {
			return val.toString();
		}
	}

	
	
	private function clickDown(Void):Void {
		clearInterval(__pressInterval);
		__value -= __stepSize;
		__value = Math.max(__value, __minimum);
		__value = validateValue(__value);
		__tf.text = setDecimals(__value);
		
		if(Selection.getFocus() != "" + this) Selection.setFocus(this);
		dispatchEvent({type:"change", target:this});
	}
	
	private function clickUp(Void):Void {
		clearInterval(__pressInterval);
		__value += __stepSize;
		__value = Math.min(__value, __maximum);
		__value = validateValue(__value);
		__tf.text = setDecimals(__value);

		if(Selection.getFocus() != "" + this) Selection.setFocus(this);
		dispatchEvent({type:"change", target:this});
	}
	
	
	
	private function onMouseDown(Void):Void {
		if(__enabled && (_xmouse > __btnUp._x) && (_xmouse < __btnUp._x + __btnUp.width) && (_ymouse > __btnUp._y) && (_ymouse < __btnUp._y + __btnUp.height)){
			clearInterval(__pressInterval);
			__pressInterval = setInterval(this, "valUp", __speed);
		} else if(__enabled && (_xmouse > __btnDown._x) && (_xmouse < __btnDown._x + __btnDown.width) && (_ymouse > __btnDown._y) && (_ymouse < __btnDown._y + __btnDown.height)){
			clearInterval(__pressInterval);
			__pressInterval = setInterval(this, "valDown", __speed);
		}
	}
	
	
	private function onMouseUp(Void):Void {
		clearInterval(__pressInterval);
	}
	
	private function onMouseWheel(delta:Number):Void {
		if(((Selection.getFocus() == "" + this) || (Selection.getFocus() eq "" + __tf) || (Selection.getFocus() eq "" + __btnUp) || (Selection.getFocus() eq "" + __btnDown)) && __enabled && (_xmouse > 0) && (_xmouse < __width) && (_ymouse > 0) && (_ymouse < __height)){
			if(delta > 0){
				valUp();
			} else {
				valDown();
			}
		}
	}
	
	private function onClickKillFocus(obj:Object):Void {
		onKillFocus(obj.newfocus);
	}
	
	private function onRollOverFocus(obj:Object):Void {
		__onButton = true;
	}
	
	private function onRollOutFocus(obj:Object):Void {
		__onButton = false;
	}
	
	private function onTFKillFocus(newFocus:Object):Void {
		update();
		if((newFocus != this && newFocus != __btnUp && newFocus != __btnDown && !__onButton) || Key.isDown(9)){
			__onTF = false;
			Key.removeListener(__keyListener);
			__keyListener = null;
			hideFocus();
			dispatchEvent({type:"killFocus", target:this, newfocus:newFocus});
		}
	}
	
	private function onKillFocus(newFocus:Object):Void {
		if(newFocus != __tf && newFocus != __btnUp && newFocus != __btnDown && newFocus != this){
			__onTF = false;
			Key.removeListener(__keyListener);
			__keyListener = null;
			hideFocus();
			dispatchEvent({type:"killFocus", target:this, newfocus:newFocus});
		}
	}
	
	
	private function onKeyPressed(Void):Void {
		if(((Selection.getFocus() == "" + this) || (Selection.getFocus() eq "" + __tf) || (Selection.getFocus() eq "" + __btnUp) || (Selection.getFocus() eq "" + __btnDown)) && __enabled && __keyEnabled){
			if(Key.getCode() == Key.ENTER){
				update();
			} else if(Key.getCode() == Key.UP){
				valUp();
			} else if(Key.getCode() == Key.DOWN){
				valDown();
			}
		}
	}
	
	private function onTFFocus(oldFocus:Object):Void {
		__onTF = true;
		if(oldFocus != this && oldFocus != __btnUp && oldFocus != __btnDown){
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
	}
	
	private function onSetFocus(oldFocus:Object):Void {
		if(oldFocus != __tf && oldFocus != __btnUp && oldFocus != __btnDown && !__onTF){
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
	}
	
	
	private function update(){
		if(__tf.text != "" && !isNaN(Number(__tf.text))){
			value = Number(__tf.text);
			invalidate();
			dispatchEvent({type:"change", target:this});
		} else {
			__tf.text = setDecimals(__value);
		}
	}
	
	
	private function valDown(Void):Void {
		__value -= __stepSize;
		__value = validateValue(__value);
		__value = Math.max(__value, __minimum);
		__tf.text = setDecimals(__value);
		dispatchEvent({type:"change", target:this});
	}
		
	private function valUp(Void):Void {
		__value += __stepSize;
		__value = validateValue(__value);
		__value = Math.min(__value, __maximum);
		__tf.text = setDecimals(__value);
		dispatchEvent({type:"change", target:this});
	}
	
	
	private function validateValue(val:Number):Number {
		var initDiv:Number = val / __stepSize;
		var roundDiv:Number = Math.floor(initDiv);

		if(val > __minimum && val < __maximum){	 
			if(initDiv - roundDiv == 0){
				return val;
			} else {
				var tmpVal:Number = Math.floor(val / __stepSize);
				var stepVal:Number = tmpVal * __stepSize;
				if((val - stepVal >= __stepSize / 2 && __maximum >= stepVal + __stepSize && __minimum <= stepVal - __stepSize) || (val + __stepSize == __maximum && __maximum - stepVal - __stepSize > 0.00000000000001)){
					stepVal += __stepSize;
				}
				return stepVal;
			}
		} else {
			if(val >= __maximum){
				return __maximum;
			} else {
				return __minimum;
			}
		}
	}

	
	/**
		Sets the minimum amount of decimals used to display the value. If set to 0, the this property is disabled, and the decimals will appear as needed.
				
		@example
		<pre>
		myNumericStepper.decimals = 3;
		</pre>
	*/
	[Inspectable (defaultValue=0)]
	public function set decimals(s:Number) {
		__decimals = s;
		invalidate();
	}
	/**
		Gets the amount of decimals used to display the value.
				
		@example
		<pre>
		myVar = myNumericStepper.decimals;
		</pre>
	*/
	public function get decimals():Number {
		return __decimals;
	}
	
	
	/**
		Sets the maximum possible value on the component. 
				
		@example
		<pre>
		myNumericStepper.maximum = 100;
		</pre>
	*/
	[Inspectable (defaultValue=10)]
	public function set maximum(max:Number) {
		__maximum = max;
		invalidate();
	}
	/**
		Gets the maximum possible value on the component.
				
		@example
		<pre>
		myVar = myNumericStepper.maximum;
		</pre>
	*/
	public function get maximum():Number {
		return __maximum;
	}
	
	/**
		Sets the minimum possible value on the component. 
				
		@example
		<pre>
		myNumericStepper.minimum = 0;
		</pre>
	*/
	[Inspectable (defaultValue=0)]
	public function set minimum(min:Number) {
		__minimum = min;
		invalidate();
	}
	/**
		Gets the minimum possible value on the component.
				
		@example
		<pre>
		myVar = myNumericStepper.minimum;
		</pre>
	*/
	public function get minimum():Number {
		return __minimum;
	}
	
	/**
		Sets the value interval (ms) when user holds down a button.
				
		@example
		<pre>
		myNumericStepper.speed = 200;
		</pre>
	*/
	public function set speed(s:Number) {
		__speed = s;
	}
	/**
		Gets the value interval (ms).
				
		@example
		<pre>
		myVar = myNumericStepper.speed;
		</pre>
	*/
	public function get speed():Number {
		return __speed;
	}
	
	/**
		Sets the step size of the component.
				
		@example
		<pre>
		myNumericStepper.stepSize = 10;
		</pre>
	*/
	[Inspectable (defaultValue=1)]
	public function set stepSize(s:Number) {
		__stepSize = s;
		invalidate();
	}
	/**
		Gets the step size of the component.
				
		@example
		<pre>
		myVar = myNumericStepper.stepSize;
		</pre>
	*/
	public function get stepSize():Number {
		return __stepSize;
	}
	
	/**
		Sets the value of the numeric stepper.
				
		@example
		<pre>
		myNumericStepper.value = 50;
		</pre>
	*/
	[Inspectable (defaultValue=0)]
	public function set value(val:Number) {
		__value = validateValue(val);
		__value = Math.max(__value, __minimum);
		__value = Math.min(__value, __maximum);
		__tf.text = setDecimals(__value);
		invalidate();
	}
	[Bindable]
	[ChangeEvent ("change")]
	/**
		Gets the value of the numeric stepper.
				
		@example
		<pre>
		myVar = myNumericStepper.value;
		</pre>
	*/
	public function get value():Number {
		return __value;
	}
	
	/**
		@exclude
	*/
	public function set tabIndex(index:Number)
	{
		__tf.tabIndex = index;
	}
	/**
		@exclude
	*/
	public function get tabIndex():Number
	{
		return __tf.tabIndex;
	}
}