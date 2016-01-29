package fairygui.event;


import starling.events.Event;

class DragEvent extends Event
{
    public var stageX : Float;
    public var stageY : Float;
    public var touchPointID : Int;
    
    private var _prevented : Bool;
    
    public static inline var DRAG_START : String = "startDrag";
    public static inline var DRAG_END : String = "endDrag";
    
    public function new(type : String, stageX : Float = 0, stageY : Float = 0, touchPointID : Int = -1)
    {
        super(type, false);
        
        this.stageX = stageX;
        this.stageY = stageY;
        this.touchPointID = touchPointID;
    }
    
    public function preventDefault() : Void
    {
        _prevented = true;
    }
    
    public function isDefaultPrevented() : Bool
    {
        return _prevented;
    }
}
