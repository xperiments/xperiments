import com.bjc.controls.Label;
import mx.events.EventDispatcher;
import mx.utils.Delegate;


[Event("click")]
[Event("open")]

/**
	@exclude
*/
class com.bjc.controls.TreeItem extends com.bjc.core.BJCComponent {
	
	private var __background:MovieClip;
	private var __bgColor:Color;
	private var __nodeBGColor:Number = 0xffffff;
	private var __enabled:Boolean = true;
	private var __highlightColor:Number = 0xeeeeee;
	private var __icon:MovieClip;
	private var __indent:Number;
	private var __indentSize:Number = 15;
	private var __index:Number;
	private var __label:Label;
	private var __labelText:String = "";
	private var __node:XMLNode;
	private var __open:String = "true";
	private var __selected:Boolean = false;
	private var __selectedColor:Number = 0xdddddd;
	private var __type:String;
	
	public var addEventListener:Function;
	public var removeEventListener:Function;
	public var dispatchEvent:Function;
	public var dispatchQueue:Function;
	public var clickHandler:Function;
	
	
	
	public function TreeItem(Void) {
	}
	
	
	private function init(Void):Void {
		super.init();
		EventDispatcher.initialize(this);
		__background.useHandCursor = false;
		__bgColor = new Color(__background);
		__background.onRollOver = Delegate.create(this, onBgRollOver);
		__background.onRollOut = Delegate.create(this, onBgRollOut);
		__background.onDragOut = Delegate.create(this, onBgDragOut);
		__background.onRelease = Delegate.create(this, onBgRelease);
		
		__icon.useHandCursor = false;
		__icon.onRelease = Delegate.create(this, onIconRelease);		
		draw();
	}
	
	
	private function createChildren(Void):Void {
		createEmptyMovieClip("__background", 0);
		__background.beginFill(0xffffff);
		__background.lineTo(100, 0);
		__background.lineTo(100, 100);
		__background.lineTo(0, 100);
		__background.lineTo(0, 0);
		__background.endFill();
		
		attachMovie("Label", "__label", 1);
		
		createEmptyMovieClip("__icon", 2);
		__icon.attachMovie("treeOpenFolderIcon", "open", 0);
		__icon.attachMovie("treeClosedFolderIcon", "closed", 1)._visible = false;
		__icon.attachMovie("treePageIcon", "page", 2)._visible = false;
	}
	
	
	public function draw(Void):Void {
		_visible = __indent != undefined;
		
		__label.enabled = __enabled;
		__label.text = __labelText;
		if(__selected){
			__background._visible = true;
			__bgColor.setRGB(__selectedColor);
		} else {
			__bgColor.setRGB(__nodeBGColor);
		}
		if(__type == "page"){
			__icon.open._visible = false;
			__icon.closed._visible = false;
			__icon.page._visible = true;
		} else if(__open == "true"){
			__icon.open._visible = true;
			__icon.closed._visible = false;
			__icon.page._visible = false;
		} else {
			__icon.open._visible = false;
			__icon.closed._visible = true;
			__icon.page._visible = false;
		}
		size();
	}
	
	
	private function size(Void):Void {
		__background._width = __width;
		__background._height = __height;
		__label.move(__indent * __indentSize + 20, 0);
		__label.setSize(__width - __label._x, __height);
		__icon._x = __indent * __indentSize;
		__icon._y = Math.round(__height / 2 - __icon._height / 2);
	}
	
	
	
	
	
	public function onBgDragOut(Void):Void {
		onRollOut();
	}
	
	
	public function onBgRelease(Void):Void {
		if(__enabled){
			dispatchEvent({type:"click"});
		}
	}
	
	
	public function onBgRollOut(Void):Void {
		if(__enabled){
			if(!__selected){
				__bgColor.setRGB(__nodeBGColor);
			} else {
				__bgColor.setRGB(__selectedColor);
			}
		}
	}
	
	
	public function onBgRollOver(Void):Void {
		if(__enabled){
			__bgColor.setRGB(__highlightColor);
		}
	}
	
	
	public function onIconRelease(Void):Void {
		if(__enabled){
			if(__type == "folder"){
				if(__open == "true"){
					__open = "false";
				} else {
					__open = "true";
				}
	 			__node.attributes.open = __open;
				dispatchEvent({type:"open"});
			}
		}
	}
	
	
	
	
	
	
	
	public function set highlightColor(col:Number) {
		__highlightColor = col;
		invalidate();
	}
	public function get highlightColor():Number {
		return __highlightColor;
	}
	public function set nodeBGColor(col:Number) {
		__nodeBGColor = col;
		invalidate();
	}
	public function get nodeBGColor():Number {
		return __nodeBGColor;
	}	
	
	public function set indent(i:Number) {
		__indent = i;
		invalidate();
	}
	public function get indent():Number {
		return __indent;
	}
	
	
	public function set indentSize(size:Number) {
		__indentSize = size;
		invalidate();
	}
	public function get indentSize():Number {
		return __indentSize;
	}


	public function set index(i:Number) {
		__index = i;
		invalidate();
	}
	public function get index():Number {
		return __index;
	}
	
	
	public function get label():Label {
		return __label;
	}


	public function set type(t:String) {
		__type = t;
		invalidate();
	}
	public function get type():String {
		return __type;
	}
	
	
	public function set text(txt:String) {
		__labelText = txt;
		invalidate();
	}
	public function get text():String {
		return __labelText;
	}
	
	
	public function set node(x:XMLNode) {
		__node = x;
		invalidate();
	}
	public function get node():XMLNode {
		return __node;
	}
	
	
	public function set open(b:String) {
		__open = b;
		invalidate();
	}
	public function get open():String {
		return __open;
	}
	
	
	public function set selected(b:Boolean) {
		__selected = b;
		invalidate();
	}
	public function get selected():Boolean {
		return __selected;
	}
	
	
	public function set selectedColor(col:Number) {
		__selectedColor = col;
		invalidate();
	}
	public function get selectedColor():Number {
		return __selectedColor;
	}
	
	
}