import com.bjc.controls.Label;
import com.bjc.resizers.HResizer;
import mx.events.EventDispatcher;

[Event("click")]

/**
	@exclude
*/
class com.bjc.controls.Tab extends com.bjc.core.BJCComponent {
	
	private var __downBtn:HResizer;
	private var __icon:MovieClip;
	private var __iconName:String;
	private var __label:Label;
	private var __labelText:String = "";
	private var __selected:Boolean = false;
	private var __upBtn:HResizer;
	
	public var addEventListener:Function;
	public var removeEventListener:Function;
	public var dispatchEvent:Function;
	public var dispatchQueue:Function;
	public var clickHandler:Function;
	
	
	
	public function Tab(Void) {
	}
	
	
	private function init(Void):Void {
		super.init();
		EventDispatcher.initialize(this);
		
		draw();
	}
	
	
	private function createChildren(Void):Void {
		attachMovie("HResizer", "__downBtn", 0);
		__downBtn.margin = 10;
		__downBtn.skin = "tabBackSkin";
		
		attachMovie("HResizer", "__upBtn", 1);
		__upBtn.margin = 10;
		__upBtn.skin = "tabSkin";
		
		attachMovie("Label", "__label", 2);
	}
	
	
	public function draw(Void):Void {
		if(__enabled){
			_alpha = 100;
		} else {
			_alpha = __alphaDisabled;
		}
		__label.enabled = __enabled;
		__upBtn._visible = __selected;
		__label.text = __labelText;
		
		if(__iconName != "" && __iconName != undefined){
			__icon = attachMovie(__iconName, "icon", 3);
		} else {
			__icon.removeMovieClip();
		}
		size();
	}
	
	
	private function size(Void):Void {
		__upBtn.setSize(__width, __height)
		__downBtn.setSize(__width, __height);
		if(__icon == undefined){
			__label._x = 5;
			__label.setSize(__width - 10, __height);
		} else {
			__icon._x = 5;
			__icon._y = __height / 2 - __icon._height / 2;
			__label._x = __icon._width + 10;
			__label.setSize(__width - __label._x - 5);
		}
	}
	
	
	
	
	
	public function onRelease(Void):Void {
		if(__enabled){
			dispatchEvent({type:"click"});
		}
	}
	
	
	
	
	public function set icon(i:String) {
		__iconName = i;
		invalidate();
	}
	public function get icon():String {
		return __iconName;
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
	
	
	public function set text(txt:String) {
		__labelText = txt;
		invalidate();
	}
	public function get text():String {
		return __labelText;
	}
	
}