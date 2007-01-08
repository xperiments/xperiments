import com.bjc.controls.IconButton;
import com.bjc.controls.Label;
import com.bjc.controls.BitList;
import com.bjc.core.LabelWrapper;
import com.bjc.resizers.Resizer;
import mx.utils.Delegate;
import mx.events.EventDispatcher;


[IconFile ("icons/ComboBox.png")]

[Event("change")]

[Event("click")]

[Event("focus")]

[Event("killFocus")]

[Event("tabFocus")]


/**
* A basic combo box for displaying and choosing amongst different values
* <BR><BR>
* Events:
* <BR><BR>
* <B>change</B> - Fired whenever the user makes a choice from the drop down list, changing the current selection.
* <BR>
* <B>focus</B> - Fired whenever the component receives focus.
* <BR>
* <B>killFocus</B> - Fired whenever the component loses focus.
* <BR>
* <B>tabFocus</B> - Fired whenever the component receives focus by pressing the TAB key.
* @author Beam Jive Consulting - www.beamjive.com
*/
class com.bjc.controls.ComboBox extends LabelWrapper {
 	private var clipParameters:Object = {numRows:1, highlightColor:1, rowHeight:1, selectedColor:1, scrollBarWidth:1};
	private static var mergedClipParameters:Boolean = com.bjc.core.BJCComponent.mergeClipParameters(ComboBox.prototype.clipParameters, LabelWrapper.prototype.clipParameters);
	
	private var __background:Resizer;
	private var __btnDown:MovieClip;
	private var __btnUp:MovieClip;
	private var __data:Array;
	private var __dataProvider:Array;
	private var __highlightColor:Number = 0xeeeeee;
	private var __keyListener:Object;
	private var __label:Label;
	private var __labelParamsSet:Boolean = false;
	private var __labels:Array;
	private var __labelText:String = "";
	private var __list:BitList;
	private var __numRows:Number = 5;
	private var __oldDepth:Number;
	private var __open:Boolean = false;
	private var __rowHeight:Number = 20;
	private var __scrollBarWidth:Number = 16;
	private var __selectedColor:Number = 0xdddddd;
	private var __selectedIndex:Number = 0;
	
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
	* @usage <pre>myComboBox.changeHandler = function(){
	* 	trace("I was changed.");
	* }</pre>
	*/
	public var changeHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myComboBox.clickHandler = function(){
	* 	trace("I was clicked.");
	* }</pre>
	*/
	public var clickHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myComboBox.focusHandler = function(){
	* 	trace("Set focus.");
	* }</pre>
	*/
	public var focusHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myComboBox.killFocusHandler = function(){
	* 	trace("Kill focus.");
	* }</pre>
	*/
	public var killFocusHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myComboBox.tabFocusHandler = function(){
	* 	trace("Tab focus.");
	* }</pre>
	*/
	public var tabFocusHandler:Function;
	
	public function ComboBox(Void) {
	}


	private function init(Void):Void {
		super.init();
		EventDispatcher.initialize(this);
		focusEnabled = true;
		
		__btnUp.onRelease = Delegate.create(this, click);
		__label.onRelease = Delegate.create(this, onLabelClick);
		__label.useHandCursor = false;
		
		if(__dataProvider == undefined){
			__dataProvider = new Array();
		}
		
		setChildProps();
		
		draw();
	}


	private function createChildren(Void):Void {
		attachMovie("Resizer", "__background", 0);
		__background.skin = "comboBoxSkin";
		__background.margin = 2;
		
		attachMovie("comboBoxBtnUpSkin", "__btnUp", 1);
		attachMovie("comboBoxBtnDownSkin", "__btnDown", 2);
		__btnDown._visible = false;
		
		attachMovie("Label", "__label", 3);
		
		attachMovie("Resizer", "__focus", 10);
		__focus.skin = "focusSkin";
		__focus.margin = 5;
		__focus._visible = false;
	}


