package fairygui.display;


import fairygui.utils.GTimers;

class PlayState
{
    public var currentFrame(get, set) : Int;

    public var reachEnding : Bool;  //是否已播放到结尾  
    public var frameStarting : Bool;  //是否刚开始新的一帧  
    public var reversed : Bool;  //是否已反向播放  
    public var repeatedCount : Int;  //重复次数  
    
    private var _curFrame : Int;  //当前帧  
    private var _lastTime : Float;
    private var _curFrameDelay : Int;  //当前帧延迟  
    private var _lastUpdateSeq : Int;
    
    public function new()
    {
        _lastTime = GTimers.time;
    }
    
    public function update(mc : MovieClip) : Void
    {
        if (_lastUpdateSeq == GTimers.workCount)               //PlayState may be shared, only update once per frame  
        return;
        
        _lastUpdateSeq = GTimers.workCount;
        var tt : Float = GTimers.time;
        var elapsed : Float = tt - _lastTime;
        _lastTime = tt;
        
        reachEnding = false;
        frameStarting = false;
        _curFrameDelay += elapsed;
        var realFrame : Int = (reversed) ? mc.frameCount - _curFrame - 1 : _curFrame;
        var interval : Int = mc.interval + mc.frames[realFrame].addDelay + (((realFrame == 0 && repeatedCount > 0)) ? mc.repeatDelay : 0);
        if (_curFrameDelay < interval) 
            return;
        
        _curFrameDelay = 0;
        _curFrame++;
        frameStarting = true;
        
        if (_curFrame > mc.frameCount - 1) 
        {
            _curFrame = 0;
            repeatedCount++;
            reachEnding = true;
            if (mc.swing) 
            {
                reversed = !reversed;
                _curFrame++;
            }
        }
    }
    
    private function get_currentFrame() : Int
    {
        return _curFrame;
    }
    
    private function set_currentFrame(value : Int) : Int
    {
        _curFrame = value;
        _curFrameDelay = 0;
        return value;
    }
    
    public function rewind() : Void
    {
        _curFrame = 0;
        _curFrameDelay = 0;
        reversed = false;
        reachEnding = false;
    }
    
    public function reset() : Void
    {
        _curFrame = 0;
        _curFrameDelay = 0;
        repeatedCount = 0;
        reachEnding = false;
        reversed = false;
    }
    
    public function copy(src : PlayState) : Void
    {
        _curFrame = src._curFrame;
        _curFrameDelay = src._curFrameDelay;
        repeatedCount = src.repeatedCount;
        reachEnding = src.reachEnding;
        reversed = src.reversed;
    }
}
