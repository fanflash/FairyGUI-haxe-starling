package fairygui;

import motion.actuators.IGenericActuator;
import openfl.media.Sound;

import fairygui.utils.GTimers;
import fairygui.utils.ToolSet;
import fairygui.GObject;

import motion.Actuate;
import motion.EaseLookup;
import motion.easing.IEasing;
import motion.easing.Quad;


class Transition
{
    public var name(get, set) : String;
    public var playing(get, never) : Bool;

    private var _name : String;
    private var _owner : GComponent;
    private var _ownerBaseX : Float;
    private var _ownerBaseY : Float;
    private var _items : Array<TransitionItem>;
    private var _totalTimes : Int;
    private var _totalTasks : Int;
    private var _playing : Bool;
    private var _onComplete : Dynamic;
    private var _onCompleteParam : Dynamic;
    private var _options : Int;
    
    public var OPTION_IGNORE_DISPLAY_CONTROLLER : Int = 1;
    
    private inline var FRAME_RATE : Int = 24;
    
    public function new(owner : GComponent)
    {
        _owner = owner;
        _items = new Array<TransitionItem>();
    }
    
    private function get_name() : String
    {
        return _name;
    }
    
    private function set_name(value : String) : String
    {
        _name = value;
        return value;
    }
    
    public function play(onComplete : Dynamic = null, onCompleteParam : Dynamic = null, times : Int = 1, delay : Float = 0) : Void
    {
        stop();
        if (times <= 0) 
            times = 1;
        _totalTimes = times;
        internalPlay(delay);
        _playing = _totalTasks > 0;
        if (_playing) 
        {
            _onComplete = onComplete;
            _onCompleteParam = onCompleteParam;
            
            _owner.internalVisible++;
            if ((_options & OPTION_IGNORE_DISPLAY_CONTROLLER) != 0) 
            {
                var cnt : Int = _items.length;
                for (i in 0...cnt){
                    var item : TransitionItem = _items[i];
                    if (item.target != null && item.target != _owner) 
                        item.target.internalVisible++;
                }
            }
        }
        else if (onComplete != null) 
        {
            if (onComplete.length > 0) 
                onComplete(onCompleteParam)
            else 
            onComplete();
        }
    }
    
    public function stop(setToComplete : Bool = true, processCallback : Bool = false) : Void
    {
        if (_playing) 
        {
            _playing = false;
            _totalTasks = 0;
            _totalTimes = 0;
            var func : Dynamic = _onComplete;
            var param : Dynamic = _onCompleteParam;
            _onComplete = null;
            _onCompleteParam = null;
            
            _owner.internalVisible--;
            
            var cnt : Int = _items.length;
            for (i in 0...cnt){
                var item : TransitionItem = _items[i];
                if (item.target == null) 
                    {i++;continue;
                };
                
                if ((_options & OPTION_IGNORE_DISPLAY_CONTROLLER) != 0) 
                {
                    if (item.target != _owner) 
                        item.target.internalVisible--;
                }
                
                if (item.completed) 
                    {i++;continue;
                };
                
                if (item.tweener != null) 
                {
                    item.tweener.kill();
                    item.tweener = null;
                }
                
                if (item.type == TransitionActionType.Transition) 
                {
                    var trans : Transition = cast((item.target), GComponent).getTransition(item.value.s);
                    if (trans != null) 
                        trans.stop(setToComplete, false);
                }
                else if (item.type == TransitionActionType.Shake) 
                {
                    if (GTimers.inst.exists(item.__shake)) 
                    {
                        GTimers.inst.remove(item.__shake);
                        item.target._gearLocked = true;
                        item.target.setXY(item.target.x - item.startValue.f1, item.target.y - item.startValue.f2);
                        item.target._gearLocked = false;
                    }
                }
                else 
                {
                    if (setToComplete) 
                    {
                        if (item.tween) 
                        {
                            if (!item.yoyo || item.repeat % 2 == 0) 
                                applyValue(item, item.endValue)
                            else 
                            applyValue(item, item.startValue);
                        }
                        else if (item.type != TransitionActionType.Sound) 
                            applyValue(item, item.value);
                    }
                }
            }
            
            if (processCallback && func != null) 
            {
                if (func.length > 0) 
                    func(param)
                else 
                func();
            }
        }
    }
    
    
    private function get_playing() : Bool
    {
        return _playing;
    }
    
