import com.bjc.controls.CalendarItem;
import com.bjc.controls.Label;
import com.bjc.resizers.Resizer;
import mx.events.EventDispatcher;
import mx.utils.Delegate;

[IconFile ("icons/Calendar.png")]

[Event("click")]

[Event("focus")]

[Event("killFocus")]

[Event("tabFocus")]


/**
* A highly customizable calendar component. 
* <BR><BR>
* Events:
* <BR><BR>
* <B>click</B> - Fired whenever the user clicks the mouse on one of the dates in the calender, changing the currently selected date.
* <BR>
* <B>focus</B> - Fired whenever the component receives focus.
* <BR>
* <B>killFocus</B> - Fired whenever the component loses focus.
* <BR>
* <B>tabFocus</B> - Fired whenever the component receives focus by pressing the TAB key.
* @author Beam Jive Consulting - www.beamjive.com
*/
class com.bjc.controls.Calendar extends com.bjc.core.BJCComponent {
 	private var clipParameters:Object = {dayNames:1, monthNames:1, yearFormat:1, dateEmbedFont:1, dateFontColor:1, dateFontFace:1, dateFontSize:1, headerEmbedFont:1, headerFontColor:1, headerFontFace:1, headerFontSize:1, markedColor:1, rolloverColor:1, selectedColor:1, todayColor:1};

	
	private var __disabledColor:Number = 0x999999;
	private var __embedFont:Boolean = false;
	private var __fontColor:Number = 0x333333;
	private var __fontFace:String = "_sans";
	private var __fontSize:Number = 10;

	private var __headerDisabledColor:Number = 0x999999;
	private var __headerEmbedFont:Boolean = false;
	private var __headerFontColor:Number = 0x000000;
	private var __headerFontFace:String = "_sans";
	private var __headerFontSize:Number = 12;
	
	private var __markedColor:Number = 0xbbbbbb;
	private var __rolloverColor:Number = 0xe6e6e6;
	private var __selectedColor:Number = 0xcccccc;
	private var __todayColor:Number = 0x888888;

	private var __backBtn:MovieClip;
	private var __background:Resizer;
	private var __colWidth:Number = 16;
	private var __data:Object;
	private var __dataProvider:Array;
	private var __date:Date;
	private var __dateNum:Number;
	private var __days:Array = ["S", "M", "T", "W", "T", "F", "S"];
	private var __depth:Number;
	private var __digits:Number = 4;
	private var __forwardBtn:MovieClip;
	private var __header:Label;
	private var __headerHeight:Number;
	private var __keyListener:Object;
	private var __month:Number;
	private var __months:Array = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
	private var __oneDay:Number = 1000 * 60 * 60 * 24;
	private var __rowHeight:Number = 16;
	private var __selectedItem:Date;
	private var __today:Date;
	private var __year:Number;
	
