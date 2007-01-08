import mx.events.EventDispatcher;


[IconFile ("icons/Loader.png")]

[Event("load")]

[Event("progress")]

/**
* A loader component for loading in a jpg or movie clip from an external source. It will load the content, and fire a load event. After content is loaded, it can optionally scale the content to fit the component, or display it full size.
* <BR><BR>
* Events:
* <BR><BR>
* <B>load</B> - Fired when the content being loaded by the loader has completely loaded.
* <BR>
* <B>progress</B> - Fired once each frame while content is being loaded into the loader.
* @author Beam Jive Consulting - www.beamjive.com
*/
class com.bjc.controls.Loader extends com.bjc.core.BJCComponent {
 	private var clipParameters:Object = {autoLoad:1, autoScale:1, url:1};

	
	private var __autoLoad:Boolean = false;
	private var __autoScale:Boolean = false;
	private var __holder:MovieClip;
	private var __loaded:Number;
	private var __progress:Number;
	private var __url:String;
	
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
	* @usage <pre>myLoader.loadHandler = function(){
	* 	trace("I am done loading.");
	* }</pre>
	*/
	public var loadHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myLoader.progressHandler = function(){
	* 	trace("I am loading.");
	* }</pre>
	*/
	public var progressHandler:Function;



	public function Loader(Void) {
	}
	
	
	private function init(Void):Void {
		super.init();
		EventDispatcher.initialize(this);
		draw();
	}
	
	
	private function createChildren(Void):Void {
		createEmptyMovieClip("__holder", 0);
	}
	
	
	/**
		@exclude
	*/
	public function draw(Void):Void {
		if(__autoLoad){
			if(__url != undefined && __url != ""){
				load();
			}
		}
		size();
	}
	
	
	private function size(Void):Void {
		if(__autoScale && __loaded > 5) doScale();
	}
	
	
	/**
		Static method used to create an instance of a Loader on stage at run time.
				
		@param target the movie clip to which the loader will be attached.
		@param id the instance name given to the new loader attached.
		@param depth the depth at which to attach the new loader.
		@param initObj (optional) an object containing any properties you want to assign to the component when it is created
		@return a reference to the new loader attached.
		@example
		<pre>
		import com.bjc.controls.Loader;
		var newLoader:Loader = Loader.create(_root, "myLoader", 0);
		</pre>
	*/
	public static function create(target:MovieClip, id:String, depth:Number, initObj:Object):Loader {
		return Loader(target.attachMovie("Loader", id, depth, initObj));
	}
		
	

	
	
	
	
	
	private function doScale(Void):Void {
		__holder._xscale = 100;
		__holder._yscale = 100;
		var xscale:Number = __width / __holder._width;
		var yscale:Number = __height / __holder._height;
		var scale:Number = Math.min(xscale, yscale) * 100;
		__holder._xscale = scale;
		__holder._yscale = scale;
		__holder._x = __width / 2 - __holder._width / 2;
		__holder._y = __height / 2 - __holder._height / 2;
	}
	
	
	/**
		Begins loading the content specified in the url property. If autoLoad is set to false, content will not begin loading until this method is called. If autoLoad is true, this method is not necessary, as content will begin loading immediately after setting the url.
	
		@example
		<pre>
		myLoader.url = "http://www.somedomain.com/somepicture.jpg";
		myLoader.load();
		</pre>
	*/
	public function load(Void):Void {
		createEmptyMovieClip("__holder", 0);
		__holder.loadMovie(__url);
		__loaded = 0;
		__progress = 0;
		_visible = false;
		onEnterFrame = preload;
	}
	
	
	private function preload(Void):Void {
		if(__loaded > 5){
			if(__autoScale){
				doScale();
			}
			_visible = true;
			dispatchEvent({type:"load", target:this});
			delete onEnterFrame;
		}
		var bl:Number = __holder.getBytesLoaded();
		var bt:Number = __holder.getBytesTotal();
		__progress = bl / bt * 100;
		dispatchEvent({type:"progress", target:this});
		if(bl > 4 && bl == bt){
			__loaded++;
		}
	}
	
	
	
	
	
	
	
	/**
		Sets the autoload mode of the component. If true, content will begin loading as soon as the url property is set. If false, you must call load to begin loading content.
	
		@example
		<pre>
		myLoader.autoLoad = false;
		myLoader.url = "http://www.somedomain.com/somepicture.jpg";
		myLoader.load();
		</pre>
	*/
	[Inspectable (type="Boolean", defaultValue=false)]
	public function set autoLoad(b:Boolean) {
		__autoLoad = b;
		invalidate();
	}
	/**
		Gets the autoload mode of the component.
	
		@example
		<pre>
		myVar = myLoader.autoLoad;
		</pre>
	*/
	public function get autoLoad():Boolean {
		return __autoLoad;
	}
	
	
	/**
		Sets the autoload mode of the component. If true, the content will scale to the size of the loader component, as set in the authoring environment, or by use of setSize, width or height. If false, content will display at full size.
	
		@example
		<pre>
		myLoader.autoScale = true;
		</pre>
	*/
	[Inspectable (type="Boolean", defaultValue=false)]
	public function set autoScale(b:Boolean) {
		__autoScale = b;
		invalidate();
	}
	/**
		Gets the autoload mode of the component.
	
		@example
		<pre>
		myVar = myLoader.autoScale;
		</pre>
	*/
	public function get autoScale():Boolean {
		return __autoScale;
	}
	
	/**
		Gets the content of the component.
	
		@example
		<pre>
		myLoader.content.play();
		</pre>
	*/
	public function get content():MovieClip {
		return __holder;
	}
	
	
	/**
		A value from 0 to 100, representing the amount of content that has successfully loaded in.
	
		@example
		<pre>
		myProgressBar.value = myLoader.progress;
		</pre>
	*/
	[Bindable]
	[ChangeEvent ("progress")]
	public function get progress():Number {
		return __progress;
	}
	
	
	/**
		Sets the url for the content (swf or jpg) to be loaded.
	
		@example
		<pre>
		myLoader.autoLoad = false;
		myLoader.url = "http://www.somedomain.com/somepicture.jpg";
		myLoader.load();
		</pre>
	*/
	[Inspectable]
	public function set url(u:String) {
		__url = u;
		invalidate();
	}
	/**
		Gets the url of the content (swf or jpg).
	
		@example
		<pre>
		myVar = myLoader.url;
		</pre>
	*/
	public function get url():String {
		return __url;
	}	
}