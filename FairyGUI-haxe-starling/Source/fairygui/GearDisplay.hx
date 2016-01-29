package fairygui;

import fairygui.GObject;


class GearDisplay extends GearBase
{
    public function new(owner : GObject)
    {
        super(owner);
    }
    
    override private function get_connected() : Bool
    {
        if (_controller != null && !_pageSet.empty) 
            return _pageSet.containsId(_controller.selectedPageId)
        else 
        return true;
    }
    
    override public function apply() : Void
    {
        if (connected) 
            _owner.internalVisible++
        else 
        _owner.internalVisible = 0;
    }
}