	/**
		See the EventDispatcher Class in Flash Help
	*/
	public var addEventListener:Function;
	/**
		See the EventDispatcher Class in Flash Help
	*/
	public var removeEventListener:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myCalendar.clickHandler = function(){
	* 	trace("I was clicked.");
	* }</pre>
	*/
	public var clickHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myCalendar.focusHandler = function(){
	* 	trace("Set focus.");
	* }</pre>
	*/
	public var focusHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myCalendar.killFocusHandler = function(){
	* 	trace("Kill focus.");
	* }</pre>
	*/
	public var killFocusHandler:Function;
	/**
	* Can be used to assign a direct event handler to the component instance. 
	* @usage <pre>myCalendar.tabFocusHandler = function(){
	* 	trace("Tab focus.");
	* }</pre>
	*/
	public var tabFocusHandler:Function;
	private var dispatchEvent:Function;
	private var dispatchQueue:Function;
	
	
	public function Calendar(Void) {
	}
	
	
	private function init(Void):Void {
		super.init();
		EventDispatcher.initialize(this);
		Mouse.addListener(this);
		__date = new Date();
		__today = new Date();

		draw();
	}
	
	
	private function createChildren(Void):Void {
		attachMovie("Resizer", "__background", 0);
		__background.margin = 5;
		__background.skin = "calendarSkin";
		
		attachMovie("Label", "__header", 1);
		__header.align = "center";
		__header.fontSize = 10;
		
		attachMovie("calendarBackBtn", "__backBtn", 2);
 		__backBtn.onRelease = Delegate.create(this, goBack);

		attachMovie("calendarForwardBtn", "__forwardBtn", 3);
 		__forwardBtn.onRelease = Delegate.create(this, goForward);
		
		attachMovie("Resizer", "__focus", 4);
		__focus.skin = "focusSkin";
		__focus.margin = 5;
		__focus._visible = false;

		createDayLabels();
		createDates();
	}
	
	
	/**
		@exclude
		this is documented in BJCComponent, not changed here.
	*/
	public function draw(Void):Void {
		__month = __date.getMonth();
		__year = __date.getFullYear();
		__dateNum = __date.getDate();
		
		if(__enabled){
			_alpha = 100;
		} else {
			_alpha = __alphaDisabled;
		}

		drawHeader();
		drawDayLabels();
		drawDates();
		
		size();
	}
	
	
	private function size(Void):Void {
		__headerHeight = (__height - 4) / 7;
		__rowHeight =(__height - 4 - __headerHeight * 2) / getNumRows();
		__colWidth = (__width - 4) / 7;
		
		__background.setSize(__width, __height);
		__focus.setSize(__width, __height);

		__header.move(2, 2);
		__header.setSize(__width - 4, __headerHeight);
		
		__backBtn._width = __backBtn._height = __headerHeight;
		__backBtn._x = 2;
		__backBtn._y = 2;
		
		__forwardBtn._width = __forwardBtn._height = __headerHeight;
		__forwardBtn._x = __width - __forwardBtn._width - 2;
		__forwardBtn._y = 2;

		sizeDayLabels();
		sizeDates();
		
	}
	
	
	/**
		Static method used to create an instance of a Calendar on stage at run time.
				
		@param target the movie clip to which the calendar will be attached.
		@param id the instance name given to the new calendar attached.
		@param depth the depth at which to attach the new calendar.
		@param initObj (optional) an object containing any properties you want to assign to the component when it is created
		@return a reference to the new calendar attached.
		@example
		<pre>
		import com.bjc.controls.Calendar;
		var newCalendar:Calendar = Calendar.create(_root, "myCalendar", 0);
		</pre>
	*/
	public static function create(target:MovieClip, id:String, depth:Number, initObj:Object):Calendar {
		return Calendar(target.attachMovie("Calendar", id, depth, initObj));
	}

	
	
	
	/**
		Adds a item to the calendar, consisting of a date and a data object. The date can be in the form of a single Date object, or passed as three separate parameters, year, month and date. In either case, the next parameter will be the data object. The item added will be put at the end of the array being used as a dataProvider.
	
		@param dateObject a reference to an instance of the Flash Date class.
		@param year a four digit number representing the year, e.g. 2004.
		@param month a zero index number representing the month, i.e. 0 = January, 11 = December.
		@param date a number representing the day of the month (1 - 31)
		@param data a generic object stored along with the date, can consist of a primitive type (number, string), or an actual object with its own properties.
		@return nothing
		@example
		First usage:
		<pre>
		var today:Date = new Date();
		myCalendar.addItem(today, "My Birthday");
		</pre>
		Second usage:
		<pre>
		myCalendar.addItem(2004, 11, 25, "Christmas");
		</pre>
		Using an object:
		<pre>
		myCalendar.addItem(new Date(), {temperature:73, humidity:50});
		</pre>
	*/
	public function addItem():Void {
		if(arguments.length == 2){
			var dateArg:Date = arguments[0];
			var year:Number = dateArg.getFullYear();
			var month:Number = dateArg.getMonth();
			var date:Number = dateArg.getDate();
			var data:Object = arguments[1];
			
		} else {
			var year:Number = arguments[0];
			var month:Number = arguments[1];
			var date:Number = arguments[2];
			var data:Object = arguments[3];
		}
			
		if(__dataProvider == undefined){
			__dataProvider = new Array();
		}
		__dataProvider.push({year:year, month:month, date:date, data:data});
		invalidate();
	}
	
	
	private function click(evtObj:Object):Void {
		__data = undefined;
		for(var i=0;i<__dataProvider.length;i++){
			var item:Object = __dataProvider[i];
			if(item.year == __year && item.month == __month && item.date == evtObj.target.date){
				__data = item.data;
			}
		}
		__selectedItem = new Date(evtObj.target.year, evtObj.target.month, evtObj.target.date);
		drawDates();
		dispatchEvent({type:"click", target:this});
		if(Selection.getFocus() != "" + this) Selection.setFocus(this);
	}


