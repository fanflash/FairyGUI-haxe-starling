package fairygui;

import fairygui.GObject;
import fairygui.GObjectPool;
import fairygui.IAnimationGear;
import fairygui.IColorGear;
import fairygui.PackageItem;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Loader;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.geom.Rectangle;
import openfl.net.URLRequest;

import fairygui.display.ImageExt;
import fairygui.display.MovieClip;
import fairygui.display.UISprite;
import fairygui.utils.ToolSet;

import starling.display.DisplayObject;
import starling.textures.Texture;
import starling.textures.TextureSmoothing;

import haxe.xml.Fast;

class GLoader extends GObject implements IColorGear implements IAnimationGear
{
    public var url(get, set) : String;
    public var align(get, set) : Int;
    public var verticalAlign(get, set) : Int;
    public var fill(get, set) : Int;
    public var autoSize(get, set) : Bool;
    public var playing(get, set) : Bool;
    public var frame(get, set) : Int;
    public var color(get, set) : Int;
    public var showErrorSign(get, set) : Bool;

    private var _gearAnimation : GearAnimation;
    private var _gearColor : GearColor;
    
    private var _url : String;
    private var _align : Int;
    private var _verticalAlign : Int;
    private var _autoSize : Bool;
    private var _fill : Int;
    private var _showErrorSign : Bool;
    private var _playing : Bool;
    private var _frame : Int;
    private var _color : Int;
    
    private var _contentItem : PackageItem;
    private var _contentSourceWidth : Int;
    private var _contentSourceHeight : Int;
    private var _contentWidth : Int;
    private var _contentHeight : Int;
    
    private var _container : UISprite;
    private var _content : DisplayObject;
    private var _errorSign : GObject;
    
    private var _updatingLayout : Bool;
    
    private var _loading : Int;
    private var _externalLoader : Loader;
    
    private static var _errorSignPool : GObjectPool = new GObjectPool();
    
    public function new()
    {
        super();
        _playing = true;
        _url = "";
        _align = AlignType.Left;
        _verticalAlign = VertAlignType.Top;
        _showErrorSign = true;
        _color = 0xFFFFFF;
        
        _gearAnimation = new GearAnimation(this);
        _gearColor = new GearColor(this);
    }
    
    override private function createDisplayObject() : Void
    {
        _container = new UISprite(this);
        _container.hitArea = new Rectangle();
        setDisplayObject(_container);
    }
    
    override public function handleControllerChanged(c : Controller) : Void
    {
        super.handleControllerChanged(c);
        if (_gearAnimation.controller == c) 
            _gearAnimation.apply();
        if (_gearColor.controller == c) 
            _gearColor.apply();
    }
    
    override public function dispose() : Void
    {
        if (_contentItem != null) 
        {
            if (_loading == 1) 
                _contentItem.owner.removeItemCallback(_contentItem, __imageLoaded)
            else if (_loading == 2) 
                _contentItem.owner.removeItemCallback(_contentItem, __movieClipLoaded);
        }
        else 
        {
            //external
            if ((Std.is(_content, ImageExt)) && cast((_content), ImageExt).texture != null) 
                freeExternal(cast((_content), ImageExt).texture);
        }  //_content will dispose in super.dispose  
        
        
        
        super.dispose();
    }
    
    private function get_url() : String
    {
        return _url;
    }
    
    private function set_url(value : String) : String
    {
        if (_url == value) 
            return;
        
        _url = value;
        loadContent();
        return value;
    }
    
    private function get_align() : Int
    {
        return _align;
    }
    
    private function set_align(value : Int) : Int
    {
        if (_align != value) 
        {
            _align = value;
            updateLayout();
        }
        return value;
    }
    
    private function get_verticalAlign() : Int
    {
        return _verticalAlign;
    }
    
    private function set_verticalAlign(value : Int) : Int
    {
        if (_verticalAlign != value) 
        {
            _verticalAlign = value;
            updateLayout();
        }
        return value;
    }
    
    private function get_fill() : Int
    {
        return _fill;
    }
    
    private function set_fill(value : Int) : Int
    {
        if (_fill != value) 
        {
            _fill = value;
            updateLayout();
        }
        return value;
    }
    
    private function get_autoSize() : Bool
    {
        return _autoSize;
    }
    
    private function set_autoSize(value : Bool) : Bool
    {
        if (_autoSize != value) 
        {
            _autoSize = value;
            updateLayout();
        }
        return value;
    }
    
    private function get_playing() : Bool
    {
        return _playing;
    }
    
    private function set_playing(value : Bool) : Bool
    {
        if (_playing != value) 
        {
            _playing = value;
            if (Std.is(_content, MovieClip)) 
                cast((_content), MovieClip).playing = value;
            
            if (_gearAnimation.controller != null) 
                _gearAnimation.updateState();
        }
        return value;
    }
    
    private function get_frame() : Int
    {
        return _frame;
    }
    
    private function set_frame(value : Int) : Int
    {
        if (_frame != value) 
        {
            _frame = value;
            if (Std.is(_content, MovieClip)) 
                cast((_content), MovieClip).currentFrame = value;
            
            if (_gearAnimation.controller != null) 
                _gearAnimation.updateState();
        }
        return value;
    }
    
