[IconFile ("icons/HResizer.png")]

/**
* Enables smooth horizontal resizing of a predefined graphic element, keeping the left and right margins the same and stretching the middle. This is useful when you have a shape with curved or irregularly shaped edges, and you don't want the curves to stretch out.
* @example
* <pre>
* attachMovie("HResizer", "toolBar", 0);
* toolBar.skin = "myToolBarSkin";
* toolBar.leftMargin = 20;
* toolBar.rightMargin = 20;
* toolBar.width = 500;
* </pre>
* @author Beam Jive Consulting - www.beamjive.com
*/
class com.bjc.resizers.HResizer extends com.bjc.core.BJCComponent {
 	private var clipParameters:Object = {leftMargin:1, rightMargin:1, skin:1};
 	
	private var __left:MovieClip;
	private var __leftMargin:Number = 30;
	private var __mid:MovieClip;
	private var __right:MovieClip;
	private var __rightMargin:Number = 30;
	private var __skin:String;
	
	public function HResizer(Void) {
	}
	
	
	private function init(Void):Void {
		super.init();
		draw();
	}
	
	
	private function createChildren(Void):Void {
		createEmptyMovieClip("__left", 0);
 		createEmptyMovieClip("__mid", 1);
 		createEmptyMovieClip("__right", 2);
		
		__left.createEmptyMovieClip("mask", 1);
		__mid.createEmptyMovieClip("mask", 1);
		__right.createEmptyMovieClip("mask", 1);
	}
	
	
	/**
		@exclude
		this is documented in BJCComponent, not changed here.
	*/
	public function draw(Void):Void {
		if(__skin != undefined && __skin != ""){
			__left.attachMovie(__skin, "skin", 0);
	 		__mid.attachMovie(__skin, "skin", 0);
			__right.attachMovie(__skin, "skin", 0);
			__left.skin.setMask(__left.mask);
			__mid.skin.setMask(__mid.mask);
	 		__right.skin.setMask(__right.mask);
			size();
		}
	}
	
	
	private function size(Void):Void {
		__width = Math.max(__width, __leftMargin + __rightMargin);
		if(__skin != undefined && __skin != ""){
			__left.skin._height = __height;
			
			// calculate how much to scale mid piece
			__mid.skin._xscale = 100;
			var midWidthOrig:Number = __mid.skin._width - __leftMargin - __rightMargin;
			var midWidthScaled:Number = __width - __leftMargin - __rightMargin;
			var scale:Number = midWidthScaled / midWidthOrig;
			
			// reposition and size mid piece based on scale
			__mid.skin._xscale = scale * 100;
			__mid.skin._x = -__leftMargin * scale;
			__mid._x = __leftMargin;
			__mid.skin._height = __height;
			
			// position and size right piece
			__right._x = __width - __rightMargin;
			__right.skin._x = __rightMargin - __right.skin._width;
			__right.skin._height = __height;
			
			// draw mask for left piece
			__left.mask.clear();
			__left.mask.beginFill(0xffffff);
			__left.mask.lineTo(__leftMargin, 0);
			__left.mask.lineTo(__leftMargin, __height);
			__left.mask.lineTo(0, __height);
			__left.mask.lineTo(0, 0);
			__left.mask.endFill();
			
			// draw mask for mid piece
			__mid.mask.clear();
			__mid.mask.beginFill(0xffffff);
			__mid.mask.lineTo(midWidthScaled, 0);
			__mid.mask.lineTo(midWidthScaled, __height);
			__mid.mask.lineTo(0, __height);
			__mid.mask.lineTo(0, 0);
			__mid.mask.endFill();
			
			// draw mask for left piece
			__right.mask.clear();
			__right.mask.beginFill(0xffffff);
			__right.mask.lineTo(__rightMargin, 0);
			__right.mask.lineTo(__rightMargin, __height);
			__right.mask.lineTo(0, __height);
			__right.mask.lineTo(0, 0);
			__right.mask.endFill();
		}
	}
	
	
	/**
		Static method used to create an instance of a HResizer on stage at run time.
				
		@param target the movie clip to which the resizer will be attached.
		@param id the instance name given to the new resizer attached.
		@param depth the depth at which to attach the new resizer.
		@param initObj (optional) an object containing any properties you want to assign to the component when it is created
		@return a reference to the new resizer attached.
		@example
		<pre>
		import com.bjc.controls.HResizer;
		var newHResizer:HResizer = HResizer.create(_root, "myHResizer", 0);
		</pre>
	*/
	public static function create(target:MovieClip, id:String, depth:Number, initObj:Object):HResizer {
		return HResizer(target.attachMovie("HResizer", id, depth, initObj));
	}
		
	

	
	
	
	
	
	/**
		Sets how much of the left hand side of the graphic will not be stretched. Default value is 20 pixels.
	
		@example
		<pre>
		attachMovie("HResizer", "toolBar", 0);
		toolBar.skin = "myToolBarSkin";
		toolBar.leftMargin = 20;
		toolBar.rightMargin = 20;
		toolBar.width = 500;
		</pre>
	*/
	[Inspectable (defaultValue=20)]
	public function set leftMargin(lm:Number) {
		__leftMargin = lm;
		invalidate();
	}
	/**
		Gets how much of the left hand side of the graphic will not be stretched. 
	
		@example
		<pre>
		myVar = toolBar.leftMargin;
		</pre>
	*/
	public function get leftMargin():Number {
		return __leftMargin;
	}
	
	
	/**
		Sets the leftMargin and rightMargin to the same value.
	
		@return If leftMargin and rightMargin are equal, returns their value, otherwise returns undefined.
		@example
		<pre>
		attachMovie("HResizer", "toolBar", 0);
		toolBar.skin = "myToolBarSkin";
		toolBar.margin = 20;
		toolBar.width = 500;
		</pre>
	*/
	public function set margin(m:Number) {
		__leftMargin = m;
		__rightMargin = m;
		invalidate();
	}
	/**
		If leftMargin and rightMargin are equal, returns their value, otherwise returns undefined.
		@example
		<pre>
		myaVar = toolBar.margin;
		</pre>
	*/
	public function get margin():Number {
		if(__leftMargin == __rightMargin){
			return __rightMargin;
		} else {
			return undefined;
		}
	}
	
	
	/**
		Sets how much of the right hand side of the graphic will not be stretched. Default value is 20 pixels.
	
		@example
		<pre>
		attachMovie("HResizer", "toolBar", 0);
		toolBar.skin = "myToolBarSkin";
		toolBar.leftMargin = 20;
		toolBar.rightMargin = 20;
		toolBar.width = 500;
		</pre>
	*/
	[Inspectable (defaultValue=20)]
	public function set rightMargin(rm:Number) {
		__rightMargin = rm;
		invalidate();
	}
	/**
		Gets how much of the right hand side of the graphic will not be stretched. 
	
		@example
		<pre>
		myVar = toolBar.rightMargin;
		</pre>
	*/
	public function get rightMargin():Number {
		return __rightMargin;
	}
	
		
	/**
		Sets the skin to be used in the resizer. This is a string set to the linkage name of a movie clip containing a graphic. The movie clip must be set to export.
	
		@example
		<pre>
		attachMovie("HResizer", "toolBar", 0);
		toolBar.skin = "myToolBarSkin";
		// "toolBarSkin" is the linkage name of a movie clip in the library, containing the stretchable graphic.
		toolBar.margin = 20;
		toolBar.width = 500;
		</pre>
	*/
	[Inspectable]
	public function set skin(symbol:String) {
		__skin = symbol;
		draw();
	}
	/**
		Gets the skin used in the resizer.
	
		@example
		<pre>
		myVar = toolBar.skin;
		</pre>
	*/
	public function get skin():String {
		return __skin;
	}
}