    public function setValue(label : String) : Void
    {
        var cnt : Int = _items.length;
        var value : TransitionValue;
        for (i in 0...cnt){
            var item : TransitionItem = _items[i];
            if (item.label == null && item.label2 == null) 
                {i++;continue;
            };
            
            if (item.label == label) 
            {
                if (item.tween) 
                    value = item.startValue
                else 
                value = item.value;
            }
            else if (item.label2 == label) 
            {
                value = item.endValue;
            }
            else 
            {i++;continue;
            }
            
            var _sw3_ = (item.type);            

            switch (_sw3_)
            {
                case TransitionActionType.XY, TransitionActionType.Size, TransitionActionType.Pivot, TransitionActionType.Scale:
                    value.b1 = true;
                    value.b2 = true;
                    value.f1 = parseFloat(args[0]);
                    value.f2 = parseFloat(args[1]);
                
                case TransitionActionType.Alpha:
                    value.f1 = parseFloat(args[0]);
                
                case TransitionActionType.Rotation:
                    value.i = parseInt(args[0]);
                
                case TransitionActionType.Color:
                    value.c = parseFloat(args[0]);
                
                case TransitionActionType.Animation:
                    value.i = parseInt(args[0]);
                    if (args.length > 1) 
                        value.b = args[1];
                
                case TransitionActionType.Visible:
                    value.b = args[0];
                
                case TransitionActionType.Controller:
                    value.s = args[0];
                
                case TransitionActionType.Sound:
                    value.s = args[0];
                    if (args.length > 1) 
                        value.f1 = parseFloat(args[1]);
                
                case TransitionActionType.Transition:
                    value.s = args[0];
                    if (args.length > 1) 
                        value.i = parseInt(args[1]);
                
                case TransitionActionType.Shake:
                    value.f1 = parseFloat(args[0]);
                    if (args.length > 1) 
                        value.f2 = parseFloat(args[1]);
            }
        }
    }
    
    public function setHook(label : String, callback : Dynamic) : Void
    {
        var cnt : Int = _items.length;
        for (i in 0...cnt){
            var item : TransitionItem = _items[i];
            if (item.label == null && item.label2 == null) 
                {i++;continue;
            };
            
            if (item.label == label) 
            {
                item.hook = callback;
            }
            else if (item.label2 == label) 
            {
                item.hook2 = callback;
            }
        }
    }
    
    public function clearHooks() : Void
    {
        var cnt : Int = _items.length;
        for (i in 0...cnt){
            var item : TransitionItem = _items[i];
            item.hook = null;
            item.hook2 = null;
        }
    }
    
    public function setTarget(label : String, newTarget : GObject) : Void
    {
        var cnt : Int = _items.length;
        var value : TransitionValue;
        for (i in 0...cnt){
            var item : TransitionItem = _items[i];
            if (item.label == null && item.label2 == null) 
                {i++;continue;
            };
            
            item.targetId = newTarget.id;
        }
    }
    
    @:allow(fairygui)
    private function updateFromRelations(targetId : String, dx : Float, dy : Float) : Void
    {
        var cnt : Int = _items.length;
        if (cnt == 0) 
            return;
        
        for (i in 0...cnt){
            var item : TransitionItem = _items[i];
            if (item.type == TransitionActionType.XY && item.targetId == targetId) 
            {
                if (item.tween) 
                {
                    if (item.startValue.b1) 
                        item.startValue.f1 += dx;
                    if (item.startValue.b2) 
                        item.startValue.f2 += dy;
                    if (item.endValue.b1) 
                        item.endValue.f1 += dx;
                    if (item.endValue.b2) 
                        item.endValue.f2 += dy;
                }
                else 
                {
                    if (item.value.b1) 
                        item.value.f1 += dx;
                    if (item.value.b2) 
                        item.value.f2 += dy;
                }
            }
        }
    }
    