	private function createDates(Void):Void {
		__depth = 100;
		var num:Number = 0;
		for(var y=2;y<7;y++){
			for(var x=0;x<7;x++){
				var box:CalendarItem = CalendarItem(attachMovie("CalendarItem", "box" + num, __depth));
				box.addEventListener("click", this);
				__depth++;
				num++;
			}
		}
		for(var i=0;i<2;i++){
			var box:CalendarItem = CalendarItem(attachMovie("CalendarItem", "box" + num, __depth));
			box.addEventListener("click", this);
			__depth++;
			num++;
		}
	}
	
	
	private function createDayLabels(Void):Void {
		__depth = 10;
		for(var x=0;x<7;x++){
			attachMovie("Label", "label" + __depth, __depth);
			var day:String = __days[x].substr(0, 2);
			this["label" + __depth].text = day;
			__depth++;
		}
	}
	
	
	private function drawDates(Void):Void {
		var num:Number = 1;
		var startedNumbering:Boolean = false;
		var endedNumbering:Boolean = false;
		for(var i=0;i<37;i++){
			var box:CalendarItem = this["box" + i];
			box._visible = false;
			box.clear();
			if(i >= getFirstDayOfMonth() || startedNumbering){
				setBoxProps(box);
				if(!endedNumbering){
					box._visible = true;
					box.setDate(__year, __month, num);
					box.isToday = isToday(num);
					
					if(__year == __selectedItem.getFullYear() && __month == __selectedItem.getMonth() && num == __selectedItem.getDate()){
						box.selected = true;
					} else {
						box.selected = false;
					}
						
					num++;
					startedNumbering = true;
					endedNumbering = (num > getDaysInMonth());
				}
			}
		}
		showSpecialDates();
	}
	
	
	private function drawDayLabels(Void):Void {
		__depth = 10;
		for(var x=0;x<7;x++){
			var box:Label = this["label" + __depth];
			box.disabledColor = __disabledColor;
			box.embedFont = __embedFont;
			box.fontColor = __headerFontColor;
			box.fontFace = __fontFace;
			box.fontSize = __fontSize;
			box.align = "center";
			box.enabled = __enabled;
			__depth++;
		}
	}
	
	
	private function drawHeader(Void):Void {
		__header.text = __months[__month];
		if(__digits == 2){
			__header.text += " " + __year.toString().substring(2);
		} else if(__digits == 3){
			__header.text += " '" + __year.toString().substring(2);
		} else {
			__header.text += " " + __year;
		}	
		__header.disabledColor = __headerDisabledColor;
		__header.embedFont = __headerEmbedFont;
		__header.fontColor = __headerFontColor;
		__header.fontFace = __headerFontFace;
		__header.fontSize = __headerFontSize;
		__header.enabled = __enabled;
	}
	
		
	private function getDaysInMonth(Void):Number {
		var first:Date = new Date(__year, __month, 1);
		var nextFirst:Date = new Date(__year, __month + 1, 1);
		return Math.round((nextFirst - first) / __oneDay);
	}
	
	
	private function getFirstDayOfMonth(Void):Number {
		return new Date(__year, __month, 1).getDay();
	}
	
	
	private function getNumRows(Void):Number {
		if(getDaysInMonth() + getFirstDayOfMonth() > 35){
			return 6;
		} else {
			return 5;
		}
	}
	
	
	private function goBack(Void):Void {
		if(__enabled){
			__date = new Date(__year, __month - 1, __dateNum);
			invalidate();
			if(Selection.getFocus() != "" + this) Selection.setFocus(this);
		}
	}
	
	
	private function goForward(Void):Void {
		if(__enabled){
			__date = new Date(__year, __month + 1, 1);
			invalidate();
			if(Selection.getFocus() != "" + this) Selection.setFocus(this);
		}
	}
	
