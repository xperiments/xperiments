import com.bjc.core.LabelWrapper;

[IconFile ("icons/Label.png")]

/**
* A general purpose label component for displaying a small amount of text.
* @author Beam Jive Consulting - www.beamjive.com
*/
class com.bjc.controls.Label extends LabelWrapper {
  	private var clipParameters:Object = {text:1};
 	private static var mergedClipParameters:Boolean = com.bjc.core.BJCComponent.mergeClipParameters(Label.prototype.clipParameters, LabelWrapper.prototype.clipParameters);



	
	private var __format:TextFormat;
	private var __text:String = "";
	private var __tf:TextField;
	

	public function Label(Void) {
	}
	
	
	private function init(Void):Void {
		super.init();
		__tf.selectable = false;
 		draw();
	}
	
	
	private function createChildren(Void):Void {
 		createTextField("tf", 0, 0, 0, 100, 22);
 		__tf = this["tf"];
	}
	
	/**
		@exclude
	*/
	public function draw(Void):Void {
		__format = new TextFormat(__fontFace, __fontSize, __fontColor);
		__format.align = __align;
		if(!__enabled){
			__format.color = __disabledColor;
		}
		if(!_global.isLivePreview){
			__tf.embedFonts = __embedFont;
		}
		if(__html){
			__tf.html = true;
			__tf.htmlText = __text;
		} else {
			__tf.html = false;
			__tf.text = __text;
		}
		if(!__disableStyles){
			__tf.setTextFormat(__format);
			__tf.setNewTextFormat(__format);
		}
		size();
	}
	
	
	private function size(Void):Void {
		__tf._width = __width;
 		__tf._height = __tf.textHeight + 4;
		__tf._y = Math.round(__height / 2 - __tf._height / 2);
	}
	
	
	/**
		Static method used to create an instance of a Label on stage at run time.
				
		@param target the movie clip to which the label will be attached.
		@param id the instance name given to the new label attached.
		@param depth the depth at which to attach the new label.
		@param initObj (optional) an object containing any properties you want to assign to the component when it is created
		@return a reference to the new label attached.
		@example
		<pre>
		import com.bjc.controls.Label;
		var newLabel:Label = Label.create(_root, "myLabel", 0);
		</pre>
	*/
	public static function create(target:MovieClip, id:String, depth:Number, initObj:Object):Label {
		return Label(target.attachMovie("Label", id, depth, initObj));
	}
		
	

	
	
	
	
	
	/**
		Sets or returns the text displayed in the label. Note that this can include basic html tags if Label.html is set to true.
		@example
		<pre>
		myLabel.text = "Volume";
		</pre>
	*/
	[Inspectable (type="String", defaultValue="Label")]
	public function set text(txt:String) {
		__text = txt;
 		draw();
	}
	[Bindable]
	/**
		Gets the text displayed in the label. Note that this can include basic html tags if Label.html is set to true.
		@example
		<pre>
		myVar = myLabel.text;
		</pre>
	*/
	public function get text():String {
		return __text;
	}
	
	
	/**
		Read only value returning the actual height in pixels of the text being displayed in the label.
		@example
		<pre>
		nextItem._y = myLabel._y + myLabel.textHeight + 10;
		</pre>
	*/
	public function get textHeight():Number {
 		return __tf.textHeight;
	}
}