    private function internalPlay(delay : Float) : Void
    {
        _ownerBaseX = _owner.x;
        _ownerBaseY = _owner.y;
        
        _totalTasks = 0;
        var cnt : Int = _items.length;
        var parms : Dynamic;
        for (i in 0...cnt){
            var item : TransitionItem = _items[i];
            if (item.targetId) 
                item.target = _owner.getChildById(item.targetId)
            else 
            item.target = _owner;
            if (item.target == null) 
                {i++;continue;
            };
            
            var startTime : Float = delay + item.time;
            
            if (item.tween) 
            {
                item.completed = false;
                var _sw4_ = (item.type);                

                switch (_sw4_)
                {
                    case TransitionActionType.XY, TransitionActionType.Size:
                        _totalTasks++;
                        if (startTime == 0) 
                            startTween(item)
                        else
                        Actuate.apply(__delayCall, item.params).delay(startTime);
//                        item.tweener = TweenMax.delayedCall(startTime, __delayCall, item.params);
                    
                    case TransitionActionType.Scale:
                        _totalTasks++;
                        item.value.f1 = item.startValue.f1;
                        item.value.f2 = item.startValue.f2;
                        parms = { };
                        parms.f1 = item.endValue.f1;
                        parms.f2 = item.endValue.f2;
                        parms.ease = item.easeType;
                        parms.onStart = __tweenStart;
                        parms.onStartParams = item.params;
                        parms.onUpdate = __tweenUpdate;
                        parms.onUpdateParams = item.params;
                        parms.onComplete = __tweenComplete;
                        parms.onCompleteParams = item.params;
                        if (startTime > 0) 
                            parms.delay = startTime
                        else 
                        applyValue(item, item.value);
                        if (item.repeat > 0) 
                        {
                            parms.repeat = item.repeat;
                            parms.yoyo = item.yoyo;
                        }
                        item.tweener = Actuate.tween(item.value, item.duration, parms);
                    
                    case TransitionActionType.Alpha:
                        _totalTasks++;
                        item.value.f1 = item.startValue.f1;
                        parms = { };
                        parms.f1 = item.endValue.f1;
                        parms.ease = item.easeType;
                        parms.onStart = __tweenStart;
                        parms.onStartParams = item.params;
                        parms.onUpdate = __tweenUpdate;
                        parms.onUpdateParams = item.params;
                        parms.onComplete = __tweenComplete;
                        parms.onCompleteParams = item.params;
                        if (startTime > 0) 
                            parms.delay = startTime
                        else 
                        applyValue(item, item.value);
                        if (item.repeat > 0) 
                        {
                            parms.repeat = item.repeat;
                            parms.yoyo = item.yoyo;
                        }
                        item.tweener = Actuate.tween(item.value, item.duration, parms);
                    
                    case TransitionActionType.Rotation:
                        _totalTasks++;
                        item.value.i = item.startValue.i;
                        parms = { };
                        parms.i = item.endValue.i;
                        parms.ease = item.easeType;
                        parms.onStart = __tweenStart;
                        parms.onStartParams = item.params;
                        parms.onUpdate = __tweenUpdate;
                        parms.onUpdateParams = item.params;
                        parms.onComplete = __tweenComplete;
                        parms.onCompleteParams = item.params;
                        if (startTime > 0) 
                            parms.delay = startTime
                        else 
                        applyValue(item, item.value);
                        if (item.repeat > 0) 
                        {
                            parms.repeat = item.repeat;
                            parms.yoyo = item.yoyo;
                        }
                        item.tweener = Actuate.tween(item.value, item.duration, parms);
                }
            }
            else 
            {
                if (startTime == 0) 
                    applyValue(item, item.value)
                else 
                {
                    item.completed = false;
                    _totalTasks++;
                    Actuate.apply(__delayCall, item.params).delay(startTime);
//                    item.tweener = TweenMax.delayedCall(startTime, __delayCall2, item.params);
                }
            }
        }
    }
    
