import com.bjc.controls.AccordionHeader;
import com.bjc.core.LabelWrapper;
import com.bjc.resizers.Resizer;
import mx.events.EventDispatcher;
import mx.utils.Delegate;

[IconFile ("icons/Accordion.png")]

[Event("change")]

[Event("focus")]

[Event("killFocus")]

[Event("tabFocus")]


/**
* A multi-sectioned accordion component. A movie clip can be attached inside each section.
* <BR><BR>
* Events:
* <BR><BR>
* <B>change</B> - Fired whenever the active section of the accordion is changed by the user clicking on one of the headers.
* <BR>
* <B>focus</B> - Fired whenever the component receives focus.
* <BR>
* <B>killFocus</B> - Fired whenever the component loses focus.
* <BR>
* <B>tabFocus</B> - Fired whenever the component receives focus by pressing the TAB key.
* @author Beam Jive Consulting - www.beamjive.com
*/
class com.bjc.controls.Accordion extends LabelWrapper {
	private var clipParameters:Object = {autoSizeContents:1, contents:1, labels:1, icons:1};
	private static var mergedClipParameters:Boolean = com.bjc.core.BJCComponent.mergeClipParameters(Accordion.prototype.clipParameters, LabelWrapper.prototype.clipParameters);

	
	private var __autoSizeContents:Boolean = false;
	private var __background:Resizer;
	private var __contentPaths:Array;
	private var __contents:Array;
	private var __contentHolder:MovieClip;
	private var __depth:Number = 10;
	private var __headerHeight:Number = 22;
	private var __icons:Array;
	private var __keyListener:Object;
	private var __labels:Array;
	private var __labelParamsSet:Boolean = false;
	private var __mask:MovieClip;
	private var __panes:Array;
	private var __selectedIndex:Number = 0;
	
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
	* @usage <pre>myAccord.changeHandler = function(){
	* 	trace("section changed.");
	* }</pre>
	*/
	public var changeHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myAccord.focusHandler = function(){
	* 	trace("Set focus.");
	* }</pre>
	*/
	public var focusHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myAccord.killFocusHandler = function(){
	* 	trace("Kill focus.");
	* }</pre>
	*/
	public var killFocusHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myAccord.tabFocusHandler = function(){
	* 	trace("Tab focus.");
	* }</pre>
	*/
	public var tabFocusHandler:Function;
	private var dispatchEvent:Function;
	private var dispatchQueue:Function;


	public function Accordion(Void) {
	}
	
	
	private function init(Void):Void {
		super.init();
		EventDispatcher.initialize(this);
		focusEnabled = true;
		__contents = new Array();
		__panes = new Array();
		__contentHolder.setMask(__mask);
		__contentHolder._x = 2;
		__mask._x = 2;
		__mask._y = 2;
		draw();
	}
	
	
	private function createChildren(Void):Void {
		attachMovie("Resizer", "__background", 0);
		__background.skin = "accordionSkin";
		createEmptyMovieClip("__contentHolder", 1);
		createEmptyMovieClip("__mask", 2);
		__mask.beginFill(0);
		__mask.lineTo(100, 0);
		__mask.lineTo(100, 100);
		__mask.lineTo(0, 100);
		__mask.lineTo(0, 0);
		__mask.endFill();
		
		attachMovie("Resizer", "__focus", 1000);
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
		if(__labelParamsSet){
			setLabels();
		}
		size();
	}
	
	
	private function size(Void):Void {
		__background.setSize(__width, __height);
		__focus.setSize(__width, __height);
		
		__mask._width = __width - 4;
		__mask._height = __height - 4;
		
		var availableHeight:Number = __height - __panes.length * __headerHeight;
		var ypos:Number = 0;
		for(var i=0;i<__panes.length;i++){
			var header:AccordionHeader = __panes[i].header;
			header.move(1, ypos);
			header.setSize(__width - 2, __headerHeight);
			header.selected = (__selectedIndex == i);
			setHeaderProps(header);
			
 			__panes[i].content._visible = header.selected;
 			__panes[i].content._y = ypos + __headerHeight;
			if(__autoSizeContents) {
	 			__panes[i].content.setSize(__width - 4, __height - __headerHeight * __panes.length);
	 		}
 			
 			if(header.selected){
 				ypos += availableHeight;
 			}
 			ypos += __headerHeight;
		}
	}
	
	
	/**
		Static method used to create an instance of an Accordion on stage at run time.
				
		@param target the movie clip to which the accordion will be attached.
		@param id the instance name given to the new accordion attached.
		@param depth the depth at which to attach the new accordion.
		@param initObj (optional) an object containing any properties you want to assign to the component when it is created
		@return a reference to the new accordion attached.
		@example
		<pre>
		import com.bjc.controls.Accordion;
		var newAccord:Accordion = Accordion.create(_root, "myAccord", 0);
		</pre>
	*/
	public static function create(target:MovieClip, id:String, depth:Number, initObj:Object):Accordion {
		return Accordion(target.attachMovie("Accordion", id, depth, initObj));
	}
	

