import com.bjc.controls.TextArea;
import mx.events.EventDispatcher;
import mx.utils.Delegate;

[IconFile ("icons/RichTextArea.png")]

[Event("selection")]

/**
* Rich Text area component for displaying text or allowing input of large amounts of text. This component handles all HTML formatting that Flash can handle.
* <BR><BR>
* Events:
* <BR><BR>
* <B>change</B> - Fired whenever the user has changed the text in the text area by typing a new character or deleting any content. Will not fire when text is changed programatically via the text property.
* <BR>
* <B>focus</B> - Fired whenever the internal text field receives focus.
* <BR>
* <B>killFocus</B> - Fired whenever the internal text field loses focus.
* <BR>
* <B>scroll</B> - Fired once each frame while text is being scrolled.
* <BR>
* <B>selection</B> - Fired whenever the text selection has changed.
* @author Beam Jive Consulting - www.beamjive.com
*/
[InspectableList("condenseWhite","editable","maxChars","restrict","scrollBarWidth","selectable","text")]
class com.bjc.controls.RichTextArea extends TextArea 
{

	private var __begin:Number;
	private var __end:Number;
	private var __cursor:Number;
	private var __format:TextFormat;
	private var __tf:TextField;
	private var __refreshSelection:Boolean;
	private var __formatSet:Boolean;
	private var __caretFormatSet:Boolean;
	private var __inKeyListener:Boolean;
	private var __editListenerLocked:Boolean;
	private var __keyListener:Object;
	private var __lastNewFormatIndex:Number;
	private var __SET_INTERVAL:Number;
	private var __tabSelections:Boolean;
	private var __tabText:Boolean;
	private var __tabIndent:Number;
	private var __handleTabs:Boolean;
	private var __beginMoveByOne:Boolean;
	private var __fixScroll:Number;
	private var __mode:Number;
	private var __defaultNewTextFormat:TextFormat;
	private var __oldTextLength:Number;
	private var __autoIndent:Boolean;
	private var __handleTab:Boolean;
	
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myRTA.selectionHandler = function(){
	* 	trace("Selection was changed.");
	* }</pre>
	*/
	public var selectionHandler:Function;
	
	
 	public function RichTextArea(Void)
	{
		// The infamous text field hack
		delete TextField.prototype.htmlText;
		TextField.prototype.addProperty( "htmlTextFix", ["ASnative"]( 104, 19 ), ["ASnative"]( 104, 20 ) );
		TextField.prototype.addProperty( "htmlText", function(){ return this.htmlTextFix; }, function( ht ){ this.htmlTextFix = ht.split(" ").join("&nbsp;"); this.htmlTextFix = ht.split("\n").join("&nbsp;\n"); } );				
	}
	
	private function init():Void
	{
		// Initialize super class (TextArea)
		super.init();	
		
		// Set constants and vars
		html = true;
		disableStyles = true;
		__SET_INTERVAL = 40;
		__formatSet = true;
		__editListenerLocked = false;
		__lastNewFormatIndex = -1;
		__tabText = false;
		__tabSelections = false;
		__tabIndent = 40;
		__handleTabs = false; // For multiline tabbing
		__handleTab = false; // For single tab
		__beginMoveByOne = false;
		__fixScroll = 0;
		__mode = 0; // 0=RTA
		__autoIndent = true;
	
		// Set update interval for selection and caret positions
		setInterval( this, "setSelections", __SET_INTERVAL );
		
		// Add a keyboard listener
		if(__keyListener == null || __keyListener == undefined){
			__keyListener = new Object();
			__keyListener.onKeyUp = Delegate.create(this, onKeyReleased);
			__keyListener.onKeyDown = Delegate.create(this, onKeyPressed);
			Key.addListener(__keyListener);
		}
	}
	