	private function previousDay(Void):Void {
		if(__enabled && __selectedItem != undefined){
			var d:Number = __selectedItem.getDate();
			var m:Number = __selectedItem.getMonth();
			var y:Number = __selectedItem.getFullYear();
			d --;
			if(d < 1){
				m --;
				if(m < 0){
					m = 11;
					y --;
				}
				var first:Date = new Date(y, m, 1);
				var second:Date = new Date(y, m + 1, 1);
				d = Math.round((second - first) / __oneDay);
			} 
			selectedItem = new Date(y, m, d);
		}
	}
	
	
	private function nextDay(Void):Void {
		if(__enabled && __selectedItem != undefined){
			var d:Number = __selectedItem.getDate();
			var m:Number = __selectedItem.getMonth();
			var y:Number = __selectedItem.getFullYear();
			d ++;
			if(d > getDaysInMonth()){
				d = 1;
				m ++;
				if(m > 11){
					m = 0;
					y ++;
				}
			}
			selectedItem = new Date(y, m, d);
		}
	}
	
	private function isToday(num:Number):Boolean {
		return __year == __today.getFullYear()
				   &&
				__month == __today.getMonth()
				   &&
				num == __today.getDate();
	}
	
	private function onKeyPressed(Void):Void {
		if((Selection.getFocus() == "" + this) && __enabled && __keyEnabled){
			if(Key.getCode() == Key.LEFT || Key.getCode() == Key.UP){
				previousDay();
			} else if(Key.getCode() == Key.RIGHT || Key.getCode() == Key.DOWN){
				nextDay();
			}
		}
	}
	
	
	private function onKillFocus(newFocus:Object):Void {
		//Key.removeListener(this);
		Key.removeListener(__keyListener);
		__keyListener = null;
		hideFocus();
		dispatchEvent({type:"killFocus", target:this, newfocus:newFocus});
	}
	
	
	private function onSetFocus(oldFocus:Object):Void {
		//Key.addListener(this);
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
	
	
	private function onMouseWheel(delta:Number):Void {
		if((Selection.getFocus() == "" + this) && __enabled && (_xmouse > 0) && (_xmouse < __width) && (_ymouse > 0) && (_ymouse < __height)){
			if(delta > 0){
				nextDay();
			} else {
				previousDay();
			}
		}
	}
	
	/**
		Removes all data that has been previously added to the calender, clearing any external array being used as a dataProvider.
	
		@return nothing
		@example
		<pre>
		myCalendar.removeAll();
		</pre>
	*/
	public function removeAll(Void):Void {
		__dataProvider = new Array();
		invalidate();
	}
	
	
	/**
		Removes the item stored at the specified date.
	
		@param year a four digit number representing the year, e.g. 2004.
		@param month a zero index number representing the month, i.e. 0 = January, 11 = December.
		@param date a number representing the day of the month (1 - 31)
		@return nothing
		@example
		<pre>
		myCalendar.removeItem(2004, 12, 25);
		</pre>
	*/
	public function removeItem(year:Number, month:Number, date:Number):Void {
		for(var i=0;i<__dataProvider.length;i++){
			var item:Object = __dataProvider[i];
			if(item.year == year && item.month == month && item.date == date){
				__dataProvider.splice(i, 1);
			}
		}
		invalidate();
	}
	
	
	private function setBoxProps(box:CalendarItem):Void {
		box.enabled = __enabled;
		box.markedColor = __markedColor;
		box.rolloverColor = __rolloverColor;
		box.selectedColor = __selectedColor;
		box.todayColor = __todayColor;
		box.clear();
		box.selected = false;

		var label:Label = box.label;
		label.disabledColor = __disabledColor;
		label.embedFont = __embedFont;
		label.fontColor = __fontColor;
		label.fontFace = __fontFace;
		label.fontSize = __fontSize;
	}
	
	
	/**
		Sets the current date of the calendar and displays that month. There are two ways to call this function. First, by passing it a date object of the date you want to change to. The other way is to pass in the year, month and date of the date you want to change to.
				
		@param date (usage 1) a Date object.
		@param year (usage 2) a four digit number representing the year.
		@param month (usage 2) a number representing the month (0-11).
		@param day (usage 2) a number representing the day of the month.
		@return nothing
		@example
		<pre>
		// usage 1:
		myDate = new Date(cal1.selectedItem.year, cal1.selectedItem.month, cal1.selectedItem.date);
		cal2.setDate(myDate);
		
		// usage 2:
		cal1.setDate(2005, 11, 25);
		</pre>
	*/
	public function setDate():Void {
		if(arguments.length == 3){
			__date = new Date(arguments[0], arguments[1], arguments[2]);
			invalidate();
		} else if(arguments.length == 1 && arguments[0] instanceof Date){
			__date = arguments[0];
			invalidate();
		}
	}
	
	
	private function showSpecialDates(Void):Void {
		for(var i=0;i<__dataProvider.length;i++){
			if(__dataProvider[i].year == __year && __dataProvider[i].month == __month){
				for(var j=0;j<42;j++){
					var box:CalendarItem = this["box" + j];
					if(box.date == __dataProvider[i].date){
						box.mark();

						if(box.date == __selectedItem.getDate()){
							box.selected = true;
						} else {
							box.selected = false;
						}
					}
				}
			}
		}
	}
		
	
	private function sizeDates(Void):Void {
		var num:Number = 0;
		for(var y=0;y<5;y++){
			for(var x=0;x<7;x++){
				var box:CalendarItem = this["box" + num];
				box.move(x * __colWidth + 2, __headerHeight * 2 + y * __rowHeight + 2);
				box.setSize(__colWidth, __rowHeight);
				num++;
			}
		}
		for(var i=0;i<2;i++){
			var box:CalendarItem = this["box" + num];
			box.move(i * __colWidth + 2, __headerHeight * 2 + 5 * __rowHeight + 2);
			box.setSize(__colWidth, __rowHeight);
			num++;
		}
	}
	
	
	
	
	private function sizeDayLabels(Void):Void {
		__depth = 10;
		for(var x=0;x<7;x++){
			var box:Label = this["label" + __depth];
			box.move(x * __colWidth + 2, __headerHeight + 2);
			box.setSize(__colWidth, __headerHeight);
			__depth++;
		}
	}
	
	





	/**
		An array used to hold the data used by the calendar. Each element of the array holds an object, which contains two properties. The date property holds an instance of the Flash Date class. The data property can hold any value.
	
		@example
		<pre>
		var myDates:Array = [{date:new Date(2004, 11, 25), data:"Christmas"}];
		myCalendar.dataProvider = myDates;
		</pre>
	*/
	public function set dataProvider(dp:Array) {
		__dataProvider = new Array();
		for(var i=0; i<dp.length; i++){
			if(dp[i].date instanceof Date){
				var dateArg:Date = dp[i].date;
				var year:Number = dateArg.getFullYear();
				var month:Number = dateArg.getMonth();
				var date:Number = dateArg.getDate();
				var data:Object = dp[i].data;
			} else {
				var year:Number = dp[i].year;
				var month:Number = dp[i].month;
				var date:Number = dp[i].date;
				var data:Object = dp[i].data;
			}
			__dataProvider.push({year:year, month:month, date:date, data:data});
		}
		invalidate();
	}
	/**
		Gets the array used to hold the data used by the calendar. 
	
		@example
		<pre>
		myVar = myCalendar.dataProvider;
		</pre>
	*/
	public function get dataProvider():Array {
		return __dataProvider;
	}
	
	/**
		An array of 7 strings used to display the names of the weekdays in the calendar. The first weekday in the clendar is Sunday.
	
		@example
		<pre>
		myCalendar.dayNames = ["S", "M", "T", "W", "T", "F", "S"];
		myCalendar.dayNames[0] = "S";
		</pre>
	*/
	[Inspectable (type="Array", defaultValue=["S,M,T,W,T,F,S")]
	public function set dayNames(names:Array) {
		__days = names;
		invalidate();
	}
	/**
		Gets an array of 7 strings used to display the names of the weekdays in the calendar.
	
		@example
		<pre>
		myVar = myCalendar.dayNames;
		</pre>
	*/
	public function get dayNames():Array {
		return __days;
	}
	
	/**
		An array of twelve strings used to display the names of the months in the calendar.
	
		@example
		<pre>
		myCalendar.monthNames = ["Jan", "Feb", "Mar" ... "Dec"];
		myCalendar.monthNames[1] = "February!!!";
		</pre>
	*/
	[Inspectable (type="Array", defaultValue=["January,February,March,April,May,June,July,August,September,October,November,December")]
	public function set monthNames(names:Array) {
		__months = names;
		invalidate();
	}
	/**
		Gets an array of twelve strings used to display the names of the months in the calendar.
	
		@example
		<pre>
		myVar = myCalendar.monthNames;
		</pre>
	*/
	public function get monthNames():Array {
		return __months;
	}
	
	
	/**
		Returns the object associated with the selected date, in the form described in the dataProvider property description.
	
		@example
		<pre>
		trace(myCalendar.selectedItem.date);
		trace(myCalendar.selectedItem.data);
		</pre>
	*/
	public function get selectedItem():Object {
		__data = undefined;
		for(var i=0;i<__dataProvider.length;i++){
			var item:Object = __dataProvider[i];
			if(item.year == __selectedItem.getFullYear() && item.month == __selectedItem.getMonth() && item.date == __selectedItem.getDate()){
				__data = item.data;
			}
		}
		return {year:__selectedItem.getFullYear(), month:__selectedItem.getMonth(), date:__selectedItem.getDate(), data:__data};
	}
	/**
		Returns the object associated with the selected date, in the form described in the dataProvider property description.
	
		@example
		<pre>
		trace(myCalendar.selectedItem.date);
		trace(myCalendar.selectedItem.data);
		</pre>
	*/
	public function set selectedItem(item:Date):Void {
		__selectedItem = item;
		__date = item;
		
		invalidate();
		dispatchEvent({type:"click", target:this});
	}

	/**
		Specifies how the year will be displayed in the calendar. A value of 4 will display in the format 2004, 3 will display '04, 2 will display 04.
	
		@example
		<pre>
		myCalendar.yearFormat = 3;
		</pre>
	*/
	[Inspectable (type=Number, defaultValue="4", enumeration="2,3,4")]
	public function set yearFormat(digits:Number) {
		__digits = digits;
		if(__digits != 2 && __digits != 3){
			__digits = 4;
		}
		invalidate();
	}
	/**
		Gets how the year is displayed in the calendar. 
	
		@example
		<pre>
		myVar = myCalendar.yearFormat;
		</pre>
	*/
	public function get yearFormat():Number {
		return __digits;
	}
	
	
	
	
	
	
	
	// TEXT STYLES =============================================================================

	/**
		Sets the color of date text when the calendar is disabled, as described in the Label component.
	
		@example
		<pre>
		myCalendar.dateDisabledColor = 0xcccccc;
		</pre>
	*/
	public function set dateDisabledColor(c:Number) {
		__disabledColor = c;
		invalidate();
	}
	/**
		Gets the color of date text when the calendar is disabled, as described in the Label component.
	
		@example
		<pre>
		myVar = myCalendar.dateDisabledColor;
		</pre>
	*/
	public function get dateDisabledColor():Number {
		return __disabledColor;
	}
	
	
	/**
		Sets whether the font for the date text will be embedded, as described in the Label component.
	
		@example
		<pre>
		myCalendar.dateEmbedFont = true;
		</pre>
	*/
	[Inspectable (defaultValue=false, type="Boolean", category="textstyles", verbose=1)]
	public function set dateEmbedFont(b:Boolean) {
		__embedFont = b;
		invalidate();
	}
	/**
		Gets whether the font for the date text will be embedded, as described in the Label component.
	
		@example
		<pre>
		myVar = myCalendar.dateEmbedFont;
		</pre>
	*/
	public function get dateEmbedFont():Boolean {
		return __embedFont;
	}
	
	
	/**
		Sets the text color of dates, as described in the Label component.
	
		@example
		<pre>
		myCalendar.dateFontColor = 0x333333;
		</pre>
	*/
	[Inspectable (type="Color", defaultValue="#666666", category="textstyles", verbose=1)]
	public function set dateFontColor(col:Number) {
		__fontColor = col;
		invalidate();
	}
	/**
		Gets the text color of dates, as described in the Label component.
	
		@example
		<pre>
		myVar = myCalendar.dateFontColor;
		</pre>
	*/
	public function get dateFontColor():Number {
		return __fontColor;
	}
	
	
	/**
		Sets the font used for the dates, as described in the Label component.
	
		@example
		<pre>
		myCalendar.dateFontFace = "Arial";
		</pre>
	*/
	[Inspectable (type="Font Name", defaultValue="_sans", category="textstyles", verbose=1)]
	public function set dateFontFace(font:String) {
		__fontFace = font;
		invalidate();
	}
	/**
		Gets the font used for the dates, as described in the Label component.
	
		@example
		<pre>
		myVar = myCalendar.dateFontFace;
		</pre>
	*/
	public function get dateFontFace():String {
		return __fontFace;
	}
	
	
	/**
		Sets the size of the font used for the dates, as described in the Label component.
	
		@example
		<pre>
		myCalendar.dateFontSize = 20;
		</pre>
	*/
	[Inspectable (defaultValue=10, category="textstyles", verbose=1)]
	public function set dateFontSize(size:Number) {
		__fontSize = size;
		invalidate();
	}
	/**
		Gets the size of the font used for the dates, as described in the Label component.
	
		@example
		<pre>
		myVar = myCalendar.dateFontSize;
		</pre>
	*/
	public function get dateFontSize():Number {
		return __fontSize;
	}
	
		
	// HEADER TEXT STYLES ======================================================================
	
	/**
		Sets the color of header text when the calendar is disabled, as described in the Label component.
	
		@example
		<pre>
		myCalendar.headerDisabledColor = 0xcccccc;
		</pre>
	*/
	public function set headerDisabledColor(c:Number) {
		__headerDisabledColor = c;
		invalidate();
	}
	/**
		Gets the color of header text when the calendar is disabled, as described in the Label component.
	
		@example
		<pre>
		myVar = myCalendar.headerDisabledColor;
		</pre>
	*/
	public function get headerDisabledColor():Number {
		return __headerDisabledColor;
	}
	

	/**
		Sets whether the font for the header text will be embedded, as described in the Label component.
	
		@example
		<pre>
		myCalendar.headerEmbedFont = true;
		</pre>
	*/
	[Inspectable (defaultValue=false, type="Boolean", category="textstyles", verbose=1)]
	public function set headerEmbedFont(b:Boolean) {
		__headerEmbedFont = b;
		invalidate();
	}
	/**
		Gets whether the font for the header text will be embedded, as described in the Label component.
	
		@example
		<pre>
		myVar = myCalendar.headerEmbedFont;
		</pre>
	*/
	public function get headerEmbedFont():Boolean {
		return __headerEmbedFont;
	}
	
	
	/**
		Sets the text color of the header, as described in the Label component.
	
		@example
		<pre>
		myCalendar.headerFontColor = 0xff00cc;
		</pre>
	*/
	[Inspectable (type="Color", defaultValue="#000000", category="textstyles", verbose=1)]
	public function set headerFontColor(col:Number) {
		__headerFontColor = col;
		invalidate();
	}
	/**
		Gets the text color of the header, as described in the Label component.
	
		@example
		<pre>
		myVar = myCalendar.headerFontColor;
		</pre>
	*/
	public function get headerFontColor():Number {
		return __headerFontColor;
	}
	
	
	/**
		Sets the font used for the header, as described in the Label component.
	
		@example
		<pre>
		myCalendar.headerFontFace = "Arial";
		</pre>
	*/
	[Inspectable (type="Font Name", defaultValue="_sans", category="textstyles", verbose=1)]
	public function set headerFontFace(font:String) {
		__headerFontFace = font;
		invalidate();
	}
	/**
		Gets the font used for the header, as described in the Label component.
	
		@example
		<pre>
		myVar = myCalendar.headerFontFace;
		</pre>
	*/
	public function get headerFontFace():String {
		return __headerFontFace;
	}
	
	
	/**
		Sets the size of the font used for the header, as described in the Label component.
	
		@example
		<pre>
		myCalendar.headerFontSize = 20;
		</pre>
	*/
	[Inspectable (defaultValue=12, category="textstyles", verbose=1)]
	public function set headerFontSize(size:Number) {
		__headerFontSize = size;
		invalidate();
	}
	/**
		Gets the size of the font used for the header, as described in the Label component.
	
		@example
		<pre>
		myVar = myCalendar.headerFontSize;
		</pre>
	*/
	public function get headerFontSize():Number {
		return __headerFontSize;
	}
	
	
	// SPECIAL TEXT STYLES =====================================================================
	/**
		Sets the background color of the special dates added to the calender.
	
		@example
		<pre>
		myCalendar.markedColor = 0xff00cc;
		</pre>
	*/
	[Inspectable (type="Color", defaultValue="#BBBBBB", category="specialcolors")]
	public function set markedColor(col:Number) {
		__markedColor = col;
		invalidate();
	}
	/**
		Gets the background color of the special dates added to the calender.
	
		@example
		<pre>
		myVar = myCalendar.markedColor;
		</pre>
	*/
	public function get markedColor():Number {
		return __markedColor;
	}


	/**
		Sets the background color of the dates when the mouse moves over them.
	
		@example
		<pre>
		myCalendar.rolloverColor = 0xffcc00;
		</pre>
	*/
	[Inspectable (type="Color", defaultValue="#E6E6E6", category="specialcolors")]
	public function set rolloverColor(col:Number) {
		__rolloverColor = col;
		invalidate();
	}
	/**
		Gets the background color of the dates when the mouse moves over them.
	
		@example
		<pre>
		myCalendar.rolloverColor = 0xffcc00;
		</pre>
	*/
	public function get rolloverColor():Number {
		return __rolloverColor;
	}


	/**
		Sets the background color of the dates when selected.
	
		@example
		<pre>
		myCalendar.selectedColor = 0xffccff;
		</pre>
	*/
	[Inspectable (type="Color", defaultValue="#CCCCCC", category="specialcolors")]
	public function set selectedColor(col:Number) {
		__selectedColor = col;
		invalidate();
	}
	/**
		Gets the background color of the dates when selected.
	
		@example
		<pre>
		myVar = myCalendar.selectedColor;
		</pre>
	*/
	public function get selectedColor():Number {
		return __selectedColor;
	}
	

	/**
		Sets the background color of the current date.
	
		@example
		<pre>
		myCalendar.todayColor = 0xffccff;
		</pre>
	*/
	[Inspectable (type="Color", defaultValue="#888888", category="specialcolors")]
	public function set todayColor(col:Number) {
		__todayColor = col;
		invalidate();
	}
	/**
		Gets the background color of the current date.
	
		@example
		<pre>
		myVar = myCalendar.todayColor;
		</pre>
	*/
	public function get todayColor():Number {
		return __todayColor;
	}
	
	
}