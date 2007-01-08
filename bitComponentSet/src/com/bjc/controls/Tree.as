import com.bjc.controls.TreeItem;
import com.bjc.core.LabelWrapper;
import com.bjc.resizers.Resizer;
import com.bjc.controls.VertScrollBar;
import mx.events.EventDispatcher;
import mx.utils.Delegate;

[IconFile ("icons/Tree.png")]

[Event("change")]

[Event("click")]

[Event("scroll")]

[Event("focus")]

[Event("killFocus")]

[Event("tabFocus")]

/**
* A tree component that displays an xml data provider. Each displayed node must have an attribute named "label".
* <BR><BR>
* Events:
* <BR><BR>
* <B>change</B> - Fired whenever the user changes the selected item of the component either by clicking a new item on the tree or using the cursor keys to move to a new item.
* <BR>
* <B>click</B> - Fired whenever the user clicks on an item in the tree, changing the currently selected item.
* <BR>
* <B>scroll</B> - Fired once each frame while tree is being scrolled.
* <BR>
* <B>focus</B> - Fired whenever the component receives focus.
* <BR>
* <B>killFocus</B> - Fired whenever the component loses focus.
* <BR>
* <B>tabFocus</B> - Fired whenever the component receives focus by pressing the TAB key.
* @author Beam Jive Consulting - www.beamjive.com
*/
class com.bjc.controls.Tree extends LabelWrapper {
 	private var clipParameters:Object = {nodeBGColor:1, highlightColor:1, indentSize:1, rowHeight:1, scrollBarWidth:1, selectedColor:1};
	private static var mergedClipParameters:Boolean = com.bjc.core.BJCComponent.mergeClipParameters(Tree.prototype.clipParameters, LabelWrapper.prototype.clipParameters);

	
	private var __background:Resizer;
	private var __dataProvider:XMLNode;
	private var __nodeBGColor:Number = 0xffffff;
	private var __highlightColor:Number = 0xeeeeee;
	private var __indentSize:Number = 15;
	private var __itemArray:Array;
	private var __keyListener:Object;
	private var __mask:MovieClip;
	private var __numRows:Number = 0;
	private var __rowHeight:Number = 20;
	private var __rowHolder:MovieClip;
	private var __rows:Array;
	private var __scrollBarWidth:Number = 16;
	private var __selectedColor:Number = 0xdddddd;
	private var __selectedIndex:Number = 0;
	private var __selectedNode:XMLNode;
	private var __vScroll:Number = 0;
	private var __vScrollBar:VertScrollBar;
	
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
	* @usage <pre>myTree.changeHandler = function(){
	* 	trace("I was changed.");
	* }</pre>
	*/
	public var changeHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myTree.clickHandler = function(){
	* 	trace("I was clicked.");
	* }</pre>
	*/
	public var clickHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myTree.scrollHandler = function(){
	* 	trace("Scrolling...");
	* }</pre>
	*/
	public var scrollHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myTree.focusHandler = function(){
	* 	trace("Set focus.");
	* }</pre>
	*/
	public var focusHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myTree.killFocusHandler = function(){
	* 	trace("Kill focus.");
	* }</pre>
	*/
	public var killFocusHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myTree.tabFocusHandler = function(){
	* 	trace("Tab focus.");
	* }</pre>
	*/
	public var tabFocusHandler:Function;
	
	
	public function Tree(Void) {
	}
	
	
	private function init(Void):Void {
		super.init();
		EventDispatcher.initialize(this);
		Mouse.addListener(this);
		focusEnabled = true;
		__rows = new Array();
		__rowHolder.setMask(__mask);
		__vScrollBar.disabledAlpha = 100;
		__vScrollBar.addEventListener("change", Delegate.create(this, onVScroll));
		__vScrollBar.addEventListener("focus", Delegate.create(this, onScrollFocus));
		makeDataProvider();
		draw();
	}
	
	
	private function createChildren(Void):Void {
		attachMovie("Resizer", "__background", 0);
		__background.skin = "listSkin";
		__background.margin = 5;
		createEmptyMovieClip("__rowHolder", 1);
		createEmptyMovieClip("__mask", 2);
		attachMovie("VertScrollBar", "__vScrollBar", 3);
		attachMovie("Resizer", "__focus", 1000);
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
		for(var i=0;i<__itemArray.length;i++){
			__itemArray[i].enabled = __enabled;
		}
		__vScrollBar.enabled = __enabled;
		size();
	}
	
	
	private function size(Void):Void {
		__height = Math.max(__height, __scrollBarWidth * 3);
		__focus.setSize(__width, __height);
		openNodes(__dataProvider.firstChild, 0);
		makeItemArray();
		drawMask();
		drawItems();
		drawScrollBar();
		displayItems();
	}


