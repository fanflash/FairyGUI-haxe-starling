package fairygui.display;


import fairygui.GObject;

class UIShape extends Shape implements UIDisplayObject
{
    public var owner(default, never) : GObject;

    private var _owner : GObject;
    
    public function new(owner : GObject)
    {
        super();
        _owner = owner;
    }
    
    private function get_owner() : GObject
    {
        return _owner;
    }
}

