package fairygui.event;


import starling.events.Event;

class TextEvent extends Event
{
    public var text(get, never) : String;

    public var _text : String;
    
    public static inline var LINK : String = "__textLink";
    
    public function new(type : String, bubbles : Bool, text : String)
    {
        super(type, bubbles);
        
        _text = text;
    }
    
    private function get_text() : String
    {
        return _text;
    }
}