	/**
		Static method used to create an instance of a Tree on stage at run time.
				
		@param target the movie clip to which the tree will be attached.
		@param id the instance name given to the new tree attached.
		@param depth the depth at which to attach the new tree.
		@param initObj (optional) an object containing any properties you want to assign to the component when it is created
		@return a reference to the new tree attached.
		@example
		<pre>
		import com.bjc.controls.Tree;
		var newTree:Tree = Tree.create(_root, "myTree", 0);
		</pre>
	*/
	public static function create(target:MovieClip, id:String, depth:Number, initObj:Object):Tree {
		return Tree(target.attachMovie("Tree", id, depth, initObj));
	}
		
	




	private function click(evtObj:Object){
		if(Selection.getFocus() != "" + this) Selection.setFocus(this);
		selectedIndex = evtObj.target.index + __vScroll;
		__selectedNode = evtObj.target.node;
		dispatchEvent({type:"change", target:this});
		dispatchEvent({type:"click", target:this});
	}


	private function displayItems(Void):Void {
		for(var i=0;i<__numRows;i++){
			var row:TreeItem = __rows[i];
			setLabelProps(row);
			if(__itemArray[i + __vScroll] != undefined){
				if(typeof __itemArray[i + __vScroll] == "string"){
					__rows[i].text = __itemArray[i + __vScroll];
				} else {
					__rows[i].text = __itemArray[i + __vScroll].label;
				}
			}
			__rows[i].indent = __itemArray[i + __vScroll].indent;
			__rows[i].type = __itemArray[i + __vScroll].type;
			__rows[i].node = __itemArray[i + __vScroll].node;
			__rows[i].open = __itemArray[i + __vScroll].open;
			__rows[i].indentSize = __indentSize;
			
		}
 		showSelected();
	}
	

	private function drawItems(){
		__numRows = Math.ceil(__height / __rowHeight);
 		var numItems:Number = Math.min(__itemArray.length, __numRows);
		for(var i=__itemArray.length;i<__numRows;i++){
			__rows[i].removeMovieClip();
			__rows[i] = undefined;
		}
		for(var i=0;i<numItems;i++){
			if(__rows[i] == undefined){
				__rows[i] = __rowHolder.attachMovie("TreeItem", "row" + i, i);
			}
			__rows[i].index = i;
			__rows[i]._y = i * __rowHeight;
			if(__itemArray.length > Math.floor(__height / __rowHeight)){
				__rows[i].setSize(__width - __scrollBarWidth - 1, __rowHeight);
			} else {
				__rows[i].setSize(__width, __rowHeight);
			}
			__rows[i].addEventListener("click", this);
			__rows[i].addEventListener("open", this);
		}
	}


	private function drawMask(Void):Void {
		__background.setSize(__width, __height);
		__mask.clear();
		__mask.beginFill(0);
		__mask.moveTo(2, 2);
		__mask.lineTo(__width - 2, 2);
		__mask.lineTo(__width - 2, __height - 2);
		__mask.lineTo(2, __height - 2);
		__mask.lineTo(2, 2);
		__mask.endFill();
	}


	private function drawScrollBar(Void):Void {
		if(__itemArray.length > Math.floor(__height / __rowHeight)){
			__vScrollBar._visible = true;
			__vScrollBar.move(__width - __scrollBarWidth - 1, 1);
			__vScrollBar.setSize(__scrollBarWidth, __height - 2);
			__vScrollBar.thumbScale = Math.floor(__height / __rowHeight) / __itemArray.length;
			__vScrollBar.maximum = __itemArray.length - Math.floor(__height / __rowHeight);
		} else {
			__vScrollBar._visible = false;
			__vScroll = 0;
		}
	}


	private function getOpenItems(x:XMLNode):Void {
		var nodeObj:Object = new Object();
		nodeObj.label = x.attributes.label;
		nodeObj.indent = x.attributes.indent;
		nodeObj.open = x.attributes.open;
		nodeObj.node = x;
		if(x.hasChildNodes()){
			nodeObj.type = "folder";
		} else {
			nodeObj.type = "page";
		}
		__itemArray.push(nodeObj);
		if(x.attributes.open == "true"){
			var numChildren:Number = x.childNodes.length;
			for(var i=0;i<numChildren;i++){
				getOpenItems(x.childNodes[i]);
			}
		}
	}	


	private function makeDataProvider(Void):Void {
 		if(__dataProvider == undefined){
			__dataProvider = new XML();
 		}
	}


	private function makeItemArray(Void):Void  {
		__itemArray = new Array();
		getOpenItems(__dataProvider.firstChild);
	}
	

