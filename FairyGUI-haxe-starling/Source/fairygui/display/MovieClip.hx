package fairygui.display;

import fairygui.display.PlayState;
import fairygui.display.QuadExt;

import openfl.geom.Rectangle;

import fairygui.utils.GTimers;

import starling.core.RenderSupport;
import starling.display.QuadBatch;
import starling.textures.Texture;
import starling.textures.TextureSmoothing;

class MovieClip extends FixedSizeObject
{
    public var playState(get, set) : PlayState;
    public var smoothing(get, set) : String;
    public var frames(get, set) : Array<Frame>;
    public var frameCount(get, never) : Int;
    public var boundsRect(get, set) : Rectangle;
    public var currentFrame(get, set) : Int;
    public var playing(get, set) : Bool;

    public var interval : Int;
    public var swing : Bool;
    public var repeatDelay : Int;
    
    private var _texture : Texture;
    private var _batch : QuadBatch;
    private var _frameRect : Rectangle;
    private var _smoothing : String;
    
    private var _playing : Bool;
    private var _playState : PlayState;
    private var _frameCount : Int;
    private var _frames : Array<Frame>;
    private var _currentFrame : Int;
    private var _boundsRect : Rectangle;
    private var _start : Int;
    private var _end : Int;
    private var _times : Int;
    private var _endAt : Int;
    private var _status : Int;  //0-none, 1-next loop, 2-ending, 3-ended  
    private var _callback : Dynamic;
    
    public function new()
    {
        super();
        //MovieClip is by default touchable
        this.touchable = false;
        
        _playState = new PlayState();
        _playing = true;
        _smoothing = TextureSmoothing.BILINEAR;
        
        _batch = new QuadBatch();
        _batch.capacity = 1;
    }
    
    private function get_playState() : PlayState
    {
        return _playState;
    }
    
    private function set_playState(value : PlayState) : PlayState
    {
        _playState = value;
        return value;
    }
    
    override public function dispose() : Void
    {
        _batch.dispose();
        
        super.dispose();
    }
    
    private function get_smoothing() : String
    {
        return _smoothing;
    }
    
    private function set_smoothing(value : String) : String
    {
        if (_smoothing != value) 
        {
            _smoothing = value;
            _needRebuild = true;
        }
        return value;
    }
    
    override private function set_blendMode(value : String) : String
    {
        super.blendMode = value;
        _batch.blendMode = value;
        return value;
    }
    
    private function get_frames() : Array<Frame>
    {
        return _frames;
    }
    
    private function set_frames(value : Array<Frame>) : Array<Frame>
    {
        _frames = value;
        if (_frames != null) 
            _frameCount = _frames.length
        else 
        _frameCount = 0;
        _currentFrame = -1;
        setPlaySettings();
        return value;
    }
    
    private function get_frameCount() : Int
    {
        return _frameCount;
    }
    
    private function get_boundsRect() : Rectangle
    {
        return _boundsRect;
    }
    
    private function set_boundsRect(value : Rectangle) : Rectangle
    {
        _boundsRect = value;
        this.setSize(_boundsRect.right, _boundsRect.bottom);
        return value;
    }
    
    private function get_currentFrame() : Int
    {
        return _currentFrame;
    }
    
    private function set_currentFrame(value : Int) : Int
    {
        if (_currentFrame != value) 
        {
            _currentFrame = value;
            _playState.currentFrame = value;
            setFrame(_currentFrame < (frameCount != 0) ? _frames[_currentFrame] : null);
        }
        return value;
    }
    
    private function get_playing() : Bool
    {
        return _playing;
    }
    
    private function set_playing(value : Bool) : Bool
    {
        _playing = value;
        
        if (playing && frameCount != 0 && _status != 3) 
            GTimers.inst.callBy24Fps(update)
        else 
        GTimers.inst.remove(update);
        return value;
    }
    
    //从start帧开始，播放到end帧（-1表示结尾），重复times次（0表示无限循环），循环结束后，停止在endAt帧（-1表示参数end）
    public function setPlaySettings(start : Int = 0, end : Int = -1,
            times : Int = 0, endAt : Int = -1,
            endCallback : Dynamic = null) : Void
    {
        _start = start;
        _end = end;
        if (_end == -1) 
            _end = frameCount - 1;
        _times = times;
        _endAt = endAt;
        if (_endAt == -1) 
            _endAt = _end;
        _status = 0;
        _callback = endCallback;
        
        this.currentFrame = start;
        if (playing && frameCount != 0) 
            GTimers.inst.callBy24Fps(update)
        else 
        GTimers.inst.remove(update);
    }
    
    private function update() : Void
    {
        if (playing && frameCount != 0 && _status != 3) 
        {
            _playState.update(this);
            if (_currentFrame != _playState.currentFrame) 
            {
                if (_status == 1) 
                {
                    _currentFrame = _start;
                    _playState.currentFrame = _currentFrame;
                    _status = 0;
                }
                //draw
                else if (_status == 2) 
                {
                    _currentFrame = _endAt;
                    _playState.currentFrame = _currentFrame;
                    _status = 3;
                    
                    //play end
                    GTimers.inst.remove(update);
                    if (_callback != null) 
                    {
                        var f : Dynamic = _callback;
                        _callback = null;
                        if (f.length == 1) 
                            f(this)
                        else 
                        f();
                    }
                }
                else 
                {
                    _currentFrame = _playState.currentFrame;
                    if (_currentFrame == _end) 
                    {
                        if (_times > 0) 
                        {
                            _times--;
                            if (_times == 0) 
                                _status = 2
                            else 
                            _status = 1;
                        }
                    }
                }
                
                
                
                setFrame(_frames[_currentFrame]);
            }
        }
        else 
        setFrame(null);
    }
    
    private function setFrame(frame : Frame) : Void
    {
        if (frame == null) 
        {
            if (_texture != null) 
            {
                _texture = null;
                _needRebuild = true;
            }
        }
        else if (_texture != frame.texture) 
        {
            _texture = frame.texture;
            _frameRect = frame.rect;
            _needRebuild = true;
        }
    }
    
    private static var sHelperQuad : QuadExt;
    override public function render(support : RenderSupport, parentAlpha : Float) : Void
    {
        if (_needRebuild) 
        {
            _needRebuild = false;
            
            if (sHelperQuad == null) 
                sHelperQuad = new QuadExt();
            
            _batch.reset();
            if (_texture != null) 
            {
                sHelperQuad.setPremultipliedAlpha(_texture.premultipliedAlpha);
                sHelperQuad.fillVertsWithScale(_frameRect.x, _frameRect.y, _texture.width, _texture.height,
                        _scaleX, _scaleY);
                sHelperQuad.fillUVOfTexture(_texture);
                _batch.addQuad(sHelperQuad, 1.0, _texture, _smoothing);
                
                _batch.blendMode = this.blendMode;
            }
        }
        
        if (_batch.numQuads > 0) 
            support.batchQuadBatch(_batch, this.alpha * parentAlpha);
    }
}

