package fairygui;

import fairygui.GObject;
import fairygui.Window;
import openfl.errors.Error;

import openfl.display.Stage;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import openfl.media.Sound;
import openfl.media.SoundTransform;
import openfl.system.Capabilities;
import openfl.system.TouchscreenType;
import openfl.ui.Multitouch;
import openfl.ui.MultitouchInputMode;

import fairygui.display.UIDisplayObject;
import fairygui.event.FocusChangeEvent;
import fairygui.utils.ToolSet;

import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Stage;
import starling.events.Event;
import starling.events.ResizeEvent;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

@:meta(Event(name="focusChanged",type="fairygui.event.FocusChangeEvent"))

class GRoot extends GComponent
{
    public static var inst(get, never) : GRoot;
    public var nativeStage(get, never) : starling.display.Stage;
    public var hasModalWindow(get, never) : Bool;
    public var modalWaiting(get, never) : Bool;
    public var hasAnyPopup(get, never) : Bool;
    public var focus(get, set) : GObject;
    public var volumeScale(get, set) : Float;

    private var _nativeStage : starling.display.Stage;
    private var _modalLayer : GGraph;
    private var _popupStack : Array<GObject>;
    private var _justClosedPopups : Array<GObject>;
    private var _modalWaitPane : GObject;
    private var _focusedObject : GObject;
    private var _tooltipWin : GObject;
    private var _defaultTooltipWin : GObject;
    private var _hitUI : Bool;
    private var _focusManagement : Bool;
    private var _volumeScale : Float;
    
    private static var _inst : GRoot;
    
    public var buttonDown : Bool;
    public var ctrlKeyDown : Bool;
    public var shiftKeyDown : Bool;
    
    public static var touchScreen : Bool;
    public static var touchPointInput : Bool;
    public static var contentScaleFactor : Float = 1;
    
    private static function get_inst() : GRoot
    {
        if (_inst == null) 
            new GRoot();
        return _inst;
    }
    
    public function new()
    {
        super();
        if (_inst == null) 
            _inst = this;
        
        _volumeScale = 1;
        this.opaque = false;
        _popupStack = new Array<GObject>();
        _justClosedPopups = new Array<GObject>();
        displayObject.addEventListener(Event.ADDED_TO_STAGE, __addedToStage);
    }
    
    private function get_nativeStage() : starling.display.Stage
    {
        return _nativeStage;
    }
    
    public function setContentScaleFactor(designUIWidth : Int, designUIHeight : Int) : Void
    {
        var w : Int;
        var h : Int;
        if (Capabilities.os.toLowerCase().substring(0, 3) == "win" || Capabilities.os.toLowerCase().substring(0, 3) == "mac") 
        {
            w = _nativeStage.stageWidth;
            h = _nativeStage.stageHeight;
        }
        else 
        {
            w = Capabilities.screenResolutionX;
            h = Capabilities.screenResolutionY;
        }
        
        if (designUIWidth > 0 && designUIHeight > 0) 
        {
            var s1 : Float = w / designUIWidth;
            var s2 : Float = h / designUIHeight;
            contentScaleFactor = Math.min(s1, s2);
        }
        else if (designUIWidth > 0) 
            contentScaleFactor = w / designUIWidth
        else if (designUIHeight > 0) 
            contentScaleFactor = h / designUIHeight
        else 
        contentScaleFactor = 1;
        this.setSize(Math.round(w / contentScaleFactor), Math.round(h / contentScaleFactor));
        this.scaleX = contentScaleFactor;
        this.scaleY = contentScaleFactor;
    }
    
    public function enableFocusManagement() : Void
    {
        _focusManagement = true;
    }
    
    public function showWindow(win : Window) : Void
    {
        if (win.parent != null && _popupStack.length > 0) 
        {
            var popup : GObject = _popupStack[0];
            var winIndex : Int = this.getChildIndex(win);
            var popupIndex : Int = this.getChildIndex(popup);
            if (popupIndex == winIndex + 1 && popup.x >= win.x && popup.y >= win.y && popup.x < win.x + win.actualWidth && popup.y < win.y + win.actualHeight) 
            {
                _showWindow(win);
                winIndex = this.getChildIndex(win);
                for (popup in _popupStack)
                {
                    this.setChildIndex(popup, winIndex);
                }
                return;
            }
        }
        
        _showWindow(win);
    }
    
    private function _showWindow(win : Window) : Void
    {
        addChild(win);
        win.requestFocus();
        adjustModalLayer();
        
        if (win.x > this.width) 
            win.x = this.width - win.width
        else if (win.x + win.width < 0) 
            win.x = 0;
        
        if (win.y > this.height) 
            win.y = this.height - win.height
        else if (win.y + win.height < 0) 
            win.y = 0;
    }
    
