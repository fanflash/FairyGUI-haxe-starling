package fairygui;

import fairygui.GObject;
import fairygui.IAnimationGear;
import fairygui.IColorGear;
import fairygui.PackageItem;

import openfl.geom.Rectangle;

import fairygui.display.MovieClip;
import fairygui.display.UIMovieClip;
import fairygui.utils.ToolSet;

import haxe.xml.Fast;

class GMovieClip extends GObject implements IAnimationGear implements IColorGear
{
    public var color(get, set) : Int;
    public var playing(get, set) : Bool;
    public var frame(get, set) : Int;
    public var gearAnimation(get, never) : GearAnimation;
    public var gearColor(get, never) : GearColor;

    private var _gearAnimation : GearAnimation;
    private var _gearColor : GearColor;
    
    private var _movieClip : MovieClip;
    
    public function new()
    {
        super();
        _gearAnimation = new GearAnimation(this);
        _gearColor = new GearColor(this);
    }
    
    private function get_color() : Int
    {
        return 0;
    }
    
    private function set_color(value : Int) : Int
    {
        
        return value;
    }
    
    override private function createDisplayObject() : Void
    {
        _movieClip = new UIMovieClip(this);
        setDisplayObject(_movieClip);
    }
    
    @:final private function get_playing() : Bool
    {
        return _movieClip.playing;
    }
    
    @:final private function set_playing(value : Bool) : Bool
    {
        if (_movieClip.playing != value) 
        {
            _movieClip.playing = value;
            if (_gearAnimation.controller) 
                _gearAnimation.updateState();
        }
        return value;
    }
    
    @:final private function get_frame() : Int
    {
        return _movieClip.currentFrame;
    }
    
    private function set_frame(value : Int) : Int
    {
        if (_movieClip.currentFrame != value) 
        {
            _movieClip.currentFrame = value;
            if (_gearAnimation.controller) 
                _gearAnimation.updateState();
        }
        return value;
    }
    
    @:final private function get_gearAnimation() : GearAnimation
    {
        return _gearAnimation;
    }
    
    @:final private function get_gearColor() : GearColor
    {
        return _gearColor;
    }
    
    override public function handleControllerChanged(c : Controller) : Void
    {
        super.handleControllerChanged(c);
        if (_gearAnimation.controller == c) 
            _gearAnimation.apply();
        if (_gearColor.controller == c) 
            _gearColor.apply();
    }
    
    override private function handleSizeChanged() : Void
    {
        displayObject.scaleX = this.width / _sourceWidth * this.scaleX;
        displayObject.scaleY = this.height / _sourceHeight * this.scaleY;
    }
    
    override public function constructFromResource(pkgItem : PackageItem) : Void
    {
        _packageItem = pkgItem;
        
        _sourceWidth = _packageItem.width;
        _sourceHeight = _packageItem.height;
        _initWidth = _sourceWidth;
        _initHeight = _sourceHeight;
        
        setSize(_sourceWidth, _sourceHeight);
        
        if (_packageItem.loaded) 
            __movieClipLoaded(_packageItem)
        else 
        _packageItem.owner.addItemCallback(_packageItem, __movieClipLoaded);
    }
    
    private function __movieClipLoaded(pi : PackageItem) : Void
    {
        _movieClip.interval = _packageItem.interval;
        _movieClip.frames = _packageItem.frames;
        _movieClip.boundsRect = new Rectangle(0, 0, sourceWidth, sourceHeight);
        handleSizeChanged();
    }
    
    override public function setup_beforeAdd(xml : Fast) : Void
    {
        super.setup_beforeAdd(xml);
        
        var str : String;
        str = xml.att.frame;
        if (str != null) 
            _movieClip.currentFrame = Std.parseInt(str);
        str = xml.att.playing;
        _movieClip.playing = str != "false";
        str = xml.att.color;
        if (str != null) 
            this.color = ToolSet.convertFromHtmlColor(str);
    }
    
    override public function setup_afterAdd(xml : Fast) : Void
    {
        super.setup_afterAdd(xml);
        
        var cxml : Fast = xml.nodes.gearAni.get(0);
        if (cxml != null) 
            _gearAnimation.setup(cxml);
        cxml = xml.nodes.gearColor.get(0);
        if (cxml != null) 
            _gearColor.setup(cxml);
    }
}
