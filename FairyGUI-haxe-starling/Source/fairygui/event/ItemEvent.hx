package fairygui.event;


import fairygui.GObject;

import starling.events.Event;

class ItemEvent extends Event
{
    public var itemObject : GObject;
    public var stageX : Float;
    public var stageY : Float;
    public var clickCount : Int;
    public var rightButton : Bool;
    
    public static inline var CLICK : String = "___itemClick";
    
    public function new(type : String, itemObject : GObject = null,
            stageX : Float = 0, stageY : Float = 0, clickCount : Int = 1, rightButton : Bool = false)
    {
        super(type, false);
        this.itemObject = itemObject;
        this.stageX = stageX;
        this.stageY = stageY;
        this.clickCount = clickCount;
        this.rightButton = rightButton;
    }
}

