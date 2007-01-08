[IconFile ("icons/VResizer.png")]

/**
* Enables smooth vertical resizing of a predefined graphic element, keeping the top and bottom margins the same and stretching the middle. This is useful when you have a shape with curved or irregularly shaped edges, and you don't want the curves to stretch out.
* @example
* <pre>
* attachMovie("VResizer", "navMenu", 0);
* navMenu.skin = "navMenuSkin";
* navMenu.topMargin = 20;
* navMenu.bottomMargin = 20;
* navMenu.height = 500;
* </pre>
* @author Beam Jive Consulting - www.beamjive.com
*/
class com.bjc.resizers.VResizer extends com.bjc.core.BJCComponent {
 	private var clipParameters:Object = {topMargin:1, bottomMargin:1, skin:1};

	private var __top:MovieClip;
	private var __topMargin:Number = 30;
	private var __mid:MovieClip;
	private var __bottom:MovieClip;
	private var __bottomMargin:Number = 30;
	private var __skin:String;
	
	public function VResizer(Void) {
	}
	
	
	private function init(Void):Void {
		super.init();
		draw();
	}
	
	
	private function createChildren(Void):Void {
		createEmptyMovieClip("__top", 0);
 		createEmptyMovieClip("__mid", 1);
 		createEmptyMovieClip("__bottom", 2);
		
		__top.createEmptyMovieClip("mask", 1);
		__mid.createEmptyMovieClip("mask", 1);
		__bottom.createEmptyMovieClip("mask", 1);
	}
	
	
	/**
		@exclude
		this is documented in BJCComponent, not changed here.
	*/
	public function draw(Void):Void {
		if(__skin != undefined && __skin != ""){
			__top.attachMovie(__skin, "skin", 0);
	 		__mid.attachMovie(__skin, "skin", 0);
			__bottom.attachMovie(__skin, "skin", 0);
			__top.skin.setMask(__top.mask);
			__mid.skin.setMask(__mid.mask);
	 		__bottom.skin.setMask(__bottom.mask);
			size();
		}
	}
	
	
	private function size(Void):Void {
		__height = Math.max(__height, __topMargin + __bottomMargin);
		if(__skin != undefined && __skin != ""){
			__top.skin._width = __width;
			
			// calculate how much to scale mid piece
			__mid.skin._yscale = 100;
			var midheightOrig:Number = __mid.skin._height - __topMargin - __bottomMargin;
			var midheightScaled:Number = __height - __topMargin - __bottomMargin;
			var scale:Number = midheightScaled / midheightOrig;
			
			// reposition and size mid piece based on scale
			__mid.skin._yscale = scale * 100;
			__mid.skin._y = -__topMargin * scale;
			__mid._y = __topMargin;
			__mid.skin._width = __width;
			
			// position and size bottom piece
			__bottom._y = __height - __bottomMargin;
			__bottom.skin._y = __bottomMargin - __bottom.skin._height;
			__bottom.skin._width = __width;
			
			// draw mask for top piece
			__top.mask.clear();
			__top.mask.beginFill(0xffffff);
			__top.mask.lineTo(0, __topMargin);
			__top.mask.lineTo(__width, __topMargin);
			__top.mask.lineTo(__width, 0);
			__top.mask.lineTo(0, 0);
			__top.mask.endFill();
			
			// draw mask for mid piece
			__mid.mask.clear();
			__mid.mask.beginFill(0xffffff);
			__mid.mask.lineTo(0, midheightScaled);
			__mid.mask.lineTo(__width, midheightScaled);
			__mid.mask.lineTo(__width, 0);
			__mid.mask.lineTo(0, 0);
			__mid.mask.endFill();
			
			// draw mask for top piece
			__bottom.mask.clear();
			__bottom.mask.beginFill(0xffffff);
			__bottom.mask.lineTo(0, __bottomMargin);
			__bottom.mask.lineTo(__width, __bottomMargin);
			__bottom.mask.lineTo(__width, 0);
			__bottom.mask.lineTo(0, 0);
			__bottom.mask.endFill();
		}
	}
	
	
	/**
		Static method used to create an instance of a VResizer on stage at run time.
				
		@param target the movie clip to which the resizer will be attached.
		@param id the instance name given to the new resizer attached.
		@param depth the depth at which to attach the new resizer.
		@param initObj (optional) an object containing any properties you want to assign to the component when it is created
		@return a reference to the new resizer attached.
		@example
		<pre>
		import com.bjc.controls.VResizer;
		var newVResizer:VResizer = VResizer.create(_root, "myVResizer", 0);
		</pre>
	*/
	public static function create(target:MovieClip, id:String, depth:Number, initObj:Object):VResizer {
		return VResizer(target.attachMovie("VResizer", id, depth, initObj));
	}
		
	
	
	
	
	
	/**
		Sets how much of the bottom of the graphic will not be stretched. Default value is 20 pixels.
	
		@example
		<pre>
		attachMovie("VResizer", "navMenu", 0);
		navMenu.skin = "navMenuSkin";
		navMenu.topMargin = 20;
		navMenu.bottomMargin = 20;
		navMenu.height = 500;
		</pre>
	*/
	[Inspectable (defaultValue=20)]
	public function set bottomMargin(rm:Number) {
		__bottomMargin = rm;
		invalidate();
	}
	/**
		Gets how much of the bottom of the graphic will not be stretched.
	
		@example
		<pre>
		myVar = navMenu.bottomMargin;
		</pre>
	*/
	public function get bottomMargin():Number {
		return __bottomMargin;
	}


	/**
		Sets the topMargin and bottomMargin to the same value.
	
		@return If topMargin and bottomMargin are equal, returns their value, otherwise returns undefined.
		@example
		<pre>
		attachMovie("VResizer", "navMenu", 0);
		navMenu.skin = "navMenuSkin";
		navMenu.margin = 20;
		navMenu.height = 500;
		</pre>
	*/
	public function set margin(m:Number) {
		__topMargin = m;
		__bottomMargin = m;
		invalidate();
	}
	/**
		If topMargin and bottomMargin are equal, returns their value, otherwise returns undefined.
		
		@example
		<pre>
		myVar = navMenu.margin;
		</pre>
	*/
	public function get margin():Number {
		if(__topMargin == __bottomMargin){
			return __bottomMargin;
		} else {
			return undefined;
		}
	}


	/**
		Sets the skin to be used in the resizer. This is a string set to the linkage name of a movie clip containing a graphic. The movie clip must be set to export.
	
		@example
		<pre>
		attachMovie("VResizer", "navMenu", 0);
		navMenu.skin = "navMenuSkin";
		// "navMenuSkin" is the linkage name of a movie clip in the library, containing the stretchable graphic.
		navMenu.topMargin = 20;
		navMenu.bottomMargin = 20;
		navMenu.height = 500;
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
		myVar = navMenu.skin;
		</pre>
	*/
	public function get skin():String {
		return __skin;
	}
	
	
	/**
		Sets how much of the top of the graphic will not be stretched. Default value is 20 pixels.
	
		@example
		<pre>
		attachMovie("VResizer", "navMenu", 0);
		navMenu.skin = "navMenuSkin";
		navMenu.topMargin = 20;
		navMenu.bottomMargin = 20;
		navMenu.height = 500;
		</pre>
	*/
	[Inspectable (defaultValue=20)]
	public function set topMargin(lm:Number) {
		__topMargin = lm;
		invalidate();
	}
	/**
		Gets how much of the top of the graphic will not be stretched. 
	
		@example
		<pre>
		myVar = navMenu.topMargin;
		</pre>
	*/
	public function get topMargin():Number {
		return __topMargin;
	}
}