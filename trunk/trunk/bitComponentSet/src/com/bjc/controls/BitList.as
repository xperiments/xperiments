import com.bjc.controls.ListItem;
import com.bjc.core.LabelWrapper;
import com.bjc.resizers.Resizer;
import com.bjc.controls.VertScrollBar;
import mx.events.EventDispatcher;
import mx.utils.Delegate;


[IconFile ("icons/List.png")]

[Event("change")]

[Event("click")]

[Event("focus")]

[Event("killFocus")]

[Event("tabFocus")]

[Event("itemRollOver")]

[Event("itemRollOut")]

/**
* A list component for showing a number of values and allowing the user to choose one.
* <BR><BR>
* Events:
* <BR><BR>
* <B>change</B> - Fired whenever the user changes the selected item of the component either by clicking a new item on the list or using the cursor keys to move to a new item.
* <BR>
* <B>click</B> - Fired whenever the user clicks on an item in the list, changing the currently selected item.
* <BR>
* <B>focus</B> - Fired whenever the component receives focus.
* <BR>
* <B>killFocus</B> - Fired whenever the component loses focus.
* <BR>
* <B>tabFocus</B> - Fired whenever the component receives focus by pressing the TAB key.
* <BR>
* <B>itemRollOver</B> - Fired whenever the user rolls over on an item in the list.
* <BR>
* <B>itemRollOut</B> - Fired whenever the user rolls off an item in the list.
* @author Beam Jive Consulting - www.beamjive.com
*/
class com.bjc.controls.BitList extends LabelWrapper {
 	private var clipParameters:Object = {highlightColor:1, highlightTextColor:1, rowHeight:1, scrollBarWidth:1, selectedColor:1, selectedTextColor:1};
	private static var mergedClipParameters:Boolean = com.bjc.core.BJCComponent.mergeClipParameters(BitList.prototype.clipParameters, LabelWrapper.prototype.clipParameters);

	
	private var __background:Resizer;
	private var __data:Array;
	private var __dataProvider:Array;
	private var __highlightColor:Number = 0xeeeeee;
	private var __highlightTextColor:Number = 0x000000;
	private var __keyListener:Object;
	private var __labelParamsSet:Boolean = false;
	private var __labels:Array;
	private var __mask:MovieClip;
	private var __numRows:Number = 0;
	private var __rowHeight:Number = 20;
	private var __rowHolder:MovieClip;
	private var __rows:Array;
	private var __scrollBarWidth:Number = 16;
	private var __selectedColor:Number = 0xdddddd;
	private var __selectedTextColor:Number = 0x000000;
	private var __selectedIndex:Number = 0;
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
	* @usage <pre>myList.changeHandler = function(){
	* 	trace("I was changed.");
	* }</pre>
	*/
	public var changeHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myList.clickHandler = function(){
	* 	trace("I was clicked.");
	* }</pre>
	*/
	public var clickHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myList.focusHandler = function(){
	* 	trace("Set focus.");
	* }</pre>
	*/
	public var focusHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myList.killFocusHandler = function(){
	* 	trace("Kill focus.");
	* }</pre>
	*/
	public var killFocusHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myList.tabFocusHandler = function(){
	* 	trace("Tab focus.");
	* }</pre>
	*/
	public var tabFocusHandler:Function;
	
	
	