    private function startTween(item : TransitionItem) : Void
    {
        if (item.type == TransitionActionType.XY) 
        {
            if (item.target == _owner) 
            {
                item.value.f1 = (item.startValue.b1) ? item.startValue.f1 : 0;
                item.value.f2 = (item.startValue.b2) ? item.startValue.f2 : 0;
            }
            else 
            {
                item.value.f1 = (item.startValue.b1) ? item.startValue.f1 : item.target.x;
                item.value.f2 = (item.startValue.b2) ? item.startValue.f2 : item.target.y;
            }
        }
        else 
        {
            item.value.f1 = (item.startValue.b1) ? item.startValue.f1 : item.target.width;
            item.value.f2 = (item.startValue.b2) ? item.startValue.f2 : item.target.height;
        }
        
        var parms : Dynamic = { };
        parms.ease = item.easeType;
        parms.onUpdate = __tweenUpdate;
        parms.onUpdateParams = item.params;
        parms.onComplete = __tweenComplete;
        parms.onCompleteParams = item.params;
        parms.f1 = (item.endValue.b1) ? item.endValue.f1 : item.value.f1;
        parms.f2 = (item.endValue.b2) ? item.endValue.f2 : item.value.f2;
        if (item.repeat > 0) 
        {
            parms.repeat = item.repeat;
            parms.yoyo = item.yoyo;
        }
        
        applyValue(item, item.value);
        item.tweener =Actuate.tween(item.value, item.duration, parms);
        
        if (item.hook != null) 
            item.hook();
    }
    
    private function __delayCall(item : TransitionItem) : Void
    {
        item.tweener = null;
        
        startTween(item);
    }
    
    private function __delayCall2(item : TransitionItem) : Void
    {
        item.tweener = null;
        _totalTasks--;
        item.completed = true;
        
        applyValue(item, item.value);
        if (item.hook != null) 
            item.hook();
        
        checkAllComplete();
    }
    
    private function __tweenStart(item : TransitionItem) : Void
    {
        if (item.hook != null) 
            item.hook();
    }
    
    private function __tweenUpdate(item : TransitionItem) : Void
    {
        applyValue(item, item.value);
    }
    
    private function __tweenComplete(item : TransitionItem) : Void
    {
        item.tweener = null;
        _totalTasks--;
        item.completed = true;
        if (item.hook2 != null) 
            item.hook2();
        
        checkAllComplete();
    }
    
    private function __playTransComplete(item : TransitionItem) : Void
    {
        _totalTasks--;
        item.completed = true;
        checkAllComplete();
    }
    
    private function checkAllComplete() : Void
    {
        if (_playing && _totalTasks == 0) 
        {
            if (_totalTimes < 0) 
            {
                internalPlay(0);
            }
            else 
            {
                _totalTimes--;
                if (_totalTimes > 0) 
                    internalPlay(0)
                else 
                {
                    _playing = false;
                    _owner.internalVisible--;
                    
                    if ((_options & OPTION_IGNORE_DISPLAY_CONTROLLER) != 0) 
                    {
                        var cnt : Int = _items.length;
                        for (i in 0...cnt){
                            var item : TransitionItem = _items[i];
                            if (item.target != null && item.target != _owner) 
                                item.target.internalVisible--;
                        }
                    }
                    if (_onComplete != null) 
                    {
                        var func : Dynamic = _onComplete;
                        var param : Dynamic = _onCompleteParam;
                        _onComplete = null;
                        _onCompleteParam = null;
                        if (func.length > 0) 
                            func(param)
                        else 
                        func();
                    }
                }
            }
        }
    }
    
