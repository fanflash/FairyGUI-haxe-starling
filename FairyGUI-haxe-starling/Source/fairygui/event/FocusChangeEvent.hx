package fairygui.event;


import fairygui.GObject;

import starling.events.Event;

class FocusChangeEvent extends Event
{
    public var oldFocusedObject(get, never) : GObject;
    public var newFocusedObject(get, never) : GObject;

    public static inline var CHANGED : String = "___focusChanged";
    
    private var _oldFocusedObject : GObject;
    private var _newFocusedObject : GObject;
    
    public function new(type : String, oldObject : GObject, newObject : GObject)
    {
        super(type, false);
        _oldFocusedObject = oldObject;
        _newFocusedObject = newObject;
    }
    
    @:final private function get_oldFocusedObject() : GObject
    {
        return _oldFocusedObject;
    }
    
    @:final private function get_newFocusedObject() : GObject
    {
        return _newFocusedObject;
    }
}