    public function hideWindow(win : Window) : Void
    {
        win.hide();
    }
    
    public function hideWindowImmediately(win : Window) : Void
    {
        if (win.parent == this) 
            removeChild(win);
        
        adjustModalLayer();
    }
    
    public function showModalWait(msg : String = null) : Void
    {
        if (UIConfig.globalModalWaiting != null) 
        {
            if (_modalWaitPane == null) 
                _modalWaitPane = UIPackage.createObjectFromURL(UIConfig.globalModalWaiting);
            _modalWaitPane.setSize(this.width, this.height);
            _modalWaitPane.addRelation(this, RelationType.Size);
            
            addChild(_modalWaitPane);
            _modalWaitPane.text = msg;
        }
    }
    
    public function closeModalWait() : Void
    {
        if (_modalWaitPane != null && _modalWaitPane.parent != null) 
            removeChild(_modalWaitPane);
    }
    
    public function closeAllExceptModals() : Void
    {
        var arr : Array<GObject> = _children.substring();
        var cnt : Int = arr.length;
        for (i in 0...cnt){
            var g : GObject = arr[i];
            if ((Std.is(g, Window)) && !(try cast(g, Window) catch(e:Dynamic) null).modal) 
                (try cast(g, Window) catch(e:Dynamic) null).hide();
        }
    }
    
    public function closeAllWindows() : Void
    {
        var arr : Array<GObject> = _children.substring();
        var cnt : Int = arr.length;
        for (i in 0...cnt){
            var g : GObject = arr[i];
            if (Std.is(g, Window)) 
                (try cast(g, Window) catch(e:Dynamic) null).hide();
        }
    }
    
    public function getTopWindow() : Window
    {
        var cnt : Int = this.numChildren;
        var i : Int = cnt - 1;
        while (i >= 0){
            var g : GObject = this.getChildAt(i);
            if (Std.is(g, Window)) {
                return cast((g), Window);
            }
            i--;
        }
        
        return null;
    }
    
    private function get_hasModalWindow() : Bool
    {
        return _modalLayer.parent != null;
    }
    
    private function get_modalWaiting() : Bool
    {
        return _modalWaitPane && _modalWaitPane.inContainer;
    }
    
    public function showPopup(popup : GObject, target : GObject = null, downward : Dynamic = null) : Void
    {
        if (_popupStack.length > 0) 
        {
            var k : Int = Lambda.indexOf(_popupStack, popup);
            if (k != -1) 
            {
                var i : Int = _popupStack.length - 1;
                while (i >= k){
                    closePopup(_popupStack.pop());
                    i--;
                }
            }
        }
        _popupStack.push(popup);
        
        addChild(popup);
        adjustModalLayer();
        
        var pos : Point;
        var sizeW : Int;
        var sizeH : Int;
        if (target != null) 
        {
            pos = target.localToRoot(0, 0, sHelperPoint);
            sizeW = target.width;
            sizeH = target.height;
        }
        else 
        {
            pos = this.globalToLocal(Starling.current.nativeStage.mouseX,
                            Starling.current.nativeStage.mouseY, sHelperPoint);
        }
        var xx : Float;
        var yy : Float;
        xx = pos.x;
        if (xx + popup.width > this.width) 
            xx = xx + sizeW - popup.width;
        yy = pos.y + sizeH;
        if ((downward == null && yy + popup.height > this.height)
            || downward == false) {
            yy = pos.y - popup.height - 1;
            if (yy < 0) {
                yy = 0;
                xx += sizeW / 2;
            }
        }
        
        popup.x = Int(xx);
        popup.y = Int(yy);
    }
    
    public function togglePopup(popup : GObject, target : GObject = null, downward : Dynamic = null) : Void
    {
        if (Lambda.indexOf(_justClosedPopups, popup) != -1) 
            return;
        
        showPopup(popup, target, downward);
    }
    
    public function hidePopup(popup : GObject = null) : Void
    {
        if (popup != null) 
        {
            var k : Int = Lambda.indexOf(_popupStack, popup);
            if (k != -1) 
            {
                var i : Int = _popupStack.length - 1;
                while (i >= k){
                    var popup : GObject = _popupStack.pop();
                    closePopup(popup);
                    i--;
                }
            }
        }
        else 
        {
            var cnt : Int = _popupStack.length;
            i = cnt - 1;
            while (i >= 0){closePopup(_popupStack[i]);
                i--;
            }
            _popupStack.length = 0;
        }
    }
    
    private function get_hasAnyPopup() : Bool
    {
        return _popupStack.length != 0;
    }
    
    private function closePopup(target : GObject) : Void
    {
        if (target.parent != null) 
        {
            if (Std.is(target, Window)) 
                cast((target), Window).hide()
            else 
            removeChild(target);
        }
    }
    
