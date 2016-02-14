package fairygui;

import fairygui.GObject;
import fairygui.IColorGear;
import fairygui.PackageItem;

import fairygui.display.ImageExt;
import fairygui.display.UIImage;
import fairygui.utils.ToolSet;

import starling.textures.TextureSmoothing;

import haxe.xml.Fast;

class GImage extends GObject implements IColorGear
{
    public var color(get, set) : Int;
    public var flip(get, set) : Int;
    public var gearColor(get, never) : GearColor;

    private var _gearColor : GearColor;
    
    private var _content : ImageExt;
    
    public function new()
    {
        super();
        _gearColor = new GearColor(this);
    }
    
    private function get_color() : Int
    {
        return _content.color;
    }
    
    private function set_color(value : Int) : Int
    {
        if (_content.color != value) 
        {
            _content.color = value;
            if (_gearColor.controller != null) 
                _gearColor.updateState();
        }
        return value;
    }
    
    private function get_flip() : Int
    {
        return _content.flip;
    }
    
    private function set_flip(value : Int) : Int
    {
        _content.flip = value;
        return value;
    }
    
    override private function createDisplayObject() : Void
    {
        _content = new UIImage(this);
        setDisplayObject(_content);
    }
    
    @:final private function get_gearColor() : GearColor
    {
        return _gearColor;
    }
    
    override public function handleControllerChanged(c : Controller) : Void
    {
        super.handleControllerChanged(c);
        if (_gearColor.controller == c) 
            _gearColor.apply();
    }
    
    override public function dispose() : Void
    {
        if (!_packageItem.loaded) 
            _packageItem.owner.removeItemCallback(_packageItem, __imageLoaded);
        super.dispose();
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
            __imageLoaded(_packageItem)
        else 
        _packageItem.owner.addItemCallback(_packageItem, __imageLoaded);
    }
    
    private function __imageLoaded(pi : PackageItem) : Void
    {
        if (pi.texture != null) 
        {
            _content.texture = pi.texture;
            _content.scale9Grid = pi.scale9Grid;
            _content.scaleByTile = pi.scaleByTile;
            _content.smoothing = (pi.smoothing) ? TextureSmoothing.BILINEAR : TextureSmoothing.NONE;
        }
        
        handleSizeChanged();
    }
    
    override private function handleSizeChanged() : Void
    {
        _content.scaleX = this.width / _sourceWidth * this.scaleX;
        _content.scaleY = this.height / _sourceHeight * this.scaleY;
    }
    
    override public function setup_beforeAdd(xml : Fast) : Void
    {
        super.setup_beforeAdd(xml);
        
        var str : String;
        str = xml.att.color;
        if (str != null) 
            this.color = ToolSet.convertFromHtmlColor(str);
        
        str = xml.att.flip;
        if (str != null) 
            _content.flip = FlipType.parse(str);
    }
    
    override public function setup_afterAdd(xml : Fast) : Void
    {
        super.setup_afterAdd(xml);
        
        var cxml : Fast = xml.nodes.gearAni.get(0);
        cxml = xml.nodes.gearColor.get(0);
        if (cxml != null) 
            _gearColor.setup(cxml);
    }
}
