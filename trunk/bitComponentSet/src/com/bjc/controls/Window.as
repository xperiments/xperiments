import com.bjc.controls.Label;
import com.bjc.core.LabelWrapper;
import com.bjc.resizers.Resizer;
import mx.events.EventDispatcher;
import mx.utils.Delegate;

[IconFile ("icons/Window.png")]

[Event("close")]

[Event("size")]

[Event("focus")]

[Event("killFocus")]

[Event("tabFocus")]

/**
* Window component.
* <BR><BR>
* Events:
* <BR><BR>
* <B>close</B> - Fired when the user clicks the close button on the window, just prior to the component being removed.
* <BR>
* <B>size</B> - Fired whenever the user manually changes the size of the window by dragging the lower right corner.
* <BR>
* <B>focus</B> - Fired whenever the component receives focus.
* <BR>
* <B>killFocus</B> - Fired whenever the component loses focus.
* <BR>
* <B>tabFocus</B> - Fired whenever the component receives focus by pressing the TAB key.
* @author Beam Jive Consulting - www.beamjive.com
*/
class com.bjc.controls.Window extends LabelWrapper {
 	private var clipParameters:Object = {closeable:1, contentPath:1, resizable:1, title:1};
	private static var mergedClipParameters:Boolean = com.bjc.core.BJCComponent.mergeClipParameters(Window.prototype.clipParameters, LabelWrapper.prototype.clipParameters);
	
	
	private var __bg:MovieClip;
	private var __closeable:Boolean = false;
	private var __closeBtn:MovieClip;
	private var __content:MovieClip;
	private var __contentPath:String;
	private var __dragBar:MovieClip;
	private var __draggable:Boolean = true;
	private var __label:Label;
	private var __labelText:String = "Window";
	private var __mask:MovieClip;
	private var __removeOnClose:Boolean = true;
	private var __resizable:Boolean = false;
	private var __resizeHandle:MovieClip;
	private var __resizer:Resizer;
	private var __shadow:MovieClip;
	
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
	* @usage <pre>myWindow.closeHandler = function(){
	* 	trace("I am about to close.");
	* }</pre>
	*/
	public var closeHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myWindow.sizeHandler = function(){
	* 	trace("I am bigger or smaller.");
	* }</pre>
	*/
	public var sizeHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myWindow.focusHandler = function(){
	* 	trace("Set focus.");
	* }</pre>
	*/
	public var focusHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myWindow.killFocusHandler = function(){
	* 	trace("Kill focus.");
	* }</pre>
	*/
	public var killFocusHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myWindow.tabFocusHandler = function(){
	* 	trace("Tab focus.");
	* }</pre>
	*/
	public var tabFocusHandler:Function;
	
	
	public function Window(Void) {
	}
	
	
	private function init(Void):Void {
		super.init();
		EventDispatcher.initialize(this);
		__dragBar.onPress = Delegate.create(this, onDrag);
		__dragBar.onRelease = __dragBar.onReleaseOutside = Delegate.create(this, onDrop);
		__dragBar.useHandCursor = false;
		__dragBar._alpha = 0;
		__bg.onPress = null;
		__bg.useHandCursor = false;
		__bg._alpha = 0;
		__resizer.margin = 5;
		__resizer.topMargin = 22;
		__resizer.skin = "windowSkin";
		__shadow.skin = "windowShadow";
		__label.fontSize = 12;
		__content.setMask(__mask);
		if(__contentPath != undefined && __contentPath != ""){
			getContent();
		} else {
			__content.createEmptyMovieClip("content", 0);
		}
		draw();
	}
	
	
	private function createChildren(Void):Void {
		attachMovie("Resizer", "__shadow", 0);
 		attachMovie("windowPanel", "__bg", 1);
		attachMovie("windowPanel", "__dragBar", 2);
		attachMovie("Resizer", "__resizer", 3);
		attachMovie("Label", "__label", 4);
		createEmptyMovieClip("__content", 5);
		createEmptyMovieClip("__mask", 6);
		attachMovie("Resizer", "__focus", 7);
		__focus.skin = "focusSkin";
		__focus.margin = 5;
		__focus._visible = false;
	}
	
	
	/**
		@exclude
	*/
	public function draw(Void):Void {
		if(__resizable){
			attachMovie("windowResizerSkin", "__resizeHandle", 7);
			__resizeHandle.onPress = Delegate.create(this, onResizeStart);
			__resizeHandle.onRelease = __resizeHandle.onReleaseOutside = Delegate.create(this, onResizeEnd);
		} else {
			__resizeHandle.removeMovieClip();
		}
		if(__closeable){
			attachMovie("windowCloseBtnSkin", "__closeBtn", 8);
			__closeBtn.onRelease = Delegate.create(this, onClose);
		} else {
			__closeBtn.removeMovieClip();
		}
		
		if(__enabled){
			_alpha = 100;
		} else {
			_alpha = __alphaDisabled;
		}
		
		__label.text = __labelText;
		__label.enabled = __enabled;
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
		__dragBar._width = __width;
		__dragBar._height = 20;
		__bg._width = __width;
		__bg._height = __height;
		__resizer.setSize(__width, __height);
		__closeBtn._x = __width - __closeBtn._width - 4;
		__closeBtn._y = 6;
		__label._x = 2;
		if(__closeable){
			__label.width = __closeBtn._x - 2;
		} else {
			__label.width = __width - 4;
		}
		__label.height = 22;
		__content._x = 2;
		__content._y = 22;
		__resizeHandle._x = __width - 10;
		__resizeHandle._y = __height - 10;
		__shadow.setSize(__width+2, __height);
		__shadow.move(-1, 2);
		drawMask();
		dispatchEvent({type:"size", target:this, width:__mask._width, height:__mask._height});
	}
	
	
	/**
		Static method used to create an instance of a Window on stage at run time.
				
		@param target the movie clip to which the window will be attached.
		@param id the instance name given to the new window attached.
		@param depth the depth at which to attach the new window.
		@param initObj (optional) an object containing any properties you want to assign to the component when it is created
		@return a reference to the new window attached.
		@example
		<pre>
		import com.bjc.controls.Window;
		var newWindow:Window = Window.create(_root, "myWindow", 0);
		</pre>
	*/
	public static function create(target:MovieClip, id:String, depth:Number, initObj:Object):Window {
		return Window(target.attachMovie("Window", id, depth, initObj));
	}
		
	

	
	
	
	
	
	
	
	private function doResize(Void):Void {
		var w = Math.max(60, _xmouse+5)
		var h = Math.max(60, _ymouse+5)
		setSize(w, h);
	}
	
	
	private function drawMask(Void):Void {
		__mask.clear();
		__mask.beginFill(0);
		__mask.moveTo(2, 22);
		__mask.lineTo(__width - 2, 22);
		__mask.lineTo(__width - 2, __height - 2);
		__mask.lineTo(2, __height - 2);
		__mask.lineTo(2, 22);
		__mask.endFill();
	}
	
	
	private function getContent(Void):Void {
		__content.attachMovie(__contentPath, "content", 0);
	}
	
	
	
