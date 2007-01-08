import com.xperiments.utils.SelectionUtils;
import org.asapframework.events.EventDelegate;
import mx.events.EventDispatcher;
import com.bjc.controls.Window;
import org.asapframework.util.FrameDelay;
import org.asapframework.util.ArrayUtils;
/**
 * @author pedro
 */
class com.xperiments.TextEditor.TextEditor
{

	private var _timeline : MovieClip;
	private var _TE_window:Window;
	private var _TE_windowContent : MovieClip;
	private var _targetTextField:TextField;
	private var _clonedTargetTextField:TextField;
	private var font_array : Array;
	private var width:Number = 500;
	private var height:Number = 300;

	private var fontSizeDataProvider : Array;

	private var font_Size : Array;
	public function TextEditor( _mc:MovieClip, _tf:TextField )
	{
		_timeline = _mc;
		_targetTextField = _tf;
		initialize( );
		createComponents( );
		new FrameDelay( this, createUI , [], 1 );
	}

	
	public function setVisible( visible:Boolean )
	{
		_TE_window._visible = visible;
		
	}

	private function setTarget( _tf:TextField )
	{
		SelectionUtils.addTarget( _tf );
		_tf.addEventListener( "onSelection", EventDelegate.create( this, setSelectionFormat  ) );
	}
	
	private function setSelectionFormat( ev:Object )
	{
		trace( 'setSelectionFormat'+ev.textFormat );
		
		var tf:TextFormat = ev.textFormat;
		//align:String
		//blockIndent:Number
		//
		//color:Number
		//indent:Number
		//leading:Number
		//leftMargin:Number
		//letterSpacing:Number
		//rightMargin:Number
		//size:Number
		//
		//tabStops:Array
		//
		//target:String
		//font:String
		//url:String
		//
		//bold:Boolean
		//bullet:Boolean
		//underline:Boolean
		//italic:Boolean
		//kerning:Boolean
		_TE_windowContent.cpicker.value = tf.color;
		if ( _TE_windowContent.fontFaceCombo.selectedIndex!= ArrayUtils.findElement( font_array, tf.font ) )
		{
			if ( ArrayUtils.findElement( font_array, tf.font ) != -1 )
			{
				_TE_windowContent.fontFaceCombo.selectedIndex = ArrayUtils.findElement( font_array, tf.font );
			}
		}
		trace( 'tf.size'+tf.size );
		if ( _TE_windowContent.fontSizeCombo.selectedIndex!= ArrayUtils.findElement( font_Size, tf.size ) )
		{
			
			if ( ArrayUtils.findElement( font_Size, tf.size ) != -1 )
			{
				_TE_windowContent.fontSizeCombo.selectedIndex = ArrayUtils.findElement( font_Size, tf.size );
			}
		}			
		_TE_windowContent.TEditor_bold.selected = tf.bold;
		_TE_windowContent.TEditor_italics.selected = tf.italic;
		_TE_windowContent.TEditor_underline.selected = tf.underline;
		



		
	}
	private function initialize() : Void
	{
		SelectionUtils.initialize( );
	}	
	private function createComponents( )
	{
		trace( [_targetTextField._width +20, width ] ); 
		var w:Number = (_targetTextField._width+20) > width ? ( _targetTextField._width+30 ) : width;
		var h:Number = (_targetTextField._height+50) > height ? ( _targetTextField._height+90 ) : height;		
		_TE_window  = Window.create( _timeline, "myWindow", _timeline.getNextHighestDepth( ) , { _visible:false, _width:w, _height:h } );
		_TE_window.contentPath = 'TextEditor_Main_Controls';
		_TE_windowContent = _TE_window.content;
		
		_TE_windowContent.cpicker.value = 0xFF00FF;		
		
	}
	
	private function createUI( )
	{
		createFontList( );
		createFontSize( );
		initEvents( );
		cloneTextField( );
		setTarget( _clonedTargetTextField );
	}
	
