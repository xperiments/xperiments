/**
 * @author pedro
 */
class com.xperiments.TextEditor.Main
{




	
}

/*

import com.xperiments.utils.SelectionUtils;
import org.asapframework.events.EventDelegate;
import mx.events.EventDispatcher;
SelectionUtils.initialize( );
SelectionUtils.addTarget( _level0.outTF );
cpicker.value = 0xFF00FF;
cpicker.changeHandler =EventDelegate.create( this, TextEditorProxy, 'color' );
stop()

TEditor_bold.addEventListener("click", EventDelegate.create( this, TextEditorProxy, 'bold' ) );
TEditor_italics.addEventListener("click", EventDelegate.create( this, TextEditorProxy, 'italic' ) );
TEditor_underline.addEventListener("click", EventDelegate.create( this, TextEditorProxy, 'underline' ) );

TEditor_font_decrease.addEventListener("click", EventDelegate.create( this, TextEditorProxy, 'font_decrease' ) );
TEditor_font_increase.addEventListener("click", EventDelegate.create( this, TextEditorProxy, 'font_increase' ) );

TEditor_left.addEventListener("click", EventDelegate.create( this, TextEditorProxy, 'left' ) );
TEditor_center.addEventListener("click", EventDelegate.create( this, TextEditorProxy, 'center' ) );
TEditor_right.addEventListener("click", EventDelegate.create( this, TextEditorProxy, 'right' ) );

var font_array:Array = TextField.getFontList();
	font_array.sort();
var fontComboDataProvider:Array = new Array( );
for (var i = 0; i< font_array.length; i++)
{
	fontComboDataProvider.push( { data:font_array[i], label:font_array[i] } )
}
fontFaceCombo.dataProvider = fontComboDataProvider;




function change( event_obj:Object )
{
	switch( event_obj.target._name )
	{
		case 'fontFaceCombo':
			TextEditorProxy( null, 'font', event_obj.target.selectedItem.data );
		break;
		case 'fontSizeCombo':
			TextEditorProxy( null, 'size', event_obj.target.selectedItem.data );
		break;		
		
		
	}
}


var fontSizeDataProvider:Array = new Array( );
for (var i = 8; i<72; i+=2 )
{
	fontSizeDataProvider.push( { data:i, label:i+'px' } )
}
fontSizeCombo.dataProvider = fontSizeDataProvider;



fontFaceCombo.addEventListener( "change", this );
fontSizeCombo.addEventListener( "change", this );

//EventDispatcher.initialize( outTF );
//outTF.addEventListener("pepe", EventDelegate.create( this, pepe, 'left' ) );
function pepe( )
{
	trace('pepe');
	
}
function TextEditorProxy( )
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
			com.xperiments.utils.SelectionUtils.setProp( 'color', cpicker.value );
		break;
		case 'font':
		case 'size':
			trace( [ action, arguments[ 2 ] ] )
			com.xperiments.utils.SelectionUtils.setProp( action, arguments[ 2 ] );
		break;
		
	}
}
*/