/*
* @author Beam Jive Consulting - www.beamjive.com
*/
class com.bjc.core.LabelWrapper extends com.bjc.core.BJCComponent {
 	private var clipParameters:Object = {align:1, disableStyles:1, embedFont:1, fontColor:1, fontFace:1, fontSize:1, html:1};

	private var __align:String = "left";
	private var __disabledColor:Number = 0x999999;
	private var __disableStyles:Boolean = false;
	private var __embedFont:Boolean = false;
	private var __fontColor:Number = 0x333333;
	private var __fontFace:String = "_sans";
	private var __fontSize:Number = 12;
	private var __html:Boolean = false;
	


	public function LabelWrapper(Void) {
	}
	
	
	private function init(Void):Void {
		super.init();
	}
	
	


	/**
		Sets the horizontal alignment of the text in the component. Valid values are "left", "right" and "center".
		@example
		<pre>
		myComp.align = "center";
		</pre>
	*/
	[Inspectable (defaultValue="left", enumeration="left,right,center", category="textstyles", verbose=1)]
	public function set align(a:String) {
		__align = a;
		invalidate();
	}
	/**
		Gets the horizontal alignment of the text in the component.
		@example
		<pre>
		myVar = myComp.align;
		</pre>
	*/
	public function get align():String {
		return __align;
	}


	/**
		Sets the color of the text in the component when the component is disabled
	
		@example
		<pre>
		myComp.disabledColor = 0x999999;
		</pre>
	*/
	public function set disabledColor(c:Number) {
		__disabledColor = c;
		invalidate();
	}
	/**
		Gets the color of the text in the component when the component is disabled
	
		@example
		<pre>
		myVar = myComp.disabledColor;
		</pre>
	*/
	public function get disabledColor():Number {
		return __disabledColor;
	}
	
	/**
		Determines whether or not the style properties for the component will be used. Set to false if you want to style the text through html or style sheets.
	
		@example
		<pre>
		myComp.disableStyles = true;
		</pre>
	*/
	[Inspectable (type="Boolean", defaultValue=false)]
	public function set disableStyles(b:Boolean) {
		__disableStyles = b;
		invalidate();
	}
	
	/**
		Gets the availability of the component style properties.
	
		@example
		<pre>
		myVar = myComp.disableStyles;
		</pre>
	*/
	public function get disableStyles():Boolean {
		return __disableStyles;
	}
	
	
	/**
		Sets whether or not the font used in the component should be embedded. Note that if this is set to true, the font used must be included in a font symbol exported from the library, or in a text field somewhere on stage in the movie, with that font embedded.
	
		@example
		<pre>
		myComp.embedFont = true;
		</pre>
	*/
	[Inspectable (defaultValue=false, type="Boolean", category="textstyles", verbose=1)]
	public function set embedFont(b:Boolean) {
		__embedFont = b;
		invalidate();
	}
	/**
		Gets whether or not the font used in the component should be embedded. Note that if this is set to true, the font used must be included in a font symbol exported from the library, or in a text field somewhere on stage in the movie, with that font embedded.
	
		@example
		<pre>
		myVar = myComp.embedFont;
		</pre>
	*/
	public function get embedFont():Boolean {
		return __embedFont;
	}
	
	
	/**
		Sets the color of the font used in the component.
	
		@example
		<pre>
		myComp.fontColor = 0xff0000;
		</pre>
	*/
	[Inspectable (type="Color", defaultValue="#000000", category="textstyles", verbose=1)]
	public function set fontColor(col:Number) {
		__fontColor = col;
		invalidate();
	}
	/**
		Gets the color of the font used in the component.
	
		@example
		<pre>
		myVar = myComp.fontColor;
		</pre>
	*/
	public function get fontColor():Number {
		return __fontColor;
	}
	
	
	/**
		Sets the font to be used to display text in the component.
	
		@example
		<pre>
		myComp.fontFace = "Arial";
		</pre>
	*/
	[Inspectable (type="Font Name", defaultValue="_sans", category="textstyles", verbose=1)]
	public function set fontFace(font:String) {
		__fontFace = font;
		invalidate();
	}
	/**
		Gets the font used to display text in the component.
	
		@example
		<pre>
		myVar = myComp.fontFace;
		</pre>
	*/
	public function get fontFace():String {
		return __fontFace;
	}
	
	
	/**
		Sets the size of the font to be used in the component.
	
		@example
		<pre>
		myComp.fontSize = 20;
		</pre>
	*/
	[Inspectable (defaultValue=12, category="textstyles", verbose=1)]
	public function set fontSize(size:Number) {
		__fontSize = size;
		invalidate();
	}
	/**
		Gets the size of the font used in the component.
	
		@example
		<pre>
		myVar = myComp.fontSize;
		</pre>
	*/
	public function get fontSize():Number {
		return __fontSize;
	}
	
	
	/**
		If html is set to true, basic html tags may be used in the component.
	
		@example
		<pre>
		myComp.html = true;
		myComp.text = "<b>Bold</b> text is possible.";
		</pre>
	*/
	[Inspectable (type="Boolean", defaultValue=false, category="textstyles", verbose=1)]
	public function set html(b:Boolean) {
		__html = b;
		invalidate();
	}
	/**
		Gets the html mode of the component.
	
		@example
		<pre>
		myVar = myComp.html;
		</pre>
	*/
	public function get html():Boolean {
		return __html;
	}
	

}