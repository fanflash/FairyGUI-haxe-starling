package fairygui.event;


import starling.display.DisplayObject;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;

class GTouchEvent extends Event
{
    public var realTarget(get, never) : DisplayObject;
    public var clickCount(get, never) : Int;
    public var stageX(get, never) : Float;
    public var stageY(get, never) : Float;
    public var shiftKey(get, never) : Bool;
    public var ctrlKey(get, never) : Bool;
    public var touchPointID(get, never) : Int;
    public var isPropagationStop(get, never) : Bool;

    private var _stopPropagation : Bool;
    
    private var _realTarget : DisplayObject;
    private var _clickCount : Int;
    private var _stageX : Float;
    private var _stageY : Float;
    private var _shiftKey : Bool;
    private var _ctrlKey : Bool;
    private var _touchPointID : Int;
    
    public static inline var BEGIN : String = "beginGTouch";
    public static inline var DRAG : String = "dragGTouch";
    public static inline var END : String = "endGTouch";
    public static inline var CLICK : String = "clickGTouch";
    public static inline var ROLL_OVER : String = "rollOverGTouch";
    public static inline var ROLL_OUT : String = "rollOutGTouch";
    
    public function new(type : String)
    {
        super(type, false);
    }
    
    public function copyFrom(evt : TouchEvent, touch : Touch, clickCount : Int = 1) : Void
    {
        if (touch != null) 
        {
            _stageX = touch.globalX;
            _stageY = touch.globalY;
            _touchPointID = touch.id;
        }
        _shiftKey = evt.shiftKey;
        _ctrlKey = evt.ctrlKey;
        
        _realTarget = try cast(evt.target, DisplayObject) catch(e:Dynamic) null;
        _clickCount = clickCount;
        _stopPropagation = false;
    }
    
    @:final private function get_realTarget() : DisplayObject
    {
        return _realTarget;
    }
    @:final private function get_clickCount() : Int
    {
        return _clickCount;
    }
    @:final private function get_stageX() : Float
    {
        return _stageX;
    }
    @:final private function get_stageY() : Float
    {
        return _stageY;
    }
    @:final private function get_shiftKey() : Bool
    {
        return _shiftKey;
    }
    @:final private function get_ctrlKey() : Bool
    {
        return _ctrlKey;
    }
    @:final private function get_touchPointID() : Int
    {
        return _touchPointID;
    }
    override public function stopPropagation() : Void
    {
        _stopPropagation = true;
    }
    
    @:final private function get_isPropagationStop() : Bool
    {
        return _stopPropagation;
    }
}
