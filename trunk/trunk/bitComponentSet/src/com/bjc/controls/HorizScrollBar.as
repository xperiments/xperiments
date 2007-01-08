import com.bjc.controls.IconButton;
import com.bjc.resizers.HResizer;
import mx.events.EventDispatcher;
import mx.utils.Delegate;



[IconFile ("icons/HScrollBar.png")]

/** 
	@exclude
*/
class com.bjc.controls.HorizScrollBar extends com.bjc.controls.ScrollBar {
	
	
	public function HorizScrollBar(Void) {
	}
	
	
	private function createChildren(Void):Void {
		attachMovie("HResizer", "__back", 0);
		__back.skin = __backSkin;
		__back.margin = 10;
		super.createChildren();
	}
	
	
	private function size(Void):Void {
		super.size();
		__btnAUp._height = __height;
		__btnAUp._width = __height;
		__btnADown._height = __height;
		__btnADown._width = __height;
		
		__btnBUp._height = __height;
		__btnBUp._width = __height;
		__btnBDown._height = __height;
		__btnBDown._width = __height;
		
		__btnBUp._x = __limitB;
		__btnBDown._x = __limitB;
		__thumb.height = __height;
	}
	
	
	/**
		Static method used to create an instance of a HorizScrollBar on stage at run time.
				
		@param target the movie clip to which the scrollbar will be attached.
		@param id the instance name given to the new scrollbar attached.
		@param depth the depth at which to attach the new scrollbar.
		@param initObj (optional) an object containing any properties you want to assign to the component when it is created
		@return a reference to the new scrollbar attached.
		@example
		<pre>
		import com.bjc.controls.HorizScrollBar;
		var newHorizScrollBar:HorizScrollBar = HorizScrollBar.create(_root, "myHorizScrollBar", 0);
		</pre>
	*/
	public static function create(target:MovieClip, id:String, depth:Number, initObj:Object):HorizScrollBar {
		return HorizScrollBar(target.attachMovie("HorizScrollBar", id, depth, initObj));
	}
		
	

	
	
	
	
	
	
	private function onStartDrag(Void):Void {
		if(__enabled){
			__thumb.startDrag(false, __limitA, 0, Math.round(__limitB - __thumb.width), 0);
			onMouseMove = update;
		}
	}
	
	
	private function setThumbMargins(){
		__thumb.margin = __height / 2;
	}
	
	
	
	
	
	public function get __backSkin():String {
		return "hScrollBarBackSkin";
	}
	
	
	public function get __btnADownSkin():String {
		return "hScrollBarLeftBtnDownSkin";
	}
	
	
	public function get __btnAUpSkin():String {
		return "hScrollBarLeftBtnUpSkin";
	}
	
	
	public function get __btnBDownSkin():String {
		return "hScrollBarRightBtnDownSkin";
	}
	
	
	public function get __btnBUpSkin():String {
		return "hScrollBarRightBtnUpSkin";
	}
	
	
	public function get __limitA():Number {
		return __height;
	}
	
	
	public function get __limitB():Number {
		return __width - __height;
	}
	
	
	public function get mousePos():Number {
		return _xmouse;
	}
	
	
	public function get __resizerType():String {
		return "HResizer";
	}
	
	
	public function set thumbPos(pos:Number){
		__thumb._x = pos;
	}
	public function get thumbPos():Number {
		return __thumb._x;
	}
	
	
	public function set thumbSize(m:Number){
		__thumb.width = m;
	}
	public function get thumbSize():Number {
		return __thumb.width;
	}
	
	
	public function get __thumbSkin():String {
		return "hScrollBarThumbSkin";
	}
	
	
}