    private function get_color() : Int
    {
        return _color;
    }
    
    private function set_color(value : Int) : Int
    {
        if (_color != value) 
        {
            _color = value;
            if (_gearColor.controller != null) 
                _gearColor.updateState();
            applyColor();
        }
        return value;
    }
    
    private function applyColor() : Void
    {
        if (Std.is(_content, ImageExt)) 
            cast((_content), ImageExt).color = _color;
    }
    
    private function get_showErrorSign() : Bool
    {
        return _showErrorSign;
    }
    
    private function set_showErrorSign(value : Bool) : Bool
    {
        _showErrorSign = value;
        return value;
    }
    
    private function loadContent() : Void
    {
        clearContent();
        
        if (_url == null) 
            return;
        
        if (ToolSet.startsWith(_url, "ui://")) 
            loadFromPackage(_url)
        else 
        loadExternal();
    }
    
    private function loadFromPackage(itemURL : String) : Void
    {
        _contentItem = UIPackage.getItemByURL(itemURL);
        if (_contentItem != null) 
        {
            if (_contentItem.type == PackageItemType.Image) 
            {
                if (_contentItem.loaded) 
                    __imageLoaded(_contentItem)
                else 
                {
                    _loading = 1;
                    _contentItem.owner.addItemCallback(_contentItem, __imageLoaded);
                }
            }
            else if (_contentItem.type == PackageItemType.MovieClip) 
            {
                if (_contentItem.loaded) 
                    __movieClipLoaded(_contentItem)
                else 
                {
                    _loading = 2;
                    _contentItem.owner.addItemCallback(_contentItem, __movieClipLoaded);
                }
            }
            else 
            setErrorState();
        }
        else 
        setErrorState();
    }
    
    private function __imageLoaded(pi : PackageItem) : Void
    {
        _loading = 0;
        
        if (pi.texture == null) 
        {
            setErrorState();
        }
        else 
        {
            if (!(Std.is(_content, ImageExt))) 
            {
                if (_content != null) 
                    _content.dispose();
                _content = new ImageExt();
                _container.addChild(_content);
            }
            else 
            _container.addChild(_content);
            cast((_content), ImageExt).texture = pi.texture;
            cast((_content), ImageExt).scale9Grid = pi.scale9Grid;
            cast((_content), ImageExt).scaleByTile = pi.scaleByTile;
            cast((_content), ImageExt).smoothing = (pi.smoothing) ? TextureSmoothing.BILINEAR : TextureSmoothing.NONE;
            cast((_content), ImageExt).color = _color;
            _contentSourceWidth = pi.width;
            _contentSourceHeight = pi.height;
            updateLayout();
        }
    }
    
    private function __movieClipLoaded(pi : PackageItem) : Void
    {
        _loading = 0;
        if (!(Std.is(_content, MovieClip))) 
        {
            if (_content != null) 
                _content.dispose();
            
            _content = new MovieClip();
            _container.addChild(_content);
        }
        else 
        _container.addChild(_content);
        
        _contentSourceWidth = pi.width;
        _contentSourceHeight = pi.height;
        cast((_content), MovieClip).interval = pi.interval;
        cast((_content), MovieClip).frames = pi.frames;
        cast((_content), MovieClip).boundsRect = new Rectangle(0, 0, _contentSourceWidth, _contentSourceHeight);
        
        updateLayout();
    }
    
