[IconFile ("icons/Resizer.png")]


/**
* Enables smooth horizontal and vertical resizing of a predefined graphic element, keeping the four corners the same and stretching the middle. This is useful when you have a shape with curved or irregularly shaped edges, and you don't want the curves to stretch out. It is recommended that you use HResizer or VResizer where resizing in only one direction is needed, as they are far simpler and more efficient.
* @example
* <pre>
* attachMovie("Resizer", "panel", 0);
* panel.skin = "panelSkin";
* panel.topMargin = 20;
* panel.bottomMargin = 20;
* panel.leftMargin = 20;
* panel.rightMargin = 20;
* panel.setSize(500, 500);
* </pre>
* @author Beam Jive Consulting - www.beamjive.com
*/
class com.bjc.resizers.Resizer extends com.bjc.core.BJCComponent {
 	private var clipParameters:Object = {topMargin:1, bottomMargin:1, leftMargin:1, rightMargin:1, skin:1};
	
	
	private var __topLeft:MovieClip;
	private var __topMid:MovieClip;
	private var __topRight:MovieClip;
	
	private var __midLeft:MovieClip;
	private var __midMid:MovieClip;
	private var __midRight:MovieClip;
	
	private var __bottomLeft:MovieClip;
	private var __bottomMid:MovieClip;
	private var __bottomRight:MovieClip;
	
	private var __bottomMargin:Number = 30;
	private var __leftMargin:Number = 30;
	private var __rightMargin:Number = 30;
	private var __topMargin:Number = 30;
	private var __skin:String = "defaultSkin";
	
