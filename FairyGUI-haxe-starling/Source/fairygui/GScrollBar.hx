package fairygui;

import fairygui.GObject;
import fairygui.ScrollPane;

import openfl.geom.Point;

import fairygui.event.GTouchEvent;

import haxe.xml.Fast;

class GScrollBar extends GComponent
{
    public var displayPerc(never, set) : Float;
    public var scrollPerc(never, set) : Float;
    public var minSize(get, never) : Int;

    private var _grip : GObject;
    private var _arrowButton1 : GObject;
    private var _arrowButton2 : GObject;
    private var _bar : GObject;
    private var _target : ScrollPane;
    
    private var _vertical : Bool;
    private var _scrollPerc : Float;
    
    private var _dragOffset : Point;
    
    public function new()
    {
        super();
        _dragOffset = new Point();
        _scrollPerc = 0;
    }
    
    public function setScrollPane(target : ScrollPane, vertical : Bool) : Void
    {
        _target = target;
        _vertical = vertical;
    }
    
    private function set_displayPerc(val : Float) : Float
    {
        if (_vertical) 
        {
            _grip.height = val * _bar.height;
            _grip.y = _bar.y + (_bar.height - _grip.height) * _scrollPerc;
        }
        else 
        {
            _grip.width = val * _bar.width;
            _grip.x = _bar.x + (_bar.width - _grip.width) * _scrollPerc;
        }
        return val;
    }
    
    private function set_scrollPerc(val : Float) : Float
    {
        _scrollPerc = val;
        if (_vertical) 
            _grip.y = _bar.y + (_bar.height - _grip.height) * _scrollPerc
        else 
        _grip.x = _bar.x + (_bar.width - _grip.width) * _scrollPerc;
        return val;
    }
    
    private function get_minSize() : Int
    {
        if (_vertical) 
            return (_arrowButton1 != (null) ? _arrowButton1.height : 0) + (_arrowButton2 != (null) ? _arrowButton2.height : 0)
        else 
        return (_arrowButton1 != (null) ? _arrowButton1.width : 0) + (_arrowButton2 != (null) ? _arrowButton2.width : 0);
    }
    
    override private function constructFromXML(xml : Fast) : Void
    {
        super.constructFromXML(xml);
        
        _grip = getChild("grip");
        if (_grip == null) 
        {
            trace("需要定义grip");
            return;
        }
        
        _bar = getChild("bar");
        if (_bar == null) 
        {
            trace("需要定义bar");
            return;
        }
        
        _arrowButton1 = getChild("arrow1");
        _arrowButton2 = getChild("arrow2");
        
        _grip.addEventListener(GTouchEvent.BEGIN, __gripMouseDown);
        _grip.addEventListener(GTouchEvent.DRAG, __gripDragging);
        
        if (_arrowButton1 != null) 
            _arrowButton1.addEventListener(GTouchEvent.BEGIN, __arrowButton1Click);
        if (_arrowButton2 != null) 
            _arrowButton2.addEventListener(GTouchEvent.BEGIN, __arrowButton2Click);
        
        addEventListener(GTouchEvent.BEGIN, __barMouseDown);
    }
    
    private function __gripMouseDown(evt : GTouchEvent) : Void
    {
        if (_bar == null) 
            return;
        
        evt.stopPropagation();
        
        this.globalToLocal(evt.stageX, evt.stageY, _dragOffset);
        _dragOffset.x -= _grip.x;
        _dragOffset.y -= _grip.y;
    }
    
    private var sHelperPoint : Point = new Point();
    private function __gripDragging(evt : GTouchEvent) : Void
    {
        var pt : Point = this.globalToLocal(evt.stageX, evt.stageY, sHelperPoint);
        var diff : Float
        if (_vertical) 
        {
            var curY : Float = pt.y - _dragOffset.y;
            diff = _bar.height - _grip.height;
            if (diff == 0) 
                _target.setPercY(0, false)
            else 
            _target.setPercY((curY - _bar.y) / diff, false);
        }
        else 
        {
            var curX : Float = pt.x - _dragOffset.x;
            diff = _bar.width - _grip.width;
            if (diff == 0) 
                _target.setPercX(0, false)
            else 
            _target.setPercX((curX - _bar.x) / diff, false);
        }
    }
    
    private function __arrowButton1Click(evt : GTouchEvent) : Void
    {
        evt.stopPropagation();
        
        if (_vertical) 
            _target.scrollUp()
        else 
        _target.scrollLeft();
    }
    
    private function __arrowButton2Click(evt : GTouchEvent) : Void
    {
        evt.stopPropagation();
        
        if (_vertical) 
            _target.scrollDown()
        else 
        _target.scrollRight();
    }
    
    private function __barMouseDown(evt : GTouchEvent) : Void
    {
        var pt : Point = _grip.globalToLocal(evt.stageX, evt.stageY, sHelperPoint);
        if (_vertical) 
        {
            if (pt.y < 0) 
                _target.scrollUp(4)
            else 
            _target.scrollDown(4);
        }
        else 
        {
            if (pt.x < 0) 
                _target.scrollLeft(4)
            else 
            _target.scrollRight(4);
        }
    }
}