    public function showTooltips(msg : String) : Void
    {
        if (_defaultTooltipWin == null) 
        {
            var resourceURL : String = UIConfig.tooltipsWin;
            if (resourceURL == null) 
            {
                trace("UIConfig.tooltipsWin not defined");
                return;
            }
            
            _defaultTooltipWin = UIPackage.createObjectFromURL(resourceURL);
        }
        
        _defaultTooltipWin.text = msg;
        showTooltipsWin(_defaultTooltipWin);
    }
    
    public function showTooltipsWin(tooltipWin : GObject, position : Point = null) : Void
    {
        hideTooltips();
        
        _tooltipWin = tooltipWin;
        
        var xx : Int;
        var yy : Int;
        if (position == null) 
        {
            xx = Starling.current.nativeStage.mouseX + 10;
            yy = Starling.current.nativeStage.mouseY + 20;
        }
        else 
        {
            xx = position.x;
            yy = position.y;
        }
        var pt : Point = this.globalToLocal(xx, yy, sHelperPoint);
        xx = pt.x;
        yy = pt.y;
        
        if (xx + _tooltipWin.width > this.width) 
        {
            xx = xx - _tooltipWin.width - 1;
            if (xx < 0) 
                xx = 10;
        }
        if (yy + _tooltipWin.height > this.height) {
            yy = yy - _tooltipWin.height - 1;
            if (xx - _tooltipWin.width - 1 > 0) 
                xx = xx - _tooltipWin.width - 1;
            if (yy < 0) 
                yy = 10;
        }
        
        _tooltipWin.x = xx;
        _tooltipWin.y = yy;
        addChild(_tooltipWin);
    }
    
    public function hideTooltips() : Void
    {
        if (_tooltipWin != null) 
        {
            if (_tooltipWin.parent) 
                removeChild(_tooltipWin);
            _tooltipWin = null;
        }
    }
    
    public function getObjectUnderMouse() : GObject
    {
        return getObjectUnderPoint(Starling.current.nativeStage.mouseX,
                Starling.current.nativeStage.mouseY);
    }
    
    public function getObjectUnderPoint(globalX : Float, globalY : Float) : GObject
    {
        var obj : DisplayObject = Starling.current.stage.hitTest(new Point(globalX, globalY));
        if (obj == null) 
            return null
        else 
        return ToolSet.displayObjectToGObject(obj);
    }
    
    private function get_focus() : GObject
    {
        if (_focusedObject != null && !_focusedObject.onStage) 
            _focusedObject = null;
        
        return _focusedObject;
    }
    
    private function set_focus(value : GObject) : GObject
    {
        if (!_focusManagement) 
            return;
        
        if (value != null && (!value.focusable || !value.onStage)) 
            throw new Error("invalid focus target");
        
        if (_focusedObject != value) 
        {
            var old : GObject;
            if (_focusedObject != null && _focusedObject.onStage) 
                old = _focusedObject;
            _focusedObject = value;
            dispatchEvent(new FocusChangeEvent(FocusChangeEvent.CHANGED, old, value));
        }
        return value;
    }
    
    private function get_volumeScale() : Float
    {
        return _volumeScale;
    }
    
    private function set_volumeScale(value : Float) : Float
    {
        _volumeScale = value;
        return value;
    }
    
    public function playOneShotSound(sound : Sound, volumeScale : Float = 1) : Void
    {
        var vs : Float = _volumeScale * volumeScale;
        if (vs == 1) 
            sound.play()
        else 
        sound.play(0, 0, new SoundTransform(vs));
    }
    
    private function adjustModalLayer() : Void
    {
        var cnt : Int = this.numChildren;
        var modalLayerIsTop : Bool = false;
        
        if (_modalWaitPane != null && _modalWaitPane.parent != null) 
            setChildIndex(_modalWaitPane, cnt - 1);
        
        var i : Int = cnt - 1;
        while (i >= 0){
            var g : GObject = this.getChildAt(i);
            if (g == _modalLayer) 
                modalLayerIsTop = true
            else if ((Std.is(g, Window)) && (try cast(g, Window) catch(e:Dynamic) null).modal) {
                if (_modalLayer.parent == null) 
                    addChildAt(_modalLayer, i)
                else if (i > 0) 
                {
                    if (modalLayerIsTop) 
                        setChildIndex(_modalLayer, i)
                    else 
                    setChildIndex(_modalLayer, i - 1);
                }
                else 
                addChildAt(_modalLayer, 0);
                return;
            }
            i--;
        }
        
        if (_modalLayer.parent != null) 
            removeChild(_modalLayer);
    }
    
