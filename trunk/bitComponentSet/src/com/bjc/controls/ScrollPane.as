import com.bjc.controls.HorizScrollBar;
import com.bjc.resizers.Resizer;
import com.bjc.controls.VertScrollBar;
import mx.events.EventDispatcher;
import mx.utils.Delegate;


[IconFile ("icons/ScrollPane.png")]

[Event("load")]

[Event("progress")]

[Event("scroll")]

[Event("focus")]

[Event("killFocus")]

[Event("tabFocus")]

/**
* A scroll pane that can hold a large movie clip or image. If the image is larger than the scroll pane, the user can scroll or drag it around to view other parts of it. This component also allows the user to zoom in and out of the content.
* <BR><BR>
* Events:
* <BR><BR>
* <B>load</B> - Fired when the content being loaded by the scrollpane has completely loaded.
* <BR>
* <B>progress</B> - Fired once each frame while content is being loaded into the scrollpane.
* <BR>
* <B>scroll</B> - Fired once each frame while content is being scrolled or dragged.
* <BR>
* <B>focus</B> - Fired whenever the component receives focus.
* <BR>
* <B>killFocus</B> - Fired whenever the component loses focus.
* <BR>
* <B>tabFocus</B> - Fired whenever the component receives focus by pressing the TAB key.
* @author Beam Jive Consulting - www.beamjive.com
*/
class com.bjc.controls.ScrollPane extends com.bjc.core.BJCComponent {
 	private var clipParameters:Object = {contentPath:1, dragContent:1, scrollBarWidth:1, zoom:1};

	
	private var __background:Resizer;
	private var __content:MovieClip;
	private var __contentPath:String;
	private var __corner:MovieClip;
	private var __dragContent:Boolean = true;
	private var __hScrollBar:HorizScrollBar;
	private var __keyListener:Object;
	private var __loadedCount:Number = 0;
	private var __mask:MovieClip;
	private var __progress:Number;
	private var __progressCount:Number;
	private var __scrollBarWidth:Number = 16;
	private var __scrollBarPolicy:String = "auto";
	private var __vScrollBar:VertScrollBar;
	private var __zoom:Number = 100;
	
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
	* @usage <pre>myScrollPane.loadHandler = function(){
	* 	trace("I am done loading.");
	* }</pre>
	*/
	public var loadHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myScrollPane.progressHandler = function(){
	* 	trace("I am loading.");
	* }</pre>
	*/
	public var progressHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myScrollPane.scrollHandler = function(obj){
	* 	trace("Scroll position: " + obj.x + ", " + obj.y);
	* }</pre>
	*/
	public var scrollHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myScrollPane.focusHandler = function(){
	* 	trace("Set focus.");
	* }</pre>
	*/
	public var focusHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myScrollPane.killFocusHandler = function(){
	* 	trace("Kill focus.");
	* }</pre>
	*/
	public var killFocusHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myScrollPane.tabFocusHandler = function(){
	* 	trace("Tab focus.");
	* }</pre>
	*/
	public var tabFocusHandler:Function;




