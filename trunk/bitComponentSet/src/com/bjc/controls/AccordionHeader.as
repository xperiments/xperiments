import com.bjc.controls.Label;
import com.bjc.resizers.HResizer;
import mx.events.EventDispatcher;

[Event("click")]

/**
	@exclude
*/
class com.bjc.controls.AccordionHeader extends com.bjc.core.BJCComponent {
	
	private var __downBtn:HResizer;
	private var __label:Label;
	private var __labelText:String = "";
	private var __selected:Boolean = false;
	private var __upBtn:HResizer;
	
	private var __ico:String;
	private var __icon:MovieClip;
	
	public var addEventListener:Function;
	public var removeEventListener:Function;
	public var dispatchEvent:Function;
	public var dispatchQueue:Function;
	public var clickHandler:Function;
	
	public function AccordionHeader(Void) {
	}
	private function init(Void):Void {
		super.init();
		EventDispatcher.initialize(this);
		
		draw();
	}
	private function createChildren(Void):Void {
		attachMovie("HResizer", "__upBtn", 0);
		__upBtn.margin = 5;
		__upBtn.skin = "accordionHeaderUpSkin";
		
		attachMovie("HResizer", "__downBtn", 1);
		__downBtn.margin = 5;
		__downBtn.skin = "accordionHeaderDownSkin";
		
		attachMovie("Label", "__label", 2);
		
		attachMovie(__ico, "__icon", 3);
	}
	public function draw(Void):Void {
		if(__enabled){
			_alpha = 100;
		} else {
			_alpha = __alphaDisabled;
		}
		__label.enabled = __enabled;
		__downBtn._visible = __selected;
		__label.text = __labelText;
		size();
	}
	private function size(Void):Void {
		__upBtn.setSize(__width, __height)
		__downBtn.setSize(__width, __height);
		if(__ico != undefined && __ico != ""){
			attachMovie(__ico, "__icon", 3);
			__icon._x = 2;
			__icon._y = 2;
			__label._x = 2 + __icon._width;
			__label.width = __width - 4 - __icon._width;
		}else{
			__label._x = 2;
			__label.width = __width - 4;
		}
	}
	
	public function onRelease(Void):Void {
		if(__enabled){
			dispatchEvent({type:"click"});
		}
	}
	
	public function set selected(b:Boolean) {
		__selected = b;
		invalidate();
	}
	public function get selected():Boolean {
		return __selected;
	}
	public function set text(txt:String) {
		__labelText = txt;
		invalidate();
	}
	public function get text():String {
		return __labelText;
	}
	
	public function get label():Label {
		return __label;
	}
	public function set icon(i:String) {
		__ico = i;
		invalidate();
	}
	public function get icon():MovieClip {
		return __icon;
	}
}