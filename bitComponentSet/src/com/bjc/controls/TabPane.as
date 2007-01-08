import com.bjc.controls.Tab;
import com.bjc.core.LabelWrapper;
import com.bjc.resizers.Resizer;
import mx.utils.Delegate;
import mx.events.EventDispatcher;


[IconFile ("icons/TabPane.png")]

[Event("size")]

[Event("change")]

[Event("focus")]

[Event("killFocus")]

[Event("tabFocus")]

/**
* A tabbed pane component that allows you to have several pages of content and display any single one by clicking on the appriate tab.
* <BR><BR>
* Events:
* <BR><BR>
* <B>size</B> - Fired whenever the component is resized.
* <BR>
* <B>change</B> - Fired whenever the user changes the active tab.
* <BR>
* <B>focus</B> - Fired whenever the component receives focus.
* <BR>
* <B>killFocus</B> - Fired whenever the component loses focus.
* <BR>
* <B>tabFocus</B> - Fired whenever the component receives focus by pressing the TAB key.
* @author Beam Jive Consulting - www.beamjive.com
*/
class com.bjc.controls.TabPane extends LabelWrapper {
 	private var clipParameters:Object = {contents:1, labels:1, maxTabWidth:1, minTabWidth:1, tabAlign:1, tabHeight:1};
	static var mergedClipParameters:Boolean = com.bjc.core.BJCComponent.mergeClipParameters(TabPane.prototype.clipParameters, LabelWrapper.prototype.clipParameters);

	
	private var __background:Resizer;
	private var __contents:Array;
	private var __contentHolder:MovieClip;
	private var __contentPaths:Array;
	private var __depth:Number = 10;
	private var __keyListener:Object;
	private var __labels:Array;
	private var __labelParamsSet:Boolean = false;
	private var __mask:MovieClip;
	private var __maxTabWidth:Number = 150;
	private var __minTabWidth:Number = 50;
	private var __panes:Array;
	private var __selectedIndex:Number = 0;
	private var __tabAlign:String = "left";
	private var __tabHeight:Number = 20;
	

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
	* @usage <pre>myTabPane.changeHandler = function(){
	* 	trace("I was changed.");
	* }</pre>
	*/
	public var changeHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myTabPane.sizeHandler = function(){
	* 	trace("I was resized.");
	* }</pre>
	*/
	public var sizeHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myTabPane.focusHandler = function(){
	* 	trace("Set focus.");
	* }</pre>
	*/
	public var focusHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myTabPane.killFocusHandler = function(){
	* 	trace("Kill focus.");
	* }</pre>
	*/
	public var killFocusHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myTabPane.tabFocusHandler = function(){
	* 	trace("Tab focus.");
	* }</pre>
	*/
	public var tabFocusHandler:Function;
	private var dispatchEvent:Function;
	private var dispatchQueue:Function;
	
	
	public function TabPane(Void) {
	}
	
	
	private function init(Void):Void {
		super.init();
		EventDispatcher.initialize(this);
		focusEnabled = true;
		__contents = new Array();
		__panes = new Array();
		__contentHolder.setMask(__mask);
		__contentHolder._x = 5;
		__contentHolder._y = __tabHeight + 5;
		__mask._x = 5;
		__mask._y = __tabHeight + 5;
		draw();
	}
	
	
	private function createChildren(Void):Void {
		attachMovie("Resizer", "__background", 0);
		__background.skin = "tabPaneSkin";
		createEmptyMovieClip("__contentHolder", 1);
		createEmptyMovieClip("__mask", 2);
		attachMovie("Resizer", "__focus", 100);
		__focus.skin = "focusSkin";
		__focus.margin = 5;
		__focus._visible = false;
		__mask.beginFill(0);
		__mask.lineTo(100, 0);
		__mask.lineTo(100, 100);
		__mask.lineTo(0, 100);
		__mask.lineTo(0, 0);
		__mask.endFill();
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
		if(__labelParamsSet){
			setLabels();
		}
		size();
	}
	
	
	private function size(Void):Void {
		__focus.setSize(__width, __height);
		__background._y = __tabHeight;
		__background.setSize(__width, __height - __tabHeight);
		
		__mask._width = __width - 10;
		__mask._height = __height - __tabHeight - 10;
		
		var tabWidth:Number = Math.min(__width / __panes.length, __width / 2);
		if(tabWidth > __maxTabWidth) tabWidth = __maxTabWidth;
		for(var i=0;i<__panes.length;i++){
			var tab:Tab = __panes[i].tab;
			if(__tabAlign == "center"){
				tab.move(__width/2 - __panes.length*tabWidth/2 + i*tabWidth, 0);
			} else if(__tabAlign == "right"){
				tab.move(__width - __panes.length*tabWidth + i*tabWidth, 0);
			} else {
				tab.move(i*tabWidth, 0);
			}
			tab.width = tabWidth;
			tab.height = __tabHeight;
			tab.selected = (__selectedIndex == i);
			setTabProps(tab);
			
 			__panes[i].content._parent._visible = tab.selected;
		}
		dispatchEvent({type:"size", target:this});
	}
	
	
	public function setSize(w:Number, h:Number):Void {
		super.setSize(Math.max(w, __minTabWidth * __panes.length), h);
	}
	
	
	/**
		Static method used to create an instance of a TabPane on stage at run time.
				
		@param target the movie clip to which the tab pane will be attached.
		@param id the instance name given to the new tab pane attached.
		@param depth the depth at which to attach the new tab pane.
		@param initObj (optional) an object containing any properties you want to assign to the component when it is created
		@return a reference to the new tab pane attached.
		@example
		<pre>
		import com.bjc.controls.TabPane;
		var newTabPane:TabPane = TabPane.create(_root, "myTabPane", 0);
		</pre>
	*/
	public static function create(target:MovieClip, id:String, depth:Number, initObj:Object):TabPane {
		return TabPane(target.attachMovie("TabPane", id, depth, initObj));
	}
		
	

	
	
	
	
	
	