	/**
		Adds a new section to the accordion
	
		@param title a string that will be displayed in the section header
		@param contentPath the linkage name of a movie clip in the library to attach in this section, or the url of an external swf or jpg to load in.
		@param icon the linkage name of a movie clip in the library to set as header icon.
		@return nothing
		@usage
		<pre>
		accordion.addSection(title:String, contentPath:String, icon:String):Void
		</pre>
		@example
		<pre>
		myAccord.addSection("Section One", "firstSectionMC", "");
		</pre>
	*/
	public function addSection(title:String, contentPath:String, icon:String):Void {
		var newHeader:Object = makeNewHeader(title, contentPath, icon);
		__panes.push(newHeader);
		invalidate();
	}
	
	
	/**
		Adds a new section to the accordion at the specified position
	
		@param title a string that will be displayed in the section header
		@param contentPath the linkage name of a movie clip in the library to attach in this section, or the url of an external swf or jpg to load in.
		@param icon the linkage name of a movie clip in the library to set as header icon.
		@index the position (zero-indexed) to insert the new section
		@return nothing
		@example
		<pre>
		myAccord.addSectionAt("Section One", "firstSectionMC", "myIcon", 3);
		</pre>
	*/
	public function addSectionAt(title:String, contentPath:String, icon:String, index:Number):Void {
		var newHeader:Object = makeNewHeader(title, contentPath, icon);
		__panes.splice(index, 0, newHeader);
		invalidate();
	}
	
	
	private function click(evtObj:Object):Void {
		__selectedIndex = getIndex(evtObj.target);
		invalidate();
		if(Selection.getFocus() != "" + this) Selection.setFocus(this);
		dispatchEvent({type:"change", target:this});
	}
	
	
	private function getIndex(header:AccordionHeader):Number {
		for(var i=0;i<__panes.length;i++){
			if(__panes[i].header == header){
				return i;
			}
		}
		return -1;
	}
	
	
	private function makeNewHeader(title:String, contentPath:String, icon:String):Object {
		var headerNum:Number = __panes.length;
		
		var header:AccordionHeader = AccordionHeader(attachMovie("AccordionHeader", "header" + __depth, __depth));
		header.text = title;
		header._visible = false;
		header.addEventListener("click", this);
		header.icon = icon;
		header.draw();
		
		var content:MovieClip = __contentHolder.attachMovie(contentPath, "content" + __depth, __depth)
// 		content._visible = false;
		if(content == undefined){
			content = __contentHolder.createEmptyMovieClip("content" + __depth, __depth);
			content.loadMovie(contentPath);
		}
		__depth++;

		
		return {header:header, content:content, icon:header.icon};
	}
		
		
	private function onKeyPressed(Void):Void {
		if((Selection.getFocus() == "" + this) && __enabled && __keyEnabled){
			if(Key.getCode() == Key.LEFT || Key.getCode() == Key.UP){
				if(__selectedIndex > 0){
					selectedIndex--;
				}
			} else if(Key.getCode() == Key.RIGHT || Key.getCode() == Key.DOWN){
				if(__selectedIndex < __panes.length - 1){
					selectedIndex++;
				}
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
			Key.addListener(__keyListener);
		}
		dispatchEvent({type:"focus", target:this, oldfocus:oldFocus});
		if(Key.isDown(9)){
			showFocus();
			dispatchEvent({type:"tabFocus", target:this, oldfocus:oldFocus});
		}
	}
	
	
	/**
		Removes all sections from the accordion
	
		@return nothing
		@example
		<pre>
		myAccord.removeAll();
		</pre>
	*/
	public function removeAll(Void):Void {
		for(var i=__panes.length-1;i>=0;i--){
			removeSectionAt(i);
		}
	}
	
	
	/**
		Removes the section at the specified index
	
		@param index the number of the section (zero-indexed) to remove
		@return nothing
		@example
		<pre>
		myAccord.removeSection(4);
		</pre>
	*/
	public function removeSectionAt(index:Number):Void {
		var pane:Object = __panes[index];
		pane.header.removeMovieClip();
		pane.content.removeMovieClip();
		__panes.splice(index, 1);
		invalidate();
	}
	
	
	private function setHeaderProps(header:AccordionHeader):Void {
		header.enabled = __enabled;
		header._visible = true;
		header.label.align = __align;
		header.label.embedFont = __embedFont;
		header.label.fontColor = __fontColor;
		header.label.fontFace = __fontFace;
		header.label.fontSize = __fontSize;
		header.label.html = __html;
		header.label.disabledColor = __disabledColor;
	}


	private function setLabels(Void):Void {
		removeAll();
		for(var i=0;i<__labels.length;i++){
			addSection(__labels[i], __contentPaths[i], __icons[i]);
		}
		__labelParamsSet = false;
	}
	
	/**
		Sets the autoSizeContent mode. If true, each content clip will be sized to the available space. Content clip must support a setSize(w ,h) method.
	
		@example
		<pre>
		myAccord.autoSizeContents = true;
		</pre>
	*/
	[Inspectable (type="Boolean", defaultValue=false)]
	public function set autoSizeContents(b:Boolean) {
		__autoSizeContents = b;
		invalidate();
	}
	/**
		Gets the autoSizeContent mode. 
	
		@example
		<pre>
		myVar = myAccord.autoSizeContents;
		</pre>
	*/
	public function get autoSizeContents():Boolean {
		return __autoSizeContents;
	}

	/**
		An array containing references to the attached movie clip in each section.
	
		@example
		<pre>
		myAccord.content[0].addEventListener("click", this);
		// this assumes that the content in section zero is a component which broadcasts a click event
		</pre>
	*/
	public function get content():Array {
		var result:Array = new Array();
		for(var i=0;i<__panes.length;i++){
			result.push(__panes[i].content);
		}
		return result;
	}



	/**
		@exclude
		for inspector panel settings only
	*/
	[Inspectable (type="Array")]
	public function set contents(c:Array) {
		__contentPaths = c;
		invalidate();
	}
	/**
		@exclude
		for inspector panel settings only
	*/
	public function get contents():Array {
		return __contentPaths;
	}
	
	
	
	
	/**
		@exclude
		for inspector panel settings only
	*/
	[Inspectable (type="Array")]
	public function set labels(labs:Array) {
		__labels = labs;
		__labelParamsSet = true;
		invalidate();
	}
	/**
		@exclude
		for inspector panel settings only
	*/
	public function get labels():Array {
		return __labels;
	}
	
	
	/**
		@exclude
		for inspector panel settings only
	*/
	[Inspectable (type="Array")]
	public function set icons(i:Array) {
		__icons = i;
		invalidate();
	}
	/**
		@exclude
		for inspector panel settings only
	*/
	public function get icons():Array {
		return __icons;
	}
	
	
	/**
		Selects the specified section
	
		@example
		<pre>
		myAccord.selectedIndex = 2;
		</pre>
	*/
	public function set selectedIndex(index:Number) {
		if(__selectedIndex != index){
			__selectedIndex = index;
			invalidate();
		}
	}
	/**
		Returns the number of the currently selected section
	
		@example
		<pre>
		myVar = myAccord.selectedIndex;
		</pre>
	*/
	public function get selectedIndex():Number {
		return __selectedIndex;
	}
}