	/**
		Static method used to create an instance of a RichTextArea on stage at run time.
				
		@param target the movie clip to which the rich text area will be attached.
		@param id the instance name given to the new rich text area attached.
		@param depth the depth at which to attach the new rich text area.
		@param initObj (optional) an object containing any properties you want to assign to the component when it is created.
		@return a reference to the new rich text area attached.
		@example
		<pre>
		import com.bjc.controls.RichTextArea;
		var newRTA:RichTextArea = RichTextArea.create(_root, "myRTA", 0);
		</pre>
	*/
	public static function create(target:MovieClip, id:String, depth:Number, initObj:Object):RichTextArea {
		return RichTextArea(target.attachMovie("RichTextArea", id, depth, initObj));
	}
	
	
	private function setSelections(Void):Void
	{	
		if( (Selection.getFocus() == __tf) /*&& (!__inKeyListener)*/ && (!__editListenerLocked)) 
		{ 						
			var oldBegin:Number = __begin;
			var oldEnd:Number = __end;

			__begin = Selection.getBeginIndex(); 
			__end = Selection.getEndIndex(); 
			__cursor = Selection.getCaretIndex();			
			
			// No selection, use the TextFormat of the previous char
			if( (__begin == __end) && (__lastNewFormatIndex != __begin) && (__mode == 0) ) 
			{			
				if( __begin > 0 )
				{
					__format = __tf.getTextFormat( __begin - 1, __end );
				}
				else
				{
					__format = __defaultNewTextFormat;
				}
				
				__tf.setNewTextFormat( __format );
				__formatSet = true;
				__caretFormatSet = false;
			}
			else if( (__begin == __end) && (__lastNewFormatIndex == __begin) && (__mode == 0) ) 
			{							
				__tf.setNewTextFormat( __format );
				__formatSet = true;
				__caretFormatSet = false;
			}
			// There is a selection
			else if( (__begin != __end) && (__mode == 0) )
			{
				// Has selection
				__format = __tf.getTextFormat( __begin, __end );
			}
			
			
			if( (__begin != oldBegin) || (__end != oldEnd) )
			{
				__caretFormatSet = false;
				dispatchEvent({type:"selection", target:this, format:__format, begin:__begin, end:__end, caret:__cursor});
			}
		}
		
		
		if( __refreshSelection ) 
		{
			
			Selection.setFocus( __tf );
			
			if( __beginMoveByOne )
			{
				Selection.setSelection( __begin + 1, __end + 1 );
				__beginMoveByOne = false;
			}
			else
			{
				Selection.setSelection( __begin, __end );		
			}
			
			__refreshSelection = false;
			
			if( __fixScroll > 0 ) 
			{
				__tf.scroll = __fixScroll;
				__fixScroll = 0;
			}
			
		}
		
		__oldTextLength = __tf.text.length;
	}		

	
	/**
		This method may be used to set text format properties to the text selection.
				
		@param name the name of the property.
		@param value the value of the given property.
		@return nothing.
		@example
		Bold:
		<pre>
		myRTA.setFormatProperty( "bold", true ); // value:Boolean
		</pre>
		Italic:
		<pre>
		myRTA.setFormatProperty( "italic", true ); // value:Boolean
		</pre>
		Underline:
		<pre>
		myRTA.setFormatProperty( "underline", true ); // value:Boolean
		</pre>
		Bullet:
		<pre>
		myRTA.setFormatProperty( "bullet", true ); // value:Boolean
		</pre>
		Color:
		<pre>
		myRTA.setFormatProperty( "color", 0xff0000 ); // value:Number
		</pre>
		URL:
		<pre>
		myRTA.setFormatProperty( "url", "http://www.beamjive.com" ); // value:String
		</pre>
		URL target:
		<pre>
		myRTA.setFormatProperty( "target", "_self" ); // value:String
		</pre>
		Font:
		<pre>
		myRTA.setFormatProperty( "font", "Arial" ); // value:String
		</pre>
		Align:
		<pre>
		myRTA.setFormatProperty( "align", "left" ); // value:String
		</pre>
		Font size:
		<pre>
		myRTA.setFormatProperty( "size", 12 ); // value:Number
		</pre>
		Left margin:
		<pre>
		myRTA.setFormatProperty( "leftMargin", 20 ); // value:Number
		</pre>
		Right margin:
		<pre>
		myRTA.setFormatProperty( "rightMargin", 20 ); // value:Number
		</pre>
		Indent:
		<pre>
		myRTA.setFormatProperty( "indent", 20 ); // value:Number
		</pre>
		Block indent:
		<pre>
		myRTA.setFormatProperty( "blockIndent", 20 ); // value:Number
		</pre>
		Leading:
		<pre>
		myRTA.setFormatProperty( "leading", 20 ); // value:Number
		</pre>
		Tab stops:
		<pre>
		myRTA.setFormatProperty( "tabStops", [0, 40, 80, 120] ); // value:Array
		</pre>
	*/
	public function setFormatProperty( name:String, value:Object ):Void
	{
		__editListenerLocked = true;
		__cursor = Selection.getCaretIndex();
		__fixScroll = __tf.scroll;
		
		// If we have selection.. 
		if( __begin != __end )
		{
			Selection.setFocus( __tf );
			Selection.setSelection( __begin, __end );
			__format[name] = value;
			__tf.setTextFormat( __begin, __end, __format );
			__refreshSelection = true;
		}
		else if( __caretFormatSet == false )
		{
			// We do not have selection, set new text format
			__format = __tf.getTextFormat( __begin - 1, __end );
			__format[name] = value;
			__tf.setNewTextFormat( __format );
			__refreshSelection = true;
			__caretFormatSet = true;
			__lastNewFormatIndex = __begin;
		}
		else
		{
			//__format = __tf.getNewTextFormat();
			__format[name] = value;
			__tf.setNewTextFormat( __format );
			__refreshSelection = true;
			__lastNewFormatIndex = __begin;
		}
		
		dispatchEvent({type:"selection", target:this, format:__format, begin:__begin, end:__end, caret:__cursor});
		__editListenerLocked = false;

		if(__mode == 0)
		{
			__text = __tf.text;
		}
		else
		{
			__text = __tf.htmlText;
		}

	}	
	
	
	private function onKeyPressed():Void
	{
		__inKeyListener = true;
		
		// Tab was clicked and no selection
		if( (Key.getAscii() == 9) && (__begin == __end) && (__tabText) )
		{
			__handleTab = true;
		}
		// Tab a selection - use the indent format instead..
		else if( (Key.getAscii() == 9) && (__begin != __end) && (__tabSelections) && (!Key.isDown(Key.SHIFT)) )
		{
			var tempBegin:Number = __begin;
			Selection.setSelection( tempBegin, tempBegin );
            __tf.replaceSel( "\t" );
            var t:Number = 1;
			var tempEnd:Number = __end ++;
			
			for(var i:Number = tempBegin; i < tempEnd; i ++)
			{                                
				if((isNaN( __tf.text.charCodeAt( i ) )) || (__tf.text.charCodeAt( i ) == 13))
				{
					Selection.setSelection(i + 1, i + 1);
				    __tf.replaceSel( "\t" );
					t++;
					tempEnd ++;
				}
			}
					
			__end = tempEnd + 1;
			__begin = tempBegin;
			__refreshSelection = true;
		}
		// Tab and shift - decrease indent
		else if( (Key.getAscii() == 9) && (__begin != __end) && (__tabSelections) && (Key.isDown(Key.SHIFT)) )
		{
			var tempBegin:Number = __begin;
			var tempEnd:Number = __end;
			var t:Number = 0;
			
			if( __tf.text.charAt( tempBegin ) == "\t" )
			{
				Selection.setSelection( tempBegin, tempBegin + 2 );
				__tf.replaceSel( __tf.text.charAt(tempBegin + 1) );        
				t ++;
			}
			
			for(var i:Number = tempBegin; i < tempEnd; i ++)
			{                                
				if( ((isNaN( __tf.text.charCodeAt( i ) )) || (__tf.text.charCodeAt( i ) == 13)) && (__tf.text.charAt( i + 1 ) == "\t") && (i + 2 < __tf.text.length) && (i + 2 < __end) )
				{
					Selection.setSelection(i, i + 2);
					__tf.replaceSel( "\n" );
					t++;
				}
			}
					
			__end = tempEnd - t;
			__begin = tempBegin;
			__refreshSelection = true;
		}
		
		
		if( (Key.getCode() == Key.ENTER) && (__autoIndent) )
		{
			__handleTabs = true;	
		}
		
		__inKeyListener = false;
	}
	
	
	private function onKeyReleased():Void
	{
		__inKeyListener = true;
				
		// Enter pressed, check auto indent if in code mode
		if( __handleTabs )
		{
			var prevLine:String = getPreviousLine();
			if( prevLine != null )
			{
				var tabs:Number = getTabCount( prevLine );
				var tabStr:String = new String();
		
				for( var i:Number = 0; i < tabs; i ++ )
				{
					tabStr += "\t";
				}
				
				if( tabs > 0 )
				{
					Selection.setSelection( __cursor, __cursor );
					__tf.replaceSel( "" + tabStr );
					Selection.setSelection( __cursor + tabs, __cursor + tabs );
				}
			}
			
			__handleTabs = false;
		}
		
		if( __handleTab )
		{
			__fixScroll = __tf.scroll;
			var txt:String = __tf.text;

			Selection.setFocus( __tf );
			Selection.setSelection( __cursor, __cursor );
			__tf.replaceSel( "\t" );
			
			__refreshSelection = true;
			__handleTab = false;
		}
		
		__inKeyListener = false;
	}
	
