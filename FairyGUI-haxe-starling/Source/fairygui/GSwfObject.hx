package fairygui;

import fairygui.GObject;
import fairygui.IAnimationGear;
import fairygui.PackageItem;

import fairygui.display.UISprite;

import starling.display.DisplayObject;

class GSwfObject extends GObject implements IAnimationGear
{
    public var playing(get, set) : Bool;
    public var frame(get, set) : Int;
    public var gearAnimation(get, never) : GearAnimation;

    private var _container : UISprite;
    private var _content : DisplayObject;
    private var _playing : Bool;
    private var _frame : Int;
    private var _gearAnimation : GearAnimation;
    
    public function new()
    {
        super();
        _playing = true;
        
        _gearAnimation = new GearAnimation(this);
    }
    
    override private function createDisplayObject() : Void
    {
        _container = new UISprite(this);
        setDisplayObject(_container);
    }
    
    @:final private function get_playing() : Bool
    {
        return _playing;
    }
    
    private function set_playing(value : Bool) : Bool
    {
        if (_playing != value) 
        {
            _playing = value;
            if (_gearAnimation.controller) 
                _gearAnimation.updateState();
        }
        return value;
    }
    
    @:final private function get_frame() : Int
    {
        return _frame;
    }
    
    private function set_frame(value : Int) : Int
    {
        if (_frame != value) 
        {
            _frame = value;
            
            if (_gearAnimation.controller) 
                _gearAnimation.updateState();
        }
        return value;
    }
    
    @:final private function get_gearAnimation() : GearAnimation
    {
        return _gearAnimation;
    }
    
    override private function handleSizeChanged() : Void
    {
        if (_content != null) 
        {
            _container.scaleX = this.width / _sourceWidth * this.scaleX;
            _container.scaleY = this.height / _sourceHeight * this.scaleY;
        }
    }
    
    override public function handleControllerChanged(c : Controller) : Void
    {
        super.handleControllerChanged(c);
        if (_gearAnimation.controller == c) 
            _gearAnimation.apply();
    }
    
    override public function constructFromResource(pkgItem : PackageItem) : Void
    {
        _packageItem = pkgItem;
        
        _sourceWidth = _packageItem.width;
        _sourceHeight = _packageItem.height;
        _initWidth = _sourceWidth;
        _initHeight = _sourceHeight;
        
        setSize(_sourceWidth, _sourceHeight);
    }
    
    override public function setup_beforeAdd(xml : FastXML) : Void
    {
        super.setup_beforeAdd(xml);
        
        var str : String = xml.att.playing;
        _playing = str != "false";
    }
    
    override public function setup_afterAdd(xml : FastXML) : Void
    {
        super.setup_afterAdd(xml);
        
        var cxml : FastXML = xml.nodes.gearAni.get(0);
        if (cxml != null) 
            _gearAnimation.setup(cxml);
    }
}
