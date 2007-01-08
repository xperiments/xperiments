import com.bjc.resizers.Resizer;

[IconFile ("icons/GroupBox.png")]


/**
* Basically a border which can be placed around any group of component, but also contains functionality to group together any Radio Buttons that it surrounds. Simply put a group box on stage, size and position it. Then place radio buttons so they fall within its border. The radio buttons within the group box will act as a single group, separate from any other radio buttons on stage.
* @author Beam Jive Consulting - www.beamjive.com
*/
class com.bjc.controls.GroupBox extends com.bjc.core.BJCComponent {
	
	private var __background:Resizer;
	private var __radioButtonGroups:Array;
	
	public function GroupBox(Void) {
	}
	
	
	private function init(Void):Void {
		super.init();
		__radioButtonGroups = new Array();
		
		draw();
	}
	
	
	private function createChildren(Void):Void {
		attachMovie("Resizer", "__background", 0);
		__background.skin = "groupBoxSkin";
		__background.margin = 5;
	}
	
	
	/**
		@exclude
	*/
	public function draw(Void):Void {
		size();
	}
	
	
	private function size(Void):Void {
		__background.setSize(__width, __height);
	}
	
	
	/**
		Static method used to create an instance of a GroupBox on stage at run time.
				
		@param target the movie clip to which the groupbox will be attached.
		@param id the instance name given to the new groupbox attached.
		@param depth the depth at which to attach the new groupbox.
		@param initObj (optional) an object containing any properties you want to assign to the component when it is created
		@return a reference to the new groupbox attached.
		@example
		<pre>
		import com.bjc.controls.GroupBox;
		var newGroupBox:GroupBox = GroupBox.create(_root, "myGroupBox", 0);
		</pre>
	*/
	public static function create(target:MovieClip, id:String, depth:Number, initObj:Object):GroupBox {
		return GroupBox(target.attachMovie("GroupBox", id, depth, initObj));
	}
		
	

	
	
	
	
	
	/**
		@exclude
	*/
	public function get isGroupBox():Boolean {
		return true;
	}
	
	
	/**
		Returns an array of radio button groups associated with this group box. Most often there will only be a single group within one group box, which would be contained in element 0.
				
		@example
		<pre>
		trace(myGroupBox.radioButtonGroups[0]);
		</pre>
	*/
	public function get radioButtonGroups():Array {
		return __radioButtonGroups;
	}
}