	private function getTabCount( str:String ):Number 
	{
		var num:Number = 0;
		var hasTabs:Boolean = true;
		
		while( hasTabs == true )
		{
			if( str.charAt( num ) != "\t" ) 
			{
				hasTabs = false;			
			}
			else
			{
				num ++;
			}
		}
		
		return( num );
	}
	
	private function getLineStart( cursorPos:Number ):Number
	{
		var pos:Number = cursorPos - 1;
		var found:Number = (-1);
		
		// Find the end
		while( (pos >= 0) && (found == (-1)) )
		{        
			if( (isNaN( __tf.text.charCodeAt( pos ) )) || (__tf.text.charCodeAt( pos ) == 13) ) found = pos;
			pos --;
		}
		
		if( found == (-1) )
		{
			return( 0 );
		}
		else
		{
			return( found );
		}
	}
	
	private function getThisLineStart():Number
	{
		var pos:Number = __cursor - 1;
		var found:Number = (-1);
		
		// Find the end
		while( (pos >= 0) && (found == (-1)) )
		{        
			if( (isNaN( __tf.text.charCodeAt( pos ) )) || (__tf.text.charCodeAt( pos ) == 13) ) found = pos;
			pos --;
		}
		
		if( found == (-1) )
		{
			return( 0 );
		}
		else
		{
			return( found );
		}
	}
	
