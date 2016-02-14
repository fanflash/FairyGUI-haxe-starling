package fairygui;

import fairygui.GObject;
import fairygui.GTextField;

import haxe.xml.Fast;

class GProgressBar extends GComponent
{
    public var titleType(get, set) : Int;
    public var max(get, set) : Int;
    public var value(get, set) : Int;

    private var _max : Int;
    private var _value : Int;
    private var _titleType : Int;
    private var _reverse : Bool;
    
    private var _titleObject : GTextField;
    private var _aniObject : GObject;
    private var _barObjectH : GObject;
    private var _barObjectV : GObject;
    private var _barMaxWidth : Int;
    private var _barMaxHeight : Int;
    private var _barMaxWidthDelta : Int;
    private var _barMaxHeightDelta : Int;
    private var _barStartX : Int;
    private var _barStartY : Int;
    
    public function new()
    {
        super();
        
        _titleType = ProgressTitleType.Percent;
        _value = 50;
        _max = 100;
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
        
        var fullWidth : Int = this.width - this._barMaxWidthDelta;
        var fullHeight : Int = this.height - this._barMaxHeightDelta;
        if (!_reverse) 
        {
            if (_barObjectH != null) 
                _barObjectH.width = fullWidth * percent;
            if (_barObjectV != null) 
                _barObjectV.height = fullHeight * percent;
        }
        else 
        {
            if (_barObjectH != null) 
            {
                _barObjectH.width = fullWidth * percent;
                _barObjectH.x = _barStartX + (fullWidth - _barObjectH.width);
            }
            if (_barObjectV != null) 
            {
                _barObjectV.height = fullHeight * percent;
                _barObjectV.y = _barStartY + (fullHeight - _barObjectV.height);
            }
        }
        if (Std.is(_aniObject, GMovieClip)) 
            cast((_aniObject), GMovieClip).frame = Math.round(percent * 100)
        else if (Std.is(_aniObject, GSwfObject)) 
            cast((_aniObject), GSwfObject).frame = Math.round(percent * 100);
    }
    
    override private function constructFromXML(xml : Fast) : Void
    {
        super.constructFromXML(xml);
        
        xml = xml.nodes.ProgressBar.get(0);
        
        var str : String;
        str = xml.att.titleType;
        if (str != null) 
            _titleType = ProgressTitleType.parse(str);
        
        _reverse = xml.att.reverse == "true";
        
        _titleObject = try cast(getChild("title"), GTextField) catch(e:Dynamic) null;
        _barObjectH = getChild("bar");
        _barObjectV = getChild("bar_v");
        _aniObject = getChild("ani");
        
        if (_barObjectH != null) 
        {
            _barMaxWidth = _barObjectH.width;
            _barMaxWidthDelta = this.width - _barMaxWidth;
            _barStartX = _barObjectH.x;
        }
        if (_barObjectV != null) 
        {
            _barMaxHeight = _barObjectV.height;
            _barMaxHeightDelta = this.height - _barMaxHeight;
            _barStartY = _barObjectV.y;
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
    
    override public function setup_afterAdd(xml : Fast) : Void
    {
        super.setup_afterAdd(xml);
        
        xml = xml.nodes.ProgressBar.get(0);
        if (xml != null) 
        {
            _value = Std.parseInt(xml.att.value);
            _max = Std.parseInt(xml.att.max);
        }
        update();
    }
}
