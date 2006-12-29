import org.asapframework.events.EventDelegate;import mx.transitions.Tween;import com.madhouse.Fiestas;/** * @author xperiments3 */class com.madhouse.Main {		private static var instance : Main;	private var _timeline : MovieClip;	private var _mainHome : MovieClip;	private var _madHouseButton : MovieClip;	private var _schranzButton : MovieClip;	private var _mainMenu : MovieClip;	private var _fiestas : Fiestas;		/**	 * @return singleton instance of Main	 */	public static function getInstance() : Main {		if (instance == null)			instance = new Main();		return instance;	}		private function Main() {			}		public function init( _mc:MovieClip )	{		_timeline = _mc;		createUI( );		initEvents( );	}			public function createUI( )	{		_mainHome = _timeline.attachMovie('MainHome','MainHomeMC', _timeline.getNextHighestDepth() );		_madHouseButton = _mainHome.MadHouseButton;		_schranzButton = _mainHome.SchranzButton;		_mainMenu = _mainHome.MainMenuMC;		_fiestas = Fiestas.getInstance();		_fiestas.init( _timeline );		} 		public function initEvents( )	{		_schranzButton.onPress = EventDelegate.create( this, showSchranz );			}		private function restoreSchranzEvents( )	{		_schranzButton.onPress = EventDelegate.create( this, showHome );		_fiestas.loadData( );			}	public function showSchranz( )	{		var tmpTween:Tween = new Tween( _mainHome, "_y", mx.transitions.easing.Regular.easeIn,0, -165, 10, false );		tmpTween.onMotionFinished = EventDelegate.create( this, restoreSchranzEvents );	}	public function showHome( )	{		initEvents( );		new Tween( _mainHome, "_y", mx.transitions.easing.Regular.easeIn,-165, 0, 10, false );	}				}