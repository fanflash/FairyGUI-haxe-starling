package fairygui;

import fairygui.GObject;
import fairygui.GearBase;
import fairygui.IAnimationGear;

class GearAnimation extends GearBase
{
    private var _storage : Dynamic;
    private var _default : GearAnimationValue;
    
    public function new(owner : GObject)
    {
        super(owner);
    }
    
    override private function init() : Void
    {
        _default = new GearAnimationValue(cast((_owner), IAnimationGear).playing, cast((_owner), IAnimationGear).frame);
        _storage = { };
    }
    
    override private function addStatus(pageId : String, value : String) : Void
    {
        var gv : GearAnimationValue;
        if (pageId == null) 
            gv = _default
        else 
        {
            gv = new GearAnimationValue();
            Reflect.setField(_storage, pageId, gv);
        }
        var arr : Array<Dynamic> = value.split(",");
        gv.frame = Int(arr[0]);
        gv.playing = arr[1] == "p";
    }
    
    override public function apply() : Void
    {
        _owner._gearLocked = true;
        
        var gv : GearAnimationValue;
        if (connected) 
        {
            gv = _storage[_controller.selectedPageId];
            if (gv == null) 
                gv = _default;
        }
        else 
        gv = _default;
        
        cast((_owner), IAnimationGear).playing = gv.playing;
        cast((_owner), IAnimationGear).frame = gv.frame;
        
        _owner._gearLocked = false;
    }
    
    override public function updateState() : Void
    {
        if (_owner._gearLocked) 
            return;
        
        var mc : IAnimationGear = cast((_owner), IAnimationGear);
        var gv : GearAnimationValue;
        if (connected) 
        {
            gv = _storage[_controller.selectedPageId];
            if (gv == null) 
            {
                gv = new GearAnimationValue();
                _storage[_controller.selectedPageId] = gv;
            }
        }
        else 
        gv = _default;
        
        gv.playing = mc.playing;
        gv.frame = mc.frame;
    }
}


class GearAnimationValue
{
    public var playing : Bool;
    public var frame : Int;
    
    public function new(playing : Bool = true, frame : Int = 0)
    {
        this.playing = playing;
        this.frame = frame;
    }
}