	public function ScrollPane(Void) {
	}
	
	
	private function init(Void):Void {
		super.init();
		EventDispatcher.initialize(this);
		__mask._x = 2;
		__mask._y = 2;
		
		__hScrollBar.addEventListener("change", Delegate.create(this, onHScroll));
		__hScrollBar.addEventListener("focus", Delegate.create(this, onScrollFocus));
		__hScrollBar.lineScroll = 10;
		__hScrollBar.minimum = -2;
		__hScrollBar.disabledAlpha = 100;
		
		__vScrollBar.addEventListener("change", Delegate.create(this, onVScroll));
		__vScrollBar.addEventListener("focus", Delegate.create(this, onScrollFocus));
		__vScrollBar.lineScroll = 10;
		__vScrollBar.minimum = -2;
		__vScrollBar.disabledAlpha = 100;
		
		__background.onPress = Delegate.create(this, onDrag);
		__background.onRelease = __background.onReleaseOutside = Delegate.create(this, onDrop);
		__background.useHandCursor = __dragContent;

		if(__contentPath != undefined){
			loadContent();
		}
		
		draw();
	}
	
	
	private function createChildren(Void):Void {
		attachMovie("Resizer", "__background", 0);
		__background.skin = "scrollPaneSkin";
		__background.margin = 5;
		createEmptyMovieClip("__content", 1);
		attachMovie("HorizScrollBar", "__hScrollBar", 2);
		attachMovie("VertScrollBar", "__vScrollBar", 3);
		attachMovie("scrollPaneCornerSkin", "__corner", 4);
		createEmptyMovieClip("__mask", 5);
		attachMovie("Resizer", "__focus", 6);
		__focus.skin = "focusSkin";
		__focus.margin = 5;
		__focus._visible = false;
		makeMask();
	}
	
	
	/**
		@exclude
	*/
	public function draw(Void):Void {
		__vScrollBar.enabled = __enabled;
		__hScrollBar.enabled = __enabled;
		if(__enabled){
			_alpha = 100;
		} else {
			_alpha = __alphaDisabled;
		}
		size();
	}
	
	
	private function size(Void):Void {
		__mask._width = __width - 4;
		__mask._height = __height - 4;
		
		__focus.setSize(__width, __height);
		__background.setSize(__width, __height);
		
		sizeScrolls();
	}
	
	
	/**
		Static method used to create an instance of a ScrollPane on stage at run time.
				
		@param target the movie clip to which the scroll pane will be attached.
		@param id the instance name given to the new scroll pane attached.
		@param depth the depth at which to attach the new scroll pane.
		@param initObj (optional) an object containing any properties you want to assign to the component when it is created
		@return a reference to the new scroll pane attached.
		@example
		<pre>
		import com.bjc.controls.ScrollPane;
		var newScrollPane:ScrollPane = ScrollPane.create(_root, "myScrollPane", 0);
		</pre>
	*/
	public static function create(target:MovieClip, id:String, depth:Number, initObj:Object):ScrollPane {
		return ScrollPane(target.attachMovie("ScrollPane", id, depth, initObj));
	}
		
	

	/**
		Sets the content to line up on the left edge of the scroll pane
	
		@example
		<pre>
		myScrollPane.alignLeft();
		</pre>
	*/
	public function alignLeft(Void):Void
	{
		__hScrollBar.value = __hScrollBar.minimum;
		__content._x = -__hScrollBar.value;
	}
	
	
	/**
		Sets the content to line up on the top edge of the scroll pane
	
		@example
		<pre>
		myScrollPane.alignLeft();
		</pre>
	*/
	public function alignTop(Void):Void
	{
		__vScrollBar.value = __vScrollBar.minimum;
		__content._y = -__vScrollBar.value;
	}
	
	
	/**
		Refreshes the scrollbars of the scrollpane. May be used when the content size have changed.
	
		@example
		<pre>
		myScrollPane.refresh();
		</pre>
	*/
	public function refresh(Void):Void {
		// resize scrollbars
		sizeScrolls();
		// check content size and position
		if(getContentWidth() < getPaneWidth() || (__content._x < Number(-__hScrollBar.maximum+2))) __content._x = 2;
		if(getContentHeight() < getPaneHeight() || (__content._y < Number(-__vScrollBar.maximum+2))) __content._y = 2;
		// update scrollpane
		sizeScrolls();
		update();
	}
	
	
	/**
		Sets the zoom so that all of the content will be visible within the area of the scrollpane, and no scrollbars will be necessary.
	
		@example
		<pre>
		myScrollPane.zoomFull();
		</pre>
	*/
	public function zoomFull(Void):Void {
		zoom = 100;
		var w:Number = __width / getContentWidth();
		var h:Number = __height / getContentHeight();
		if(h < w) {
			zoomHeight();
		} else {
			zoomWidth();
		}
//  	zoom = Math.min(w,h);
	}
	

