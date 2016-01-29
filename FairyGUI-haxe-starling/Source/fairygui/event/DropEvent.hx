package fairygui.event;


import starling.events.Event;

class DropEvent extends Event
{
    public static inline var DROP : String = "__drop";
    
    public var source : Dynamic;
    
    public function new(type : String, source : Dynamic)
    {
        super(type, false, false);
        this.source = source;
    }
}