	private function onKeyPressed(Void):Void {
		if((Selection.getFocus() == "" + this) && __enabled && __keyEnabled){
			if(Key.getCode() == Key.UP && selectedIndex > 0){
				selectedIndex --;
				dispatchEvent({type:"change", target:this});
			} else if(Key.getCode() == Key.DOWN && selectedIndex < (__itemArray.length - 1)){
				if(selectedIndex == undefined){ 
					selectedIndex = 0;
				} else {
					selectedIndex ++;
				}
				dispatchEvent({type:"change", target:this});
			} else if(Key.getCode() == Key.RIGHT){
				if(__rows[__selectedIndex - __vScroll].type == "folder"){
					__rows[__selectedIndex - __vScroll].open = "false";
					__rows[__selectedIndex - __vScroll].onIconRelease();
				}
			} else if(Key.getCode() == Key.LEFT){
				if(__rows[__selectedIndex - __vScroll].type == "folder"){
					__rows[__selectedIndex - __vScroll].open = "true";
					__rows[__selectedIndex - __vScroll].onIconRelease();
				}
			}
		}
	}
	
	
	private function onMouseWheel(delta:Number):Void {
		if((Selection.getFocus() == "" + this) && __enabled && __vScrollBar._visible && (_xmouse > 0) && (_xmouse < __width) && (_ymouse > 0) && (_ymouse < __height)){
			__vScrollBar.value -= delta;
 			__vScroll = __vScrollBar.value;
			displayItems();
			dispatchEvent({type:"scroll", target:this});
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
	
	
	private function onVScroll(evtObj:Object):Void {
		__vScroll = Math.floor(__vScrollBar.value);
		displayItems();
		dispatchEvent({type:"scroll", target:this});
	}
	
	private function onScrollFocus(evtObj:Object):Void {
		if(Selection.getFocus() != "" + this) Selection.setFocus(this);
	}
	
	
	private function open(evtObj:Object):Void {
		if(evtObj.target.__index < __selectedIndex){
			var __parentNode:XMLNode = evtObj.target.__node;
			if(__parentNode.hasChildNodes()){
				var numChildren:Number = __parentNode.childNodes.length;
				if(__parentNode.attributes.open == "true"){
					__selectedIndex += numChildren;
				} else if(__parentNode.attributes.open == "false" && __selectedIndex > (evtObj.target.__index + numChildren)){
					__selectedIndex -= numChildren;
				} else {
					__selectedIndex = evtObj.target.__index;
				}
			}
		}
		invalidate();
		dispatchEvent({type:"click", target:this});
	}
	
	
	private function openNodes(x:XMLNode, indent:Number):Void {
		x.attributes.indent = indent;
		if(x.hasChildNodes()){
			if(x.attributes.open == undefined){
				x.attributes.open = "true";
			}
			var numChildren:Number = x.childNodes.length;
			for(var i=0;i<numChildren;i++){
				openNodes(x.childNodes[i], indent + 1);
			}
		}
	}


	private function scrollToSelection(Void):Void {
		var rowCheck:Number = Math.floor(__height / __rowHeight);
		if(__selectedIndex < __vScroll){
			__vScrollBar.value = __vScroll = __selectedIndex;
			displayItems();
		} else if((__selectedIndex - __vScroll) > rowCheck - 1){
			__vScrollBar.value = __vScroll = __selectedIndex - rowCheck + 1;
			displayItems();
		}
	}
	
	
	private function setLabelProps(row:TreeItem):Void {
		row.text = "";
		row.selectedColor = __selectedColor;
		row.nodeBGColor = __nodeBGColor;
		row.highlightColor = __highlightColor;
		row.enabled = __enabled;
		row.label.align = __align;
		row.label.embedFont = __embedFont;
		row.label.fontColor = __fontColor;
		row.label.fontFace = __fontFace;
		row.label.fontSize = __fontSize;
		row.label.html = __html;
		row.label.disabledColor = __disabledColor;
	}
	
	
	private function showSelected(){
		for(var i=0;i<__numRows;i++){
			__rows[i].selected = false;
		}
		if(__selectedIndex != undefined){
			//trace("SEL: "+ __selectedNode +", INDEX: "+ __rows[__selectedIndex - __vScroll].__node);
			__rows[__selectedIndex - __vScroll].selected = true;
			__selectedNode = __rows[__selectedIndex - __vScroll].__node;
		}
	}
	
	
	
	
	
	
	
	
	
	/**
		Sets the data provider of the component (an xml object). Each node that is to be displayed should contain an attribute named "label". If that node contains child nodes, you can also include an attribute named "open" which can be set to true or false, and will determine if that folder on the tree is open or not.
	
		@example
		<pre>
		myDP = new XML("<node label='Top' open='true'><subnode label='Some node'/></node>");
		myTree.dataProvider = myDP;
		</pre>
	*/
	public function set dataProvider(dp:XMLNode) {
		__dataProvider = dp;
		invalidate();
	}
	/**
		Gets the data provider of the component. 
	
		@example
		<pre>
		myVar = myTree.dataProvider;
		</pre>
	*/
	public function get dataProvider():XMLNode {
		return __dataProvider;
	}
	
	
	/**
		Sets the color to use when an item in the tree is rolled over.
				
		@example
		<pre>
		myTree.highlightColor = 0xcccccc;
		</pre>
	*/
	[Inspectable (type="Color", defaultValue="#eeeeee")]
	public function set highlightColor(col:Number) {
		__highlightColor = col;
		displayItems();
	}
	/**
		Gets the color used when an item in the tree is rolled over.
				
		@example
		<pre>
		myVar = myTree.highlightColor;
		</pre>
	*/
	public function get highlightColor():Number {
		return __highlightColor;
	}
	[Inspectable (type="Color", defaultValue="#ffffff")]
	public function set nodeBGColor(col:Number) {
		__nodeBGColor = col;
		displayItems();
	}
	public function get nodeBGColor():Number {
		return __nodeBGColor;
	}	
	
	
	/**
		Sets the distance in pixels that each new level of the tree will be indented.
	
		@example
		<pre>
		myTree.indent = 20;
		</pre>
	*/
	[Inspectable (defaultValue=15)]
	public function set indentSize(size:Number) {
		__indentSize = size;
		invalidate();
	}
	/**
		Gets the distance in pixels that each new level of the tree will be indented.
	
		@example
		<pre>
		myVar = myTree.indent;
		</pre>
	*/
	public function get indentSize():Number {
		return __indentSize;
	}

	
	/**
		Sets the height for the individual rows in the tree.
				
		@example
		<pre>
		myTree.rowHeight = 25;
		</pre>
	*/
	[Inspectable (defaultValue=20)]
	public function set rowHeight(h:Number) {
		__rowHeight = h;
		invalidate();
	}
	/**
		Gets the height of the individual rows in the tree.
				
		@example
		<pre>
		myVar = myTree.rowHeight;
		</pre>
	*/
	public function get rowHeight():Number {
		return __rowHeight;
	}
	
	/**
		Sets the current scroll value of the component.
	
		@example
		<pre>
		myTree.scroll = 10;
		</pre>
	*/
	public function set scroll(s:Number) {
		if(s > __vScrollBar.maximum){
			__vScroll = __vScrollBar.maximum;
		} else if(s < 0){
			__vScroll = 0;
		} else {
			__vScroll = s;
		}
		__vScrollBar.value = __vScroll;
 		invalidate();
	}
	/**
		Gets the current scroll value of the component.
	
		@example
		<pre>
		myVar = myTree.scroll;
		</pre>
	*/
	public function get scroll():Number {
		return __vScroll;
	}
	
	
	/**
		Sets the width of the scrollbar used in the tree (if needed)
				
		@example
		<pre>
		myTree.scrollBarWidth = 20;
		</pre>
	*/
	[Inspectable (defaultValue=16)]
	public function set scrollBarWidth(w:Number) {
		__scrollBarWidth = w;
		invalidate();
	}
	/**
		Gets the width of the scrollbar used in the tree
				
		@example
		<pre>
		myVar = myTree.scrollBarWidth;
		</pre>
	*/
	public function get scrollBarWidth():Number {
		return __scrollBarWidth;
	}
	
	
	/**
		Sets the color to use when an item in the tree is clicked on.
				
		@example
		<pre>
		myTree.selectedColor = 0xaaaaaa;
		</pre>
	*/
	[Inspectable (type="Color", defaultValue="#dddddd")]
	public function set selectedColor(col:Number) {
		__selectedColor = col;
		displayItems();
	}
	/**
		Gets the color used when an item in the tree is clicked on.
				
		@example
		<pre>
		myVar = myTree.selectedColor;
		</pre>
	*/
	public function get selectedColor():Number {
		return __selectedColor;
	}
	
	
	/**
		Sets the selected item.
				
		@example
		<pre>
		myTree.selectedIndex = 5;
		</pre>
	*/
	public function set selectedIndex(index:Number) {
		if(__selectedIndex != index){
			__selectedIndex = index;
			__selectedIndex = Math.max(0, __selectedIndex);
			__selectedIndex = Math.min(__itemArray.length - 1, __selectedIndex);
		}
		if(index == -1){
			__selectedIndex = undefined;
		}
 		scrollToSelection();
 		showSelected();
	}
	/**
		Gets the number of the currently selected item in the tree. 
				
		@example
		<pre>
		myVar = myTree.selectedIndex;
		</pre>
	*/
	public function get selectedIndex():Number {
		return __selectedIndex;
	}


	/**
		A reference to the currently selected xml node in the tree.
	
		@example
		<pre>
		trace(myTree.selectedNode.attributes.label);
		</pre>
	*/
	public function get selectedNode():XMLNode {
		return __selectedNode;
	}
}