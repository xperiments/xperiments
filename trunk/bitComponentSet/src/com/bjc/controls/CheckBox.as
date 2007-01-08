import com.bjc.controls.Label;
import com.bjc.core.LabelWrapper;
import com.bjc.resizers.Resizer;
import mx.events.EventDispatcher;
import mx.utils.Delegate;

[IconFile("icons/CheckBox.png")]

[Event("click")]

[Event("focus")]

[Event("killFocus")]

[Event("tabFocus")]

/**
* A simple check box for setting true/false values
* <BR><BR>
* Events:
* <BR><BR>
* <B>click</B> - Fired whenever the user presses and releases the mouse button while on the checkbox, changing its state.
* <BR>
* <B>focus</B> - Fired whenever the component receives focus.
* <BR>
* <B>killFocus</B> - Fired whenever the component loses focus.
* <BR>
* <B>tabFocus</B> - Fired whenever the component receives focus by pressing the TAB key.
* @author Beam Jive Consulting - www.beamjive.com
*/
class com.bjc.controls.CheckBox extends LabelWrapper {
 	private var clipParameters:Object = {selected:1, label:1};
	private static var mergedClipParameters:Boolean = com.bjc.core.BJCComponent.mergeClipParameters(CheckBox.prototype.clipParameters, LabelWrapper.prototype.clipParameters);

	
	private var __label:Label;
	private var __labelText:String = "CheckBox";
	private var __checkTrue:MovieClip;
	private var __checkFalse:MovieClip;
	private var __keyListener:Object;
	private var __selected:Boolean = false;

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
	* @usage <pre>myCheckBox.clickHandler = function(){
	* 	trace("I was clicked.");
	* }</pre>
	*/
	public var clickHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myCheckBox.focusHandler = function(){
	* 	trace("Set focus.");
	* }</pre>
	*/
	public var focusHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myCheckBox.killFocusHandler = function(){
	* 	trace("Kill focus.");
	* }</pre>
	*/
	public var killFocusHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myCheckBox.tabFocusHandler = function(){
	* 	trace("Tab focus.");
	* }</pre>
	*/
	public var tabFocusHandler:Function;
	
	
	
	public function CheckBox(Void) {
	}
	
	
	private function init(Void):Void {
		super.init();
		EventDispatcher.initialize(this);
		draw();
	}
	
	
	private function createChildren(Void):Void {
		attachMovie("Label", "__label", 0);
		attachMovie("checkBoxTrueSkin", "__checkTrue", 1);
		attachMovie("checkBoxFalseSkin", "__checkFalse", 2);
		attachMovie("Resizer", "__focus", 3);
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
		__label.enabled = __enabled;
		__checkTrue._visible = __selected;
		__checkFalse._visible = !__selected;
		
		__label.align = __align;
		__label.disabledColor = __disabledColor;
		__label.embedFont = __embedFont;
		__label.fontColor = __fontColor;
		__label.fontFace = __fontFace;
		__label.fontSize = __fontSize;
		__label.html = __html;
		__label.text = __labelText;
		
		size();
	}
	
	
	private function size(Void):Void {
		__focus.setSize(__width, __height);
		__checkTrue._y = __height / 2 - 5;
		__checkFalse._y = __height / 2 - 5;
		__label._x = 12;
		__label.setSize(__width - 12, __height);
	}
	
	
	/**
		Static method used to create an instance of a CheckBox on stage at run time.
				
		@param target the movie clip to which the check box will be attached.
		@param id the instance name given to the new check box attached.
		@param depth the depth at which to attach the new check box.
		@param initObj (optional) an object containing any properties you want to assign to the component when it is created
		@return a reference to the new check box attached.
		@example
		<pre>
		import com.bjc.controls.CheckBox;
		var newCheckBox:CheckBox = CheckBox.create(_root, "myCheckBox", 0);
		</pre>
	*/
	public static function create(target:MovieClip, id:String, depth:Number, initObj:Object):CheckBox {
		return CheckBox(target.attachMovie("CheckBox", id, depth, initObj));
	}
		

	
	private function onKeyPressed(Void):Void {
		if((Selection.getFocus() == "" + this) && __enabled && __keyEnabled){
			if(Key.getCode() == Key.ENTER){
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
			__keyListener.onKeyUp = Delegate.create(this, onKeyPressed);
			Key.addListener(__keyListener);
		}
		dispatchEvent({type:"focus", target:this, oldfocus:oldFocus});
		if(Key.isDown(9)){
			dispatchEvent({type:"tabFocus", target:this, oldfocus:oldFocus});
			showFocus();
		}
	}
	
	private function onPress(Void):Void {
		if(__enabled){
			if(Selection.getFocus() != "" + this) Selection.setFocus(this);
		}
	}
	
	private function onRelease(Void):Void {
		if(__enabled){
			__selected = !__selected;
			invalidate();
			dispatchEvent({type:"click", target:this});
			if(Selection.getFocus() != "" + this) Selection.setFocus(this);
		}
	}
	
	
	/**
		True if the check box is currently in a "checked" state. Can also be used to set the check box's state to down.
	
		@example
		<pre>
		myCheckBox.selected = true;
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
		Gets the current state of the check box.
	
		@example
		<pre>
		myVar = myCheckBox.selected;
		</pre>
	*/
	public function get selected():Boolean {
		return __selected;
	}
	
	
	/**
		Sets the text to be shown on the check box.
	
		@example
		<pre>
		myCheckBox.label = "Remember me";
		</pre>
	*/
	[Inspectable (defaultValue="CheckBox")]
	public function set label(txt:String) {
		__labelText = txt;
		invalidate();
	}
	/**
		Gets the text shown on the check box.
	
		@example
		<pre>
		myVar = myCheckBox.label;
		</pre>
	*/
	public function get label():String {
		return __labelText;
	}
}