    private function applyValue(item : TransitionItem, value : TransitionValue) : Void
    {
        item.target._gearLocked = true;
        
        var _sw5_ = (item.type);        

        switch (_sw5_)
        {
            case TransitionActionType.XY:
                if (item.target == _owner) 
                {
                    var f1 : Float;
                    var f2 : Float;
                    if (!value.b1) 
                        f1 = item.target.x
                    else 
                    f1 = value.f1 + _ownerBaseX;
                    if (!value.b2) 
                        f2 = item.target.y
                    else 
                    f2 = value.f2 + _ownerBaseY;
                    item.target.setXY(f1, f2);
                }
                else 
                {
                    if (!value.b1) 
                        value.f1 = item.target.x;
                    if (!value.b2) 
                        value.f2 = item.target.y;
                    item.target.setXY(value.f1, value.f2);
                }
            
            case TransitionActionType.Size:
                if (!value.b1) 
                    value.f1 = item.target.width;
                if (!value.b2) 
                    value.f2 = item.target.height;
                item.target.setSize(value.f1, value.f2);
            
            case TransitionActionType.Pivot:
                item.target.setPivot(value.f1, value.f2);
            
            case TransitionActionType.Alpha:
                item.target.alpha = value.f1;
            
            case TransitionActionType.Rotation:
                item.target.rotation = value.i;
            
            case TransitionActionType.Scale:
                item.target.setScale(value.f1, value.f2);
            
            case TransitionActionType.Color:
                cast((item.target), IColorGear).color = value.c;
            
            case TransitionActionType.Animation:
                if (!value.b1) 
                    value.i = cast((item.target), IAnimationGear).frame;
                cast((item.target), IAnimationGear).frame = value.i;
                cast((item.target), IAnimationGear).playing = value.b;
            
            case TransitionActionType.Visible:
                item.target.visible = value.b;
            
            case TransitionActionType.Controller:
                var arr : Array<Dynamic> = value.s.split(",");
                for (str in arr)
                {
                    var arr2 : Array<Dynamic> = str.split("=");
                    var cc : Controller = cast((item.target), GComponent).getController(arr2[0]);
                    if (cc != null) 
                    {
                        str = arr2[1];
                        if (str.charAt(0) == "$") 
                        {
                            str = str.substring(1);
                            cc.selectedPage = str;
                        }
                        else 
                        cc.selectedIndex = parseInt(str);
                    }
                }
            
            case TransitionActionType.Transition:
                var trans : Transition = cast((item.target), GComponent).getTransition(value.s);
                if (trans != null) 
                {
                    if (value.i == 0) 
                        trans.stop(false, true)
                    else if (trans.playing) 
                        trans._totalTimes = value.i
                    else 
                    {
                        item.completed = false;
                        _totalTasks++;
                        trans.play(__playTransComplete, item, value.i);
                    }
                }
            
            case TransitionActionType.Sound:
                var pi : PackageItem = UIPackage.getItemByURL(value.s);
                if (pi != null) 
                {
                    var sound : Sound = pi.owner.getSound(pi);
                    if (sound != null) 
                        GRoot.inst.playOneShotSound(sound, value.f1);
                }
            
            case TransitionActionType.Shake:
                item.startValue.f1 = 0;  //offsetX  
                item.startValue.f2 = 0;  //offsetY  
                item.startValue.f3 = item.value.f2;  //shakePeriod  
                item.startValue.i = Math.round(haxe.Timer.stamp() * 1000);  //startTime  
                GTimers.inst.add(1, 0, item.__shake, this.shakeItem);
                _totalTasks++;
                item.completed = false;
        }
        
        item.target._gearLocked = false;
    }
    
    private function shakeItem(item : TransitionItem) : Void
    {
        var r : Float = Math.ceil(item.value.f1 * item.startValue.f3 / item.value.f2);
        var rx : Float = (Math.random() * 2 - 1) * r;
        var ry : Float = (Math.random() * 2 - 1) * r;
        rx = rx > (0) ? Math.ceil(rx) : Math.floor(rx);
        ry = ry > (0) ? Math.ceil(ry) : Math.floor(ry);
        
        item.target._gearLocked = true;
        item.target.setXY(item.target.x - item.startValue.f1 + rx, item.target.y - item.startValue.f2 + ry);
        item.target._gearLocked = false;
        
        item.startValue.f1 = rx;
        item.startValue.f2 = ry;
        
        var t : Int = Math.round(haxe.Timer.stamp() * 1000);
        item.startValue.f3 -= (t - item.startValue.i) / 1000;
        item.startValue.i = t;
        if (item.startValue.f3 <= 0) 
        {
            item.target._gearLocked = true;
            item.target.setXY(item.target.x - item.startValue.f1, item.target.y - item.startValue.f2);
            item.target._gearLocked = false;
            
            item.completed = true;
            _totalTasks--;
            GTimers.inst.remove(item.__shake);
            
            checkAllComplete();
        }
    }
    
