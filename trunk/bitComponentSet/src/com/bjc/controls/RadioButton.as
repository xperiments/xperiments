import com.bjc.controls.GroupBox;
import com.bjc.controls.Label;
import com.bjc.resizers.Resizer;
import com.bjc.core.LabelWrapper;
import mx.utils.Delegate;
import mx.events.EventDispatcher;

[IconFile ("icons/RadioButton.png")]

[Event("click")]

[Event("focus")]

[Event("killFocus")]

[Event("tabFocus")]


/**
* A radio button for choosing a single value amongst several possibilities. All radio buttons placed within a particular movie clip or component will be grouped together, unless they are within the bounds of a GroupBox component in the same clip.
* <BR><BR>
* Events:
* <BR><BR>
* <B>click</B> - Fired whenever the user presses and releases the mouse button while on the radio button, changing its state.
* <BR>
* <B>focus</B> - Fired whenever the component receives focus.
* <BR>
* <B>killFocus</B> - Fired whenever the component loses focus.
* <BR>
* <B>tabFocus</B> - Fired whenever the component receives focus by pressing the TAB key.
* @author Beam Jive Consulting - www.beamjive.com
*/
class com.bjc.controls.RadioButton extends LabelWrapper {
 	private var clipParameters:Object = {radioButtonGroupName:1, selected:1, label:1};
	private static var mergedClipParameters:Boolean = com.bjc.core.BJCComponent.mergeClipParameters(RadioButton.prototype.clipParameters, LabelWrapper.prototype.clipParameters);

	
	private var __falseBtn:MovieClip;
	private var __keyListener:Object;
	private var __label:Label;
	private var __labelText:String = "RadioButton";
	private var __radioButtonGroup:Array;
	private var __radioButtonGroupName:String = "radioButtonGroup";
	private var __selected:Boolean = false;
	private var __trueBtn:MovieClip;
	
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
	* @usage <pre>myRadioButton.clickHandler = function(){
	* 	trace("I was clicked.");
	* }</pre>
	*/
	public var clickHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myRadioButton.focusHandler = function(){
	* 	trace("Set focus.");
	* }</pre>
	*/
	public var focusHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myRadioButton.killFocusHandler = function(){
	* 	trace("Kill focus.");
	* }</pre>
	*/
	public var killFocusHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myRadioButton.tabFocusHandler = function(){
	* 	trace("Tab focus.");
	* }</pre>
	*/
	public var tabFocusHandler:Function;
	
	
	
	
	public function RadioButton(Void) {
	}
	
	
	private function init(Void):Void {
		super.init();
		EventDispatcher.initialize(this);
		__label.fontColor = 0x666666;
		setRadioButtonGroup();
		draw();
	}
	
	
	private function createChildren(Void):Void {
		attachMovie("radioButtonTrueSkin", "__trueBtn", 0);
		attachMovie("radioButtonFalseSkin", "__falseBtn", 1);
		attachMovie("Label", "__label", 2);
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
		__label.text = __labelText;
		__trueBtn._visible = __selected;
		__falseBtn._visible = !__selected;
		
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
		__label._x = 14;
		__label.setSize(__width, __height);
		__falseBtn._y = __height / 2 - __falseBtn._height / 2;
		__trueBtn._y = __height / 2 - __trueBtn._height / 2;
	}
	
	
	/**
		Static method used to create an instance of a RadioButton on stage at run time.
				
		@param target the movie clip to which the radio button will be attached.
		@param id the instance name given to the new radio button attached.
		@param depth the depth at which to attach the new radio button.
		@param initObj (optional) an object containing any properties you want to assign to the component when it is created
		@return a reference to the new radio button attached.
		@example
		<pre>
		import com.bjc.controls.RadioButton;
		var newRadioButton:RadioButton = RadioButton.create(_root, "myRadioButton", 0);
		</pre>
	*/
	public static function create(target:MovieClip, id:String, depth:Number, initObj:Object):RadioButton {
		return RadioButton(target.attachMovie("RadioButton", id, depth, initObj));
	}
	
	
	
	
	private function getGroupBox(Void):GroupBox {
		for(var object in _parent){
			var theObject = _parent[object];
			
			if(theObject.isGroupBox){
				if(theObject.hitTest(_x, _y, false)){
					return theObject;
				}
			}
		}
		return undefined;
	}
	
	private function nextInGroup(Void):Void {
		for(var i=0;i<__radioButtonGroup.length;i++){
			if(__radioButtonGroup[i].selected){
				if(i < __radioButtonGroup.length-1){
					var radio:RadioButton = __radioButtonGroup[i+1];
				} else {
					var radio:RadioButton = __radioButtonGroup[0];
				}
				
				unselectGroup();
				radio.selected = true;
				if(!radio.enabled){
					nextInGroup();
				} else {
					Selection.setFocus(radio);
					radio.onRelease();
				}
				
				break;
			}
		}
	}
	
