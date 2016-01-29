package fairygui.event;


import starling.events.Event;

class StateChangeEvent extends Event
{
    public static inline var CHANGED : String = "___stateChanged";
    
    public function new(type : String)
    {
        super(type, false);
    }
}

