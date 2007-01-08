import com.bjc.resizers.Resizer;
import com.bjc.core.LabelWrapper;
import mx.events.EventDispatcher;
import mx.utils.Delegate;

[IconFile ("icons/TextInput.png")]

[Event("change")]

[Event("focus")]

[Event("killFocus")]

[Event("tabFocus")]

/**
* Text input component for allowing user input of text strings.
* <BR><BR>
* Events:
* <BR><BR>
* <B>change</B> - Fired whenever the user has changed the text in the text input by typing a new character or deleting any content. Will not fire when text is changed programatically via the text property.
* <BR>
* <B>focus</B> - Fired whenever the internal text field receives focus.
* <BR>
* <B>killFocus</B> - Fired whenever the internal text field loses focus.
* <BR>
* <B>tabFocus</B> - Fired whenever the internal text field receives focus by pressing the TAB key.
* @author Beam Jive Consulting - www.beamjive.com
*/
class com.bjc.controls.TextInput extends LabelWrapper {	
 	private var clipParameters:Object = {maxChars:1, password:1, restrict:1, text:1};
	private static var mergedClipParameters:Boolean = com.bjc.core.BJCComponent.mergeClipParameters(TextInput.prototype.clipParameters, LabelWrapper.prototype.clipParameters);

	
	private var __background:Resizer;
	private var __format:TextFormat;
	private var __maxChars:Number = null;
	private var __password:Boolean = false;
	private var __restrict:String = ""
	private var __text:String = "";
	private var __tf:TextField;
	
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
	* @usage <pre>myTextInput.changeHandler = function(){
	* 	trace("I was changed.");
	* }</pre>
	*/
	public var changeHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myTextInput.focusHandler = function(){
	* 	trace("Set focus.");
	* }</pre>
	*/
	public var focusHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myTextInput.killFocusHandler = function(){
	* 	trace("Kill focus.");
	* }</pre>
	*/
	public var killFocusHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myTextInput.tabFocusHandler = function(){
	* 	trace("Tab focus.");
	* }</pre>
	*/
	public var tabFocusHandler:Function;
	
	
	public function TextInput(Void) {
	}
	
	
	private function init(Void):Void {
		super.init();		
		EventDispatcher.initialize(this);
		__tf.type = "input";
		__tf.onChanged = Delegate.create(this, onTFChanged);
		__tf.onSetFocus = Delegate.create(this, onTFFocus);
		__tf.onKillFocus = Delegate.create(this, onTFKillFocus);
		draw();
	}
	
	
	private function createChildren(Void):Void {
		attachMovie("Resizer", "__background", 0);
		__background.skin = "textInputBackgroundSkin";
		__background.margin = 5;
		createTextField("__tf", 1, 2, 1, 98, 20);
		attachMovie("Resizer", "__focus", 2);
		__focus.skin = "focusSkin";
		__focus.margin = 5;
		__focus._visible = false;
	}
	
	
	/**
		@exclude
	*/
	public function draw(Void):Void {
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
			__tf.embedFonts = __embedFont;
		}
		__tf.restrict = __restrict
		__tf.maxChars = __maxChars;
		__tf.password = __password;
		if(__html){
			__tf.html = true;
			__tf.htmlText = __text;
		} else {
			__tf.html = false;
			__tf.text = __text;
		}
		if(!__disableStyles){
			__tf.setTextFormat(__format);
			__tf.setNewTextFormat(__format);
		}
		size();
	}
	
	
	private function size(Void):Void {
		__focus.setSize(__width, __height);
		__tf._width = __width - 2;
 		__tf._height = __tf.textHeight + 4;
		__tf._y = Math.round(__height / 2 - __tf._height / 2);
 		__background.setSize(__width, __height);
	}
	
	
	/**
		Static method used to create an instance of a TextInput on stage at run time.
				
		@param target the movie clip to which the text input will be attached.
		@param id the instance name given to the new text input attached.
		@param depth the depth at which to attach the new text input.
		@param initObj (optional) an object containing any properties you want to assign to the component when it is created
		@return a reference to the new text input attached.
		@example
		<pre>
		import com.bjc.controls.TextInput;
		var newTextInput:TextInput = TextInput.create(_root, "myTextInput", 0);
		</pre>
	*/
	public static function create(target:MovieClip, id:String, depth:Number, initObj:Object):TextInput {
		return TextInput(target.attachMovie("TextInput", id, depth, initObj));
	}
	
	

	
	
	
	
	
	
	private function onTFChanged(Void):Void {		
		__text = __tf.text;
		dispatchEvent({type:"change", target:this});
	}
	
	
	
	private function onTFFocus(oldFocus:Object):Void {
		dispatchEvent({type:"focus", target:this, oldfocus:oldFocus});
		if(Key.isDown(9)){
			showFocus();
			dispatchEvent({type:"tabFocus", target:this, oldfocus:oldFocus});
		}
	}
	
	
	private function onTFKillFocus(newFocus:Object):Void {
		trace("no focus");
		hideFocus();
		dispatchEvent({type:"killFocus", target:this, newfocus:newFocus});
	}
	
	
	
	
	/**
		Sets the maximum number of allowable characters in the the text input.
	
		@example
		<pre>
		myTI.maxChars = 100;
		</pre>
	*/
	[Inspectable (type="Number", defaultValue=0)]
	public function set maxChars(max:Number) {
		__maxChars = max;
		if(__maxChars == 0){
			__maxChars = null;
		}
		invalidate();
	}
	/**
		Gets the maximum number of allowable characters in the the text input.
	
		@example
		<pre>
		myVar = myTI.maxChars;
		</pre>
	*/
	public function get maxChars():Number {
		return __maxChars;
	}


	/**
		Sets the password mode of the component. If true, text entered into the text input will not be legible, allowing for secure password entry.
	
		@example
		<pre>
		myTI.password = true;
		</pre>
	*/
	[Inspectable (defaultValue=false, type="Boolean")]
	public function set password(b:Boolean) {
		__password = b;
		invalidate();
	}
	/**
		Gets the password mode of the component. 
	
		@example
		<pre>
		myVar = myTI.password;
		</pre>
	*/
	public function get password():Boolean {
		return __password;
	}
	
	
	/**
		Restricts the characters that can be entered in the text input. See the Flash help for TextField.restrict for a full description on how to use this property. In the text input component, setting restrict to "" will allow any characters to be entered.
	
		@example
		<pre>
		myTI.restrict = "0123456789"; // only these characters will be allowed.
		</pre>
	*/
	[Inspectable (defaultValue="")]
	public function set restrict(txt:String) {
		__restrict = txt;
		if(__restrict == ""){
			__restrict = "^";
		}
		invalidate();
	}
	/**
		Gets the character restriction of the component.
	
		@example
		<pre>
		myVar = myTI.restrict.
		</pre>
	*/
	public function get restrict():String {
		return __restrict;
	}


	/**
		Sets the text in the text input. This can include html tags which will be rendered if html is set to true.
	
		@example
		<pre>
		myTI.text = "hello world.";
		</pre>
	*/
	[Inspectable (type="String", defaultValue="")]
	public function set text(txt:String) {
		__text = txt;
		invalidate();
	}
	[Bindable]
	[ChangeEvent ("change")]
	/**
		Gets the text displayed in the text input.
	
		@example
		<pre>
		myVar = myTI.text;
		</pre>
	*/
	public function get text():String {
		return __text;
	}
	
	
	/**
		The height of the text in the the text input. This is simply the textHeight taken from the internal text field in the component.
	
		@example
		<pre>
		myTI.height = myTI.textHeight + 10;
		</pre>
	*/
	public function get textHeight():Number {
		return __tf.textHeight;
	}
	
	/**
		Returns a reference to the text field within the text input. You can use this for lower level control of the text, such as applying style sheets, or to access properties of the text field not exposed to the component.
	
		@example
		<pre>
		var tf:TextField = myTI.textField;
		tf.background = true;
		tf.backgroundColor = 0xffcccc;	// creates a pink background
		</pre>
	*/
	public function get textField():TextField {
		return __tf;
	}
	
	/**
		@exclude
	*/
	public function set tabIndex(index:Number) {
		__tf.tabIndex = index;
	}
	/**
		@exclude
	*/
	public function get tabIndex():Number {
		return __tf.tabIndex;
	}
}