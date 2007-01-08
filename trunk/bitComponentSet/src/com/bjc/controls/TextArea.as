import com.bjc.controls.HorizScrollBar;
import com.bjc.resizers.Resizer;
import com.bjc.controls.VertScrollBar;
import com.bjc.core.LabelWrapper;
import mx.events.EventDispatcher;
import mx.utils.Delegate;


[IconFile ("icons/TextArea.png")]

[Event("change")]

[Event("focus")]

[Event("killFocus")]

[Event("tabFocus")]

[Event("scroll")]


/**
* Text area component for displaying text or allowing input of large amounts of text.
* <BR><BR>
* Events:
* <BR><BR>
* <B>change</B> - Fired whenever the user has changed the text in the text area by typing a new character or deleting any content. Will not fire when text is changed programatically via the text property.
* <BR>
* <B>focus</B> - Fired whenever the internal text field receives focus.
* <BR>
* <B>killFocus</B> - Fired whenever the internal text field loses focus.
* <BR>
* <B>tabFocus</B> - Fired whenever the internal text field receives focus by pressing the TAB key.
* <BR>
* <B>scroll</B> - Fired once each frame while text is being scrolled.
* @author Beam Jive Consulting - www.beamjive.com
*/
class com.bjc.controls.TextArea extends LabelWrapper {
 	private var clipParameters:Object = {editable:1, maxChars:1, password:1, restrict:1, scrollBarWidth:1, selectable:1, text:1};
	private static var mergedClipParameters:Boolean = com.bjc.core.BJCComponent.mergeClipParameters(TextArea.prototype.clipParameters, LabelWrapper.prototype.clipParameters);

	
	private var __background:Resizer;
	private var __condenseWhite:Boolean = false;
	private var __corner:MovieClip;
	private var __editable:Boolean = true;
	private var __format:TextFormat;
	private var __maxChars:Number = null;
	private var __password:Boolean = false;
	private var __restrict:String = "^"
	private var __hScrollBar:HorizScrollBar;
	private var __vScrollBar:VertScrollBar;
	private var __scrollBarWidth:Number = 16;
	private var __selectable:Boolean = true;
	private var __text:String = "";
	private var __tf:TextField;
	private var __update:Boolean = true;
	private var __updateCount:Number = 0;
	private var __wordWrap:Boolean = true;
	private var __onScorllBar:Boolean = false;
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
	* @usage <pre>myTextArea.changeHandler = function(){
	* 	trace("I was changed.");
	* }</pre>
	*/
	public var changeHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myTextArea.focusHandler = function(){
	* 	trace("Set focus.");
	* }</pre>
	*/
	public var focusHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myTextArea.killFocusHandler = function(){
	* 	trace("Kill focus.");
	* }</pre>
	*/
	public var killFocusHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myTextArea.tabFocusHandler = function(){
	* 	trace("Tab focus.");
	* }</pre>
	*/
	public var tabFocusHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myTextArea.scrollHandler = function(){
	* 	trace("Scrolling...");
	* }</pre>
	*/
	public var scrollHandler:Function;
	
	
	public function TextArea(Void) {
	}
	
	
	private function init(Void):Void {
		super.init();
		EventDispatcher.initialize(this);
		Mouse.addListener(this);
		//Selection.addListener(this);
		
		__hScrollBar.disabledAlpha = 100;
 		__hScrollBar._visible = false;
		__hScrollBar.minimum = 0;
		__hScrollBar.lineScroll = 10;
		__hScrollBar.addEventListener("change", Delegate.create(this, onHScroll));
		__hScrollBar.addEventListener("focus", Delegate.create(this, onScrollFocus));
		__hScrollBar.rollOverHandler = Delegate.create(this, onRollOverFocus);
		__hScrollBar.rollOutHandler = Delegate.create(this, onRollOutFocus);
		__hScrollBar.releaseOutsideHandler = Delegate.create(this, onRollOutFocus);
		__vScrollBar.disabledAlpha = 100;
		__vScrollBar._visible = false;
 		__vScrollBar.minimum = 1;
		__vScrollBar.addEventListener("change", Delegate.create(this, onVScroll));
		__vScrollBar.addEventListener("focus", Delegate.create(this, onScrollFocus));
		__vScrollBar.rollOverHandler = Delegate.create(this, onRollOverFocus);
		__vScrollBar.rollOutHandler = Delegate.create(this, onRollOutFocus);
		__vScrollBar.releaseOutsideHandler = Delegate.create(this, onRollOutFocus);
		
		__tf.type = "input";
		__tf.multiline = true;
		__tf.onChanged = Delegate.create(this, onTFChanged);
		__tf.onScroller = Delegate.create(this, update);
		__tf.onSetFocus = Delegate.create(this, onTFFocus);
		__tf.onKillFocus = Delegate.create(this, onTFKillFocus);
		
		draw();
	}
	
	
	private function createChildren(Void):Void {
		attachMovie("Resizer", "__background", 0);
		__background.margin = 5;
		__background.skin = "textAreaSkin";
		createTextField("__tf", 1, 2, 2, 96, 40);
		attachMovie("HorizScrollBar", "__hScrollBar", 2);
		attachMovie("VertScrollBar", "__vScrollBar", 3);
		attachMovie("textAreaCornerSkin", "__corner", 4);
		
		attachMovie("Resizer", "__focus", 5);
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
		__hScrollBar.enabled = __enabled;
		__vScrollBar.enabled = __enabled;
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
		if(__editable){
			__tf.type = "input";
		} else {
			__tf.type = "dynamic";
		}
		if(__selectable && __enabled){
			__tf.selectable = true;
		} else {
			__tf.selectable = false;
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
		__tf.condenseWhite = __condenseWhite;
		__tf.wordWrap = __wordWrap;
		if(!__disableStyles){
 			__tf.setTextFormat(__format);
		  	__tf.setNewTextFormat(__format);
		}
		size();
	}
	
	
	private function size(Void):Void {
		__height = Math.max(__height, __scrollBarWidth);
		__background.setSize(__width, __height);
		__focus.setSize(__width, __height);
		checkScrollBars();
		sizeScrolls();

		__update = true;
		__updateCount = 0;
 		onEnterFrame = doUpdate;
	}
	
	private function doUpdate()
	{
		update();
		if(__updateCount++ > 3) {
			delete onEnterFrame;
		}
	}

	/**
		Static method used to create an instance of a TextArea on stage at run time.
				
		@param target the movie clip to which the text area will be attached.
		@param id the instance name given to the new text area attached.
		@param depth the depth at which to attach the new text area.
		@param initObj (optional) an object containing any properties you want to assign to the component when it is created
		@return a reference to the new text area attached.
		@example
		<pre>
		import com.bjc.controls.TextArea;
		var newTextArea:TextArea = TextArea.create(_root, "myTextArea", 0);
		</pre>
	*/
	public static function create(target:MovieClip, id:String, depth:Number, initObj:Object):TextArea {
		return TextArea(target.attachMovie("TextArea", id, depth, initObj));
	}
		
	
	
	private function checkScrollBars(Void):Void {
		__tf._width = __width - 4;
		__tf._height = __height - 4;
		if(__tf.maxhscroll > 1 && !__wordWrap){
			__tf._height = __height - __scrollBarWidth - 2;
			__hScrollBar._visible = true;
		} else {
			__tf._height = __height - 4;
			__hScrollBar._visible = false;
		}
		if(__tf.maxscroll > 1){
			__tf._width = __width - __scrollBarWidth - 2;
			__vScrollBar._visible = true;
		} else {
			__tf._width = __width - 4;
			__vScrollBar._visible = false;
		}
	}
	
	private function getPaneHeight(Void):Number {
		if( __hScrollBar._visible ){
			return __height - __scrollBarWidth - 4;
		} else {
			return __height - 4;
		}
	}
	
	
	private function getPaneWidth(Void):Number {
		if( __vScrollBar._visible ){
			return  __width - __scrollBarWidth - 4;
		} else {
			return __width - 4;
		}
	}
	
	private function needsCorner(Void):Boolean {
		return __hScrollBar._visible && __vScrollBar._visible;
	}
	
	
	private function onMouseWheel(delta:Number):Void {
		if(__enabled && __selectable && (_xmouse > 0) && (_xmouse < __width) && (_ymouse > 0) && (_ymouse < __height)){
			__tf.scroll -= delta / 4;
			dispatchEvent({type:"scroll", target:this});
		}
		update();
	}
	
	private function onScrollFocus(evtObj:Object):Void {
		if(Selection.getFocus() != "" + this) Selection.setFocus(this);
	}
	
	private function onRollOverFocus(obj:Object):Void {
		__onScorllBar = true;
	}
	
	private function onRollOutFocus(obj:Object):Void {
		__onScorllBar = false;
	}
	
	private function onKillFocus(newFocus:Object, oldFocus:Object):Void {
		if(newFocus != __tf && newFocus != __hScrollBar && newFocus != __vScrollBar && newFocus != __corner){
			__onTF = false;
			hideFocus();
			dispatchEvent({type:"killFocus", target:this, newfocus:newFocus});
		}
	}
	
	
	private function onSetFocus(oldFocus:Object, newFocus:Object):Void {
		if(!__onTF) dispatchEvent({type:"focus", target:this, oldfocus:oldFocus});
	}
	
	
	private function onTFChanged(Void):Void {
		if(__html){
			__text = __tf.htmlText;
		} else {
	 		__text = __tf.text;
	 	}
 		checkScrollBars();
		sizeScrolls();
 		update();
 		dispatchEvent({type:"change", target:this});
	}
	
	
	private function onTFFocus(oldFocus:Object):Void {
		__onTF = true;
		if(oldFocus != this && oldFocus != __hScrollBar && oldFocus != __vScrollBar && oldFocus != __corner){
			dispatchEvent({type:"focus", target:this, oldfocus:oldFocus});
			if(Key.isDown(9)){
				showFocus();
				dispatchEvent({type:"tabFocus", target:this, oldfocus:oldFocus});
			}
		}
	}
	
	private function onTFKillFocus(newFocus:Object):Void {
		if(!__onScorllBar || Key.isDown(9)){
			__onTF = false;
			hideFocus();
			dispatchEvent({type:"killFocus", target:this, newfocus:newFocus});
		}
	}
	
	private function onHScroll(evtObj:Object):Void {
		__update = false;
		__tf.hscroll = Math.round(__hScrollBar.value);
		dispatchEvent({type:"scroll", target:this, x:__hScrollBar.value+2, y:__vScrollBar.value});
	}
	
	private function onVScroll(evtObj:Object):Void {
		__update = false;
		__tf.scroll = __vScrollBar.value;
		dispatchEvent({type:"scroll", target:this, x:__hScrollBar.value+2, y:__vScrollBar.value});
	}
	
	private function sizeCorner(Void):Void {
		if( needsCorner() ){
			__corner._visible = true;
			__corner._x = __vScrollBar._x;
			__corner._y = __hScrollBar._y;
			__corner._width = __corner._height = __scrollBarWidth;
		} else {
			__corner._visible = false;
		}
	}


	private function sizeHScroll(Void):Void {
		if( __tf.maxhscroll > 1 ){
			__hScrollBar._visible = true;
			__hScrollBar.move(1, __height - __scrollBarWidth - 1);
			__hScrollBar.setSize(getPaneWidth() + 2, __scrollBarWidth);
			update();
		} else {
			__hScrollBar._visible = false;
		}
	}
	
	
	private function sizeScrolls(Void):Void {
		sizeHScroll();
		sizeVScroll();
		sizeCorner();
	}
	
	
	private function sizeVScroll(Void):Void {	
		if( __tf.maxscroll > 1 ){
			__vScrollBar._visible = true;
			__vScrollBar.move(__width - __scrollBarWidth - 1, 1);
			__vScrollBar.setSize(__scrollBarWidth, getPaneHeight() + 2);
			update();
		} else {
			__vScrollBar._visible = false;
		}
	}
	
	
	private function update(Void):Void {
		if(__update){
			var showing:Number = __tf.bottomScroll - __tf.scroll + 1;
			var total:Number = __tf.maxscroll + showing;
			__vScrollBar.maximum = __tf.maxscroll;
			__vScrollBar.thumbScale = showing / total;
			__vScrollBar.value = __tf.scroll;
			
			var total:Number = __tf.maxhscroll + getPaneWidth();
			__hScrollBar.maximum = __tf.maxhscroll;
			__hScrollBar.thumbScale = getPaneWidth() / total;
			__hScrollBar.value = __tf.hscroll;
		}
		__update = true;
	}		








	/**
		Specified whether or not extra white space (spaces and returns) will be stripped out of the text. Only valid if html is set to true.
	
		@example
		<pre>
		myTA.condenseWhite = false;
		</pre>
	*/
	[Inspectable (type="Boolean", defaultValue=false)]
	public function set condenseWhite(b:Boolean) {
		__condenseWhite = b;
		invalidate();
	}
	/**
		Gets the extra white space mode of the component.
	
		@example
		<pre>
		myVar = myTA.condenseWhite;
		</pre>
	*/
	public function get condenseWhite():Boolean {
		return __condenseWhite;
	}


	/**
		Specified whether or not the user will be able to select and edit the text in the text area.
	
		@example
		<pre>
		myTA.editable = false;
		</pre>
	*/
	[Inspectable (type="Boolean", defaultValue=true)]
	public function set editable(b:Boolean) {
		__editable = b;
		invalidate();
	}
	/**
		Gets the editable mode of the component.
	
		@example
		<pre>
		myVar = myTA.editable;
		</pre>
	*/
	public function get editable():Boolean {
		return __editable;
	}
	
	/**
		Sets the current horizontal scroll value for the text field in the component, as described in the Flash help.
	
		@example
		<pre>
		myTA.scroll = 10;
		</pre>
	*/
	public function set hscroll(s:Number) {
		__tf.hscroll = s;
		invalidate();
	}
	/**
		Gets the current horizontal scroll value for the text field in the component, as described in the Flash help.
	
		@example
		<pre>
		myVar = myTA.scroll;
		</pre>
	*/
	public function get hscroll():Number {
		return __tf.hscroll;
	}


	/**
		Sets the maximum number of allowable characters in the the text area. If set to 0, there will be no limitation.
	
		@example
		<pre>
		myTA.maxChars = 100;
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
		Gets the maximum number of allowable characters in the the text area.
	
		@example
		<pre>
		myVar = myTA.maxChars;
		</pre>
	*/
	public function get maxChars():Number {
		return __maxChars;
	}
	

	/**
		Gets the current maxscroll value for the text field in the component, as described in the Flash help.
	
		@example
		<pre>
		trace(myTA.maxscroll);
		</pre>
	*/
	public function get maxscroll():Number {
		// make sure the text field is updated before returning value
		draw();
		return __tf.maxscroll;
	}
	
	/**
		Gets the current maxhscroll value for the text field in the component, as described in the Flash help.
	
		@example
		<pre>
		trace(myTA.maxhscroll);
		</pre>
	*/
	public function get maxhscroll():Number {
		// make sure the text field is updated before returning value
		draw();
		return __tf.maxhscroll;
	}
	
	
	/**
		Sets the password mode of the component. If true, text entered into the text area will not be legible, allowing for secure password entry.
	
		@example
		<pre>
		myTA.password = true;
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
		myVar = myTA.password;
		</pre>
	*/
	public function get password():Boolean {
		return __password;
	}
	
	
	/**
		Restricts the characters that can be entered in the text area. See the Flash help for TextField.restrict for a full description on how to use this property. In the text area component, setting restrict to "" will allow any characters to be entered.
	
		@example
		<pre>
		myTA.restrict = "0123456789"; // only these characters will be allowed.
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
		myVar = myTA.restrict.
		</pre>
	*/
	public function get restrict():String {
		return __restrict;
	}
	

	/**
		Sets the current scroll value for the text field in the component, as described in the Flash help.
	
		@example
		<pre>
		myTA.scroll = 10;
		</pre>
	*/
	public function set scroll(s:Number) {
		__tf.scroll = s;
		invalidate();
	}
	/**
		Gets the current scroll value for the text field in the component, as described in the Flash help.
	
		@example
		<pre>
		myVar = myTA.scroll;
		</pre>
	*/
	public function get scroll():Number {
		return __tf.scroll;
	}
	
	
	/**
		Sets the width of the scrollbar used in the text area (if needed)
				
		@example
		<pre>
		myTA.scrollBarWidth = 20;
		</pre>
	*/
	[Inspectable (defaultValue=16)]
	public function set scrollBarWidth(w:Number) {
		__scrollBarWidth = w;
		invalidate();
	}
	/**
		Gets the width of the scrollbar used in the text area (if needed)
				
		@example
		<pre>
		myVar = myTA.scrollBarWidth;
		</pre>
	*/
	public function get scrollBarWidth():Number {
		return __scrollBarWidth;
	}
	
	/**
		Specified whether or not the user will be able to select the text in the text area.
	
		@example
		<pre>
		myTA.selectable = false;
		</pre>
	*/
	[Inspectable (type="Boolean", defaultValue=true)]
	public function set selectable(b:Boolean) {
		__selectable = b;
		invalidate();
	}
	/**
		Gets the selectable mode of the component.
	
		@example
		<pre>
		myVar = myTA.selectable;
		</pre>
	*/
	public function get selectable():Boolean {
		return __selectable;
	}

	/**
		Sets the text in the text area. This can include html tags which will be rendered if html is set to true.
	
		@example
		<pre>
		myTA.text = "hello world.";
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
		Gets the text displayed in the text area.
	
		@example
		<pre>
		myVar = myTA.text;
		</pre>
	*/
	public function get text():String {
		return __text;
	}
	
	
	/**
		The height of the text in the the text area. This is simply the textHeight taken from the internal text field in the component.
	
		@example
		<pre>
		myTA.height = myTA.textHeight + 10;
		</pre>
	*/
	public function get textHeight():Number {
		return __tf.textHeight;
	}
	
	/**
		Returns a reference to the text field within the text area. You can use this for lower level control of the text, such as applying style sheets, or to access properties of the text field not exposed to the component.
	
		@example
		<pre>
		var tf:TextField = myTA.textField;
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
	
	/**
		Sets the wordWrap mode of the text area.
	
		@example
		<pre>
		myTA.wordWrap = false;
		</pre>
	*/
	[Inspectable (type="Boolean", defaultValue=true)]
	public function set wordWrap(b:Boolean) {
		__wordWrap = b;
		invalidate();
	}
	/**
		Gets the wordWrap mode of the text area.
	
		@example
		<pre>
		myVar = myTA.wordWrap;
		</pre>
	*/
	public function get wordWrap():Boolean {
		return __wordWrap;
	}
}