	public function Resizer(Void) {
	}
	
	
	private function init(Void):Void {
		super.init();
		draw();
	}
	
	
	private function createChildren(Void):Void {
		createEmptyMovieClip("__topLeft", 0);
		createEmptyMovieClip("__topMid", 1);
		createEmptyMovieClip("__topRight", 2);
 		createEmptyMovieClip("__midLeft", 3);
 		createEmptyMovieClip("__midMid", 4);
 		createEmptyMovieClip("__midRight", 5);
 		createEmptyMovieClip("__bottomLeft", 6);
 		createEmptyMovieClip("__bottomMid", 7);
 		createEmptyMovieClip("__bottomRight", 8);
		
		__topLeft.createEmptyMovieClip("mask", 1);
		__topMid.createEmptyMovieClip("mask", 1);
		__topRight.createEmptyMovieClip("mask", 1);
		__midLeft.createEmptyMovieClip("mask", 1);
		__midMid.createEmptyMovieClip("mask", 1);
		__midRight.createEmptyMovieClip("mask", 1);
		__bottomLeft.createEmptyMovieClip("mask", 1);
		__bottomMid.createEmptyMovieClip("mask", 1);
		__bottomRight.createEmptyMovieClip("mask", 1);
	}
	
	
	/**
		@exclude
		this is documented in BJCComponent, not changed here.
	*/
	public function draw(Void):Void {
		__topLeft.attachMovie(__skin, "skin", 0);
		__topMid.attachMovie(__skin, "skin", 0);
		__topRight.attachMovie(__skin, "skin", 0);
 		__midLeft.attachMovie(__skin, "skin", 0);
 		__midMid.attachMovie(__skin, "skin", 0);
 		__midRight.attachMovie(__skin, "skin", 0);
		__bottomLeft.attachMovie(__skin, "skin", 0);
		__bottomMid.attachMovie(__skin, "skin", 0);
		__bottomRight.attachMovie(__skin, "skin", 0);
		
		__topLeft.skin.setMask(__topLeft.mask);
		__topMid.skin.setMask(__topMid.mask);
		__topRight.skin.setMask(__topRight.mask);
		__midLeft.skin.setMask(__midLeft.mask);
		__midMid.skin.setMask(__midMid.mask);
		__midRight.skin.setMask(__midRight.mask);
 		__bottomLeft.skin.setMask(__bottomLeft.mask);
 		__bottomMid.skin.setMask(__bottomMid.mask);
 		__bottomRight.skin.setMask(__bottomRight.mask);
		size();
	}
	
	
	private function size(Void):Void {
		__width = Math.max(__width, __leftMargin + __rightMargin);
		__height = Math.max(__height, __topMargin + __bottomMargin);
		// calculate how much to scale mid pieces
		__midMid.skin._xscale = 100;
		__midMid.skin._yscale = 100;
		var midWidthOrig:Number = __midMid.skin._width - __leftMargin - __rightMargin;
		var midWidthScaled:Number = __width - __leftMargin - __rightMargin;
		var xscale:Number = midWidthScaled / midWidthOrig;
		var midheightOrig:Number = __midMid.skin._height - __topMargin - __bottomMargin;
		var midheightScaled:Number = __height - __topMargin - __bottomMargin;
		var yscale:Number = midheightScaled / midheightOrig;
		
// top row===================================================
		
		// __topLeft doesn't need to do anything
		
		__topMid.skin._xscale = xscale * 100;
		__topMid.skin._x = -__leftMargin * xscale;
		__topMid._x = __leftMargin;
		
		__topRight._x = __width - __rightMargin;
		__topRight.skin._x = __rightMargin - __topRight.skin._width;
		
		
// mid row===================================================
		
		__midLeft.skin._yscale = yscale * 100;
		__midLeft.skin._y = -__topMargin * yscale;
		__midLeft._y = __topMargin;
		
		__midMid.skin._xscale = xscale * 100;
		__midMid.skin._x = -__leftMargin * xscale;
		__midMid._x = __leftMargin;
		__midMid.skin._yscale = yscale * 100;
		__midMid.skin._y = -__topMargin * yscale;
		__midMid._y = __topMargin;
		
		__midRight._x = __width - __rightMargin;
		__midRight.skin._x = __rightMargin - __midRight.skin._width;
		__midRight.skin._yscale = yscale * 100;
		__midRight.skin._y = -__topMargin * yscale;
		__midRight._y = __topMargin;

// bottom row================================================

		__bottomLeft._y = __height - __bottomMargin;
		__bottomLeft.skin._y = __bottomMargin - __bottomLeft.skin._height;

		__bottomMid.skin._xscale = xscale * 100;
		__bottomMid.skin._x = -__leftMargin * xscale;
		__bottomMid._x = __leftMargin;
		__bottomMid._y = __height - __bottomMargin;
		__bottomMid.skin._y = __bottomMargin - __bottomMid.skin._height;

		__bottomRight._x = __width - __rightMargin;
		__bottomRight.skin._x = __rightMargin - __bottomRight.skin._width;
		__bottomRight._y = __height - __bottomMargin;
		__bottomRight.skin._y = __bottomMargin - __bottomRight.skin._height;


// masks ====================================================
	// top ---------------------------------
		// draw mask for top left piece
		__topLeft.mask.clear();
		__topLeft.mask.beginFill(0xffffff);
		__topLeft.mask.lineTo(__leftMargin, 0);
		__topLeft.mask.lineTo(__leftMargin, __topMargin);
		__topLeft.mask.lineTo(0, __topMargin);
		__topLeft.mask.lineTo(0, 0);
		__topLeft.mask.endFill();

		// draw mask for top mid piece
		__topMid.mask.clear();
		__topMid.mask.beginFill(0xffffff);
		__topMid.mask.lineTo(midWidthScaled, 0);
		__topMid.mask.lineTo(midWidthScaled, __topMargin);
		__topMid.mask.lineTo(0, __topMargin);
		__topMid.mask.lineTo(0, 0);
		__topMid.mask.endFill();

		// draw mask for top right piece
		__topRight.mask.clear();
		__topRight.mask.beginFill(0xffffff);
		__topRight.mask.lineTo(__rightMargin, 0);
		__topRight.mask.lineTo(__rightMargin, __topMargin);
		__topRight.mask.lineTo(0, __topMargin);
		__topRight.mask.lineTo(0, 0);
		__topRight.mask.endFill();

	// mid ---------------------------------
		// draw mask for top left piece
		__midLeft.mask.clear();
		__midLeft.mask.beginFill(0xffffff);
		__midLeft.mask.lineTo(__leftMargin, 0);
		__midLeft.mask.lineTo(__leftMargin, midheightScaled);
		__midLeft.mask.lineTo(0, midheightScaled);
		__midLeft.mask.lineTo(0, 0);
		__midLeft.mask.endFill();

		// draw mask for top mid piece
		__midMid.mask.clear();
		__midMid.mask.beginFill(0xffffff);
		__midMid.mask.lineTo(midWidthScaled, 0);
		__midMid.mask.lineTo(midWidthScaled, midheightScaled);
		__midMid.mask.lineTo(0, midheightScaled);
		__midMid.mask.lineTo(0, 0);
		__midMid.mask.endFill();

		// draw mask for top right piece
		__midRight.mask.clear();
		__midRight.mask.beginFill(0xffffff);
		__midRight.mask.lineTo(__rightMargin, 0);
		__midRight.mask.lineTo(__rightMargin, midheightScaled);
		__midRight.mask.lineTo(0, midheightScaled);
		__midRight.mask.lineTo(0, 0);
		__midRight.mask.endFill();


	// bottom ------------------------------
		// draw mask for top left piece
		__bottomLeft.mask.clear();
		__bottomLeft.mask.beginFill(0xffffff);
		__bottomLeft.mask.lineTo(__leftMargin, 0);
		__bottomLeft.mask.lineTo(__leftMargin, __bottomMargin);
		__bottomLeft.mask.lineTo(0, __bottomMargin);
		__bottomLeft.mask.lineTo(0, 0);
		__bottomLeft.mask.endFill();

		// draw mask for top mid piece
		__bottomMid.mask.clear();
		__bottomMid.mask.beginFill(0xffffff);
		__bottomMid.mask.lineTo(midWidthScaled, 0);
		__bottomMid.mask.lineTo(midWidthScaled, __bottomMargin);
		__bottomMid.mask.lineTo(0, __bottomMargin);
		__bottomMid.mask.lineTo(0, 0);
		__bottomMid.mask.endFill();

		// draw mask for top right piece
		__bottomRight.mask.clear();
		__bottomRight.mask.beginFill(0xffffff);
		__bottomRight.mask.lineTo(__rightMargin, 0);
		__bottomRight.mask.lineTo(__rightMargin, __bottomMargin);
		__bottomRight.mask.lineTo(0, __bottomMargin);
		__bottomRight.mask.lineTo(0, 0);
		__bottomRight.mask.endFill();

	}
	
	
	/**
		Static method used to create an instance of a Resizer on stage at run time.
				
		@param target the movie clip to which the resizer will be attached.
		@param id the instance name given to the new resizer attached.
		@param depth the depth at which to attach the new resizer.
		@param initObj (optional) an object containing any properties you want to assign to the component when it is created
		@return a reference to the new resizer attached.
		@example
		<pre>
		import com.bjc.controls.Resizer;
		var newResizer:Resizer = Resizer.create(_root, "myResizer", 0);
		</pre>
	*/
	public static function create(target:MovieClip, id:String, depth:Number, initObj:Object):Resizer {
		return Resizer(target.attachMovie("Resizer", id, depth, initObj));
	}
		
	

	
	
	
	
	
	