	public function BitList(Void) {
	}
	
	
	private function init(Void):Void {
		super.init();
		EventDispatcher.initialize(this);
		Mouse.addListener(this);
		focusEnabled = true;		
		__rows = new Array();
		__rowHolder.setMask(__mask);
		__vScrollBar.disabledAlpha = 100;
		__vScrollBar.minimum = 0;
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
		
		attachMovie("Resizer", "__focus", 4);
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
		if(__labelParamsSet){
			setLabels();
		}
		__vScrollBar.enabled = __enabled;
		size();
	}
	
	
	private function size(Void):Void {
		__height = Math.max(__height, __scrollBarWidth * 3);
		drawMask();
		drawItems();
		drawScrollBar();
		displayItems();
	}
	
	
	/**
		Static method used to create an instance of a List on stage at run time.
				
		@param target the movie clip to which the list will be attached.
		@param id the instance name given to the new list attached.
		@param depth the depth at which to attach the new list.
		@param initObj (optional) an object containing any properties you want to assign to the component when it is created
		@return a reference to the new list attached.
		@example
		<pre>
		import com.bjc.controls.BitList;
		var newList:BitList = BitList.create(_root, "myList", 0);
		</pre>
	*/
	public static function create(target:MovieClip, id:String, depth:Number, initObj:Object):BitList {
		return BitList(target.attachMovie("BitList", id, depth, initObj));
	}
		
	

	
	
	
	
	
	/**
		Adds a new item to the list, tacking it on to the end of the list.
	
		@param item an object containing minimally a parameter called label. This would be the string displayed in the list. The object can also contain any other properties, usually stored in a data property. Item can also be a simple string itself.
		@return nothing
		@example
		<pre>
		// using an object
		myList.addItem({label:"First item", data:100});
		// using a string
		myList.addItem("Second Item");
		</pre>
	*/
	public function addItem(item:Object):Void {
		__dataProvider.push(item);
		scrollToSelection();
		invalidate();
	}
	
	
	/**
		Adds a new item to the list, placing it in the position specified.
	
		@param item an object containing minimally a parameter called label. This would be the string displayed in the list. The object can also contain any other properties, usually stored in a data property. Item can also be a simple string itself.
		@param index the position at which to place the item
		@return nothing
		@example
		<pre>
		// using an object
		myList.addItem({label:"First item", data:100}, 3);
		// using a string
		myList.addItem("Second Item", 4);
		</pre>
	*/
	public function addItemAt(item:Object, index:Number):Void {
		__dataProvider.splice(index, 0, item);
		if(index == __selectedIndex){
			selectedIndex++;
		}
		invalidate();
	}


	private function click(evtObj:Object){
		if(Selection.getFocus() != "" + this) Selection.setFocus(this);
		selectedIndex = evtObj.target.index + __vScroll;
		dispatchEvent({type:"change", target:this});
		dispatchEvent({type:"click", target:this});
	}
	
	
	private function displayItems(Void):Void {
		for(var i=0;i<__numRows;i++){
			var row:ListItem = __rows[i];
			setLabelProps(row);
			if(__dataProvider[i + __vScroll] != undefined){
				if(typeof __dataProvider[i + __vScroll] == "string"){
					__rows[i].text = __dataProvider[i + __vScroll];
				} else {
					/* TODO - make labelfield property */
					__rows[i].text = __dataProvider[i + __vScroll].label;
				}
 				__rows[i].draw();
			}
		}
 		showSelected();
	}
	
	
	private function drawItems(){
		__numRows = Math.ceil(__height / __rowHeight);
		var numItems:Number = Math.min(__dataProvider.length, __numRows);
		for(var i=0;i<__numRows;i++){
			__rows[i].removeMovieClip();
		}
		for(var i=0;i<numItems;i++){
			__rows[i] = __rowHolder.attachMovie("ListItem", "row" + i, i);
			__rows[i].index = i;
			__rows[i]._y = i * __rowHeight;
			if(__dataProvider.length > Math.floor(__height / __rowHeight)){
				__rows[i].setSize(__width - __scrollBarWidth - 1, __rowHeight);
			} else {
				__rows[i].setSize(__width, __rowHeight);
			}
			__rows[i].addEventListener("click", this);
			__rows[i].addEventListener("itemRollOver", this);
			__rows[i].addEventListener("itemRollOut", this);
		}
	}
	
	
	private function drawMask(Void):Void {
		__background.setSize(__width, __height);
		__focus.setSize(__width, __height);
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
		if(__dataProvider.length > Math.floor(__height / __rowHeight)){
			__vScrollBar._visible = true;
			__vScrollBar.move(__width - __scrollBarWidth - 1, 1);
			__vScrollBar.setSize(__scrollBarWidth, __height - 2);
			__vScrollBar.thumbScale = Math.floor(__height / __rowHeight) / __dataProvider.length;
			__vScrollBar.maximum = __dataProvider.length - Math.floor(__height / __rowHeight);
			__vScrollBar.pageSize = Math.floor(__height / __rowHeight);
		} else {
			__vScrollBar._visible = false;
			__vScroll = 0;
		}
	}
	