	/**
		Sets the zoom so that the content's height will be that of the scrollpane's height, and no vertical scrollbar will be necessary.
	
		@example
		<pre>
		myScrollPane.zoomHeight();
		</pre>
	*/
	public function zoomHeight(Void):Void {
		zoom = 100;
 		zoom = (__height - 5) / getContentHeight() * 100;
 		if(needsHScroll())
 		{
			zoom = 100;
 			zoom = (__height - __scrollBarWidth - 4) / getContentHeight() * 100;
 		}
	}
	
	
	/**
		Sets the zoom so that the content's width will be that of the scrollpane's width, and no horizontal scrollbar will be necessary.
	
		@example
		<pre>
		myScrollPane.zoomWidth();
		</pre>
	*/
	public function zoomWidth(Void):Void {
		zoom = 100;
		zoom = (__width - 5) / getContentWidth() * 100;
		if(needsVScroll())
		{
			zoom = 100;
	 		zoom = (__width - __scrollBarWidth - 4) / getContentWidth() * 100;
	 	}
	}
	
	
	
	
	private function getContentHeight(Void):Number {
		return __content.getBounds(__content).yMax;
	}
	
	
	private function getContentWidth(Void):Number {
		return __content.getBounds(__content).xMax;
	}
	
	
	private function getLeftLimit(){
		return Math.min(0, getPaneWidth() - getContentWidth()) + 2;
	}
	
	
	private function getPaneCenterX(Void):Number {
		return getPaneWidth() / 2;
	}
	
	
	private function getPaneCenterY(Void):Number {
		return getPaneHeight() / 2;
	}
	
	
	private function getPaneHeight(Void):Number {
		if( __hScrollBar._visible || __scrollBarPolicy == "yes"){
			return __height - __scrollBarWidth - 4;
		} else {
			return __height - 4;
		}
	}
	
	
	private function getPaneWidth(Void):Number {
		if( __vScrollBar._visible || __scrollBarPolicy == "yes"){
			return  __width - __scrollBarWidth - 4;
		} else {
			return __width - 4;
		}
	}
	
	
	private function getTopLimit(){
		return Math.min(0, getPaneHeight() - getContentHeight()) + 2;
	}
	
	
	private function loadContent(Void):Void {
		if(__content != undefined && __contentPath != "" && __contentPath != undefined){
			__content.content.removeMovieClip();
			__content.attachMovie(__contentPath, "content", 0);
			if(__content.content != undefined){
				__content._x = 2;
				__content._y = 2;
				__content.content._xscale = __zoom;
				__content.content._yscale = __zoom;
				sizeScrolls();
				update();
				__progress = 100;
				dispatchEvent({type:"load", target:this});
			} else {
				__loadedCount = 0;
				__progressCount = 0;
				__content.createEmptyMovieClip("content", 0);
				__content._visible = false;
				__content.content.loadMovie(__contentPath);
				__progress = 0;
				onEnterFrame = preload;
			}
		}
	}
	
	
	private function makeMask(Void):Void {
		__mask.beginFill(0);
		__mask.lineTo(100, 0);
		__mask.lineTo(100, 100);
		__mask.lineTo(0, 100);
		__mask.lineTo(0, 0);
		__mask.endFill();
		__content.setMask(__mask);
	}
	
	
	private function needsCorner(Void):Boolean {
		if(__scrollBarPolicy == "yes"){
			return true;
		} else if(__scrollBarPolicy == "no"){
			return false;
		} else {
			return __hScrollBar._visible && __vScrollBar._visible;
		}
	}
	
	
	private function needsHScroll(Void):Boolean {
		if(__scrollBarPolicy == "yes"){
			return true;
		} else if(__scrollBarPolicy == "no"){
			return false;
		} else {
			return getContentWidth() > __width - 4;
		}
			
	}
	
	
	private function needsVScroll(Void):Boolean {
		if(__scrollBarPolicy == "yes"){
			return true;
		} else if(__scrollBarPolicy == "no"){
			return false;
		} else {
			return getContentHeight() > __height - 4;
		}
	}
	
	
	private function onDrag(Void):Void {
		if(__dragContent && __enabled){
			__content.startDrag(false, Math.round(getLeftLimit()), Math.round(getTopLimit()), 2, 2);
			__loadedCount = 0;
			onEnterFrame = update;
		}
	}
	
	
	private function onDrop(Void):Void {
		__content.stopDrag();
		delete onEnterFrame;
		if(Selection.getFocus() != "" + this) Selection.setFocus(this);
	}
	
	
	private function onHScroll(evtObj:Object):Void {
		if(getContentWidth() > getPaneWidth()){
			__content._x = Math.round(-__hScrollBar.value);
			dispatchEvent({type:"scroll", target:this, x:__hScrollBar.value+2, y:__vScrollBar.value+2});
		}
	}
	
	
	private function onKeyPressed(Void):Void {
		if((Selection.getFocus() == "" + this) && __enabled && __keyEnabled){
			if(Key.getCode() == Key.DOWN && getContentHeight() > getPaneHeight()){
				vScrollPosition ++;
			} else if(Key.getCode() == Key.UP && getContentHeight() > getPaneHeight()){
				vScrollPosition --;
			} else if(Key.getCode() == Key.RIGHT && getContentWidth() > getPaneWidth()){
				hScrollPosition ++;
			} else if(Key.getCode() == Key.LEFT && getContentWidth() > getPaneWidth()){
				hScrollPosition --;
			}
		}
	}
	
	
	private function onKillFocus(newFocus:Object):Void {
		Mouse.removeListener(this);
		Key.removeListener(__keyListener);
		__keyListener = null;
		hideFocus();
		dispatchEvent({type:"killFocus", target:this, newfocus:newFocus});
	}
	
	
	private function onMouseWheel(delta:Number):Void {
		if(__enabled && _xmouse > 0 && _xmouse < __width && _ymouse > 0 && _ymouse < __height){
			__vScrollBar.value -= delta * 4;
			onVScroll();
		}
	}
	
	
	private function onScrollFocus(evtObj:Object):Void {
		if(Selection.getFocus() != "" + this) Selection.setFocus(this);
	}
	
	
	private function onSetFocus(oldFocus:Object):Void {
		Mouse.addListener(this);
		if(__keyListener == null || __keyListener == undefined){
			__keyListener = new Object();
			__keyListener.onKeyDown = Delegate.create(this, onKeyPressed);
			Key.addListener(__keyListener);
		}
		dispatchEvent({type:"focus", target:this, oldfocus:oldFocus});
		if(Key.isDown(9)){
			showFocus();
			dispatchEvent({type:"tabFocus", target:this, oldfocus:oldFocus});
		}
	}
	
	
	private function onVScroll(evtObj:Object):Void {
		if(getContentHeight() > getPaneHeight()){
			__content._y = Math.round(-__vScrollBar.value);
			dispatchEvent({type:"scroll", target:this, x:__hScrollBar.value+2, y:__vScrollBar.value+2});
		}
	}
	
	
	private function preload(Void):Void {
		if(__loadedCount > 5){
			__content.content._xscale = __zoom;
			__content.content._yscale = __zoom;
			__content._visible = true;
			__content._x = 2;
			__content._y = 2;
			sizeScrolls();
			update();
			dispatchEvent({type:"load", target:this});
			delete onEnterFrame;
		}
		var loaded:Number = __content.content.getBytesLoaded();
		var total:Number = __content.content.getBytesTotal();
		__progress = loaded / total * 100;
		
		__progressCount++;
		if(__progressCount > 200 && __progress == 0){
			delete onEnterFrame;
			contentPath = "";
			__content.content.removeMovieClip();
			__content._visible = true;
			refresh();
		}
		
		if(loaded > 4 && loaded == total){
			__loadedCount++;
		}
		dispatchEvent({type:"progress", target:this});
	}
	
	
	private function update(Void):Void {
 		__hScrollBar.value = -__content._x;
 		__vScrollBar.value = -__content._y;
		dispatchEvent({type:"scroll", target:this, x:__hScrollBar.value+2, y:__vScrollBar.value+2});
	}
	

