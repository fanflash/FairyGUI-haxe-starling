package fairygui;

import fairygui.GLoader;
import fairygui.GObject;

import openfl.geom.Point;

import fairygui.event.DragEvent;
import fairygui.event.DropEvent;

import starling.utils.Max;

class DragDropManager
{
    public static var inst(get, never) : DragDropManager;
    public var dragAgent(get, never) : GObject;
    public var dragging(get, never) : Bool;

    private var _agent : GLoader;
    private var _sourceData : Dynamic;
    
    private static var _inst : DragDropManager;
    private static function get_inst() : DragDropManager
    {
        if (_inst == null) 
            _inst = new DragDropManager();
        return _inst;
    }
    
    public function new()
    {
        _agent = new GLoader();
        _agent.draggable = true;
        _agent.touchable = false;  //important  
        _agent.setSize(100, 100);
        _agent.sortingOrder = Max.INT_MAX_VALUE;
        _agent.addEventListener(DragEvent.DRAG_END, __dragEnd);
    }
    
    private function get_dragAgent() : GObject
    {
        return _agent;
    }
    
    private function get_dragging() : Bool
    {
        return _agent.parent != null;
    }
    
    public function startDrag(source : GObject, icon : String, sourceData : Dynamic, touchPointId : Int = -1) : Void
    {
        if (_agent.parent != null) 
            return;
        
        _sourceData = sourceData;
        _agent.url = icon;
        GRoot.inst.addChild(_agent);
        var pt : Point = source.localToRoot();
        _agent.setXY(pt.x, pt.y);
        _agent.startDrag(touchPointId);
    }
    
    public function cancel() : Void
    {
        if (_agent.parent != null) 
        {
            _agent.stopDrag();
            GRoot.inst.removeChild(_agent);
            _sourceData = null;
        }
    }
    
    private function __dragEnd(evt : DragEvent) : Void
    {
        if (_agent.parent == null)               //cancelled  
        return;
        
        GRoot.inst.removeChild(_agent);
        
        var sourceData : Dynamic = _sourceData;
        _sourceData = null;
        
        var obj : GObject = GRoot.inst.getObjectUnderPoint(evt.stageX, evt.stageY);
        while (obj != null)
        {
            if (obj.hasEventListener(DropEvent.DROP)) 
            {
                var dropEvt : DropEvent = new DropEvent(DropEvent.DROP, sourceData);
                obj.requestFocus();
                obj.dispatchEvent(dropEvt);
                return;
            }
            
            obj = obj.parent;
        }
    }
}