	/**
		@exclude
		this is documented in BJCComponent, not changed here.
	*/
	public function draw(Void):Void {
		if(__labelParamsSet){
			setLabels();
		}
		
		
		if(__enabled){
			_alpha = 100;
		} else {
			_alpha = __alphaDisabled;
		}
		
		__label.enabled = __enabled;
		__btnDown.enabled = __enabled;
		__btnUp.enabled = __enabled;
		
		if(!__enabled){
			__open = false;
		}
		
		if(__dataProvider.length > 0){
			if(typeof __dataProvider[__selectedIndex] == "string"){
				__label.text = __dataProvider[__selectedIndex];
			} else {
				__label.text = __dataProvider[__selectedIndex].label;
			}
		} else {
			__label.text = "";
		}
		if(__open && __dataProvider.length > 0){
	 		attachMovie("BitList", "__list", 4);
			setListProps();
	 		__list.addEventListener("click", Delegate.create(this, onListClick));
			__list.enabled = __enabled;
			__list.dataProvider = __dataProvider;
			__list._y = __height;
			__list.setSize(__width, Math.min(__numRows, __list.dataProvider.length) * __list.rowHeight);
			__list.selectedIndex = __selectedIndex;
		} else {
			__list.removeMovieClip();
		}
			
		
		__btnDown._visible = __open;
		
		if(selectedIndex == undefined){
			selectedIndex = 0;
		}
		setChildProps();
		
		
		size();
	}


	private function size(Void):Void {
		__background.setSize(__width, __height);
		__focus.setSize(__width, __height);
		
		__btnDown._x = __width - __btnDown._width - 1;
		__btnDown._y = Math.round(__height / 2 - __btnDown._height / 2);
		
		__btnUp._x = __width - __btnUp._width - 1;
		__btnUp._y = Math.round(__height / 2 - __btnUp._height / 2);
		
		__label.move(2, 1);
		__label.setSize(__width - __btnUp._width - 2, __height - 2);
		
	}
	
	
	/**
		Static method used to create an instance of a ComboBox on stage at run time.
				
		@param target the movie clip to which the combobox will be attached.
		@param id the instance name given to the new combobox attached.
		@param depth the depth at which to attach the new combobox.
		@param initObj (optional) an object containing any properties you want to assign to the component when it is created
		@return a reference to the new combobox attached.
		@example
		<pre>
		import com.bjc.controls.ComboBox;
		var newComboBox:ComboBox = ComboBox.create(_root, "myComboBox", 0);
		</pre>
	*/
	public static function create(target:MovieClip, id:String, depth:Number, initObj:Object):ComboBox {
		return ComboBox(target.attachMovie("ComboBox", id, depth, initObj));
	}
		
	

	
	
	
	
	
	/**
		Adds a new item to the combo box, tacking it on to the end of the list.
	
		@param item an object containing minimally a parameter called label. This would be the string displayed in the combo box. The object can also contain any other properties, usually stored in a data property. Item can also be a simple string itself.
		@return nothing
		@example
		<pre>
		// using an object
		myComboBox.addItem({label:"First item", data:100});
		// using a string
		myComboBox.addItem("Second Item");
		</pre>
	*/
	public function addItem(item:Object):Void {
		__dataProvider.push(item);
		update();
	}
	
	
	/**
		Adds a new item to the combo box, placing it in the position specified.
	
		@param item an object containing minimally a parameter called label. This would be the string displayed in the combo box. The object can also contain any other properties, usually stored in a data property. Item can also be a simple string itself.
		@param index the position at which to place the item
		@return nothing
		@example
		<pre>
		// using an object
		myComboBox.addItem({label:"First item", data:100}, 3);
		// using a string
		myComboBox.addItem("Second Item", 4);
		</pre>
	*/
	public function addItemAt(item:Object, index:Number):Void {
		__dataProvider.splice(index, 0, item);
		update();
	}
	
	
	private function click(evtObj:Object):Void {
		if(!__open){
			__oldDepth = this.getDepth();
			__open = true;
			__btnDown._visible = true;
			if(_parent.getNextHighestDepth() != undefined){ 
				this.swapDepths(_parent.getNextHighestDepth());
			} else {
				this.swapDepths(1048575);
			}
//			Selection.setFocus(__list);
 			onMouseDown = Delegate.create(this, mouseDown);
		} else {
			__open = false;
			__btnDown._visible = false;
			this.swapDepths(__oldDepth);
			delete onMouseDown;
		}
		invalidate();
		if(Selection.getFocus() != "" + this) Selection.setFocus(this); 
		dispatchEvent({type:"click", target:this});
	}
	
	
	private function mouseDown(Void):Void {
		if(__open){
			if(_xmouse < 0 || _xmouse > __width || _ymouse < 0 || _ymouse > __height + __numRows * __rowHeight){
				closeMe();
			}
		} 
	}
	
	
	private function onKillFocus(newFocus:Object):Void {
		Key.removeListener(__keyListener);
		__keyListener = null;
		
		if(newFocus != __list){
			closeMe();
		}
		hideFocus();
		dispatchEvent({type:"killFocus", target:this, newfocus:newFocus});
	}
	
	
	private function closeMe(Void):Void {
		__open = false;
		__btnDown._visible = false;
		this.swapDepths(__oldDepth);
		
		delete onMouseDown;
		invalidate();
	}
	
	
	private function onLabelClick(evtObj:Object):Void {
		if(Selection.getFocus() != "" + this) Selection.setFocus(this); 
		dispatchEvent({type:"click", target:this});
	}
	
	
	private function onListClick(evtObj:Object):Void {
		__selectedIndex = __list.selectedIndex;
		update();
		if(Selection.getFocus() != "" + this) Selection.setFocus(this);
	}
	
	
	private function onKeyPressed(Void):Void {
		if((Selection.getFocus() == "" + this) && __enabled && __keyEnabled){
			if(__open){
				if(Key.getCode() == Key.ENTER && __list.selectedIndex != undefined){
					onListClick();
				} else if((Key.getCode() == Key.LEFT || Key.getCode() == Key.UP) && __list.selectedIndex > 0){
					__list.selectedIndex --;
				} else if(Key.getCode() == Key.RIGHT || Key.getCode() == Key.DOWN){
					__list.selectedIndex ++;
				}
			} else {
				if(Key.getCode() == Key.ENTER ){
					click();
				}
			}
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
			showFocus();
			dispatchEvent({type:"tabFocus", target:this, oldfocus:oldFocus});
		}
	}
	
		
	/**
		Removes all existing items from the combo box.
	
		@return nothing
		@example
		<pre>
		myComboBox.removeAll();
		</pre>
	*/
	public function removeAll(Void):Void {
		__dataProvider = new Array();
		update();
	}
	
	
	/**
		Removes the item at the specified index.
	
		@param index the position of the item you want to remove
		@return nothing
		@example
		<pre>
		myComboBox.removeItemAt(1);
		</pre>
	*/
	public function removeItemAt(index:Number):Void {
		__dataProvider.splice(index, 1);
		update();
	}
	
	
	private function setChildProps():Void {
		__label.align = __align;
		__label.disabledColor = __disabledColor;
		__label.embedFont = __embedFont;
		__label.fontColor = __fontColor;
		__label.fontFace = __fontFace;
		__label.fontSize = __fontSize;
		__label.html = __html;

		__list.align = __align;
		__list.disabledColor = __disabledColor;
		__list.embedFont = __embedFont;
		__list.fontColor = __fontColor;
		__list.fontFace = __fontFace;
		__list.fontSize = __fontSize;
		__list.highlightColor = __highlightColor;
		__list.html = __html;
		__list.rowHeight = __rowHeight;
		__list.selectedColor = __selectedColor;
		__list.scrollBarWidth = __scrollBarWidth;
	}
	