	private function createFontList( )
	{
		font_array = TextField.getFontList();
		font_array.sort();
		
		var fontComboDataProvider:Array = new Array( );
		for (var i = 0; i< font_array.length; i++)
		{
			fontComboDataProvider.push( { data:i, label:font_array[i] } );
		}
		_TE_windowContent.fontFaceCombo.dataProvider = fontComboDataProvider;
		_TE_windowContent.fontFaceCombo.selectedIndex = 0;	
		
		
	}
	private function createFontSize( )
	{
		fontSizeDataProvider  = new Array( );
		font_Size = new Array( );
		for (var i = 8; i<72; i+=2 )
		{
			font_Size.push( i );
			fontSizeDataProvider.push( { data:i, label:i+'px' } );
		}
		_TE_windowContent.fontSizeCombo.dataProvider = fontSizeDataProvider;
		
	}
	
	private function initEvents( )
	{


		_TE_windowContent.TEditor_bold.addEventListener("click", EventDelegate.create( this, TextEditorProxy, 'bold' ) );
		_TE_windowContent.TEditor_italics.addEventListener("click", EventDelegate.create( this, TextEditorProxy, 'italic' ) );
		_TE_windowContent.TEditor_underline.addEventListener("click", EventDelegate.create( this, TextEditorProxy, 'underline' ) );
		
		_TE_windowContent.TEditor_font_decrease.addEventListener("click", EventDelegate.create( this, TextEditorProxy, 'font_decrease' ) );
		_TE_windowContent.TEditor_font_increase.addEventListener("click", EventDelegate.create( this, TextEditorProxy, 'font_increase' ) );
		
		_TE_windowContent.TEditor_left.addEventListener("click", EventDelegate.create( this, TextEditorProxy, 'left' ) );
		_TE_windowContent.TEditor_center.addEventListener("click", EventDelegate.create( this, TextEditorProxy, 'center' ) );
		_TE_windowContent.TEditor_right.addEventListener("click", EventDelegate.create( this, TextEditorProxy, 'right' ) );
		
		_TE_windowContent.cpicker.changeHandler =EventDelegate.create( this, TextEditorProxy, 'color' );
		
		_TE_windowContent.fontFaceCombo.addEventListener( "change", this );
		_TE_windowContent.fontSizeCombo.addEventListener( "change", this );
		
	}


	public function TextEditorProxy( )
	{

		var action:String = String( arguments[ 1 ] );
		switch( action )
		{
			case 'bold':
			case 'italic':
			case 'underline':
				com.xperiments.utils.SelectionUtils.toogleProp( action );
			break;
			
			case 'left':
			case 'center':
			case 'right':
				com.xperiments.utils.SelectionUtils.setProp( 'align', action );
			break;
			
			case 'font_increase':
				com.xperiments.utils.SelectionUtils.setPropIncrease( 'size', 1 );
			break;
			case 'font_increase':
				com.xperiments.utils.SelectionUtils.setPropIncrease( 'size', -1 );
			break;		
			
			case 'color':
				trace('color');
				com.xperiments.utils.SelectionUtils.setProp( 'color', _TE_windowContent.cpicker.value );
			break;
			case 'font':
			case 'size':
				com.xperiments.utils.SelectionUtils.setProp( action, arguments[ 2 ] );
			break;
			
		}
	
	
	}
	
	private function change( event_obj:Object )
	{

		switch( event_obj.target._name )
		{
			case 'fontFaceCombo':
				if ( event_obj.target.selectedItem.label != 'undefined' )
				{
					TextEditorProxy( null, 'font', event_obj.target.selectedItem.label );
				}
			break;
			case 'fontSizeCombo':
				TextEditorProxy( null, 'size', event_obj.target.selectedItem.data );
			break;		
			
			
		}
	}

	private function cloneTextField( )
	{
		_clonedTargetTextField = _TE_windowContent.createTextField( 'EditableTextField' , _TE_windowContent.getNextHighestDepth( ), 10, 50, _targetTextField._width, _targetTextField._height);
		_clonedTargetTextField.setNewTextFormat( _targetTextField.getTextFormat( ) );
		for (var i in _targetTextField )
		{
			_clonedTargetTextField[i ] = _targetTextField[ i ];
		}
		if ( _clonedTargetTextField.html )
		{
			_clonedTargetTextField.htmlText = _targetTextField.htmlText;
		}
	}


	
}
