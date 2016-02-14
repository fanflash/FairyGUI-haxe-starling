package fairygui;

import starling.utils.StarlingUtils;
import fairygui.GObject;
import openfl.errors.Error;

import fairygui.display.Shape;
import fairygui.display.UIShape;
import fairygui.display.UISprite;
import fairygui.utils.ToolSet;

import starling.display.DisplayObject;
import starling.display.Sprite;
import starling.utils.StarlingUtils;

import haxe.xml.Fast;

class GGraph extends GObject
{
    private var shape(get, never) : Shape;

    private var _shape : UIShape;
    
    public function new()
    {
        super();
    }
    
    public function drawRect(lineSize : Int, lineColor : Int, lineAlpha : Float,
            fillColor : Int, fillAlpha : Float, corner : Array<Dynamic> = null) : Void
    {
        shape.drawRect(lineSize, lineColor, lineAlpha, fillColor, fillAlpha, corner);
    }
    
    public function drawEllipse(lineSize : Int, lineColor : Int, lineAlpha : Float,
            fillColor : Int, fillAlpha : Float) : Void
    {
        shape.drawEllipse(lineSize, lineColor, lineAlpha, fillColor, fillAlpha);
    }
    
    public function clearGraphics() : Void
    {
        if (_shape != null) 
            _shape.clear();
    }
    
    public function replaceMe(target : GObject) : Void
    {
        if (_parent == null) 
            throw new Error("parent not set");
        
        target.name = this.name;
        target.alpha = this.alpha;
        target.rotation = this.rotation;
        target.visible = this.visible;
        target.touchable = this.touchable;
        target.grayed = this.grayed;
        target.setXY(this.x, this.y);
        target.setSize(this.width, this.height);
        
        var index : Int = _parent.getChildIndex(this);
        _parent.addChildAt(target, index);
        target.relations.copyFrom(this.relations);
        
        _parent.removeChild(this, true);
    }
    
    public function addBeforeMe(target : GObject) : Void
    {
        if (_parent == null) 
            throw new Error("parent not set");
        
        var index : Int = _parent.getChildIndex(this);
        _parent.addChildAt(target, index);
    }
    
    public function addAfterMe(target : GObject) : Void
    {
        if (_parent == null) 
            throw new Error("parent not set");
        
        var index : Int = _parent.getChildIndex(this);
        index++;
        _parent.addChildAt(target, index);
    }
    
    public function setNativeObject(obj : DisplayObject) : Void
    {
        if (displayObject == _shape) 
        {
            _shape.dispose();
            _shape = null;
            
            setDisplayObject(new UISprite(this));
            if (_parent != null) 
                _parent.childStateChanged(this);
            handleXYChanged();
            displayObject.alpha = this.alpha;
            displayObject.rotation = StarlingUtils.deg2rad(this.normalizeRotation);
            displayObject.visible = this.visible;
            cast((displayObject), Sprite).touchable = this.touchable;
        }
        else 
        cast((displayObject), Sprite).removeChildren();
        
        if (obj != null) 
            cast((displayObject), Sprite).addChild(obj);
    }
    
    private function get_shape() : Shape
    {
        if (_shape != null) 
            return _shape;
        
        if (displayObject != null) 
            displayObject.dispose();
        
        _shape = new UIShape(this);
        setDisplayObject(_shape);
        if (parent != null) 
            parent.childStateChanged(this);
        handleXYChanged();
        _shape.alpha = this.alpha;
        _shape.rotation = this.normalizeRotation;
        _shape.visible = this.visible;
        _shape.setSize(this.width * this.scaleX, this.height * this.scaleY);
        
        return _shape;
    }
    
    override private function handleSizeChanged() : Void
    {
        if (_shape != null) 
        {
            _shape.setSize(this.width * this.scaleX, this.height * this.scaleY);
        }
    }
    
    override public function setup_beforeAdd(xml : Fast) : Void
    {
        var type : String = xml.att.type;
        if (type != null && type != "empty") 
            this.shape;  //create shape now  ;
        
        super.setup_beforeAdd(xml);
        
        if (_shape != null) 
        {
            var str : String;
            
            var lineSize : Int = 1;
            str = xml.att.lineSize;
            if (str != null) 
                lineSize = Std.parseInt(str);
            
            var lineColor : Int = 0;
            var lineAlpha : Float = 1;
            str = xml.att.lineColor;
            if (str != null) 
            {
                var c : Int = ToolSet.convertFromHtmlColor(str, true);
                lineColor = c & 0xFFFFFF;
                lineAlpha = ((c >> 24) & 0xFF) / 0xFF;
            }
            
            var fillColor : Int = 0xFFFFFF;
            var fillAlpha : Float = 1;
            str = xml.att.fillColor;
            if (str != null) 
            {
                c = ToolSet.convertFromHtmlColor(str, true);
                fillColor = c & 0xFFFFFF;
                fillAlpha = ((c >> 24) & 0xFF) / 0xFF;
            }
            
            var corner : Array<Dynamic>;
            str = xml.att.corner;
            if (str != null) 
                corner = str.split(",");
            
            if (type == "rect") 
                drawRect(lineSize, lineColor, lineAlpha, fillColor, fillAlpha, corner)
            else 
            drawEllipse(lineSize, lineColor, lineAlpha, fillColor, fillAlpha);
            
            _shape.setSize(this.width * this.scaleX, this.height * this.scaleY);
        }
    }
}
