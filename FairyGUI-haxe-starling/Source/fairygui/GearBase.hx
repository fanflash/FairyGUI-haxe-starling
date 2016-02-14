package fairygui;

import haxe.xml.Fast;
import fairygui.GObject;
import fairygui.PageOptionSet;

import motion.easing.IEasing;
import motion.easing.Quad;
import motion.EaseLookup;

class GearBase
{
    public var controller(get, set) : Controller;
    public var tween(get, set) : Bool;
    public var tweenTime(get, set) : Float;
    public var easeType(get, set) : IEasing;
    private var connected(default, never) : Bool;

    private var _pageSet : PageOptionSet;
    private var _tween : Bool;
    private var _easeType : IEasing;
    private var _tweenTime : Float;
    
    private var _owner : GObject;
    private var _controller : Controller;
    
    public function new(owner : GObject)
    {
        _owner = owner;
        _pageSet = new PageOptionSet();
        _easeType = Quad.easeOut;
        _tweenTime = 0.3;
    }
    
    @:final private function get_controller() : Controller
    {
        return _controller;
    }
    
    private function set_controller(val : Controller) : Controller
    {
        if (val != _controller) 
        {
            _controller = val;
            _pageSet.controller = val;
            _pageSet.clear();
            if (_controller != null) 
                init();
        }
        return val;
    }
    
    @:final public function getPageSet() : PageOptionSet
    {
        return _pageSet;
    }
    
    @:final private function get_tween() : Bool
    {
        return _tween;
    }
    
    private function set_tween(val : Bool) : Bool
    {
        _tween = val;
        return val;
    }
    
    @:final private function get_tweenTime() : Float
    {
        return _tweenTime;
    }
    
    private function set_tweenTime(value : Float) : Float
    {
        _tweenTime = value;
        return value;
    }
    
    @:final private function get_easeType() : IEasing
    {
        return _easeType;
    }
    
    private function set_easeType(value : IEasing) : IEasing
    {
        _easeType = value;
        return value;
    }

    private function get_connected() : Bool
    {
        if (_controller != null && !_pageSet.empty)
            return _pageSet.containsId(_controller.selectedPageId)
        else
            return false;
    }

    @:allow(fairygui)
    private function addStatus(pageId : String, value : String) : Void
    {

    }

    @:allow(fairygui)
    private function init() : Void
    {


    }

    public function apply() : Void
    {

    }

    public function updateState() : Void
    {

    }
    
    public function setup(xml:Fast) : Void
    {
        _controller = _owner.parent.getController(xml.att.resolve("controller"));
        if (_controller == null)
            return;

        init();

        var str : String;
        str = xml.att.resolve("pages");
        var pages : Array<Dynamic>;
        if (str != null)
            pages = str.split(",")
        else
        pages = [];
        for (str in pages)
        _pageSet.addById(str);

        str = xml.att.resolve("tween");
        if (str != null)
            _tween = true;

        str = xml.att("ease");
        if (str != null)
        {
            var pos : Int = str.indexOf(".");
            if (pos != -1)
                str = str.substr(0, pos) + ".ease" + str.substr(pos + 1);
            if (str == "Linear")
                _easeType = EaseLookup.find("linear.easenone")
            else
            _easeType = EaseLookup.find(str);
        }

        str = xml.att.resolve("duration");
        if (str != null)
            _tweenTime = parseFloat(str);

        str = xml.att.resolve("values");
        var values : Array<Dynamic>;
        if (str != null)
            values = xml.att.resolve("values").split("|")
        else
        values = [];

        for (i in 0...values.length){
            str = values[i];
            if (str != "-")
                addStatus(pages[i], str);
        }
        str = xml.att.resolve("default");
        if (str != null)
            addStatus(null, str);
    }
    

}