	private function getThisLineEnd():Number
	{
		var pos:Number = __cursor - 1;
		var found:Number = (-1);
		
		// Find the end
		while( (pos <= __tf.text.length) && (found == (-1)) )
		{	
			if( (isNaN( __tf.text.charCodeAt( pos ) )) || (__tf.text.charCodeAt( pos ) == 13) ) found = pos;
			pos ++;
		}
		
		return( found );
	}	
	
	private function getPreviousLine():String
	{
		var pos:Number = __cursor - 1;
		var start:Number = (-1);
		var end:Number = (-1);
		
		// Find the end
		while( (pos >= 0) && (end == (-1)) )
		{	
			if( (isNaN( __tf.text.charCodeAt( pos ) )) || (__tf.text.charCodeAt( pos ) == 13) ) end = pos;
			pos --;
		}
		
		// Find the end
		while( (pos >= 0) && (start == (-1)) )
		{	
			if( (isNaN( __tf.text.charCodeAt( pos ) )) || (__tf.text.charCodeAt( pos ) == 13) ) start = pos;
			pos --;
		}
		
		// There is a previous line
		if( (start != (-1)) && (end != (-1)) )
		{
			return( __tf.text.substring( start + 1, end ) );
		}
		// The previous line is the first line
		else if( (start == (-1)) && (end != (-1)) )
		{
			return( __tf.text.substring( 0, end ) );
		}
		else 
		{
			return( null );
		}
	}
	