    private function loadExternal() : Void
    {
        if (_externalLoader == null) 
        {
            _externalLoader = new Loader();
            _externalLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, __externalLoadCompleted);
            _externalLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, __externalLoadFailed);
        }
        _externalLoader.load(new URLRequest(url));
    }
    
    private function freeExternal(texture : Texture) : Void
    {
        texture.dispose();
    }
    
    @:final private function onExternalLoadSuccess(texture : Texture) : Void
    {
        if (!(Std.is(_content, ImageExt))) 
        {
            if (_content != null) 
                _content.dispose();
            
            _content = new ImageExt();
            _container.addChild(_content);
        }
        else 
        _container.addChild(_content);
        cast((_content), ImageExt).texture = texture;
        cast((_content), ImageExt).scale9Grid = null;
        cast((_content), ImageExt).scaleByTile = false;
        cast((_content), ImageExt).color = _color;
        _contentSourceWidth = texture.width;
        _contentSourceHeight = texture.height;
        updateLayout();
    }
    
    @:final private function onExternalLoadFailed() : Void
    {
        setErrorState();
    }
    
    private function __externalLoadCompleted(evt : Event) : Void
    {
        var cc : openfl.display.DisplayObject = _externalLoader.content;
        if (Std.is(cc, Bitmap)) 
        {
            var bmd : BitmapData = cast((cc), Bitmap).bitmapData;
            var texture : Texture = Texture.fromBitmapData(bmd, false);
            bmd.dispose();
            texture.root.onRestore = loadContent;
            onExternalLoadSuccess(texture);
        }
        else 
        onExternalLoadFailed();
    }
    
    private function __externalLoadFailed(evt : Event) : Void
    {
        onExternalLoadFailed();
    }
    
    private function setErrorState() : Void
    {
        if (!_showErrorSign) 
            return;
        
        if (_errorSign == null) 
        {
            if (UIConfig.loaderErrorSign != null) 
            {
                _errorSign = _errorSignPool.getObject(UIConfig.loaderErrorSign);
            }
        }
        
        if (_errorSign != null) 
        {
            _errorSign.width = this.width;
            _errorSign.height = this.height;
            _container.addChild(_errorSign.displayObject);
        }
    }
    
    private function clearErrorState() : Void
    {
        if (_errorSign != null) 
        {
            _container.removeChild(_errorSign.displayObject);
            _errorSignPool.returnObject(_errorSign);
            _errorSign = null;
        }
    }
    
    private function updateLayout() : Void
    {
        if (_content == null) 
        {
            if (_autoSize) 
            {
                _updatingLayout = true;
                this.setSize(50, 30);
                _updatingLayout = false;
            }
            return;
        }
        
        _content.x = 0;
        _content.y = 0;
        _content.scaleX = 1;
        _content.scaleY = 1;
        _contentWidth = _contentSourceWidth;
        _contentHeight = _contentSourceHeight;
        
        if (_autoSize) 
        {
            _updatingLayout = true;
            if (_contentWidth == 0) 
                _contentWidth = 50;
            if (_contentHeight == 0) 
                _contentHeight = 30;
            this.setSize(_contentWidth, _contentHeight);
            _updatingLayout = false;
        }
        else 
        {
            var sx : Float = 1;
            var sy : Float = 1;
            if (_fill == FillType.Scale || _fill == FillType.ScaleFree) 
            {
                sx = this.width / _contentSourceWidth;
                sy = this.height / _contentSourceHeight;
                
                if (sx != 1 || sy != 1) 
                {
                    if (_fill == FillType.Scale) 
                    {
                        if (sx > sy) 
                            sx = sy
                        else 
                        sy = sx;
                    }
                    _contentWidth = _contentSourceWidth * sx;
                    _contentHeight = _contentSourceHeight * sy;
                }
            }
            
            _content.scaleX = sx;
            _content.scaleY = sy;
            
            if (_align == AlignType.Center) 
                _content.x = Int((this.width - _contentWidth) / 2)
            else if (_align == AlignType.Right) 
                _content.x = this.width - _contentWidth;
            if (_verticalAlign == VertAlignType.Middle) 
                _content.y = Int((this.height - _contentHeight) / 2)
            else if (_verticalAlign == VertAlignType.Bottom) 
                _content.y = this.height - _contentHeight;
        }
    }
    
    private function clearContent() : Void
    {
        clearErrorState();
        
        if (_content != null && _content.parent != null) 
            _container.removeChild(_content);
        
        if (_contentItem != null) 
        {
            if (_loading == 1) 
                _contentItem.owner.removeItemCallback(_contentItem, __imageLoaded)
            else if (_loading == 2) 
                _contentItem.owner.removeItemCallback(_contentItem, __movieClipLoaded);
        }
        else 
        {
            //external
            if ((Std.is(_content, ImageExt)) && cast((_content), ImageExt).texture != null) 
                freeExternal(cast((_content), ImageExt).texture);
        }
        
        if (Std.is(_content, ImageExt)) 
            cast((_content), ImageExt).texture = null
        else if (Std.is(_content, MovieClip)) 
            cast((_content), MovieClip).frames = null;
        
        _contentItem = null;
        _loading = 0;
    }
    
    override private function handleSizeChanged() : Void
    {
        if (!_updatingLayout) 
            updateLayout();
        
        _container.hitArea.setTo(0, 0, this.width, this.height);
        _container.scaleX = this.scaleX;
        _container.scaleY = this.scaleY;
    }
    
    override public function setup_beforeAdd(xml : Fast) : Void
    {
        super.setup_beforeAdd(xml);
        
        var str : String;
        str = xml.att.url;
        if (str != null) 
            _url = str;
        
        str = xml.att.align;
        if (str != null) 
            _align = AlignType.parse(str);
        
        str = xml.att.vAlign;
        if (str != null) 
            _verticalAlign = VertAlignType.parse(str);
        
        str = xml.att.fill;
        if (str != null) 
            _fill = FillType.parse(str);
        
        _autoSize = xml.att.autoSize == "true";
        
        str = xml.att.errorSign;
        if (str != null) 
            _showErrorSign = str == "true";
        
        _playing = xml.att.playing != "false";
        
        str = xml.att.color;
        if (str != null) 
            this.color = ToolSet.convertFromHtmlColor(str);
        
        if (_url != null) 
            loadContent();
    }
    
    override public function setup_afterAdd(xml : Fast) : Void
    {
        super.setup_afterAdd(xml);
        
        var cxml : Fast = xml.nodes.gearAni.get(0);
        if (cxml != null) 
            _gearAnimation.setup(cxml);
        cxml = xml.nodes.gearAni.get(0);
        cxml = xml.nodes.gearColor.get(0);
        if (cxml != null) 
            _gearColor.setup(cxml);
    }
}
