import com.bjc.controls.IconButton;
import com.bjc.resizers.VResizer;
import mx.events.EventDispatcher;
import mx.utils.Delegate;



[IconFile ("icons/VScrollBar.png")]

/**
	@exclude
*/
class com.bjc.controls.VertScrollBar extends com.bjc.controls.ScrollBar {
	
	
	public function VertScrollBar(Void) {
	}
	
	private function createChildren(Void):Void {
		attachMovie("VResizer", "__back", 0);
		__back.skin = __backSkin;
		__back.margin = 10;
		super.createChildren();
	}
	
	
	private function size(Void):Void {
		super.size();
		__btnAUp._height = __width;
		__btnAUp._width = __width;
		__btnADown._height = __width;
		__btnADown._width = __width;
		
		__btnBUp._height = __width;
		__btnBUp._width = __width;
		__btnBDown._height = __width;
		__btnBDown._width = __width;
		
		__btnBUp._y = __limitB;
		__btnBDown._y = __limitB;
		__thumb.width = __width;
	}
	
	
	/**
		Static method used to create an instance of a VertScrollBar on stage at run time.
				
		@param target the movie clip to which the scrollbar will be attached.
		@param id the instance name given to the new scrollbar attached.
		@param depth the depth at which to attach the new scrollbar.
		@param initObj (optional) an object containing any properties you want to assign to the component when it is created
		@return a reference to the new scrollbar attached.
		@example
		<pre>
		import com.bjc.controls.VertScrollBar;
		var newVertScrollBar:VertScrollBar = VertScrollBar.create(_root, "myVertScrollBar", 0);
		</pre>
	*/
	public static function create(target:MovieClip, id:String, depth:Number, initObj:Object):VertScrollBar {
		return VertScrollBar(target.attachMovie("VertScrollBar", id, depth, initObj));
	}
		
	

	
	
	
	private function onStartDrag(Void):Void {
		if(__enabled){
			__thumb.startDrag(false, 0, __limitA, 0, Math.round(__limitB - __thumb.height));
			onMouseMove = update;
		}
	}
	
	
	private function setThumbMargins(){
		__thumb.margin = __width / 2;
	}
	
	
	
	
	
	
	
	public function get __backSkin():String {
		return "vScrollBarBackSkin";
	}
	
	
	public function get __btnADownSkin():String {
		return "vScrollBarUpBtnDownSkin";
	}
	
	
	public function get __btnAUpSkin():String {
		return "vScrollBarUpBtnUpSkin";
	}
	
	
	public function get __btnBDownSkin():String {
		return "vScrollBarDownBtnDownSkin";
	}
	
	
	public function get __btnBUpSkin():String {
		return "vScrollBarDownBtnUpSkin";
	}
	
	
	public function get __limitA():Number {
		return __width;
	}


	public function get __limitB():Number {
		return __height - __width;
	}
	
	
	public function get mousePos():Number {
		return _ymouse;
	}
	
	
	public function get __resizerType():String {
		return "VResizer";
	}
	
	
	public function set thumbPos(pos:Number){
		__thumb._y = pos;
	}
	public function get thumbPos():Number {
		return __thumb._y;
	}
	
	
	public function set thumbSize(m:Number){
		__thumb.height = m;
	}
	public function get thumbSize():Number {
		return __thumb.height;
	}
	
	
	public function get __thumbSkin():String {
		return "vScrollBarThumbSkin";
	}
}