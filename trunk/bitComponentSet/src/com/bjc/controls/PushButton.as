import com.bjc.controls.Label;
import com.bjc.core.LabelWrapper;
import com.bjc.resizers.Resizer;
import mx.events.EventDispatcher;
import mx.utils.Delegate;
import com.bjc.controls.*;


[IconFile("icons/Button.png")]

[Event("click")]

[Event("focus")]

[Event("killFocus")]

[Event("tabFocus")]

[Event("rollOver")]

[Event("rollOut")]

[Event("releaseOutside")]

/**
* A basic button component.
* <BR><BR>
* Events:
* <BR><BR>
* <B>click</B> - Fired whenever the user presses and releases the mouse on the button.
* <BR>
* <B>releaseOutside</B> - Fired whenever the user presses and releases the mouse outside the button.
* <BR>
* <B>rollOver</B> - Fired whenever the mouse moves over the button.
* <BR>
* <B>rollOut</B> - Fired whenever the mouse leaves the button.
* <BR>
* <B>focus</B> - Fired whenever the component receives focus.
* <BR>
* <B>killFocus</B> - Fired whenever the component loses focus.
* <BR>
* <B>tabFocus</B> - Fired whenever the component receives focus by pressing the TAB key.
* @author Beam Jive Consulting - www.beamjive.com
*/
class com.bjc.controls.PushButton extends LabelWrapper {
 	private var clipParameters:Object = {align:1, selected:1, label:1, toggle:1};
	private static var mergedClipParameters:Boolean = com.bjc.core.BJCComponent.mergeClipParameters(PushButton.prototype.clipParameters, LabelWrapper.prototype.clipParameters);
	
	
	private var __align:String = "center";
	private var __up:Resizer;
	private var __over:Resizer;
	private var __down:Resizer;
	private var __keyListener:Object;
	private var __label:Label;
	private var __labelText:String = "";
	private var __margin:Number = 8;
	private var __selected:Boolean = false;
	private var __shadow:Resizer;
	private var __toggle:Boolean = false;
	

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
	* @usage <pre>myButton.clickHandler = function(){
	* 	trace("I was clicked.");
	* }</pre>
	*/
	public var clickHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myButton.focusHandler = function(){
	* 	trace("Set focus.");
	* }</pre>
	*/
	public var focusHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myButton.killFocusHandler = function(){
	* 	trace("Kill focus.");
	* }</pre>
	*/
	public var killFocusHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myButton.tabFocusHandler = function(){
	* 	trace("Tab focus.");
	* }</pre>
	*/
	public var tabFocusHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myButton.releaseOutsideHandler = function(){
	* 	trace("Release outside.");
	* }</pre>
	*/
	public var releaseOutsideHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myButton.rollOverHandler = function(){
	* 	trace("Roll over.");
	* }</pre>
	*/
	public var rollOverHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myButton.rollOutHandler = function(){
	* 	trace("Roll out.");
	* }</pre>
	*/
	public var rollOutHandler:Function;
	private var dispatchEvent:Function;
	private var dispatchQueue:Function;
	
	public function PushButton(Void) {
	}
	
	
	private function init(Void):Void {
		super.init();
		EventDispatcher.initialize(this);
		
		__up.skin = "buttonUpSkin";
		__up.margin = __margin;
		
		__over.skin = "buttonOverSkin";
		__over.margin = __margin;
		__over._visible = false;
		
		__down.skin = "buttonDownSkin";
		__down.margin = __margin;
		__down._visible = false;
		
		__label.align = __align;
		__label.fontColor = 0x666666;
		
		__shadow.skin = "buttonShadow";
		__shadow.margin = __margin;
		
		draw();
	}
	
	
	private function createChildren(Void):Void {
 		attachMovie("Resizer", "__shadow", 0);
		attachMovie("Resizer", "__up", 1);
		attachMovie("Resizer", "__over", 2);
		attachMovie("Resizer", "__down", 3);
		attachMovie("Label", "__label", 4);
		attachMovie("Resizer", "__focus", 5);
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
		__label.enabled = __enabled;
		if(!__toggle){
			__selected = false;
		}
		if(__selected){
			__up._visible = false;
			__over._visible = false;
			__down._visible = true;
		} else {
			__up._visible = true;
			__over._visible = false;
			__down._visible = false;
		}
		__label.text = __labelText;
		__label.align = __align;
		__label.disabledColor = __disabledColor;
		__label.embedFont = __embedFont;
		__label.fontColor = __fontColor;
		__label.fontFace = __fontFace;
		__label.fontSize = __fontSize;
		__label.html = __html;
		
		size();
	}
	
	
	private function size(Void):Void {
		__focus.setSize(__width, __height);
		__up.setSize(__width, __height);
		__over.setSize(__width, __height);
		__down.setSize(__width, __height);
		__label.move(3, 0);
		__label.setSize(__width - 6, __height)
 		__shadow.setSize(__width, __height);
 		__shadow._y = 4;
	}
	
	
	/**
		Static method used to create an instance of a PushButton on stage at run time.
				
		@param target the movie clip to which the button will be attached.
		@param id the instance name given to the new button attached.
		@param depth the depth at which to attach the new button.
		@param initObj (optional) an object containing any properties you want to assign to the component when it is created
		@return a reference to the new button attached.
		@example
		<pre>
		import com.bjc.controls.PushButton;
		var newButton:PushButton = PushButton.create(_root, "myButton", 0);
		</pre>
	*/
	public static function create(target:MovieClip, id:String, depth:Number, initObj:Object):PushButton {
		return PushButton(target.attachMovie("PushButton", id, depth, initObj));
	}
	
