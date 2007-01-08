import com.bjc.resizers.Resizer;
import mx.events.EventDispatcher;
import mx.utils.Delegate;

[IconFile ("icons/IconButton.png")]

[Event("click")]

[Event("focus")]

[Event("killFocus")]

[Event("tabFocus")]

[Event("rollOver")]

[Event("rollOut")]

[Event("releaseOutside")]

/**
* A button component with icon
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
class com.bjc.controls.IconButton extends com.bjc.core.BJCComponent {
 	private var clipParameters:Object = {downIcon:1, upIcon:1, overIcon:1, selected:1, toggle:1};

	
	private var __down:MovieClip;
	private var __downIcon:String;
	private var __keyListener:Object;
	private var __over:MovieClip;
	private var __overIcon:String;
	private var __selected:Boolean = false;
	private var __toggle:Boolean = false;
	private var __up:MovieClip;
	private var __upIcon:String;
	
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
	
	public function IconButton(Void) {
	}
	
	
	private function init(Void):Void {
		super.init();
		if(_global.isLivePreview){
	 		attachMovie("iconButtonPreview", "__up", 0);
			attachMovie("iconButtonPreview", "__down", 1);
			attachMovie("iconButtonPreview", "__over", 2);
			
			__down._visible = false;
			__over._visible = false;
		}
		EventDispatcher.initialize(this);
		
		draw();
	}
	
	
	private function createChildren(Void):Void {
		attachMovie("Resizer", "__focus", 3);
		__focus.skin = "focusSkin";
		__focus.margin = 5;
		__focus._visible = false;
	}
	
	
	/**
		@exclude
	*/
	public function draw(Void):Void {
		attachMovie(__upIcon, "__up", 0);
		attachMovie(__overIcon, "__over", 1);
		attachMovie(__downIcon, "__down", 2);
		if(__enabled){
			_alpha = 100;
		} else {
			_alpha = __alphaDisabled;
		}
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
		size();
	}
	
	
	private function size(Void):Void {
		__width = __up._width;
		__height = __up._height;
		__focus.setSize(__width, __height);
	}
	
	
	/**
		Static method used to create an instance of a IconButton on stage at run time.
				
		@param target the movie clip to which the button will be attached.
		@param id the instance name given to the new button attached.
		@param depth the depth at which to attach the new button.
		@param initObj (optional) an object containing any properties you want to assign to the component when it is created
		@return a reference to the new button attached.
		@example
		<pre>
		import com.bjc.controls.IconButton;
		var newIconButton:IconButton = IconButton.create(_root, "myIconButton", 0);
		</pre>
	*/
	public static function create(target:MovieClip, id:String, depth:Number, initObj:Object):IconButton {
		return IconButton(target.attachMovie("IconButton", id, depth, initObj));
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
			if(!__selected){
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
		Sets the linkage name of a symbol to use for the button's down state.
				
		@example
		<pre>
		myButton.downIcon = "customDownIcon";
		</pre>
	*/
	[Inspectable]
	public function set downIcon(icon:String) {
		__downIcon = icon;
		invalidate();
	}
	/**
		Gets the linkage name of a symbol used for the button's down state.
				
		@example
		<pre>
		myVar = myButton.downIcon;
		</pre>
	*/
	public function get downIcon():String {
		return __downIcon;
	}
	
	
	/**
		Sets the linkage name of a symbol to use for the button's over state.
				
		@example
		<pre>
		myButton.overIcon = "customOverIcon";
		</pre>
	*/
	[Inspectable]
	public function set overIcon(icon:String) {
		__overIcon = icon;
		invalidate();
	}
	/**
		Gets the linkage name of a symbol used for the button's over state.
				
		@example
		<pre>
		myVar = myButton.overIcon;
		</pre>
	*/
	public function get overIcon():String {
		return __overIcon;
	}
	
	
	/**
		Sets the linkage name of a symbol to use for the button's up state.
				
		@example
		<pre>
		myButton.upIcon = "customUpIcon";
		</pre>
	*/
	[Inspectable]
	public function set upIcon(icon:String) {
		__upIcon = icon;
		invalidate();
	}
	/**
		Gets the linkage name of a symbol used for the button's up state.
				
		@example
		<pre>
		myVar = myButton.upIcon;
		</pre>
	*/
	public function get upIcon():String {
		return __upIcon;
	}
	
	
	/**
		True if the button is set to toggle and is currently in a "down" state. Can also be used to set the button's state to down, if toggle is set to true.
	
		@see com.bjc.controls.IconButton#toggle
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
		Gets the selection mode of the component.
	
		@example
		<pre>
		myVar = myButton.selected;
		</pre>
	*/
	public function get selected():Boolean {
		return __selected;
	}
	
	
	/**
		Determine if button is a simple pushbutton, or a button that can be toggled on and off. If toggle is set to true, the buttons up or down state can be set or retrieved with the Button.selected property.
	
		@see com.bjc.controls.IconButton#selected
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