    public function setup(xml : Fast) : Void
    {
        this.name = xml.att.name;
        var str : String = xml.att.options;
        if (str != null) 
            _options = Std.parseInt(str);
        var col : FastXMLList = xml.node.item.innerData;
        for (cxml in col)
        {
            var item : TransitionItem = new TransitionItem();
            _items.push(item);
            
            item.time = Std.parseInt(cxml.att.time) / FRAME_RATE;
            item.targetId = cxml.att.target;
            str = cxml.att.type;
            switch (str)
            {
                case "XY":
                    item.type = TransitionActionType.XY;
                case "Size":
                    item.type = TransitionActionType.Size;
                case "Scale":
                    item.type = TransitionActionType.Scale;
                case "Pivot":
                    item.type = TransitionActionType.Pivot;
                case "Alpha":
                    item.type = TransitionActionType.Alpha;
                case "Rotation":
                    item.type = TransitionActionType.Rotation;
                case "Color":
                    item.type = TransitionActionType.Color;
                case "Animation":
                    item.type = TransitionActionType.Animation;
                case "Visible":
                    item.type = TransitionActionType.Visible;
                case "Controller":
                    item.type = TransitionActionType.Controller;
                case "Sound":
                    item.type = TransitionActionType.Sound;
                case "Transition":
                    item.type = TransitionActionType.Transition;
                case "Shake":
                    item.type = TransitionActionType.Shake;
                default:
                    item.type = TransitionActionType.Unknown;
                    break;
            }
            item.tween = cxml.att.tween == "true";
            item.label = cxml.att.label;
            if (item.label.length == 0) 
                item.label = null;
            
            if (item.tween) 
            {
                item.duration = Std.parseInt(cxml.att.duration) / FRAME_RATE;
                
                str = cxml.att.ease;
                if (str != null) 
                {
                    var pos : Int = str.indexOf(".");
                    if (pos != -1) 
                        str = str.substr(0, pos) + ".ease" + str.substr(pos + 1);
                    if (str == "Linear")
                        item.easeType = EaseLookup.find("linear.easenone")
                    else 
                    item.easeType = EaseLookup.find(str);
                }
                
                item.repeat = Std.parseInt(cxml.att.repeat);
                item.yoyo = cxml.att.yoyo == "true";
                item.label2 = cxml.att.label2;
                if (item.label2.length == 0) 
                    item.label2 = null;
                
                var v : String = cxml.att.endValue;
                if (v != null) 
                {
                    decodeValue(item.type, cxml.att.startValue, item.startValue);
                    decodeValue(item.type, v, item.endValue);
                }
                else 
                {
                    item.tween = false;
                    decodeValue(item.type, cxml.att.startValue, item.value);
                }
                
                v = cxml.att.throughPoints;
                if (v != null) 
                {
                    /*string[] arr = v.Split(jointChar1);
						foreach (string str in arr)
						{
						if (str.Length == 0)
						continue;
						string[] arr2 = str.Split(jointChar0);
						item.throughPoints.Add(new Point(int.Parse(arr2[0]), int.Parse(arr2[1])));
						}*/
                    
                }
            }
            else 
            {
                decodeValue(item.type, cxml.att.value, item.value);
            }
        }
    }
    
