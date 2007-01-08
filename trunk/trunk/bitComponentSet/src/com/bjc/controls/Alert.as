import com.bjc.controls.Window;
import com.bjc.controls.Label;
import com.bjc.core.LabelWrapper;
import mx.events.EventDispatcher;

[IconFile ("icons/Alert.png")]

[Event("close")]

/**
* An alert box that can be popped up to display a message.
* <BR><BR>
* Events:
* <BR><BR>
* <B>close</B> - Fired when the user clicks the close button on the window, just prior to the component being removed.
* @author Beam Jive Consulting - www.beamjive.com
*/
class com.bjc.controls.Alert extends LabelWrapper {
	
	private var __html:Boolean = false;
	private var __message:String;
	private var __title:String = "Alert!";
	private var __window:Window;
	
	/**
		See the EventDispatcher Class in Flash Help
	*/
	public var addEventListener:Function;
	/**
		See the EventDispatcher Class in Flash Help
	*/
	public var removeEventListener:Function;
	private var dispatchEvent:Function;
	private var dispatchQueue:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myAlert.closeHandler = function(){
	* 	trace("I am about to close.");
	* }</pre>
	*/
	public var closeHandler:Function;
	
	public function Alert(Void) {
	}
	
	
	private function init(Void):Void {
		super.init();
		EventDispatcher.initialize(this);
		__window.setSize(__width, __height);
		__window.closeable = true;
		__window.move(Stage.width / 2 - __window.width / 2, Stage.height / 2 - __window.height / 2);
		__window.addEventListener("close", this);
		__window.contentPath = "alertContent";
		Selection.setFocus(__window);
		
		draw();
	}
	
	
	private function createChildren(Void):Void {
		attachMovie("Window", "__window", 0);
	}
	
	
	/**
		@exclude
		this is documented in BJCComponent, not changed here.
	*/
	public function draw(Void):Void {
		if(__enabled){
			_alpha = 100;
		} else {
			_alpha = __alphaDisabled;
		}
		__window.title = __title;
		if(__html){
			__window.content.textField.htmlText = __message;
		} else {
			__window.content.textField.text = __message;
		}
		__window.align = __align;
		__window.disabledColor = __disabledColor;
		__window.embedFont = __embedFont;
		__window.fontColor = __fontColor;
		__window.fontFace = __fontFace;
		__window.fontSize = __fontSize;
		__window.html = __html;
		size();
	}
	
	
	private function size(Void):Void {
		__window.setSize(__width, __height);
		__window.content.textField._width = __width - 4;
		__window.content.textField._height = __height - 22;
	}
	
	
	
	
	
	
	private function close(evtObj:Object):Void {
		dispatchEvent({type:"close", target:this});
		this.removeMovieClip();
	}
	
	
	/**
		Static method used to pop up an alert. Note, you must have the Alert component in the library of the movie that calls this function.
	
		@param target the movie clip in which the alert will be created.
		@param depth the depth at which to create the alert.
		@param message the message that will be shown in the alert box
		@param title the title shown in the alert window title bar
		@param initObj (optional) an object containing any properties you want to assign to the component when it is created
		@return reference to the alert object created.
		@example
		<pre>
		import com.bjc.controls.Alert;
		var myAlert:Alert = com.bjc.controls.Alert.create(_root, 1000, "Warning, you can't do that!", "This is an alert.");
		</pre>
	*/
	public static function create(target:MovieClip, depth:Number, message:String, title:String, initObj:Object):Alert {
		var alert:Alert = Alert(target.attachMovie("Alert", "alert" + depth, depth, initObj));
		alert.message = message;
		if(title != undefined){
			alert.title = title;
		} else {
			alert.title = "Alert";
		}
		return alert;
	}


	/**
		@exclude
		this is documented in BJCComponent, not changed here.
	*/
	public function move(x:Number, y:Number):Void {
		__window.move(x, y);
	}
	
	
	
	
	
	
	/**
		If true, message may contain html tags (limited to those that Flash handles).
	
		@example
		<pre>
		var myAlert:Alert = com.bjc.controls.Alert.create(_root, 1000, "<b>Warning</b>, you can't do that!", "This is an alert.");
		myAlert.html = true;
		</pre>
	*/
	public function set html(b:Boolean) {
		__html = b;
		invalidate();
	}
	/**
		Gets the html mode of the component.
	
		@example
		<pre>
		myVar = myAlert.html;
		</pre>
	*/
	public function get html():Boolean {
		return __html;
	}
	
	
	/**
		Sets the message displayed in the alert box. This is usually set as a parameter in the create function, but can also be set or changed here.
	
		<pre>
		var myAlert:Alert = com.bjc.controls.Alert.create(_root, 1000, "I'm thinking...", "This is an alert.");
		myAlert.message = "Warning, you can't do that!";
		</pre>
	*/
	public function set message(txt:String) {
		__message = txt;
		invalidate();
	}
	/**
		Gets the message displayed in the alert box.
	
		<pre>
		myVar = myAlert.message;
		</pre>
	*/
	public function get message():String {
		return __message;
	}
	
	
	/**
		Sets the title displayed in the alert window title bar. This is usually set as a parameter in the create function, but can also be set or changed here.
	
		<pre>
		var myAlert:Alert = com.bjc.controls.Alert.create(_root, 1000, "Warning, you can't do that!", "I'm thinking...");
		myAlert.title = "This is an alert.";
		</pre>
	*/
	public function set title(txt:String) {
		__title = txt;
		invalidate();
	}
	/**
		Gets the title displayed in the alert window title bar.
	
		<pre>
		myVar = myAlert.title = "This is an alert.";
		</pre>
	*/
	public function get title():String {
		return __title;
	}
	
}