	private function onClose(Void):Void {
		if(__enabled){
			if(__removeOnClose){
				var depth:Number = this.getDepth();
				if(depth < 0){
					depth = 0;
				}
				while(depth >= 1048575){
					depth--;
				}
				this.swapDepths(depth);
				dispatchEvent({type:"close", target:this});
				this.removeMovieClip();
			} else {
				dispatchEvent({type:"close", target:this});
			}				
		}
	}
	
	
	private function onDrag(Void):Void {
		if(__enabled && __draggable){
			if(_parent.getNextHighestDepth() != undefined){ 
				this.swapDepths(_parent.getNextHighestDepth());
			} else {
				this.swapDepths(1048575);
			}
			this.startDrag();
			__shadow.setSize(__width + 6);
			__shadow._alpha = 65;
			__shadow.move(-3, 5);
		}
	}
	
	
	private function onDrop(Void):Void {
		if(__draggable){
			this.stopDrag();
			__shadow.setSize(__width + 2);
			__shadow._alpha = 100;
			__shadow.move(-1, 2);
		}
		if(Selection.getFocus() != "" + this) Selection.setFocus(this);
	}
	
	
	private function onResizeEnd(Void):Void {
		delete onMouseMove;
		if(Selection.getFocus() != "" + this) Selection.setFocus(this);
	}
	
	
	private function onResizeStart(Void):Void {
		if(__enabled){
			this.swapDepths(_parent.getNextHighestDepth());
			onMouseMove = doResize;
		}
	}
	
	
	private function onKillFocus(newFocus:Object):Void {
		hideFocus();
		dispatchEvent({type:"killFocus", target:this, newfocus:newFocus});
	}
	
	
	private function onSetFocus(oldFocus:Object):Void {
		dispatchEvent({type:"focus", target:this, oldfocus:oldFocus});
		if(Key.isDown(9)){
			showFocus();
			dispatchEvent({type:"tabFocus", target:this, oldfocus:oldFocus});
		}
	}
	
	
	
	
	
