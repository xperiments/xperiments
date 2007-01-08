import com.bjc.controls.Label;
import mx.events.EventDispatcher;

[Event("click")]

/**
	@exclude
*/
class com.bjc.controls.CalendarItem extends com.bjc.core.BJCComponent {
	
	private var __background:MovieClip;
	private var __bgColor:Color;
	private var __date:Number;
	private var __isToday:Boolean;
	private var __label:Label;
	private var __marked:Boolean = false;
	private var __markedColor:Number = 0xbbbbbb;
	private var __month:Number;
	private var __rolloverColor:Number = 0xe6e6e6;
	private var __selected:Boolean = false;
	private var __selectedColor:Number = 0xcccccc;
	private var __todayColor:Number = 0x888888;
	private var __year:Number;
	
	public var addEventListener:Function;
	public var removeEventListener:Function;
	public var dispatchEvent:Function;
	public var dispatchQueue:Function;
	public var clickHandler:Function;
	
	public function CalendarItem(Void) {
	}
	private function init(Void):Void {
		super.init();
		EventDispatcher.initialize(this);
		
		useHandCursor = false;

		__bgColor = new Color(__background);
		__label.align = "center";
		
		draw();
	}
	private function createChildren(Void):Void {
		attachMovie("Label", "__label", 0);
	}
	public function draw(Void):Void {
		size();
	}
	private function size(Void):Void {
		__background._width = __width;
		__background._height = __height;
		__label.setSize(__width, __height);
	}
	
	public function onRelease(Void):Void {
		if(__enabled){
			dispatchEvent({type:"click"});
		}
	}
	public function onRollOver(Void):Void {
		if(__enabled){
			__background._alpha = 100;
			__bgColor.setRGB(__rolloverColor);
		}
	}
	public function onRollOut(Void):Void {
		if(__enabled){
			__background._alpha = 0;
			__bgColor.setRGB(0xffffff);
			
			isToday = __isToday;
			if(__marked){
				mark();
			}
			selected = __selected;
		}
	}
	public function setDate(year:Number, month:Number, date:Number):Void {
		__year = year;
		__month = month;
		__date = date;
		__label.text = __date.toString();
	}
	public function clear(Void):Void {
		__marked = false;
		__bgColor.setRGB(0xffffff);
		__label.text = "";
		__background._alpha = 0;
		useHandCursor = false;
	}
	
	
	public function get label():Label {
		return __label;
	}

	public function mark(Void):Void {
		__marked = true;
		__background._alpha = 100;
		__bgColor.setRGB(__markedColor);
		useHandCursor = true;
	}
	
	
	public function set isToday(b:Boolean) {
		__isToday = b;
		if(__isToday){
			__background._alpha = 100;
			__bgColor.setRGB(__todayColor);
		}
	}
	public function get isToday():Boolean {
		return __isToday;
	}
	
	public function set selected(b:Boolean) {
		__selected = b;
		if(__selected){
			__background._alpha = 100;
			__bgColor.setRGB(__selectedColor);
		}
	}
	public function get selected():Boolean {
		return __selected;
	}
	
	public function get date():Number {
		return __date;
	}
	
	public function get month():Number {
		return __month;
	}
	
	public function get year():Number {
		return __year;
	}


	public function set markedColor(col:Number) {
		__markedColor = col;
		invalidate();
	}
	public function get markedColor():Number {
		return __markedColor;
	}
	
	public function set rolloverColor(col:Number) {
		__rolloverColor = col;
		invalidate();
	}
	public function get rolloverColor():Number {
		return __rolloverColor;
	}
	
	public function set selectedColor(col:Number) {
		__selectedColor = col;
		invalidate();
	}
	public function get selectedColor():Number {
		return __selectedColor;
	}
	
	public function set todayColor(col:Number) {
		__todayColor = col;
		invalidate();
	}
	public function get todayColor():Number {
		return __todayColor;
	}

	
}