    private function decodeValue(type : Int, str : String, value : TransitionValue) : Void
    {
        var arr : Array<Dynamic>;
        switch (type)
        {
            case TransitionActionType.XY, TransitionActionType.Size, TransitionActionType.Pivot:
                arr = str.split(",");
                if (arr[0] == "-") 
                {
                    value.b1 = false;
                }
                else 
                {
                    value.f1 = Std.parseInt(arr[0]);
                    value.b1 = true;
                }
                if (arr[1] == "-") 
                {
                    value.b2 = false;
                }
                else 
                {
                    value.f2 = Std.parseInt(arr[1]);
                    value.b2 = true;
                }
            
            case TransitionActionType.Alpha:
                value.f1 = Std.parseFloat(str);
            
            case TransitionActionType.Rotation:
                value.i = Std.parseInt(str);
            
            case TransitionActionType.Scale:
                arr = str.split(",");
                value.f1 = Std.parseFloat(arr[0]);
                value.f2 = Std.parseFloat(arr[1]);
            
            case TransitionActionType.Color:
                value.c = ToolSet.convertFromHtmlColor(str);
            
            case TransitionActionType.Animation:
                arr = str.split(",");
                if (arr[0] == "-") 
                {
                    value.b1 = false;
                }
                else 
                {
                    value.i = Std.parseInt(arr[0]);
                    value.b1 = true;
                }
                value.b = arr[1] == "p";
            
            case TransitionActionType.Visible:
                value.b = str == "true";
            
            case TransitionActionType.Controller:
                value.s = str;
            
            case TransitionActionType.Sound:
                arr = str.split(",");
                value.s = arr[0];
                if (arr.length > 1) 
                {
                    var intv : Int = Std.parseInt(arr[1]);
                    if (intv == 0 || intv == 100) 
                        value.f1 = 1
                    else 
                    value.f1 = intv / 100;
                }
                else 
                value.f1 = 1;
            
            case TransitionActionType.Transition:
                arr = str.split(",");
                value.s = arr[0];
                if (arr.length > 1) 
                    value.i = Std.parseInt(arr[1])
                else 
                value.i = 1;
            
            case TransitionActionType.Shake:
                arr = str.split(",");
                value.f1 = Std.parseFloat(arr[0]);
                value.f2 = Std.parseFloat(arr[1]);
        }
    }
}




class TransitionActionType
{
    public static inline var XY : Int = 0;
    public static inline var Size : Int = 1;
    public static inline var Scale : Int = 2;
    public static inline var Pivot : Int = 3;
    public static inline var Alpha : Int = 4;
    public static inline var Rotation : Int = 5;
    public static inline var Color : Int = 6;
    public static inline var Animation : Int = 7;
    public static inline var Visible : Int = 8;
    public static inline var Controller : Int = 9;
    public static inline var Sound : Int = 10;
    public static inline var Transition : Int = 11;
    public static inline var Shake : Int = 12;
    public static inline var Unknown : Int = 13;

    public function new()
    {
    }
}

class TransitionItem
{
    public var time : Float;
    public var targetId : String;
    public var type : Int;
    public var duration : Float;
    public var value : TransitionValue;
    public var startValue : TransitionValue;
    public var endValue : TransitionValue;
    public var easeType : IEasing;
    public var repeat : Int;
    public var yoyo : Bool;
    public var tween : Bool;
    public var label : String;
    public var label2 : String;
    public var hook : Dynamic;
    public var hook2 : Dynamic;
    public var tweener : IGenericActuator;
    public var completed : Bool;
    public var target : GObject;
    
    public var params : Array<Dynamic>;
    public function new()
    {
        easeType = Quad.easeOut;
        value = new TransitionValue();
        startValue = new TransitionValue();
        endValue = new TransitionValue();
        params = [this];
    }
    
    public function __shake(param : Dynamic) : Void
    {
        param(this);
    }
}

class TransitionValue
{
    public var f1 : Float;  //x, scalex, pivotx,alpha,shakeAmplitude  
    public var f2 : Float;  //y, scaley, pivoty, shakePeriod  
    public var f3 : Float;
    public var i : Int;  //rotation,frame  
    public var c : Int;  //color  
    public var b : Bool;  //playing  
    public var s : String;  //sound,transName  
    
    public var b1 : Bool = true;
    public var b2 : Bool = true;

    public function new()
    {
    }
}