	private function itemRollOut(evtObj:Object):Void {
		dispatchEvent({type:"itemRollOut", target:this, index:evtObj.index + __vScroll});
	}	
	
	
	private function itemRollOver(evtObj:Object):Void {
		dispatchEvent({type:"itemRollOver", target:this, index:evtObj.index + __vScroll});
	}
	
	
	private function makeDataProvider(Void):Void {
 		if(__dataProvider == undefined){
			__dataProvider = new Array();
 		}
	}
	
	
	private function onKeyPressed(Void):Void {
		if((Selection.getFocus() == "" + this) && __enabled && __keyEnabled){
			if(Key.getCode() == Key.UP && selectedIndex > 0){
				selectedIndex --;
				dispatchEvent({type:"change", target:this});
			} else if(Key.getCode() == Key.DOWN){
				if(selectedIndex == undefined){ 
					selectedIndex = 0;
				} else {
					selectedIndex ++;
				}
				dispatchEvent({type:"change", target:this});
			}
		}
	}
	
	private function onScrollFocus(evtObj:Object):Void {
		if(Selection.getFocus() != "" + this) Selection.setFocus(this);
	}
	
	
	private function onKillFocus(newFocus:Object):Void {
		Key.removeListener(__keyListener);
		__keyListener = null;
		hideFocus();
		dispatchEvent({type:"killFocus", target:this, newfocus:newFocus});
	}
	
	
	private function onMouseWheel(delta:Number):Void {
		if(__enabled && __vScrollBar._visible && (_xmouse > 0) && (_xmouse < __width) && (_ymouse > 0) && (_ymouse < __height)){
			__vScrollBar.value -= delta;
 			__vScroll = Math.round(__vScrollBar.value);
			displayItems();
			dispatchEvent({type:"change", target:this});
		}
	}
	
	
	private function onSetFocus(oldFocus:Object):Void {
		if(__keyListener == null || __keyListener == undefined){
			__keyListener = new Object();
			__keyListener.onKeyDown = Delegate.create(this, onKeyPressed);
			Key.addListener(__keyListener);
		}
		dispatchEvent({type:"focus", target:this, oldfocus:oldFocus});
		if(Key.isDown(9)){
			dispatchEvent({type:"tabFocus", target:this, oldfocus:oldFocus});
			showFocus();
		}
	}
	
	
	private function onVScroll(evtObj:Object):Void {
		__vScroll = Math.floor(__vScrollBar.value);
		displayItems();
	}
	
	
	/**
		Removes all existing items from the list.
	
		@return nothing
		@example
		<pre>
		myList.removeAll();
		</pre>
	*/
	public function removeAll(Void):Void {
		__dataProvider = new Array();
		invalidate();
	}
	
	
	/**
		Removes the item at the specified index.
	
		@param index the position of the item you want to remove
		@return nothing
		@example
		<pre>
		myList.removeItemAt(1);
		</pre>
	*/
	public function removeItemAt(index:Number):Void {
		__dataProvider.splice(index, 1);
		__selectedIndex = undefined;
		invalidate();
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
	
	
	private function setLabelProps(row:ListItem):Void {
		row.text = "";
		row.selectedColor = __selectedColor;
		row.selectedTextColor = __selectedTextColor;
		row.highlightColor = __highlightColor;
		row.highlightTextColor = __highlightTextColor;
		row.enabled = __enabled;
		row.align = __align;
		row.embedFont = __embedFont;
		row.fontColor = __fontColor;
		row.fontFace = __fontFace;
		row.fontSize = __fontSize;
		row.html = __html;
		row.disabledColor = __disabledColor;
	}
	
	
	private function setLabels(Void):Void {
		__dataProvider = new Array();
		for(var i=0;i<__labels.length;i++){
			__dataProvider[i] = {label:__labels[i], data:__data[i]};
		}
		__labelParamsSet = false;
	}
	
	
	private function showSelected(){
		for(var i=0;i<__numRows;i++){
			__rows[i].selected = false;
		}
		if(__selectedIndex != undefined){
			__rows[__selectedIndex - __vScroll].selected = true;
		}
	}
	
	
	/**
		@exclude
		for inspector panel settings only
	*/
	[Inspectable (type="Array")]
	public function set data(dat:Array) {
		__data = dat;
		invalidate();
	}
	/**
		@exclude
		for inspector panel settings only
	*/
	public function get data():Array {
		return __data;
	}
	
	
	/**
		Sets the array of items used to populate the list.
	
		@param dp an array containing objects described in BitList.addItem(). Each object would be a string itself, or an object containing minimally a label property, which is a string.
		@example
		<pre>
		var myDP:Array = ["item one", "item two", "item three"];
		myList.dataProvider = myDP;
		</pre>
	*/
	public function set dataProvider(dp:Array) {
		__dataProvider = dp;
		invalidate();
	}
	/**
		Gets the array of items used to populate the list.
	
		@example
		<pre>
		myVar = myList.dataProvider;
		</pre>
	*/
	public function get dataProvider():Array {
		return __dataProvider;
	}
		
	
	/**
		Sets the color to use when an item in the list is rolled over.
				
		@example
		<pre>
		myList.highlightColor = 0xcccccc;
		</pre>
	*/
	[Inspectable (type="Color", defaultValue="#eeeeee")]
	public function set highlightColor(col:Number) {
		__highlightColor = col;
		displayItems();
	}
	/**
		Gets the color used when an item in the list is rolled over.
				
		@example
		<pre>
		myVar = myList.highlightColor;
		</pre>
	*/
	public function get highlightColor():Number {
		return __highlightColor;
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
		Sets the height for the individual rows in the list.
				
		@example
		<pre>
		myList.rowHeight = 25;
		</pre>
	*/
	[Inspectable (defaultValue=20)]
	public function set rowHeight(h:Number) {
		__rowHeight = h;
		invalidate();
	}
	/**
		Gets the height of the individual rows in the list.
				
		@example
		<pre>
		myVar = myList.rowHeight;
		</pre>
	*/
	public function get rowHeight():Number {
		return __rowHeight;
	}
	
	
	/**
		Sets the width of the scrollbar used in the list (if needed)
				
		@example
		<pre>
		myList.scrollBarWidth = 20;
		</pre>
	*/
	[Inspectable (defaultValue=16)]
	public function set scrollBarWidth(w:Number) {
		__scrollBarWidth = w;
		invalidate();
	}
	/**
		Gets the width of the scrollbar used in the list
				
		@example
		<pre>
		myVar = myList.scrollBarWidth;
		</pre>
	*/
	public function get scrollBarWidth():Number {
		return __scrollBarWidth;
	}
	
	
	/**
		Sets the selected item.
				
		@example
		<pre>
		myList.selectedIndex = 5;
		</pre>
	*/
	public function set selectedIndex(index:Number) {
		if(__selectedIndex != index){
			__selectedIndex = index;
			__selectedIndex = Math.min(__dataProvider.length - 1, __selectedIndex);
			__selectedIndex = Math.max(0, __selectedIndex);
		}
		if(index == -1){
			__selectedIndex = undefined;
		}
		scrollToSelection();
		showSelected();
	}
	/**
		Retrieves the number of the currently selected item in the list.
				
		@example
		<pre>
		myVar = myList.selectedIndex;
		</pre>
	*/
	public function get selectedIndex():Number {
		return __selectedIndex;
	}
	
	
	/**
		A reference to the currently selected item in the list.
				
		@example
		<pre>
		trace(myList.selectedItem.label);
		</pre>
	*/
	public function get selectedItem():Object {
		return __dataProvider[__selectedIndex];
	}
		
	
	/**
		Sets the color to use when an item in the list is clicked on.
				
		@example
		<pre>
		myList.selectedColor = 0xaaaaaa;
		</pre>
	*/
	[Inspectable (type="Color", defaultValue="#dddddd")]
	public function set selectedColor(col:Number) {
		__selectedColor = col;
		displayItems();
	}
	/**
		Gets the color used when an item in the list is clicked on.
				
		@example
		<pre>
		myVar = myList.selectedColor;
		</pre>
	*/
	public function get selectedColor():Number {
		return __selectedColor;
	}
	
	/**
		Sets the font color to use when an item in the list is rolled over.
				
		@example
		<pre>
		myList.highlightTextColor = 0x555555;
		</pre>
	*/
	[Inspectable (type="Color", defaultValue="#333333")]
	public function set highlightTextColor(col:Number) {
		__highlightTextColor = col;
		invalidate();
	}
	/**
		Gets the font color to use when an item in the list is rolled over.
				
		@example
		<pre>
		myVar = myList.highlightTextColor;
		</pre>
	*/
	public function get highlightTextColor():Number {
		return __highlightTextColor;
	}
	
	/**
		Sets the font color used when an item in the list is clicked on.
				
		@example
		<pre>
		myList.selectedTextColor = 0x555555;
		</pre>
	*/
	[Inspectable (type="Color", defaultValue="#333333")]
	public function set selectedTextColor(col:Number) {
		__selectedTextColor = col;
		invalidate();
	}
	/**
		Gets the font color used when an item in the list is clicked on.
				
		@example
		<pre>
		myVar = myList.selectedTextColor;
		</pre>
	*/
	public function get selectedTextColor():Number {
		return __selectedTextColor;
	}
}