import com.bjc.controls.Label;
import mx.events.EventDispatcher;

[Event("click")]
[Event("itemRollOver")]
[Event("itemRollOut")]

/**
	@exclude
*/
class com.bjc.controls.ListItem extends com.bjc.core.LabelWrapper {
	
	private var __background:MovieClip;
	private var __bgColor:Color;
	private var __highlightColor:Number = 0xeeeeee;
	private var __index:Number;
	private var __label:Label;
	private var __labelText:String = "";
	private var __selected:Boolean = false;
	private var __selectedColor:Number = 0xdddddd;
	private var __highlightTextColor:Number = 0x000000;
	private var __selectedTextColor:Number = 0x000000;
	
	public var addEventListener:Function;
	public var removeEventListener:Function;
	public var dispatchEvent:Function;
	public var dispatchQueue:Function;
	public var clickHandler:Function;
	
	
	
	
	public function ListItem(Void) {
	}
	
	
	private function init(Void):Void {
		super.init();
		EventDispatcher.initialize(this);
		__bgColor = new Color(__background);
		
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
	}
	
	
	public function draw(Void):Void {
		__label.enabled = __enabled;
		__label.align = __align;
		__label.embedFont = __embedFont;
		__label.fontColor = __fontColor;
		__label.fontFace = __fontFace;
		__label.fontSize = __fontSize;
		__label.html = __html;
		__label.disabledColor = __disabledColor;
		__label.text = __labelText;
		if(__selected){
			__background._visible = true;
			__bgColor.setRGB(__selectedColor);
			__label.fontColor = __selectedTextColor;
		} else {
			__background._visible = false;
		}
		size();
	}
	
	
	private function size(Void):Void {
		__background._width = __width;
		__background._height = __height;
		__label._x = 5;
		__label.setSize(__width - 5, __height);
	}
	
	
	
	
	
	
	
	public function onDragOut(Void):Void {
		onRollOut();
	}
	
	
	public function onRelease(Void):Void {
		if(__enabled){
			dispatchEvent({type:"click"});
		}
	}
	
	
	public function onReleaseOutside(Void):Void {
		if(__enabled){
			dispatchEvent({type:"click"});
		}
	}
	
	
	public function onRollOut(Void):Void {
		if(__enabled){
			if(!__selected){
				__bgColor.setRGB(0x0000ff);
				__background._visible = false;
				__label.fontColor = __fontColor;
			} else {
				__bgColor.setRGB(__selectedColor);
				__background._visible = true;
				__label.fontColor = __selectedTextColor;
			}
			dispatchEvent({type:"itemRollOut", index:__index});
		}
	}
	
	
	public function onRollOver(Void):Void {
		if(__enabled){
			__label.fontColor = __highlightTextColor;
			__background._visible = true;
			__bgColor.setRGB(__highlightColor);
			dispatchEvent({type:"itemRollOver", index:__index});
		}
	}
	
	
	
	
	
	public function set highlightColor(col:Number) {
		__highlightColor = col;
		invalidate();
	}
	public function get highlightColor():Number {
		return __highlightColor;
	}
	
	public function set highlightTextColor(col:Number) {
		__highlightTextColor = col;
		invalidate();
	}
	public function get highlightTextColor():Number {
		return __highlightTextColor;
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
	
	public function set selectedTextColor(col:Number) {
		__selectedTextColor = col;
		invalidate();
	}
	public function get selectedTextColor():Number {
		return __selectedTextColor;
	}
	
	
	public function set text(txt:String) {
		__labelText = txt;
		invalidate();
	}
	public function get text():String {
		return __labelText;
	}
	
	
}