	/**
		Sets how much of the bottom of the graphic will not be stretched. Default value is 20 pixels.
	
		@example
		<pre>
		attachMovie("Resizer", "panel", 0);
		panel.skin = "panelSkin";
		panel.topMargin = 20;
		panel.bottomMargin = 20;
		panel.leftMargin = 20;
		panel.rightMargin = 20;
		panel.setSize(500, 500);
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
		myVar = panel.bottomMargin;
		</pre>
	*/
	public function get bottomMargin():Number {
		return __bottomMargin;
	}
	
	
	/**
		Sets how much of the left hand side of the graphic will not be stretched. Default value is 20 pixels.
	
		@example
		<pre>
		attachMovie("Resizer", "panel", 0);
		panel.skin = "panelSkin";
		panel.topMargin = 20;
		panel.bottomMargin = 20;
		panel.leftMargin = 20;
		panel.rightMargin = 20;
		panel.setSize(500, 500);
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
		myVar = panel.leftMargin;
		</pre>
	*/
	public function get leftMargin():Number {
		return __leftMargin;
	}
	
	
	/**
		Sets the topMargin, bottomMargin, leftMargin and rightMargin to the same value.
	
		@example
		<pre>
		attachMovie("Resizer", "panel", 0);
		panel.skin = "panelSkin";
		panel.margin = 20;
		panel.setSize(500, 500);
		</pre>
	*/
	public function set margin(m:Number) {
		__topMargin = m;
		__bottomMargin = m;
		__leftMargin = m;
		__rightMargin = m;
		invalidate();
	}
	/**
		If all four margin values are equal, returns their value, otherwise returns undefined.
		@example
		<pre>
		myVar = panel.margin;
		</pre>
	*/
	public function get margin():Number {
		if((__topMargin == __bottomMargin) && (__topMargin == __leftMargin) && (__topMargin == __rightMargin)){
			return __topMargin;
		} else {
			return undefined;
		}
	}
	
	
	/**
		Sets how much of the right hand side of the graphic will not be stretched. Default value is 20 pixels.
	
		@example
		<pre>
		attachMovie("Resizer", "panel", 0);
		panel.skin = "panelSkin";
		panel.topMargin = 20;
		panel.bottomMargin = 20;
		panel.leftMargin = 20;
		panel.rightMargin = 20;
		panel.setSize(500, 500);
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
		myVar = panel.rightMargin;
		</pre>
	*/
	public function get rightMargin():Number {
		return __rightMargin;
	}
	
	
	/**
		Sets the skin to be used in the resizer. This is a string set to the linkage name of a movie clip containing a graphic. The movie clip must be set to export.
	
		@example
		<pre>
		attachMovie("Resizer", "panel", 0);
		panel.skin = "panelSkin";
		// "panelSkin" is the linkage name of a movie clip in the library, containing the stretchable graphic.
		panel.topMargin = 20;
		panel.bottomMargin = 20;
		panel.leftMargin = 20;
		panel.rightMargin = 20;
		panel.setSize(500, 500);
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
		myVar = panel.skin;
		</pre>
	*/
	public function get skin():String {
		return __skin;
	}
	
	
	/**
		Sets how much of the top of the graphic will not be stretched. Default value is 20 pixels.
	
		@example
		<pre>
		attachMovie("Resizer", "panel", 0);
		panel.skin = "panelSkin";
		panel.topMargin = 20;
		panel.bottomMargin = 20;
		panel.leftMargin = 20;
		panel.rightMargin = 20;
		panel.setSize(500, 500);
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
		myVar = panel.topMargin;
		</pre>
	*/
	public function get topMargin():Number {
		return __topMargin;
	}
}