	/**
		Sets the closable mode of the component. If true, a button will appear on the window allowing it to be closed.
	
		@example
		<pre>
		myWindow.closeable = true;
		</pre>
	*/
	[Inspectable (type="Boolean", defaultValue=false)]
	public function set closeable(b:Boolean) {
		__closeable = b;
		invalidate();
	}
	/**
		Gets the closable mode of the component.
	
		@example
		<pre>
		myVar = myWindow.closeable;
		</pre>
	*/
	public function get closeable():Boolean {
		return __closeable;
	}
	
	
	/**
		Returns a reference to the content attached into the window.
	
		@example
		<pre>
		myWindow.content.attachMovie("someAdditionalContent", "stuff", 0);
		</pre>
	*/
	public function get content():MovieClip {
		return __content.content;
	}
	
	
	/**
		Sets the linkage name of an exported symbol in the library. This will be attached inside the window.
	
		@example
		<pre>
		myWindow.contentPath = "responseForm";
		</pre>
	*/
	[Inspectable]
	public function set contentPath(path:String) {
		__contentPath = path;
		getContent();
	}
	/**
		Gets the linkage name of the content symbol. 
	
		@example
		<pre>
		myVar = myWindow.contentPath;
		</pre>
	*/
	public function get contentPath():String {
		return __contentPath;
	}
	
	
	/**
		Sets the resizable mode of the component. If true, handles will appear in the lower right corner of the window allowing the user to resize the window with the mouse.
	
		@example
		<pre>
		myWindow.resizable = true;
		</pre>
	*/
	[Inspectable (type="Boolean", defaultValue=false)]
	public function set resizable(b:Boolean) {
		__resizable = b;
		invalidate();
	}
	/**
		Gets the resizable mode of the component. 
	
		@example
		<pre>
		myVar = myWindow.resizable;
		</pre>
	*/
	public function get resizable():Boolean {
		return __resizable;
	}
	
	
	/**
		Sets the text to show in the title bar of the window.
	
		@example
		<pre>
		myWindow.text = "Response Form";
		</pre>
	*/
	[Inspectable (defaultValue="Window")]
	public function set title(txt:String) {
		__labelText = txt;
		__label.text = __labelText;
	}
	/**
		Gets the text showed in the title bar of the window.
	
		@example
		<pre>
		myVar = myWindow.text;
		</pre>
	*/
	public function get title():String {
		return __labelText;
	}
	
	/**
		Sets the removeOnClose mode of the component. If true, the component will be removed when the user clicks the close button in the upper right corner. If false, the window will only broadcast a "close" event and it is up to you to handle that event and implement whatever behavior you want.
	
		@example
		<pre>
		myWindow.removeOnClose = false;
		myWindow.closeHandler = function(){
			this._visible = false;
		}
		</pre>
	*/
	[Inspectable (type="Boolean", defaultValue=true)]
	public function set removeOnClose(b:Boolean) {
		__removeOnClose = b;
		invalidate();
	}
	/**
		Gets the removeOnClose mode of the component.
	
		@example
		<pre>
		myVar = myWindow.removeOnClose;
		</pre>
	*/
	public function get removeOnClose():Boolean {
		return __removeOnClose;
	}
	
	/**
		Determines if the window can be dragged by clicking on the title bar.
	
		@example
		<pre>
		myWindow.draggable = false;
		</pre>
	*/
	[Inspectable (type="Boolean", defaultValue=true)]
	public function set draggable(b:Boolean) {
		__draggable = b;
		invalidate();
	}
	/**
		Gets the the draggable mode of the component.
	
		@example
		<pre>
		myVar = myWindow.draggable;
		</pre>
	*/
	public function get draggable():Boolean {
		return __draggable;
	}
}