	private function onKeyPressed(Void):Void {
		if((Selection.getFocus() == "" + this) && __enabled && __keyEnabled){
			if(Key.getCode() == Key.ENTER || Key.getCode() == Key.SPACE){
				onPress();
			}
		}
	}

	private function onKeyReleased(Void):Void {
		if((Selection.getFocus() == "" + this) && __enabled && __keyEnabled){
			if(Key.getCode() == Key.ENTER || Key.getCode() == Key.SPACE){
				onRelease();
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
			__keyListener.onKeyUp = Delegate.create(this, onKeyReleased);
			Key.addListener(__keyListener);
		}
		dispatchEvent({type:"focus", target:this, oldfocus:oldFocus});
		if(Key.isDown(9)){
			showFocus();
			dispatchEvent({type:"tabFocus", target:this, oldfocus:oldFocus});
		}
	}
	
	
	private function onPress(Void):Void {
		if(__enabled){
			__up._visible = false;
			__over._visible = false;
			__down._visible = true;
		}
	}
	
	
	private function onRelease(Void):Void {
		if(__enabled){
			if(__toggle){
				__selected = !__selected;
			}
			if(!__selected ){
				if(_xmouse > 0 && _xmouse < __width && _ymouse > 0 && _ymouse < __height){
					__up._visible = false;
					__over._visible = true;
					__down._visible = false;
				} else {
					__up._visible = true;
					__over._visible = false;
					__down._visible = false;
				}
			}
			dispatchEvent({type:"click", target:this});
			if(Selection.getFocus() != "" + this) Selection.setFocus(this);
		}
	}
	
	
	private function onReleaseOutside(Void):Void {
		if(__enabled){
			if(!__selected){
				__up._visible = true;
				__over._visible = false;
				__down._visible = false;
			}
			dispatchEvent({type:"releaseOutside", target:this});
		}
	}
	
	
	private function onRollOut(Void):Void {
		if(__enabled){
			if(!__selected){
				__up._visible = true;
				__over._visible = false;
				__down._visible = false;
			}
			dispatchEvent({type:"rollOut", target:this});
		}
	}
	
	
	private function onRollOver(Void):Void {
		if(__enabled){
			if(!__selected){
				__up._visible = false;
				__over._visible = true;
				__down._visible = false;
			}
			dispatchEvent({type:"rollOver", target:this});
		}
	}


	/**
		Sets the horizontal alignment of the text in the component. Valid values are "left", "right" and "center".
		@example
		<pre>
		myButton.align = "center";
		</pre>
	*/
	[Inspectable (defaultValue="center", enumeration="left,right,center", category="textstyles", verbose=1)]
	public function set align(a:String) {
		// overwrite to make it default to center
		__align = a;
		invalidate();
	}
	/**
		Gets the horizontal alignment of the text in the component. 
		@example
		<pre>
		myVar = myButton.align;
		</pre>
	*/
	public function get align():String {
		return __align;
	}


	/**
		Sets the margin for the internal Resizer component
	
		@example
		<pre>
		myButton.margin = 5;
		</pre>
	*/
	public function set margin(m:Number) {
		__margin = m
		__up.margin = __margin;
		__over.margin = __margin;
		__down.margin = __margin;
		invalidate();
	}
	/**
		Gets the margin for the internal Resizer component
	
		@example
		<pre>
		myVar = myButton.margin;
		</pre>
	*/
	public function get margin():Number {
		return __margin;
	}
	
	
	/**
		Sets to set the button's state. Can be used to set the button's state to down, if toggle is set to true.
	
		@see com.bjc.controls.PushButton#toggle
		@example
		<pre>
		myButton.toggle = true;
		myButton.selected = true;
		</pre>
	*/
	[Inspectable (type="Boolean", defaultValue=false)]
	public function set selected(b:Boolean) {
		__selected = b;
		invalidate();
	}
	[Bindable]
	[ChangeEvent ("click")]
	/**
		Gets the button's state.
	
		@example
		<pre>
		myVar = myButton.selected;
		</pre>
	*/
	public function get selected():Boolean {
		return __selected;
	}
	
	
	/**
		Sets the text to be shown on the button.
	
		@example
		<pre>
		myButton.label = "Press me";
		</pre>
	*/
	[Inspectable (defaultValue="Button")]
	public function set label(txt:String) {
		__labelText = txt;
		invalidate();
	}
	/**
		Gets the text to be shown on the button.
	
		@example
		<pre>
		myVar = myButton.label;
		</pre>
	*/
	public function get label():String {
		return __labelText;
	}
	
	
	/**
		Determines if button is a simple pushbutton, or a button that can be toggled on and off. If toggle is set to true, the buttons up or down state can be set or retrieved with the PushButton.selected property.
	
		@see com.bjc.controls.PushButton#selected
		@example
		<pre>
		myButton.toggle = true;
		myButton.selected = true;
		</pre>
	*/
	[Inspectable (type="Boolean", defaultValue=false)]
	public function set toggle(b:Boolean) {
		__toggle = b;
		if(!__toggle){
			__selected = false;
		}
		invalidate();
	}
	/**
		Gets the toggle mode of the component.
	
		@example
		<pre>
		myVar = myButton.toggle;
		</pre>
	*/
	public function get toggle():Boolean {
		return __toggle;
	}
	
	
}