	private function sizeCorner(Void):Void {
		if( needsCorner() ){
			__corner._visible = true;
			__corner._x = __vScrollBar._x;
			__corner._y = __hScrollBar._y;
			__corner._width = __corner._height = __scrollBarWidth;
		} else {
			__corner._visible = false;
		}
	}


	private function sizeHScroll(Void):Void {
		if( needsHScroll() || ( needsVScroll() && getContentWidth() > (__width - __scrollBarWidth - 2) ) ){
			__hScrollBar._visible = true;
			__hScrollBar.move(1, __height - __scrollBarWidth - 1);
			__hScrollBar.setSize(getPaneWidth() + 2, __scrollBarWidth);
			__hScrollBar.maximum = getContentWidth() - getPaneWidth() - 2;
			__hScrollBar.thumbScale = __hScrollBar.width / (__hScrollBar.maximum + __hScrollBar.width);
		} else {
			__hScrollBar._visible = false;
		}
	}
	
	
	private function sizeScrolls(Void):Void {
		if(__content.content != undefined){
			sizeHScroll();
			sizeVScroll();
			sizeCorner();
		} else {
			__hScrollBar._visible = false;
			__vScrollBar._visible = false;
			__corner._visible = false;
		}
	}
	
	
	private function sizeVScroll(Void):Void {	
		if( needsVScroll() || ( needsHScroll() && getContentHeight() > (__height - __scrollBarWidth - 2) ) ){
			__vScrollBar._visible = true;
			__vScrollBar.move(__width - __scrollBarWidth - 1, 1);
			__vScrollBar.setSize(__scrollBarWidth, getPaneHeight() + 2);
			__vScrollBar.maximum = getContentHeight() - getPaneHeight() - 2;
			__vScrollBar.thumbScale = __vScrollBar.height / (__vScrollBar.maximum + __vScrollBar.height);
		} else {
			__vScrollBar._visible = false;
		}
	}
	
	
	
	
	
	
	
	
	
	
	/**
		Returns a reference to the content loaded into the scrollpane. Note that if you alter the content after it has been set, you should invalidate the scrollpane so that the scrollbars correctly reflect the size and position of the new content.
	
		@example
		<pre>
		myScrollPane.content.attachMovie("someAdditionalContent", "stuff", 0);
		myScrollPane.invalidate();
		</pre>
	*/
	public function get content():MovieClip {
		return __content.content;
	}
	
	
	/**
		Sets the linkage name of a symbol in the library to attach inside the scrollpane, or the url of an external swf or jpg image to load in.
	
		@example
		<pre>
		myScrollPane.contentPath = "exportedMovieClip";
		myOtherScrollPane.contentPath = "http://www.somedomain.com/somepicture.jpg";
		</pre>
	*/
	[Inspectable]
	public function set contentPath(path:String) {
		__contentPath = path;
		loadContent();
	}
	/**
		Gets the linkage name of a symbol in the library to attach inside the scrollpane, or the url of an external swf or jpg image to load in.
	
		@example
		<pre>
		myVar = myScrollPane.contentPath;
		</pre>
	*/
	public function get contentPath():String {
		return __contentPath;
	}
	
	
	/**
		Sets the drag mode of the component. If true, content can be moved around by clicking and dragging within the scrollpane. If false, scrollbars must be used to move the content.
	
		@example
		<pre>
		myScrollPane.dragContent = false;
		</pre>
	*/
	[Inspectable (type="Boolean", defaultValue=true)]
	public function set dragContent(b:Boolean) {
		__dragContent = b;
		__background.useHandCursor = __dragContent;
	}
	/**
		Gets the drag mode of the component. 
	
		@example
		<pre>
		myVar = myScrollPane.dragContent;
		</pre>
	*/
	public function get dragContent():Boolean {
		return __dragContent;
	}
	
	
	/**
		The percentage of content loaded into the scrollpane. If you are attaching a symbol, this will be either 0 or 100 (before and after attaching). If you are loading external content, this will go from 0 to 100 as the content loads in.
	
		@example
		<pre>
		trace(myScrollpane.progress);
		</pre>
	*/
	[Bindable]
	[ChangeEvent ("progress")]
	public function get progress():Number {
		return __progress;
	}
	