	private function previousInGroup(Void):Void {
		for(var i=0;i<__radioButtonGroup.length;i++){
			if(__radioButtonGroup[i].selected){
				if(i > 0){
					var radio:RadioButton = __radioButtonGroup[i-1];
				} else {
					var radio:RadioButton = __radioButtonGroup[__radioButtonGroup.length-1];
				}
				unselectGroup();
				radio.selected = true;
				if(!radio.enabled){
					previousInGroup();
				} else {
					Selection.setFocus(radio);
					radio.onRelease();
				}
				
				break;
			}
		}
	}
	
	
	private function onKeyPressed(Void):Void {
		if((Selection.getFocus() == "" + this) && __enabled && __keyEnabled){
			if(Key.getCode() == Key.ENTER){
				onRelease();
			} else if(Key.getCode() == Key.DOWN || Key.getCode() == Key.RIGHT){
				nextInGroup();
			} else if(Key.getCode() == Key.UP || Key.getCode() == Key.LEFT){
				previousInGroup();
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
			unselectGroup();
			selected = true;
			__radioButtonGroup.selectedButton = this;
			dispatchEvent({type:"click", target:this});
			if(Selection.getFocus() != "" + this) Selection.setFocus(this);
		}
	}
	
	
	private function setRadioButtonGroup(Void):Void {
		var groupBox:GroupBox = getGroupBox();
		if(groupBox != undefined){
			if(groupBox.radioButtonGroups[__radioButtonGroupName] == undefined){
				groupBox.radioButtonGroups[__radioButtonGroupName] = new Array();
			}
			__radioButtonGroup = groupBox.radioButtonGroups[__radioButtonGroupName];
		} else {
			if(_parent.radioButtonGroups == undefined){
				_parent.radioButtonGroups = new Object();
			}
			if(_parent.radioButtonGroups[__radioButtonGroupName] == undefined){
				_parent.radioButtonGroups[__radioButtonGroupName] = new Array();
			}
			__radioButtonGroup = _parent.radioButtonGroups[__radioButtonGroupName];
		}
		var isInGroup:Boolean = false;
		var numButtons:Number = __radioButtonGroup.length;
		for(var i=0;i<numButtons;i++){
			if(__radioButtonGroup[i] == this){
				isInGroup = true;
				break;
			}
		}
		if(!isInGroup){
			__radioButtonGroup.push(this);
		}
	}
	
	
	private function unselectGroup(Void):Void {
		var numButtons:Number = __radioButtonGroup.length;
		for(var i=0;i<numButtons;i++){
			__radioButtonGroup[i].selected = false;
		}
	}
	
	
	
	
	
	
	
	/**
		An array containing all the radio buttons in this particular group. Mainly used internally to ensure that only one button is selected at a time. 
	
		@example
		<pre>
		trace("there are " + radioButton1.radioButtonGroup.length + " buttons in this group.");
		</pre>
	*/
	public function get radioButtonGroup():Array {
		return __radioButtonGroup;
	}
	
	
	/**
		Sets the name of the radioButtonGroup that this button is assigned to. This is usually assigned internally, but can be used to set some buttons in one group, and some in another.
	
		@example
		<pre>
		radioButton1.radioButtonGroupName = "group1";
		radioButton2.radioButtonGroupName = "group1";
		radioButton3.radioButtonGroupName = "group1";
		radioButton4.radioButtonGroupName = "group2";
		radioButton5.radioButtonGroupName = "group2";
		radioButton6.radioButtonGroupName = "group2";
		// this will cause radio buttons 1-3 to be in one group, and 4-6 to be in another.
		</pre>
	*/
	[Inspectable (defaultValue="radioButtonGroup")]
	public function set radioButtonGroupName(rbg:String) {
		__radioButtonGroupName = rbg;
		setRadioButtonGroup();
	}
	/**
		Gets the name of the radioButtonGroup that this button is assigned to. 
	
		@example
		<pre>
		myVar = radioButton1.radioButtonGroupName;
		</pre>
	*/
	public function get radioButtonGroupName():String {
		return __radioButtonGroupName;
	}
	
	
	/**
		Sets the selection mode of a radio button. This will fire the click event if the eventOnValue is set to true (changed in version 1.3).
	
		@example
		<pre>
		radioButton1.selected = true;
		</pre>
	*/
	[Inspectable (type="Boolean", defaultValue=false)]
	public function set selected(b:Boolean) {
		__selected = b;
		__trueBtn._visible = __selected;
		__falseBtn._visible = !__selected;
	}
	[Bindable]
	[ChangeEvent ("click")]
	/**
		Gets the selection mode of a radio button.
	
		@example
		<pre>
		myVar = radioButton1.selected;
		</pre>
	*/
	public function get selected():Boolean {
		return __selected;
	}
	
	
	/**
		Sets the text to display in the label of the radio button.
	
		@example
		<pre>
		radioButton1.label = "Choice 1";
		</pre>
	*/
	[Inspectable (defaultValue="RadioButton")]
	public function set label(txt:String) {
		__labelText = txt;
		invalidate();
	}
	/**
		Gets the text to display in the label of the radio button.
	
		@example
		<pre>
		myVar = radioButton1.label;
		</pre>
	*/
	public function get label():String {
		return __labelText;
	}
}