    private function __addedToStage(evt : Event) : Void
    {
        displayObject.removeEventListener(Event.ADDED_TO_STAGE, __addedToStage);
        
        _nativeStage = displayObject.stage;
        
        touchScreen = Capabilities.os.toLowerCase().substring(0, 3) != "win" && Capabilities.os.toLowerCase().substring(0, 3) != "mac" && Capabilities.touchscreenType != TouchscreenType.NONE;
        
        if (touchScreen) 
        {
            Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
            touchPointInput = true;
        }
        
        _nativeStage.addEventListener(TouchEvent.TOUCH, __stageTouch);
        
        var stage : openfl.display.Stage = Starling.current.nativeStage;
        stage.addEventListener(MouseEvent.MOUSE_DOWN, __stageMouseDownCapture, true);
        stage.addEventListener(MouseEvent.MOUSE_UP, __stageMouseUpCapture, true);
        stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, __stageMouseDownCapture, true);
        stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, __stageMouseUpCapture, true);
        
        _modalLayer = new GGraph();
        _modalLayer.setSize(this.width, this.height);
        _modalLayer.drawRect(0, 0, 0, UIConfig.modalLayerColor, UIConfig.modalLayerAlpha);
        _modalLayer.addRelation(this, RelationType.Size);
        
        if (Capabilities.os.toLowerCase().substring(0, 3) == "win" || Capabilities.os.toLowerCase().substring(0, 3) == "mac") 
            displayObject.stage.addEventListener(ResizeEvent.RESIZE, __winResize)
        else 
        stage.addEventListener("orientationChange", __orientationChange);
        __winResize(null);
    }
    
    private function __stageTouch(evt : TouchEvent) : Void
    {
        if (evt.touches.length == 0) 
            return;
        
        var touch : Touch = evt.touches[0];
        if (touch.phase == TouchPhase.BEGAN) 
        {
            if (this._focusManagement) 
            {
                //因为starling不支持事件的capture，所以焦点处理是在所有显示对象处理完touch begin之后。
                //也就是说，在touch begin里获取当前焦点对象可能不是最新的
                var mc : DisplayObject = touch.target;
                while (mc != _nativeStage && mc != null){
                    if (Std.is(mc, UIDisplayObject)) 
                    {
                        var gg : GObject = cast((mc), UIDisplayObject).owner;
                        if (gg.touchable && gg.focusable) 
                        {
                            this.focus = gg;
                            break;
                        }
                    }
                    mc = mc.parent;
                }
            }
        }
    }
    
    private static var sHelperPoint : Point = new Point();
    private function __stageMouseDownCapture(evt : MouseEvent) : Void
    {
        ctrlKeyDown = evt.ctrlKey;
        shiftKeyDown = evt.shiftKey;
        buttonDown = true;
        
        if (_tooltipWin != null) 
            hideTooltips();
        
        var cnt : Int = _popupStack.length;
        if (cnt > 0) 
        {
            //这里的evt.target永远是Stage，是得不到实际点击的对象的，所以只能用范围来判断了
            var pt : Point = this.globalToLocal(evt.stageX, evt.stageY, sHelperPoint);
            var thisX : Float = pt.x;
            var thisY : Float = pt.y;
            var handled : Bool = false;
            var i : Int = cnt - 1;
            while (i >= 0){
                var popup : GObject = _popupStack[i];
                if (thisX >= popup.x && thisY >= popup.y && thisX < popup.x + popup.actualWidth && thisY < popup.y + popup.actualHeight) 
                {
                    var j : Int = cnt - 1;
                    while (j > i){
                        popup = _popupStack.pop();
                        closePopup(popup);
                        j--;
                    }
                    handled = true;
                    break;
                }
                i--;
            }
            
            if (!handled) 
            {
                cnt = _popupStack.length;
                i = cnt - 1;
                while (i >= 0){
                    popup = _popupStack[i];
                    closePopup(popup);
                    i--;
                }
                _popupStack.length = 0;
            }
        }
    }
    
    private function __stageMouseUpCapture(evt : MouseEvent) : Void
    {
        buttonDown = false;
    }
    
    private function __winResize(evt : Event) : Void
    {
        var w : Int;
        var h : Int;
        if (Capabilities.os.toLowerCase().substring(0, 3) == "win" || Capabilities.os.toLowerCase().substring(0, 3) == "mac") 
        {
            w = _nativeStage.stageWidth;
            h = _nativeStage.stageHeight;
        }
        else 
        {
            w = Capabilities.screenResolutionX;
            h = Capabilities.screenResolutionY;
        }
        this.setSize(Math.round(w / contentScaleFactor), Math.round(h / contentScaleFactor));
        
        trace("screen size=" + w + "x" + h + "/" + this.width + "x" + this.height);
    }
    
    private function __orientationChange(evt : Event) : Void
    {
        __winResize(null);
    }
}