	/**
		Sets the visibility of the scrollbars in the scrollpane. If set to 'yes', the scrollbars are always visible. If set to 'no', the scrollbars are not visible. If set to 'auto', the scrollbars are visible when needed.
	
		@example
		<pre>
		myScrollpane.scrollBarPolicy = "no";
		</pre>
	*/
	[Inspectable (type="List", defaultValue="auto", enumeration="auto,yes,no")]
	public function set scrollBarPolicy(p:String) {
		__scrollBarPolicy = p;
		refresh();
	}
	/**
		Gets the scrollBarPolicy mode of the scrollpane.
	
		@example
		<pre>
		myVar = myScrollpane.scrollBarPolicy;
		</pre>
	*/
	public function get scrollBarPolicy():String {
		return __scrollBarPolicy;
	}


	/**
		Sets the width of the scrollbars (if visible) in the scrollpane. Note that width here refers to both the width of the veritical scrollbar AND the height of hte horizontal scrollbar.
	
		@example
		<pre>
		myScrollpane.scrollBarWidth = 20;
		</pre>
	*/
	[Inspectable(defaultValue=16)]
	public function set scrollBarWidth(w:Number) {
		__scrollBarWidth = w;
		if(__vScrollBar != undefined && __hScrollBar != undefined){
			__scrollBarWidth = Math.min(__width * .25, __scrollBarWidth);
			__scrollBarWidth = Math.min(__height * .25, __scrollBarWidth);
		}
		invalidate();
	}
	/**
		Gets the width of the scrollbars in the scrollpane.
	
		@example
		<pre>
		myVar = myScrollpane.scrollBarWidth;
		</pre>
	*/
	public function get scrollBarWidth():Number {
		return __scrollBarWidth;
	}
	