	private function setListProps(Void):Void {
		__list.align = __align;
		__list.disabledColor = __disabledColor;
		__list.embedFont = __embedFont;
		__list.fontColor = __fontColor;
		__list.fontFace = __fontFace;
		__list.fontSize = __fontSize;
		__list.highlightColor = __highlightColor;
		__list.html = __html;
		__list.rowHeight = __rowHeight;
		__list.selectedColor = __selectedColor;
		__list.scrollBarWidth = __scrollBarWidth;
	}
	
	
	private function setLabels(Void):Void {
		for(var i=0;i<__labels.length;i++){
			dataProvider[i] = {label:__labels[i], data:__data[i]};
		}
		
		// this is only for labels set in property/component inspector. once set, get rid of it
		__labels.length = 0;
	}
	
	
	private function update(){
		this.swapDepths(__oldDepth);
		
		__open = false;
		invalidate();
		dispatchEvent({type:"change", target:this});
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
		Sets the array of items used to populate the combo box.
	
		@param dp an array containing objects described in ComboBox.addItem(). Each object would be a string itself, or an object containing minimally a label property, which is a string.
		@example
		<pre>
		var myDP:Array = ["item one", "item two", "item three"];
		myComboBox.dataProvider = myDP;
		</pre>
	*/
	public function set dataProvider(dp:Array) {
		__dataProvider = dp;
		__selectedIndex = 0;
		update();
	}
	/**
		Retrieves the array of items used to populate the combo box.
	
		@example
		<pre>
		var myDP = myComboBox.dataProvider;
		</pre>
	*/
	public function get dataProvider():Array {
		return __dataProvider;
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
		Sets the number of visible rows displayed when the combo box is open. If there are more items than this value, a scrollbar will appear to allow you to scroll through the items.
		
		@example
		<pre>
		myComboBox.numRows = 5;
		</pre>
	*/
	[Inspectable (defaultValue=5)]
	public function set numRows(num:Number) {
		__numRows = num;
		invalidate();
	}
	/**
		Gets the number of visible rows displayed when the combo box is open. 
		
		@example
		<pre>
		myVar = myComboBox.numRows;
		</pre>
	*/
	public function get numRows():Number {
		return __numRows;
	}
	
	
	/**
		Sets the selected item.
				
		@example
		<pre>
		myComboBox.selectedIndex = 5;
		</pre>
	*/
	public function set selectedIndex(index:Number) {
		if(__selectedIndex != index){
			__selectedIndex = index;
			update();
		}
	}
	/**
		Retrieves the number of the currently selected item in the combo box.
				
		@example
		<pre>
		myVar = myComboBox.selectedIndex;
		</pre>
	*/
	public function get selectedIndex():Number {
		return __selectedIndex;
	}
	
	
	/**
		A reference to the currently selected item in the combo box.
				
		@example
		<pre>
		myVar = myComboBox.selectedItem;
		myLabel = myVar.label;
		</pre>
	*/
	public function get selectedItem():Number {
		return __dataProvider[__selectedIndex];
	}
	

	


	/**
		Sets the color to use when an item in the drop down list is rolled over.
				
		@example
		<pre>
		myComboBox.highlightColor = 0xcccccc;
		</pre>
	*/
	[Inspectable (type="Color", defaultValue="#eeeeee")]
	public function set highlightColor(col:Number) {
		__highlightColor = col;
		setChildProps();
	}
	/**
		Gets the color used when an item in the drop down list is rolled over.
				
		@example
		<pre>
		myVar = myComboBox.highlightColor;
		</pre>
	*/
	public function get highlightColor():Number {
		return __highlightColor;
	}


	/**
		Sets the height for the individual rows in the drop down list.
				
		@example
		<pre>
		myComboBox.rowHeight = 25;
		</pre>
	*/
	[Inspectable (defaultValue=20)]
	public function set rowHeight(h:Number) {
		__rowHeight = h;
		setChildProps();
	}
	/**
		Gets the height of the individual rows in the drop down list.
				
		@example
		<pre>
		myVar = myComboBox.rowHeight;
		</pre>
	*/
	public function get rowHeight():Number {
		return __rowHeight;
	}

	
	/**
		Sets the color to use when an item in the drop down list is clicked on.
				
		@example
		<pre>
		myComboBox.selectedColor = 0xaaaaaa;
		</pre>
	*/
	[Inspectable (type="Color", defaultValue="#dddddd")]
	public function set selectedColor(col:Number) {
		__selectedColor = col;
		setChildProps();
	}
	/**
		Gets the color used when an item in the drop down list is clicked on.
				
		@example
		<pre>
		myVar = myComboBox.selectedColor;
		</pre>
	*/
	public function get selectedColor():Number {
		return __selectedColor;
	}

	
	/**
		Sets the width of the scrollbar used in the drop down list (if needed)
				
		@example
		<pre>
		myComboBox.scrollBarWidth = 20;
		</pre>
	*/
	[Inspectable (defaultValue=16)]
	public function set scrollBarWidth(w:Number) {
		__scrollBarWidth = w;
		setChildProps();
	}
	/**
		Gets the width of the scrollbar used in the drop down list
				
		@example
		<pre>
		myVar = myComboBox.scrollBarWidth;
		</pre>
	*/
	public function get scrollBarWidth():Number {
		return __scrollBarWidth;
	}
}