	private function getThisLine():String
	{
		var pos:Number = __cursor - 1;
		var start:Number = (-1);
		var end:Number = (-1);
		
		// Find the start
		while( (pos >= 0) && (start == (-1)) )
		{	
			if( (isNaN( __tf.text.charCodeAt( pos ) )) || (__tf.text.charCodeAt( pos ) == 13) ) start = pos;
			pos --;
		}
		
		pos = __cursor;
		
		// Find the end
		while( (pos <= __tf.text.length) && (end == (-1)) )
		{	
			if( (isNaN( __tf.text.charCodeAt( pos ) )) || (__tf.text.charCodeAt( pos ) == 13) ) end = pos;
			pos ++;
		}
		
		if( (start != (-1)) && (end != (-1)) )
		{
			return( __tf.text.substring( start + 1, end + 2 ) );
		}
		else if( (start != (-1)) && (end == (-1)) )
		{
			return( __tf.text.substring( start + 1, __tf.text.length ) );
		}
		else if( (start == (-1)) && (end != (-1)) )
		{
			return( __tf.text.substring( 0, end + 2 ) );
		}
		else
		{
			return( __tf.text.substring( 0, __tf.text.length ) );
		}
	}
	
	
	
	/*public function set data( txt:String ):Void
	{
		text = txt;
		invalidate();
	}
	
	public function get data():String
	{
		if( __mode != 2 )
		{
			return(__tf.htmlText);
		}
		else
		{
			if( __tabText ) return( __tf.text.split("&#09;").join("\t") );
			else return( __tf.text );
		}
	}*/
	
	/**
		Sets the update speed of the rich text area. 
		
		@example
		<pre>
		myRTA.updateInterval = 50;
		</pre>
	*/
	public function set updateInterval( interval:Number ):Void
	{
		__SET_INTERVAL = interval;
	}
	/**
		Gets the update speed of the rich text area. 
		
		@example
		<pre>
		myVar = myRTA.updateInterval;
		</pre>
	*/
	public function get updateInterval():Number
	{
		return( __SET_INTERVAL );
	}
	
	/**
		@exclude
	*/
	public function set tabSelections( tab:Boolean ):Void
	{
		__tabSelections = tab;
	}
	/**
		@exclude
	*/
	public function get tabSelections():Boolean
	{
		return( __tabSelections );
	}
	
	/**
		@exclude
	*/
	public function set tabText( tab:Boolean ):Void
	{
		__tabText = tab;
	}
	/**
		@exclude
	*/
	public function get tabText():Boolean
	{
		return( __tabText );
	}
	
	/**
		@exclude
	*/
	public function set tabIndent( tab:Number ):Void
	{
		__tabIndent = tab;
	}
	/**
		@exclude
	*/
	public function get tabIndent():Number
	{
		return( __tabIndent );
	}
	
	/**
		@exclude
	*/
	public function set autoIndent( auto:Boolean ):Void
	{
		__autoIndent = auto;
	}
	/**
		@exclude
	*/
	public function get autoIndent():Boolean
	{
		return( __autoIndent );
	}
	
	/**
		Sets the text format of the component. 
		
		@example
		<pre>
		myRTA.newTextFormat = myTextFormat;
		</pre>
	*/
	public function set newTextFormat( tformat:TextFormat ):Void
	{
		__tf.setNewTextFormat( tformat );
		__defaultNewTextFormat = tformat;
	}
	
	/**
		Sets the mode of the component. If set to 0, the html format is on. If set to 1, the html tags are visible and are editable.
		
		@example
		<pre>
		myRTA.mode = 1;
		</pre>
	*/
	public function set mode( m:Number ):Void
	{
		if( (m > 1) || (m < 0) ) m = 0;
		
		// Changing from rta to source mode
		if( (__mode == 0) && (m == 1) )
		{
			var ht:String = __tf.htmlText;
			__tf.html = false;
			__tf.text = ht;
		}
		// Changing from source mode to rta mode
		else if( (__mode == 1) && (m == 0) )
		{
			var ht:String = __tf.text;
			__tf.html = true;
			__tf.htmlText = ht;
		}
		
		__mode = m;
		__update = true;
		checkScrollBars();
		sizeScrolls();
		update();		
	}
	/**
		Gets the mode of the component.
		
		@example
		<pre>
		myVar = myRTA.mode;
		</pre>
	*/
	public function get mode():Number
	{
		return( __mode );
	}
}