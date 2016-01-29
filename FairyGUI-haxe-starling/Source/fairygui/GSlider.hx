package fairygui;

import fairygui.GObject;
import fairygui.GTextField;

import openfl.geom.Point;

import fairygui.event.GTouchEvent;
import fairygui.event.StateChangeEvent;

@:meta(Event(name="stateChanged",type="fairygui.event.StateChangeEvent"))

class GSlider extends GComponent
{
    public var titleType(get, set) : Int;
    public var max(get, set) : Int;
    public var value(get, set) : Int;

    private var _max : Int;
    private var _value : Int;
    private var _titleType : Int;
    
    private var _titleObject : GTextField;
    private var _aniObject : GObject;
    private var _barObjectH : GObject;
    private var _barObjectV : GObject;
    private var _barMaxWidth : Int;
    private var _barMaxHeight : Int;
    private var _barMaxWidthDelta : Int;
    private var _barMaxHeightDelta : Int;
    private var _gripObject : GObject;
    private var _clickPos : Point;
    private var _clickPercent : Float;
    
    public function new()
    {
        super();
        
        _titleType = ProgressTitleType.Percent;
        _value = 50;
        _max = 100;
        _clickPos = new Point();
    }
    
    @:final private function get_titleType() : Int
    {
        return _titleType;
    }
    
    @:final private function set_titleType(value : Int) : Int
    {
        _titleType = value;
        return value;
    }
    
    @:final private function get_max() : Int
    {
        return _max;
    }
    
    @:final private function set_max(value : Int) : Int
    {
        if (_max != value) 
        {
            _max = value;
            update();
        }
        return value;
    }
    
    @:final private function get_value() : Int
    {
        return _value;
    }
    
    @:final private function set_value(value : Int) : Int
    {
        if (_value != value) 
        {
            _value = value;
            update();
        }
        return value;
    }
    
    public function update() : Void
    {
        var percent : Float = Math.min(_value / _max, 1);
        updateWidthPercent(percent);
    }
    
    private function updateWidthPercent(percent : Float) : Void
    {
        if (_titleObject != null) 
        {
            switch (_titleType)
            {
                case ProgressTitleType.Percent:
                    _titleObject.text = Math.round(percent * 100) + "%";
                
                case ProgressTitleType.ValueAndMax:
                    _titleObject.text = _value + "/" + _max;
                
                case ProgressTitleType.Value:
                    _titleObject.text = "" + _value;
                
                case ProgressTitleType.Max:
                    _titleObject.text = "" + _max;
            }
        }
        
        if (_barObjectH != null) 
            _barObjectH.width = (this.width - _barMaxWidthDelta) * percent;
        if (_barObjectV != null) 
            _barObjectV.height = (this.height - _barMaxHeightDelta) * percent;
        
        if (Std.is(_aniObject, GMovieClip)) 
            cast((_aniObject), GMovieClip).frame = Math.round(percent * 100)
        else if (Std.is(_aniObject, GSwfObject)) 
            cast((_aniObject), GSwfObject).frame = Math.round(percent * 100);
    }
    
    override private function constructFromXML(xml : FastXML) : Void
    {
        super.constructFromXML(xml);
        
        xml = xml.nodes.Slider.get(0);
        
        var str : String;
        str = xml.att.titleType;
        if (str != null) 
            _titleType = ProgressTitleType.parse(str);
        
        _titleObject = try cast(getChild("title"), GTextField) catch(e:Dynamic) null;
        _barObjectH = getChild("bar");
        _barObjectV = getChild("bar_v");
        _aniObject = getChild("ani");
        _gripObject = getChild("grip");
        
        if (_barObjectH != null) 
        {
            _barMaxWidth = _barObjectH.width;
            _barMaxWidthDelta = this.width - _barMaxWidth;
        }
        if (_barObjectV != null) 
        {
            _barMaxHeight = _barObjectV.height;
            _barMaxHeightDelta = this.height - _barMaxHeight;
        }
        if (_gripObject != null) 
        {
            _gripObject.addEventListener(GTouchEvent.BEGIN, __gripMouseDown);
            _gripObject.addEventListener(GTouchEvent.DRAG, __gripMouseMove);
            _gripObject.addEventListener(GTouchEvent.END, __gripMouseUp);
        }
    }
    
    override private function handleSizeChanged() : Void
    {
        super.handleSizeChanged();
        
        if (_barObjectH != null) 
            _barMaxWidth = this.width - _barMaxWidthDelta;
        if (_barObjectV != null) 
            _barMaxHeight = this.height - _barMaxHeightDelta;
        if (!this._underConstruct) 
            update();
    }
    
    override public function setup_afterAdd(xml : FastXML) : Void
    {
        super.setup_afterAdd(xml);
        
        xml = xml.nodes.Slider.get(0);
        if (xml != null) 
        {
            _value = parseInt(xml.att.value);
            _max = parseInt(xml.att.max);
        }
        
        update();
    }
    
    private function __gripMouseDown(evt : GTouchEvent) : Void
    {
        this.globalToLocal(evt.stageX, evt.stageY, _clickPos);
        _clickPercent = _value / _max;
    }
    
    private var sHelperPoint : Point = new Point();
    private function __gripMouseMove(evt : GTouchEvent) : Void
    {
        var pt : Point = this.globalToLocal(evt.stageX, evt.stageY, sHelperPoint);
        var deltaX : Int = pt.x - _clickPos.x;
        var deltaY : Int = pt.y - _clickPos.y;
        
        var percent : Float;
        if (_barObjectH != null) 
            percent = _clickPercent + deltaX / _barMaxWidth
        else 
        percent = _clickPercent + deltaY / _barMaxHeight;
        if (percent > 1) 
            percent = 1
        else if (percent < 0) 
            percent = 0;
        var newValue : Int = Math.round(_max * percent);
        if (newValue != _value) 
        {
            _value = newValue;
            dispatchEvent(new StateChangeEvent(StateChangeEvent.CHANGED));
        }
        updateWidthPercent(percent);
    }
    
    private function __gripMouseUp(evt : GTouchEvent) : Void
    {
        var percent : Float = _value / _max;
        updateWidthPercent(percent);
    }
}


