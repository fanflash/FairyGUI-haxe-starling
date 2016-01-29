package fairygui.display;


import openfl.geom.Point;
import openfl.geom.Rectangle;

import fairygui.GObject;

import starling.core.RenderSupport;
import starling.display.DisplayObject;
import starling.display.Sprite;

class UISprite extends Sprite implements UIDisplayObject
{
    public var owner(default, never) : GObject;
    public var hitArea(get, set) : Rectangle;

    private var _owner : GObject;
    private var _hitArea : Rectangle;
    private var _skipRendering : Bool;
    
    public var renderCallback : Dynamic;
    
    public function new(owner : GObject)
    {
        super();
        _owner = owner;
    }
    
    private function get_owner() : GObject
    {
        return _owner;
    }
    
    private function get_hitArea() : Rectangle
    {
        return _hitArea;
    }
    
    private function set_hitArea(value : Rectangle) : Rectangle
    {
        if (_hitArea != null && value != null)             _hitArea.copyFrom(value)
        else _hitArea = ((value != null) ? value.clone() : null);
        return value;
    }
    
    override public function dispose() : Void
    {
        renderCallback = null;
        super.dispose();
    }
    
    override public function hitTest(localPoint : Point, forTouch : Bool = false) : DisplayObject
    {
        if (_skipRendering) 
            return null;
        
        var localX : Float = localPoint.x;
        var localY : Float = localPoint.y;
        
        var ret : DisplayObject = super.hitTest(localPoint, forTouch);
        if (ret == null && (this.touchable || !forTouch) && _hitArea != null && _hitArea.contains(localX, localY)) 
            ret = this;
        
        return ret;
    }
    
    override public function render(support : RenderSupport, parentAlpha : Float) : Void
    {
        _skipRendering = _owner.parent != null && !_owner.parent.isChildInView(_owner);
        if (_skipRendering) 
            return;
        
        if (renderCallback != null) 
            renderCallback();
        
        super.render(support, parentAlpha);
    }
}

