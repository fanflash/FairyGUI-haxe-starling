package fairygui;

import fairygui.GObject;

import fairygui.utils.ToolSet;

class GearColor extends GearBase
{
    private var _storage : Dynamic;
    private var _default : Int;
    
    public function new(owner : GObject)
    {
        super(owner);
    }
    
    override private function init() : Void
    {
        _default = cast((_owner), IColorGear).color;
        _storage = { };
    }
    
    override private function addStatus(pageId : String, value : String) : Void
    {
        var col : Int = ToolSet.convertFromHtmlColor(value);
        if (pageId == null) 
            _default = col
        else 
        Reflect.setField(_storage, pageId, col);
    }
    
    override public function apply() : Void
    {
        _owner._gearLocked = true;
        
        if (connected) 
        {
            var data : Dynamic = _storage[_controller.selectedPageId];
            if (data != null) 
                cast((_owner), IColorGear).color = Int(data)
            else 
            cast((_owner), IColorGear).color = Int(_default);
        }
        else 
        cast((_owner), IColorGear).color = _default;
        
        _owner._gearLocked = false;
    }
    
    override public function updateState() : Void
    {
        if (_owner._gearLocked) 
            return;
        
        if (connected) 
            _storage[_controller.selectedPageId] = cast((_owner), IColorGear).color
        else 
        _default = cast((_owner), IColorGear).color;
    }
}
