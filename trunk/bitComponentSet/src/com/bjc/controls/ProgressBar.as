import com.bjc.controls.Label;
import com.bjc.resizers.HResizer;
import com.bjc.core.LabelWrapper;

[IconFile ("icons/ProgressBar.png")]


/**
* Displays the progress of any changing value, such as percent loaded, or amount of a song played.
* @author Beam Jive Consulting - www.beamjive.com
*/
class com.bjc.controls.ProgressBar extends LabelWrapper {
 	private var clipParameters:Object = {autoHide:1, digits:1, displayLabel:1, displayType:1, maximum:1, suffix:1};
	private static var mergedClipParameters:Boolean = com.bjc.core.BJCComponent.mergeClipParameters(ProgressBar.prototype.clipParameters, LabelWrapper.prototype.clipParameters);

	
	private var __autoHide:Boolean = false;
	private var __background:MovieClip;
	private var __bar:MovieClip;
	private var __digits:Number = 0;
	private var __displayLabel:Boolean = true;
	private var __displayType:String = "percent";
	private var __label:Label;
	private var __mask:MovieClip;
	private var __maximum:Number = 100;
	private var __suffix:String = "%";
	private var __value:Number = 0;
	
	
	
	
	public function ProgressBar(Void) {
	}
	
	
	private function init(Void):Void {
		super.init();
		__label.fontSize = 10;
		draw();
	}
	
	
	private function createChildren(Void):Void {
		attachMovie("HResizer", "__background", 0);
		__background.skin = "progressBarFalseSkin";
		__background.margin = 20;
		
		var temp:MovieClip = attachMovie("progressBarFalseSkin", "temp", 99);
		__background.height = temp._height;
		temp.removeMovieClip();
		
		attachMovie("HResizer", "__bar", 1);
		__bar.skin = "progressBarTrueSkin";
		__bar.margin = 20;
		
		temp = attachMovie("progressBarTrueSkin", "temp", 99);
		__bar.height = temp._height;
		temp.removeMovieClip();
		
		createEmptyMovieClip("__mask", 2)
		__mask.beginFill(0);
		__mask.lineTo(100, 0);
		__mask.lineTo(100, 100);
		__mask.lineTo(0, 100);
		__mask.lineTo(0, 0);
		__mask.endFill();
		
		__bar.setMask(__mask);
		attachMovie("Label", "__label", 3);
	}
	
	
	/**
		@exclude
	*/
	public function draw(Void):Void {
		if(__autoHide){
			_visible = (__value < __maximum);
		}
		if(__enabled){
			_alpha = 100;
		} else {
			_alpha = __alphaDisabled;
		}
		__label.enabled = __enabled;
		if(__displayLabel){
			__label._visible = true;
			if(isNaN(__value)){
				__value = 0;
			}
			if(__enabled){
				if(__displayType == "percent"){
					var percent = Math.round(__value / __maximum * __digits * 100) / __digits;
					__label.text = percent + " " + __suffix;
				} else if(__displayType == "value"){
					__label.text = (Math.round(__value * __digits) / __digits).toString() + " " + __suffix;
				} else if(__displayType == "valueTotal"){
					__label.text = (Math.round(__value * __digits) / __digits) + " / " + (Math.round(__maximum * __digits) / __digits) + " " + __suffix;
				}
			}
		} else {
			__label._visible = false;
		}
		__label.align = __align;
		__label.disabledColor = __disabledColor;
		__label.embedFont = __embedFont;
		__label.fontColor = __fontColor;
		__label.fontFace = __fontFace;
		__label.fontSize = __fontSize;
		__label.html = __html;
		size();
	}
	
	
	private function size(Void):Void {
		__label.width = __width;
		__label._y = __background.height;
		
		__background.width = __width;
		__bar.width = __width;
		if(__enabled){
			__mask._width = __width * __value / __maximum;
		}
	}
	
	
	/**
		Static method used to create an instance of a ProgressBar on stage at run time.
				
		@param target the movie clip to which the progress bar will be attached.
		@param id the instance name given to the new progress bar attached.
		@param depth the depth at which to attach the new progress bar.
		@param initObj (optional) an object containing any properties you want to assign to the component when it is created
		@return a reference to the new progress bar attached.
		@example
		<pre>
		import com.bjc.controls.ProgressBar;
		var newProgressBar:ProgressBar = ProgressBar.create(_root, "myProgressBar", 0);
		</pre>
	*/
	public static function create(target:MovieClip, id:String, depth:Number, initObj:Object):ProgressBar {
		return ProgressBar(target.attachMovie("ProgressBar", id, depth, initObj));
	}
		
	

	
	
	
	
	
	/**
		Sets the autohide mode of the component. If set to true, the progress bar will become invisible when the value has reached the maximum.
	
		@example
		<pre>
		myProgressBar.autoHide = true;
		</pre>
	*/
	[Inspectable (type="Boolean", defaultValue=false)]
	public function set autoHide(b:Boolean) {
		__autoHide = b;
		invalidate();
	}
	/**
		Gets the autohide mode of the component.
	
		@example
		<pre>
		myVar = myProgressBar.autoHide;
		</pre>
	*/
	public function get autoHide():Boolean {
		return __autoHide;
	}
	
	
	/**
		Determines how many digits of accuracy to display in the display label. i.e. a value of two will show 99.99 %, one will show 99.9 %, zero will show 99 %.
	 
		@example
		<pre>
		myProgressBar.digits = 2;
		</pre>
	*/
	[Inspectable (defaultValue=0)]
	public function set digits(d:Number) {
		__digits = Math.pow(10, d);
	}
	/**
		Gets the amount of accuracy digits displayed in the label.
	 
		@example
		<pre>
		myVar = myProgressBar.digits;
		</pre>
	*/
	public function get digits():Number {
		return __digits.toString().length - 1;
	}
	
	
	/**
		Sets the visibility of the component label. If true, a label will appear below the bar, showing percent loaded, value, or value / maximum.
	
		@example
		<pre>
		myProgressbar.displayLabel = true;
		</pre>
	*/
	[Inspectable (type="Boolean", defaultValue=true)]
	public function set displayLabel(b:Boolean) {
		__displayLabel = b;
	}
	/**
		Gets the visibility of the component label. 
	
		@example
		<pre>
		myVar = myProgressbar.displayLabel;
		</pre>
	*/
	public function get displayLabel():Boolean {
		return __displayLabel;
	}	
	
	
	/**
		Determines what type of data will be displayed in the label. "percent" will display the percentage of the value to maximum. "value" simply displays the value. "valueTotal displays value and total, separated by "/".
	
		@example
		<pre>
		myProgressBar.displayLabel = true;
		myProgressBar.displaytype = "valueTotal";
		myProgressBar.suffix = "seconds";
		// will display something like: "34 / 45 seconds"
		</pre>
	*/
	[Inspectable (defaultValue="percent", enumeration="percent,value,valueTotal")]
	public function set displayType(type:String) {
		__displayType = type;
	}
		/**
		Gets the data type displayed in the label. 
	
		@example
		<pre>
		myVar = myProgressBar.displaytype;
		</pre>
	*/
	public function get displayType():String {
		return __displayType;
	}
	
	
	/**
		Sets the maximum value that the progress bar can achieve. This would often be 100 for diplaying a percentage value, or could be MovieClip.getBytesTotal(), or Sound.duration.
	
		@example
		<pre>
		myProgressBar.maximum = mySound.duration;
		</pre>
	*/
	[Inspectable (defaultValue=100)]
	public function set maximum(max:Number) {
		__maximum = max;
	}
	/**
		Gets the maximum value that the progress bar can achieve.
	
		@example
		<pre>
		myVar = myProgressBar.maximum;
		</pre>
	*/
	public function get maximum():Number {
		return __maximum;
	}
	
	
	/**
		A string added on to the end of the numbers displayed in the label. Used to show what the units specify.
	
		@example
		<pre>
		myProgressBar.suffix = "bytes";
		</pre>
	*/
	[Inspectable (defaultValue="%")]
	public function set suffix(str:String) {
		__suffix = str;
	}
	/**
		Gets the string added on to the end of the numbers displayed in the label. 
	
		@example
		<pre>
		myVar = myProgressBar.suffix;
		</pre>
	*/
	public function get suffix():String {
		return __suffix;
	}
	
	
	/**
		Sets the progress displayed by the bar. For example, if maximum is 100 and value is 50, the progress bar will show 1/2 way done.
	
		@example
		<pre>
		myProgressBar.value = myClip.getBytesLoaded();
		</pre>
	*/
	public function set value(v:Number) {
		__value = v;
		__value = Math.min(__value, __maximum);
		invalidate();
	}
	[Bindable]
	[ChangeEvent ("value")]
	/**
		Gets the progress displayed by the bar. 
	
		@example
		<pre>
		myVar = myProgressBar.value;
		</pre>
	*/
	public function get value():Number {
		return __value;
	}
	
	
}