	/**
		Adds a new tab to the tabpane. Tabs are sized proportionately to the width of the tabpane. i.e. if the width is 200 and there are 5 tabs, each tab will be 40. If adding a new tab would cause the tab width to be less than minimum, the new tab will not be added.

	
		@param title a string that will be displayed in the new tab
		@param contentPath the linkage name of a movie clip in the library to attach in this section, or the url of an external swf or jpg to load in.
		@param icon the linkage name of a movie clip containing a graphic to be used as an icon for the tab (optional).
		@return nothing
		@example
		<pre>
		myTabPane.addTab("Section One", "firstSectionMC");
		</pre>
	*/
	public function addTab(title:String, contentPath:String, icon:String):Boolean {
		var newTab:Object = makeNewTab(title, contentPath, icon);
		if(newTab){
			__panes.push(newTab);
			invalidate();
			return true;
		} else {
			return false;
		}
	}
	
	
	/**
		Adds a new tab to the tabpane at the specified position. Tabs are sized proportionately to the width of the tabpane. i.e. if the width is 200 and there are 5 tabs, each tab will be 40. If adding a new tab would cause the tab width to be less than minimum, the new tab will not be added.
	
		@param title a string that will be displayed in the new tab
		@param contentPath the linkage name of a movie clip in the library to attach in this section, or the url of an external swf or jpg to load in.
		@index the position (zero-indexed) to insert the new tab
		@param icon the linkage name of a movie clip containing a graphic to be used as an icon for the tab (optional).
		@return nothing
		@example
		<pre>
		myTabPane.addTabAt("Section One", "firstSectionMC", 3);
		</pre>
	*/
	public function addTabAt(title:String, contentPath:String, index:Number, icon:String):Boolean {
		var newTab:Object = makeNewTab(title, contentPath, icon);
		if(newTab){
			__panes.splice(index, 0, newTab);
			invalidate();
			return true;
		} else {
			return false;
		}
	}
	
	
	private function click(evtObj:Object):Void {
		__selectedIndex = getIndex(evtObj.target);
		invalidate();
		if(Selection.getFocus() != "" + this) Selection.setFocus(this);
		dispatchEvent({type:"change", target:this});
	}
	
	
	private function getIndex(tab:Tab):Number {
		for(var i=0;i<__panes.length;i++){
			if(__panes[i].tab == tab){
				return i;
			}
		}
		return -1;
	}
	
	
	private function makeNewTab(title:String, contentPath:String, icon:String):Object {
		var tabNum:Number = __panes.length;
		
		if(__width / (tabNum + 1) < __minTabWidth){
			return false;
		}
		var tab:Tab = Tab(attachMovie("Tab", "tab" + __depth, __depth));
		tab.text = title;
		tab.icon = icon;
		tab._visible = false;
		tab.addEventListener("click", this);
		tab.draw();
		
		var holder:MovieClip = __contentHolder.createEmptyMovieClip("content" + __depth, __depth);
		__depth++;
		var content:MovieClip = holder.attachMovie(contentPath, "content", 0);
		if(content == undefined){
			content = holder.createEmptyMovieClip("content", 0);
			content.loadMovie(contentPath);
		}
		holder._visible = false;
		return {tab:tab, content:content};
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
			__keyListener.onKeyUp = Delegate.create(this, onKeyPressed);
			Key.addListener(__keyListener);
		}
		dispatchEvent({type:"focus", target:this, oldfocus:oldFocus});
		if(Key.isDown(9)){
			showFocus();
			dispatchEvent({type:"tabFocus", target:this, oldfocus:oldFocus});
		}
	}
	
	
	/**
		Removes all tabs from the tabpane
	
		@return nothing
		@example
		<pre>
		myTabPane.removeAll();
		</pre>
	*/
	public function removeAll(Void):Void {
		for(var i=__panes.length-1;i>=0;i--){
			removeTabAt(i);
		}
	}
	
	
	/**
		Removes the tab at the specified index
	
		@param index the number of the tab (zero-indexed) to remove
		@return nothing
		@example
		<pre>
		myTabPane.removeTab(4);
		</pre>
	*/
	public function removeTabAt(index:Number):Void {
		var pane:Object = __panes[index];
		pane.tab.removeMovieClip();
		pane.content.removeMovieClip();
		__panes.splice(index, 1);
		invalidate();
	}
	
	
	private function setTabProps(tab:Tab):Void {
		tab.enabled = __enabled;
		tab._visible = true;
		tab.label.align = __align;
		tab.label.disabledColor = __disabledColor;
		tab.label.embedFont = __embedFont;
		tab.label.fontColor = __fontColor;
		tab.label.fontFace = __fontFace;
		tab.label.fontSize = __fontSize;
		tab.label.html = __html;
	}
	
	
	private function setLabels(Void):Void {
		removeAll();
		for(var i=0;i<__labels.length;i++){
			addTab(__labels[i], __contentPaths[i]);
		}
		__labelParamsSet = false;
	}
	
	
	
	
	/**
		An array containing references to the attached movie clip in each tab section.
	
		@example
		<pre>
		myTabPane.content[0].addEventListener("click", this);
		// this assumes that the content in tab zero is a component which broadcasts a click event
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
		Sets the maximum width of a tab. Tabs are sized proportionately to the width of the tabpane. i.e. if the width is 200 and there are 5 tabs, each tab will be 40. If adding a new tab would cause the tab width to be less than minimum, the new tab will not be added.
	
		@example
		<pre>
		myTabPane.maxTabWidth = 100;
		</pre>
	*/
	[Inspectable (defaultValue=150)]
	public function set maxTabWidth(max:Number) {
		__maxTabWidth = max;
		invalidate();
	}
	/**
		Gets the maximum width of a tab. 
	
		@example
		<pre>
		myVar = myTabPane.maxTabWidth;
		</pre>
	*/
	public function get maxTabWidth():Number {
		return __maxTabWidth;
	}
	
	/**
		Sets the minimum width of a tab. Tabs are sized proportionately to the width of the tabpane. i.e. if the width is 200 and there are 5 tabs, each tab will be 40. If adding a new tab would cause the tab width to be less than minimum, the new tab will not be added.
	
		@example
		<pre>
		myTabPane.minTabWidth = 50;
		</pre>
	*/
	[Inspectable (defaultValue=50)]
	public function set minTabWidth(min:Number) {
		__minTabWidth = min;
		__width = Math.max(__width, __panes.length * __minTabWidth);
		invalidate();
	}
	/**
		Gets the minimum width of a tab. 
	
		@example
		<pre>
		myVar = myTabPane.minTabWidth;
		</pre>
	*/
	public function get minTabWidth():Number {
		return __minTabWidth;
	}
	
	
	/**
		Selects the specified tab.
	
		@example
		<pre>
		myTab.selectedIndex = 2;
		</pre>
	*/
	public function set selectedIndex(index:Number) {
		if(__selectedIndex != index){
			__selectedIndex = index;
			invalidate();
		}
	}
	/**
		Gets the selected tab number.
	
		@example
		<pre>
		myVar = myTab.selectedIndex;
		</pre>
	*/
	public function get selectedIndex():Number {
		return __selectedIndex;
	}
	
	/**
		Sets the align of the tabs.
	
		@example
		<pre>
		myTab.tabAlign = "right";
		</pre>
	*/
	[Inspectable (enumeration="left,center,right", defaultValue="left")]
	public function set tabAlign(a:String) {
		__tabAlign = a;
		invalidate();
	}
	/**
		Gets the align of the tabs.
	
		@example
		<pre>
		myVar = myTab.tabAlign;
		</pre>
	*/
	public function get tabAlign():String {
		return __tabAlign;
	}
	
	/**
		Sets the height of the tab, usually this would be based on the skin you use for the tabs.
	
		@example
		<pre>
		myTab.tabHeight = 25;
		</pre>
	*/
	[Inspectable (defaultValue=20)]
	public function set tabHeight(h:Number) {
		__tabHeight = h;
		invalidate();
	}
	/**
		Gets the height of the tab.
	
		@example
		<pre>
		myVar = myTab.tabHeight;
		</pre>
	*/
	public function get tabHeight():Number {
		return __tabHeight;
	}
}