	/**
		Sets the horizontal position of the content in the scrollpane.
	
		@example
		<pre>
		myScrollpane.hScrollPosition = 10;
		</pre>
	*/
	public function set hScrollPosition(pos:Number)
	{
		__hScrollBar.value = pos - 2;
		__content._x = -__hScrollBar.value;
	}
	/**
		Gets the horizontal position of the content in the scrollpane.
	
		@example
		<pre>
		myVar = myScrollpane.hScrollPosition;
		</pre>
	*/
	public function get hScrollPosition():Number
	{
		return __hScrollBar.value + 2;
	}
	/**
		Gets the maximum horizontal position of the content in the scrollpane.
	
		@example
		<pre>
		myVar = myScrollpane.maxHScrollPosition;
		</pre>
	*/
	public function get maxHScrollPosition():Number
	{
		return __hScrollBar.maximum + 2;
	}
	
	/**
		Sets the vertical position of the content in the scrollpane.
	
		@example
		<pre>
		myScrollpane.vScrollPosition = 10;
		</pre>
	*/
	public function set vScrollPosition(pos:Number)
	{
		__vScrollBar.value = pos - 2;
		__content._y = -__vScrollBar.value;
	}
	/**
		Gets the vertical position of the content in the scrollpane.
	
		@example
		<pre>
		myVar = myScrollpane.vScrollPosition;
		</pre>
	*/
	public function get vScrollPosition():Number
	{
		return __vScrollBar.value + 2;
	}
	/**
		Gets the maximum vertical position of the content in the scrollpane.
	
		@example
		<pre>
		myVar = myScrollpane.maxVScrollPosition;
		</pre>
	*/
	public function get maxVScrollPosition():Number
	{
		return __vScrollBar.maximum + 2;
	}
	
	/**
		Sets the _xscale and _yscale of the content. Special care has been taken to ensure that scaling and scrolling the content will not result in the content going "out of bounds" and becoming invisible.
	
		@example
		<pre>
		myScrollPane.zoom = 150;
		</pre>
	*/
	[Inspectable (defaultValue=100)]
	public function set zoom(z:Number) {
		// get current center position
		var cx:Number = (getPaneCenterX() - __content._x) / __zoom;
		var cy:Number = (getPaneCenterY() - __content._y) / __zoom;
		
		// apply zoom
		__zoom = z;
		__content.content._xscale = __zoom;
		__content.content._yscale = __zoom;
		
		// find new center
		var x:Number = getPaneCenterX() - cx * __zoom;
		var y:Number = getPaneCenterY() - cy * __zoom;

		// adjust  for limits
		x = Math.max(x, getLeftLimit());
		y = Math.max(y, getTopLimit());
		__content._x = Math.min(x, 2);
		__content._y = Math.min(y, 2);

		// update scroll bars
		sizeScrolls();
		update();
	}
	[Bindable]
	/**
		Gets the _xscale and _yscale of the content. 
	
		@example
		<pre>
		myVar = myScrollPane.zoom;
		</pre>
	*/
	public function get zoom():Number {
		return __zoom;
	}
}
