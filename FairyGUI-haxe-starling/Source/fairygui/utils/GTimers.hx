package fairygui.utils;



import openfl.events.TimerEvent;
import openfl.utils.Dictionary;
import openfl.utils.Timer;

import starling.core.Starling;

class GTimers
{
    private var _items : Dynamic;
    private var _itemMap : Dictionary;
    private var _itemPool : Dynamic;
    private var _timer : Timer;
    
    private var _lastTime : Float;
    
    private var _enumI : Int;
    private var _enumCount : Int;
    
    public static var deltaTime : Int;
    public static var time : Float;
    public static var workCount : Int;
    
    public static var inst : GTimers = new GTimers();
    
    private static var FPS24 : Int = Std.int(1000 / 24);
    
    public function new()
    {
        _items = new Array<TimerItem>();
        _itemMap = new Dictionary();
        _itemPool = new Array<TimerItem>();
        
        deltaTime = 1;
        _lastTime = Date.now().time;
        time = _lastTime;
        
        _timer = new Timer(10);
        _timer.addEventListener(TimerEvent.TIMER, __timer);
        _timer.start();
    }
    
    private function getItem() : TimerItem
    {
        if (_itemPool.length) 
            return _itemPool.pop()
        else 
        return new TimerItem();
    }
    
    public function add(delayInMiniseconds : Int, repeat : Int, callback : Dynamic, callbackParam : Dynamic = null) : Void{
        var item : TimerItem = Reflect.field(_itemMap, Std.string(callback));
        if (item == null) 
        {
            item = getItem();
            item.callback = callback;
            item.hasParam = callback.length == 1;
            Reflect.setField(_itemMap, Std.string(callback), item);
            _items.push(item);
        }
        item.delay = delayInMiniseconds;
        item.counter = 0;
        item.repeat = repeat;
        item.param = callbackParam;
        item.end = false;
    }
    
    public function callLater(callback : Dynamic, callbackParam : Dynamic = null) : Void
    {
        add(1, 1, callback, callbackParam);
    }
    
    public function callDelay(delay : Int, callback : Dynamic, callbackParam : Dynamic = null) : Void
    {
        add(delay, 1, callback, callbackParam);
    }
    
    public function callBy24Fps(callback : Dynamic, callbackParam : Dynamic = null) : Void
    {
        add(FPS24, 0, callback, callbackParam);
    }
    
    public function exists(callback : Dynamic) : Bool{
        return Reflect.field(_itemMap, Std.string(callback)) != null;
    }
    
    public function remove(callback : Dynamic) : Void{
        var item : TimerItem = Reflect.field(_itemMap, Std.string(callback));
        if (item != null) 
        {
            var i : Int = _items.indexOf(item);
            _items.splice(i, 1);
            if (i < _enumI) 
                _enumI--;
            _enumCount--;
            
            item.callback = null;
            item.param = null;

            _itemPool.push(item);
        }
    }
    
    private function __timer(evt : TimerEvent) : Void{
        if (!Starling.current.contextValid) 
            return;
        
        time = Date.now().time;
        workCount++;
        
        deltaTime = time - _lastTime;
        _lastTime = time;
        
        if (deltaTime > 125) 
            deltaTime = 125;
        
        _enumI = 0;
        _enumCount = _items.length;
        
        while (_enumI < _enumCount)
        {
            var item : TimerItem = _items[_enumI];
            _enumI++;
            
            if (item.advance(deltaTime)) {
                if (item.end) 
                {
                    _enumI--;
                    _enumCount--;
                    _items.splice(_enumI, 1);

                    _itemPool.push(item);
                }
                
                if (item.hasParam) 
                    item.callback(item.param)
                else 
                item.callback();
            }
        }
    }
}


class TimerItem
{
    public var delay : Int;
    public var counter : Int;
    public var repeat : Int;
    public var callback : Dynamic;
    public var param : Dynamic;
    
    public var hasParam : Bool;
    public var end : Bool;
    
    public function new()
    {
        
    }
    
    public function advance(elapsed : Int) : Bool
    {
        counter += elapsed;
        if (counter >= delay) {
            counter -= delay;
            if (counter > delay) 
                counter = delay;
            
            if (repeat > 0) 
            {
                repeat--;
                if (repeat == 0) 
                    end = true;
            }
            
            return true;
        }
        else 
        return false;
    }
}
