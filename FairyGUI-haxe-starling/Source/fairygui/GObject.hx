package fairygui;

import starling.utils.StarlingUtils;
import fairygui.Controller;
import fairygui.GButton;
import fairygui.GComboBox;
import fairygui.GComponent;
import fairygui.GGraph;
import fairygui.GGroup;
import fairygui.GLabel;
import fairygui.GList;
import fairygui.GLoader;
import fairygui.GMovieClip;
import fairygui.GProgressBar;
import fairygui.GRichTextField;
import fairygui.GRoot;
import fairygui.GSlider;
import fairygui.GTextField;
import fairygui.GTextInput;
import fairygui.GearDisplay;
import fairygui.GearLook;
import fairygui.GearSize;
import fairygui.GearXY;
import fairygui.PackageItem;
import fairygui.Relations;

import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.text.TextField;
import openfl.text.TextFieldType;
import openfl.ui.Mouse;


import fairygui.event.DragEvent;
import fairygui.event.GTouchEvent;
import fairygui.utils.GTimers;
import fairygui.utils.SimpleDispatcher;
import fairygui.utils.ToolSet;

import starling.core.Starling;
import starling.display.DisplayObject;
import starling.events.Event;
import starling.events.EventDispatcher;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.filters.ColorMatrixFilter;

import starling.utils.StarlingUtils;

import haxe.xml.Fast;

@:meta(Event(name="startDrag",type="fairygui.event.DragEvent"))

@:meta(Event(name="endDrag",type="fairygui.event.DragEvent"))

@:meta(Event(name="beginGTouch",type="fairygui.event.GTouchEvent"))

@:meta(Event(name="endGTouch",type="fairygui.event.GTouchEvent"))

@:meta(Event(name="dragGTouch",type="fairygui.event.GTouchEvent"))

@:meta(Event(name="clickGTouch",type="fairygui.event.GTouchEvent"))

@:meta(Event(name="rollOverGTouch",type="fairygui.event.GTouchEvent"))

@:meta(Event(name="rollOutGTouch",type="fairygui.event.GTouchEvent"))

class GObject extends EventDispatcher
{
    public var id(get, never) : String;
    public var name(get, set) : String;
    public var x(get, set) : Float;
    public var y(get, set) : Float;
    public var width(get, set) : Float;
    public var height(get, set) : Float;
    public var sourceHeight(get, never) : Int;
    public var sourceWidth(get, never) : Int;
    public var initHeight(get, never) : Int;
    public var initWidth(get, never) : Int;
    public var actualWidth(get, never) : Float;
    public var actualHeight(get, never) : Float;
    public var scaleX(get, set) : Float;
    public var scaleY(get, set) : Float;
    public var pivotX(get, set) : Int;
    public var pivotY(get, set) : Int;
    public var touchable(get, set) : Bool;
    public var grayed(get, set) : Bool;
    public var enabled(get, set) : Bool;
    public var rotation(get, set) : Int;
    public var normalizeRotation(get, never) : Int;
    public var alpha(get, set) : Float;
    public var visible(get, set) : Bool;
    private var internalVisible(get, set) : Int;
    public var finalVisible(get, never) : Bool;
    public var sortingOrder(get, set) : Int;
    public var focusable(get, set) : Bool;
    public var focused(get, never) : Bool;
    public var tooltips(get, set) : String;
    public var inContainer(get, never) : Bool;
    public var onStage(get, never) : Bool;
    public var resourceURL(get, never) : String;
    public var group(get, set) : GGroup;
    public var gearDisplay(get, never) : GearDisplay;
    public var gearXY(get, never) : GearXY;
    public var gearSize(get, never) : GearSize;
    public var gearLook(get, never) : GearLook;
    public var relations(get, never) : Relations;
    public var displayObject(get, never) : DisplayObject;
    public var parent(get, set) : GComponent;
    public var root(get, never) : GRoot;
    public var asCom(get, never) : GComponent;
    public var asButton(get, never) : GButton;
    public var asLabel(get, never) : GLabel;
    public var asProgress(get, never) : GProgressBar;
    public var asTextField(get, never) : GTextField;
    public var asRichTextField(get, never) : GRichTextField;
    public var asTextInput(get, never) : GTextInput;
    public var asLoader(get, never) : GLoader;
    public var asList(get, never) : GList;
    public var asGraph(get, never) : GGraph;
    public var asGroup(get, never) : GGroup;
    public var asSlider(get, never) : GSlider;
    public var asComboBox(get, never) : GComboBox;
    public var asMovieClip(get, never) : GMovieClip;
    public var text(get, set) : String;
    public var draggable(get, set) : Bool;
    public var dragBounds(get, set) : Rectangle;
    public var dragging(get, never) : Bool;
    public var isDown(get, never) : Bool;

    public var data : Dynamic;
    
    private var _x : Float;
    private var _y : Float;
    private var _width : Float;
    private var _height : Float;
    private var _pivotX : Int;
    private var _pivotY : Int;
    private var _alpha : Float;
    private var _rotation : Int;
    private var _visible : Bool;
    private var _touchable : Bool;
    private var _grayed : Bool;
    private var _draggable : Bool;
    private var _scaleX : Float;
    private var _scaleY : Float;
    private var _pivotOffsetX : Float;
    private var _pivotOffsetY : Float;
    private var _sortingOrder : Int;
    private var _internalVisible : Int;
    private var _focusable : Bool;
    private var _tooltips : String;
    
    private var _relations : Relations;
    private var _group : GGroup;
    private var _gearDisplay : GearDisplay;
    private var _gearXY : GearXY;
    private var _gearSize : GearSize;
    private var _gearLook : GearLook;
    private var _displayObject : DisplayObject;
    private var _dragBounds : Rectangle;
    
    @:allow(fairygui)
    private var _parent : GComponent;
    @:allow(fairygui)
    private var _dispatcher : SimpleDispatcher;
    @:allow(fairygui)
    private var _rawWidth : Float;
    @:allow(fairygui)
    private var _rawHeight : Float;
    @:allow(fairygui)
    private var _sourceWidth : Int;
    @:allow(fairygui)
    private var _sourceHeight : Int;
    @:allow(fairygui)
    private var _initWidth : Int;
    @:allow(fairygui)
    private var _initHeight : Int;
    @:allow(fairygui)
    private var _id : String;
    @:allow(fairygui)
    private var _name : String;
    @:allow(fairygui)
    private var _packageItem : PackageItem;
    @:allow(fairygui)
    private var _underConstruct : Bool;
    @:allow(fairygui)
    private var _constructingData : Fast;
    @:allow(fairygui)
    private var _gearLocked : Bool;
    
    @:allow(fairygui)
    private static var _gInstanceCounter : Int;
    
    @:allow(fairygui)
    private static inline var XY_CHANGED : Int = 1;
    @:allow(fairygui)
    private static inline var SIZE_CHANGED : Int = 2;
    @:allow(fairygui)
    private static inline var SIZE_DELAY_CHANGE : Int = 3;
    
    public function new()
    {
        super();
        _x = 0;
        _y = 0;
        _width = 0;
        _height = 0;
        _rawWidth = 0;
        _rawHeight = 0;
        _id = "_n" + _gInstanceCounter++;
        _name = "";
        _alpha = 1;
        _rotation = 0;
        _visible = true;
        _internalVisible = 1;
        _touchable = true;
        _scaleX = 1;
        _scaleY = 1;
        _pivotOffsetX = 0;
        _pivotOffsetY = 0;
        
        createDisplayObject();
        
        _relations = new Relations(this);
        _dispatcher = new SimpleDispatcher();
        
        _gearDisplay = new GearDisplay(this);
        _gearXY = new GearXY(this);
        _gearSize = new GearSize(this);
        _gearLook = new GearLook(this);
    }
    
    @:final private function get_id() : String
    {
        return _id;
    }
    
    @:final private function get_name() : String
    {
        return _name;
    }
    
    @:final private function set_name(value : String) : String
    {
        _name = value;
        return value;
    }
    
    @:final private function get_x() : Float
    {
        return _x;
    }
    
    @:final private function set_x(value : Float) : Float
    {
        setXY(value, _y);
        return value;
    }
    
    @:final private function get_y() : Float
    {
        return _y;
    }
    
    @:final private function set_y(value : Float) : Float
    {
        setXY(_x, value);
        return value;
    }
    
    @:final public function setXY(xv : Float, yv : Float) : Void
    {
        if (_x != xv || _y != yv) 
        {
            var dx : Float = xv - _x;
            var dy : Float = yv - _y;
            _x = xv;
            _y = yv;
            
            handleXYChanged();
            if (Std.is(this, GGroup)) 
                cast((this), GGroup).moveChildren(dx, dy);
            
            if (_gearXY.controller) 
                _gearXY.updateState();
            
            if (parent != null && !(Std.is(parent, GList))) 
            {
                _parent.setBoundsChangedFlag();
                _dispatcher.dispatch(this, XY_CHANGED);
            }
        }
    }
    
    public function center(restraint : Bool = false) : Void
    {
        var r : GComponent;
        if (parent != null) 
            r = parent
        else 
        {
            r = this.root;
            if (r == null) 
                r = GRoot.inst;
        }
        
        this.setXY(Int((r.width - this.width) / 2), Int((r.height - this.height) / 2));
        if (restraint) 
        {
            this.addRelation(r, RelationType.Center_Center);
            this.addRelation(r, RelationType.Middle_Middle);
        }
    }
    
    @:final private function get_width() : Float
    {
        ensureSizeCorrect();
        if (_relations.sizeDirty) 
            _relations.ensureRelationsSizeCorrect();
        return _width;
    }
    
    @:final private function set_width(value : Float) : Float
    {
        setSize(value, _rawHeight);
        return value;
    }
    
    @:final private function get_height() : Float
    {
        ensureSizeCorrect();
        if (_relations.sizeDirty) 
            _relations.ensureRelationsSizeCorrect();
        return _height;
    }
    
    @:final private function set_height(value : Float) : Float
    {
        setSize(_rawWidth, value);
        return value;
    }
    
    public function setSize(wv : Float, hv : Float, ignorePivot : Bool = false) : Void
    {
        if (_rawWidth != wv || _rawHeight != hv) 
        {
            _rawWidth = wv;
            _rawHeight = hv;
            if (wv < 0) 
                wv = 0;
            if (hv < 0) 
                hv = 0;
            var dWidth : Float = wv - _width;
            var dHeight : Float = hv - _height;
            _width = wv;
            _height = hv;
            
            if ((_pivotX != 0 || _pivotY != 0) && sourceWidth != 0 && sourceHeight != 0) 
            {
                if (!ignorePivot) 
                    this.setXY(this.x - _pivotX * dWidth / sourceWidth,
                        this.y - _pivotY * dHeight / sourceHeight);
                applyPivot();
            }
            
            handleSizeChanged();
            
            if (_gearSize.controller) 
                _gearSize.updateState();
            
            if (_parent != null) 
            {
                _relations.onOwnerSizeChanged(dWidth, dHeight);
                _parent.setBoundsChangedFlag();
            }
            
            _dispatcher.dispatch(this, SIZE_CHANGED);
        }
    }
    
    public function ensureSizeCorrect() : Void
    {
        
    }
    
    @:final private function get_sourceHeight() : Int
    {
        return _sourceHeight;
    }
    
    @:final private function get_sourceWidth() : Int
    {
        return _sourceWidth;
    }
    
    @:final private function get_initHeight() : Int
    {
        return _initHeight;
    }
    
    @:final private function get_initWidth() : Int
    {
        return _initWidth;
    }
    
    @:final private function get_actualWidth() : Float
    {
        return this.width * _scaleX;
    }
    
    @:final private function get_actualHeight() : Float
    {
        return this.height * _scaleY;
    }
    
    @:final private function get_scaleX() : Float
    {
        return _scaleX;
    }
    
    @:final private function set_scaleX(value : Float) : Float
    {
        setScale(value, _scaleY);
        return value;
    }
    
    @:final private function get_scaleY() : Float
    {
        return _scaleY;
    }
    
    @:final private function set_scaleY(value : Float) : Float
    {
        setScale(_scaleX, value);
        return value;
    }
    
    @:final public function setScale(sx : Float, sy : Float) : Void
    {
        if (_scaleX != sx || _scaleY != sy) 
        {
            _scaleX = sx;
            _scaleY = sy;
            applyPivot();
            handleSizeChanged();
            
            if (_gearSize.controller) 
                _gearSize.updateState();
        }
    }
    
    @:final private function get_pivotX() : Int
    {
        return _pivotX;
    }
    
    @:final private function set_pivotX(value : Int) : Int
    {
        setPivot(value, _pivotY);
        return value;
    }
    
    @:final private function get_pivotY() : Int
    {
        return _pivotY;
    }
    
    @:final private function set_pivotY(value : Int) : Int
    {
        setPivot(_pivotX, value);
        return value;
    }
    
    @:final public function setPivot(xv : Int, yv : Int) : Void
    {
        if (_pivotX != xv || _pivotY != yv) 
        {
            _pivotX = xv;
            _pivotY = yv;
            
            applyPivot();
        }
    }
    
    private function applyPivot() : Void
    {
        var ox : Float = _pivotOffsetX;
        var oy : Float = _pivotOffsetY;
        if (_pivotX != 0 || _pivotY != 0) 
        {
            var rot : Int = this.normalizeRotation;
            if (rot != 0 || _scaleX != 1 || _scaleY != 1) 
            {
                var rotInRad : Float = rot * Math.PI / 180;
                var cos : Float = Math.cos(rotInRad);
                var sin : Float = Math.sin(rotInRad);
                var a : Float = _scaleX * cos;
                var b : Float = _scaleX * sin;
                var c : Float = _scaleY * -sin;
                var d : Float = _scaleY * cos;
                var sx : Float = sourceWidth != (0) ? (_width / sourceWidth) : 1;
                var sy : Float = sourceHeight != (0) ? (_height / sourceHeight) : 1;
                var px : Float = _pivotX * sx;
                var py : Float = _pivotY * sy;
                _pivotOffsetX = px - (a * px + c * py);
                _pivotOffsetY = py - (d * py + b * px);
            }
            else 
            {
                _pivotOffsetX = 0;
                _pivotOffsetY = 0;
            }
        }
        else 
        {
            _pivotOffsetX = 0;
            _pivotOffsetY = 0;
        }
        if (ox != _pivotOffsetX || oy != _pivotOffsetY) 
            handleXYChanged();
    }
    
    @:final private function get_touchable() : Bool
    {
        return _touchable;
    }
    
    private function set_touchable(value : Bool) : Bool
    {
        _touchable = value;
        if ((Std.is(this, GImage)) || (Std.is(this, GMovieClip)) || (Std.is(this, GTextField)) && !(Std.is(this, GTextInput)) && !(Std.is(this, GRichTextField))) 
            //Touch is not supported by GImage/GMovieClip/GTextField
        return;
        
        if (_displayObject != null) 
            _displayObject.touchable = _touchable;
        return value;
    }
    
    @:final private function get_grayed() : Bool
    {
        return _grayed;
    }
    
    private function set_grayed(value : Bool) : Bool
    {
        if (_grayed != value) 
        {
            _grayed = value;
            handleGrayChanged();
            
            if (_gearLook.controller) 
                _gearLook.updateState();
        }
        return value;
    }
    
    @:final private function get_enabled() : Bool
    {
        return !_grayed && _touchable;
    }
    
    private function set_enabled(value : Bool) : Bool
    {
        this.grayed = !value;
        this.touchable = value;
        return value;
    }
    
    @:final private function get_rotation() : Int
    {
        return _rotation;
    }
    
    private function set_rotation(value : Int) : Int
    {
        if (_rotation != value) 
        {
            _rotation = value;
            applyPivot();
            if (_displayObject != null) 
                _displayObject.rotation = StarlingUtils.deg2rad(this.normalizeRotation);
            
            if (_gearLook.controller) 
                _gearLook.updateState();
        }
        return value;
    }
    
    private function get_normalizeRotation() : Int
    {
        var rot : Int = _rotation % 360;
        if (rot > 180) 
            rot = rot - 360
        else if (rot < -180) 
            rot = 360 + rot;
        return rot;
    }
    
    @:final private function get_alpha() : Float
    {
        return _alpha;
    }
    
    private function set_alpha(value : Float) : Float
    {
        if (_alpha != value) 
        {
            _alpha = value;
            if (_displayObject != null) 
                _displayObject.alpha = _alpha;
            
            if (_gearLook.controller) 
                _gearLook.updateState();
        }
        return value;
    }
    
    @:final private function get_visible() : Bool
    {
        return _visible;
    }
    
    private function set_visible(value : Bool) : Bool
    {
        if (_visible != value) 
        {
            _visible = value;
            if (_displayObject != null) 
                _displayObject.visible = _visible;
            if (_parent != null) 
                _parent.childStateChanged(this);
        }
        return value;
    }
    
    @:allow(fairygui)
    private function set_internalVisible(value : Int) : Int
    {
        if (value < 0) 
            value = 0;
        var oldValue : Bool = _internalVisible > 0;
        var newValue : Bool = value > 0;
        _internalVisible = value;
        if (oldValue != newValue) 
        {
            if (_parent != null) 
                _parent.childStateChanged(this);
        }
        return value;
    }
    
    @:allow(fairygui)
    private function get_internalVisible() : Int
    {
        return _internalVisible;
    }
    
    private function get_finalVisible() : Bool
    {
        return _visible && _internalVisible > 0 && (!_group || _group.finalVisible);
    }
    
    @:final private function get_sortingOrder() : Int
    {
        return _sortingOrder;
    }
    
    private function set_sortingOrder(value : Int) : Int
    {
        if (value < 0) 
            value = 0;
        if (_sortingOrder != value) 
        {
            var old : Int = _sortingOrder;
            _sortingOrder = value;
            if (_parent != null) 
                _parent.childSortingOrderChanged(this, old, _sortingOrder);
        }
        return value;
    }
    
    @:final private function get_focusable() : Bool
    {
        return _focusable;
    }
    
    private function set_focusable(value : Bool) : Bool
    {
        _focusable = value;
        return value;
    }
    
    private function get_focused() : Bool
    {
        var r : GRoot = this.root;
        if (r != null) 
            return r.focus == this
        else 
        return false;
    }
    
    public function requestFocus() : Void
    {
        var r : GRoot = this.root;
        if (r != null) 
        {
            var p : GObject = this;
            while (p && !p._focusable)
            p = p.parent;
            if (p != null) 
                r.focus = p;
        }
    }
    
    @:final private function get_tooltips() : String
    {
        return _tooltips;
    }
    
    private function set_tooltips(value : String) : String
    {
        if (_tooltips != null && Mouse.supportsCursor) 
        {
            this.removeEventListener(GTouchEvent.ROLL_OVER, __rollOver);
            this.removeEventListener(GTouchEvent.ROLL_OUT, __rollOut);
        }
        
        _tooltips = value;
        if (_tooltips != null && Mouse.supportsCursor)
        {
            this.addEventListener(GTouchEvent.ROLL_OVER, __rollOver);
            this.addEventListener(GTouchEvent.ROLL_OUT, __rollOut);
        }
        return value;
    }
    
    private function __rollOver(evt : GTouchEvent) : Void
    {
        var r : GRoot = this.root;
        if (r != null) 
            GTimers.inst.callDelay(100, __doShowTooltips, r);
    }
    
    private function __doShowTooltips(r : GRoot) : Void
    {
        r.showTooltips(_tooltips);
    }
    
    private function __rollOut(evt : GTouchEvent) : Void
    {
        var r : GRoot = this.root;
        if (r != null) 
        {
            GTimers.inst.remove(__doShowTooltips);
            r.hideTooltips();
        }
    }
    
    @:final private function get_inContainer() : Bool
    {
        return _displayObject != null && _displayObject.parent != null;
    }
    
    @:final private function get_onStage() : Bool
    {
        return _displayObject != null && _displayObject.stage != null;
    }
    
    @:final private function get_resourceURL() : String
    {
        if (_packageItem != null) 
            return "ui://" + _packageItem.owner.id + _packageItem.id
        else 
        return null;
    }
    
    @:final private function set_group(value : GGroup) : GGroup
    {
        _group = value;
        return value;
    }
    
    @:final private function get_group() : GGroup
    {
        return _group;
    }
    
    @:final private function get_gearDisplay() : GearDisplay
    {
        return _gearDisplay;
    }
    
    @:final private function get_gearXY() : GearXY
    {
        return _gearXY;
    }
    
    @:final private function get_gearSize() : GearSize
    {
        return _gearSize;
    }
    
    @:final private function get_gearLook() : GearLook
    {
        return _gearLook;
    }
    
    @:final private function get_relations() : Relations
    {
        return _relations;
    }
    
    @:final public function addRelation(target : GObject, relationType : Int, usePercent : Bool = false) : Void
    {
        _relations.add(target, relationType, usePercent);
    }
    
    @:final public function removeRelation(target : GObject, relationType : Int) : Void
    {
        _relations.remove(target, relationType);
    }
    
    @:final private function get_displayObject() : DisplayObject
    {
        return _displayObject;
    }
    
    @:final private function setDisplayObject(value : DisplayObject) : Void
    {
        _displayObject = value;
    }
    
    @:final private function get_parent() : GComponent
    {
        return _parent;
    }
    
    @:final private function set_parent(val : GComponent) : GComponent
    {
        _parent = val;
        return val;
    }
    
    @:final public function removeFromParent() : Void
    {
        if (_parent != null) 
            _parent.removeChild(this);
    }
    
    private function get_root() : GRoot
    {
        var p : GObject = _parent;
        while (p)
        {
            if (Std.is(p, GRoot)) 
                return cast((p), GRoot);
            p = p.parent;
        }
        return GRoot.inst;
    }
    
    @:final private function get_asCom() : GComponent
    {
        return try cast(this, GComponent) catch(e:Dynamic) null;
    }
    
    @:final private function get_asButton() : GButton
    {
        return try cast(this, GButton) catch(e:Dynamic) null;
    }
    
    @:final private function get_asLabel() : GLabel
    {
        return try cast(this, GLabel) catch(e:Dynamic) null;
    }
    
    @:final private function get_asProgress() : GProgressBar
    {
        return try cast(this, GProgressBar) catch(e:Dynamic) null;
    }
    
    @:final private function get_asTextField() : GTextField
    {
        return try cast(this, GTextField) catch(e:Dynamic) null;
    }
    
    @:final private function get_asRichTextField() : GRichTextField
    {
        return try cast(this, GRichTextField) catch(e:Dynamic) null;
    }
    
    @:final private function get_asTextInput() : GTextInput
    {
        return try cast(this, GTextInput) catch(e:Dynamic) null;
    }
    
    @:final private function get_asLoader() : GLoader
    {
        return try cast(this, GLoader) catch(e:Dynamic) null;
    }
    
    @:final private function get_asList() : GList
    {
        return try cast(this, GList) catch(e:Dynamic) null;
    }
    
    @:final private function get_asGraph() : GGraph
    {
        return try cast(this, GGraph) catch(e:Dynamic) null;
    }
    
    @:final private function get_asGroup() : GGroup
    {
        return try cast(this, GGroup) catch(e:Dynamic) null;
    }
    
    @:final private function get_asSlider() : GSlider
    {
        return try cast(this, GSlider) catch(e:Dynamic) null;
    }
    
    @:final private function get_asComboBox() : GComboBox
    {
        return try cast(this, GComboBox) catch(e:Dynamic) null;
    }
    
    @:final private function get_asMovieClip() : GMovieClip
    {
        return try cast(this, GMovieClip) catch(e:Dynamic) null;
    }
    
    private function get_text() : String
    {
        return null;
    }
    
    private function set_text(value : String) : String
    {
        
        return value;
    }
    
    public function dispose() : Void
    {
        _relations.dispose();
        if (_displayObject != null) 
        {
            _displayObject.dispose();
            _displayObject = null;
        }
    }
    
    public function addClickListener(listener : Dynamic) : Void
    {
        addEventListener(GTouchEvent.CLICK, listener);
    }
    
    public function removeClickListener(listener : Dynamic) : Void
    {
        removeEventListener(GTouchEvent.CLICK, listener);
    }
    
    public function hasClickListener() : Bool
    {
        return hasEventListener(GTouchEvent.CLICK);
    }
    
    public function addXYChangeCallback(listener : Dynamic) : Void
    {
        _dispatcher.addListener(XY_CHANGED, listener);
    }
    
    public function addSizeChangeCallback(listener : Dynamic) : Void
    {
        _dispatcher.addListener(SIZE_CHANGED, listener);
    }
    
    @:allow(fairygui)
    private function addSizeDelayChangeCallback(listener : Dynamic) : Void
    {
        _dispatcher.addListener(SIZE_DELAY_CHANGE, listener);
    }
    
    public function removeXYChangeCallback(listener : Dynamic) : Void
    {
        _dispatcher.removeListener(XY_CHANGED, listener);
    }
    
    public function removeSizeChangeCallback(listener : Dynamic) : Void
    {
        _dispatcher.removeListener(SIZE_CHANGED, listener);
    }
    
    @:allow(fairygui)
    private function removeSizeDelayChangeCallback(listener : Dynamic) : Void
    {
        _dispatcher.removeListener(SIZE_DELAY_CHANGE, listener);
    }
    
    override public function addEventListener(type : String, listener : Dynamic) : Void
    {
        super.addEventListener(type, listener);
        
        if (_displayObject != null) 
        {
            if (MTOUCH_EVENTS.indexOf(type) != -1) 
                initMTouch()
            else 
            _displayObject.addEventListener(type, _reDispatch);
        }
    }
    
    override public function removeEventListener(type : String, listener : Dynamic) : Void
    {
        super.removeEventListener(type, listener);
        
        if (_displayObject != null && !this.hasEventListener(type)) 
        {
            _displayObject.removeEventListener(type, _reDispatch);
        }
    }
    
    private function _reDispatch(evt : Event) : Void
    {
        this.dispatchEvent(evt);
    }
    
    @:final private function get_draggable() : Bool
    {
        return _draggable;
    }
    
    @:final private function set_draggable(value : Bool) : Bool
    {
        if (_draggable != value) 
        {
            _draggable = value;
            initDrag();
        }
        return value;
    }
    
    @:final private function get_dragBounds() : Rectangle
    {
        return _dragBounds;
    }
    
    @:final private function set_dragBounds(value : Rectangle) : Rectangle
    {
        _dragBounds = value;
        return value;
    }
    
    public function startDrag(touchPointID : Int = -1) : Void
    {
        if (_displayObject.stage == null) 
            return;
        
        dragBegin(null);
        triggerDown(touchPointID);
    }
    
    public function stopDrag() : Void
    {
        dragEnd();
    }
    
    private function get_dragging() : Bool
    {
        return sDragging == this;
    }
    
    public function localToGlobal(ax : Float = 0, ay : Float = 0, resultPonit : Point = null) : Point
    {
        sHelperPoint.x = ax;
        sHelperPoint.y = ay;
        return _displayObject.localToGlobal(sHelperPoint, resultPonit);
    }
    
    public function globalToLocal(ax : Float = 0, ay : Float = 0, resultPonit : Point = null) : Point
    {
        sHelperPoint.x = ax;
        sHelperPoint.y = ay;
        return _displayObject.globalToLocal(sHelperPoint, resultPonit);
    }
    
    public function localToRoot(ax : Float = 0, ay : Float = 0, resultPoint : Point = null) : Point
    {
        sHelperPoint.x = ax;
        sHelperPoint.y = ay;
        var pt : Point = _displayObject.localToGlobal(sHelperPoint, resultPoint);
        pt.x /= GRoot.contentScaleFactor;
        pt.y /= GRoot.contentScaleFactor;
        return pt;
    }
    
    public function rootToLocal(ax : Float = 0, ay : Float = 0, resultPoint : Point = null) : Point
    {
        sHelperPoint.x = ax;
        sHelperPoint.y = ay;
        sHelperPoint.x *= GRoot.contentScaleFactor;
        sHelperPoint.y *= GRoot.contentScaleFactor;
        return _displayObject.globalToLocal(sHelperPoint, resultPoint);
    }
    
    public function localToGlobalRect(ax : Float = 0, ay : Float = 0, aWidth : Float = 0, aHeight : Float = 0,
            resultRect : Rectangle = null) : Rectangle
    {
        if (resultRect == null) 
            resultRect = new Rectangle();
        var pt : Point = this.localToGlobal(ax, ay);
        resultRect.x = pt.x;
        resultRect.y = pt.y;
        pt = this.localToGlobal(ax + aWidth, ay + aHeight);
        resultRect.right = pt.x;
        resultRect.bottom = pt.y;
        return resultRect;
    }
    
    public function globalToLocalRect(ax : Float = 0, ay : Float = 0, aWidth : Float = 0, aHeight : Float = 0,
            resultRect : Rectangle = null) : Rectangle
    {
        if (resultRect == null) 
            resultRect = new Rectangle();
        var pt : Point = this.globalToLocal(ax, ay);
        resultRect.x = pt.x;
        resultRect.y = pt.y;
        pt = this.globalToLocal(ax + aWidth, ay + aHeight);
        resultRect.right = pt.x;
        resultRect.bottom = pt.y;
        return resultRect;
    }
    
    private function createDisplayObject() : Void
    {
        
        
    }
    
    private function handleXYChanged() : Void
    {
        if (_displayObject != null) 
        {
            _displayObject.x = Int(_x + _pivotOffsetX);
            _displayObject.y = Int(_y + _pivotOffsetY);
        }
    }
    
    private function handleSizeChanged() : Void
    {
        
    }
    
    public function handleControllerChanged(c : Controller) : Void
    {
        if (_gearDisplay.controller == c) 
            _gearDisplay.apply();
        if (_gearXY.controller == c) 
            _gearXY.apply();
        if (_gearSize.controller == c) 
            _gearSize.apply();
        if (_gearLook.controller == c) 
            _gearLook.apply();
    }
    
    private function handleGrayChanged() : Void
    {
        if (_displayObject != null) 
        {
            if (_displayObject.filter != null) 
                _displayObject.filter.dispose();
            
            if (_grayed) 
                _displayObject.filter = new ColorMatrixFilter(ToolSet.GRAY_FILTERS_MATRIX)
            else 
            _displayObject.filter = null;
        }
    }
    
    public function constructFromResource(pkgItem : PackageItem) : Void
    {
        _packageItem = pkgItem;
    }
    
    public function setup_beforeAdd(xml : Fast) : Void
    {
        var str : String;
        var arr : Array<Dynamic>;
        
        _id = xml.att.id;
        _name = xml.att.name;
        
        str = xml.att.xy;
        arr = str.split(",");
        this.setXY(Int(arr[0]), Int(arr[1]));
        
        str = xml.att.size;
        if (str != null) 
        {
            arr = str.split(",");
            _initWidth = Int(arr[0]);
            _initHeight = Int(arr[1]);
            setSize(_initWidth, _initHeight);
        }
        
        str = xml.att.scale;
        if (str != null) 
        {
            arr = str.split(",");
            setScale(Std.parseFloat(arr[0]), Std.parseFloat(arr[1]));
        }
        
        str = xml.att.rotation;
        if (str != null) 
            this.rotation = parseInt(str);
        
        str = xml.att.alpha;
        if (str != null) 
            this.alpha = Std.parseFloat(str);
        
        str = xml.att.pivot;
        if (str != null) 
        {
            arr = str.split(",");
            this.setPivot(Int(arr[0]), Int(arr[1]));
        }
        
        this.touchable = xml.att.touchable != "false";
        this.visible = xml.att.visible != "false";
        this.grayed = xml.att.grayed == "true";
        this.tooltips = xml.att.tooltips;
    }
    
    public function setup_afterAdd(xml : Fast) : Void
    {
        var cxml : Fast;
        
        var s : String = xml.att.group;
        if (s != null) 
            _group = try cast(_parent.getChildById(s), GGroup) catch(e:Dynamic) null;
        
        cxml = xml.nodes.gearDisplay.get(0);
        if (cxml != null) 
            _gearDisplay.setup(cxml);
        
        cxml = xml.nodes.gearXY.get(0);
        if (cxml != null) 
            _gearXY.setup(cxml);
        
        cxml = xml.nodes.gearSize.get(0);
        if (cxml != null) 
            _gearSize.setup(cxml);
        
        cxml = xml.nodes.gearLook.get(0);
        if (cxml != null) 
            _gearLook.setup(cxml);
    }
    
    //touch support
    //-------------------------------------------------------------------
    private var _touchPointId : Int;
    private var _lastClick : Int;
    private var _buttonStatus : Int;
    private var _rollOver : Bool;
    private static var sHelperPoint : Point = new Point();
    private static var MTOUCH_EVENTS : Array<Dynamic> = 
        [GTouchEvent.BEGIN, GTouchEvent.DRAG, GTouchEvent.END, GTouchEvent.CLICK, 
        GTouchEvent.ROLL_OVER, GTouchEvent.ROLL_OUT];
    
    private function get_isDown() : Bool
    {
        return _buttonStatus == 1;
    }
    
    public function triggerDown(touchPointID : Int = -1) : Void
    {
        _buttonStatus = 1;
        _touchPointId = touchPointID;
        
        _displayObject.stage.addEventListener(TouchEvent.TOUCH, __stageTouch);
    }
    
    private function initMTouch() : Void
    {
        _displayObject.addEventListener(TouchEvent.TOUCH, __touch);
    }
    
    private function __stageTouch(evt : TouchEvent) : Void
    {
        var touch : Touch = evt.getTouch(_displayObject.stage);
        if (touch != null) 
        {
            if (touch.phase == TouchPhase.MOVED) 
            {
                if (_buttonStatus == 0 || GRoot.touchPointInput && _touchPointId != touch.id) 
                    return;
                
                var devt : GTouchEvent = new GTouchEvent(GTouchEvent.DRAG);
                devt.copyFrom(evt, touch);
                this.dispatchEvent(devt);
                if (devt.isPropagationStop) 
                    evt.stopPropagation();
            }
            else if (touch.phase == TouchPhase.ENDED) 
            {
                _displayObject.stage.removeEventListener(TouchEvent.TOUCH, __stageTouch);
                handleEnded(evt, touch);
            }
        }
    }
    
    private function __touch(evt : TouchEvent) : Void
    {
        var touch : Touch = evt.getTouch(displayObject);
        var devt : GTouchEvent;
        if (touch == null) 
        {
            if (_rollOver) 
            {
                _rollOver = false;
                devt = new GTouchEvent(GTouchEvent.ROLL_OUT);
                devt.copyFrom(evt, touch);
                this.dispatchEvent(devt);
            }
        }
        else if (touch.phase == TouchPhase.BEGAN) 
        {
            devt = new GTouchEvent(GTouchEvent.BEGIN);
            devt.copyFrom(evt, touch);
            this.dispatchEvent(devt);
            if (devt.isPropagationStop) 
                evt.stopPropagation();
            
            triggerDown(touch.id);
        }
        else if (touch.phase == TouchPhase.ENDED) 
        {
            handleEnded(evt, touch);
        }
        else if (touch.phase == TouchPhase.HOVER) 
        {
            if (!_rollOver) 
            {
                _rollOver = true;
                devt = new GTouchEvent(GTouchEvent.ROLL_OVER);
                devt.copyFrom(evt, touch);
                this.dispatchEvent(devt);
            }
        }
    }
    
    private function handleEnded(evt : TouchEvent, touch : Touch) : Void
    {
        if (_buttonStatus == 0 || GRoot.touchPointInput && _touchPointId != touch.id) 
            return;
        var devt : GTouchEvent
        if (_buttonStatus == 1) 
        {
            var cc : Int = 1;
            var now : Int = Math.round(haxe.Timer.stamp() * 1000);
            if (now - _lastClick < 500) 
            {
                cc = 2;
                _lastClick = 0;
            }
            else 
            _lastClick = now;

            devt = new GTouchEvent(GTouchEvent.CLICK);
            devt.copyFrom(evt, touch, cc);
            
            this.dispatchEvent(devt);
        }
        
        _buttonStatus = 0;
        
        devt = new GTouchEvent(GTouchEvent.END);
        devt.copyFrom(evt, touch);
        this.dispatchEvent(devt);
    }
    
    @:allow(fairygui)
    private function cancelChildrenClickEvent() : Void
    {
        var cnt : Int = cast((this), GComponent).numChildren;
        for (i in 0...cnt){
            var child : GObject = cast((this), GComponent).getChildAt(i);
            child._buttonStatus = 2;
            if (Std.is(child, GComponent)) 
                child.cancelChildrenClickEvent();
        }
    }
    //-------------------------------------------------------------------
    
    //drag support
    //-------------------------------------------------------------------
    private static var sDragging : GObject;
    private static var sGlobalDragStart : Point = new Point();
    private static var sGlobalRect : Rectangle = new Rectangle();
    private static var sDragHelperPoint : Point = new Point();
    private static var sDragHelperRect : Rectangle = new Rectangle();
    
    private function initDrag() : Void
    {
        if (_draggable) 
            addEventListener(GTouchEvent.BEGIN, __begin)
        else 
        removeEventListener(GTouchEvent.BEGIN, __begin);
    }
    
    private function dragBegin(evt : GTouchEvent) : Void
    {
        if (sDragging != null) 
            sDragging.stopDrag();
        
        if (evt != null) 
        {
            sGlobalDragStart.x = evt.stageX;
            sGlobalDragStart.y = evt.stageY;
        }
        else 
        {
            sGlobalDragStart.x = Starling.current.nativeStage.mouseX;
            sGlobalDragStart.y = Starling.current.nativeStage.mouseY;
        }
        this.localToGlobalRect(0, 0, this.width, this.height, sGlobalRect);
        sDragging = this;
        
        addEventListener(GTouchEvent.DRAG, __dragging);
        addEventListener(GTouchEvent.END, __dragEnd);
    }
    
    private function dragEnd() : Void
    {
        if (sDragging == this) 
        {
            removeEventListener(GTouchEvent.DRAG, __dragStart);
            removeEventListener(GTouchEvent.END, __dragEnd);
            removeEventListener(GTouchEvent.DRAG, __dragging);
            sDragging = null;
        }
    }
    
    private function __begin(evt : GTouchEvent) : Void
    {
        if ((Std.is(evt.realTarget, TextField)) && cast((evt.realTarget), TextField).type == TextFieldType.INPUT) 
            return;
        
        addEventListener(GTouchEvent.DRAG, __dragStart);
    }
    
    private function __dragStart(evt : GTouchEvent) : Void
    {
        removeEventListener(GTouchEvent.DRAG, __dragStart);
        
        if ((Std.is(evt.realTarget, TextField)) && cast((evt.realTarget), TextField).type == TextFieldType.INPUT) 
            return;
        
        var dragEvent : DragEvent = new DragEvent(DragEvent.DRAG_START);
        dragEvent.stageX = evt.stageX;
        dragEvent.stageY = evt.stageY;
        dragEvent.touchPointID = evt.touchPointID;
        dispatchEvent(dragEvent);
        
        if (!dragEvent.isDefaultPrevented()) 
            dragBegin(evt);
    }

    private function __dragging(evt:GTouchEvent):Void
    {
        if(this.parent==null)
            return;

        var xx:Float = evt.stageX - sGlobalDragStart.x + sGlobalRect.x;
        var yy:Float = evt.stageY - sGlobalDragStart.y + sGlobalRect.y;

        if (_dragBounds!=null)
        {
            var rect:Rectangle = GRoot.inst.localToGlobalRect(_dragBounds.x, _dragBounds.y,
            _dragBounds.width,_dragBounds.height, sDragHelperRect);
            if (xx < rect.x)
                xx = rect.x;
            else if(xx + sGlobalRect.width > rect.right)
            {
                xx = rect.right - sGlobalRect.width;
                if (xx < rect.x)
                    xx = rect.x;
            }

            if(yy < rect.y)
                yy = rect.y;
            else if(yy + sGlobalRect.height > rect.bottom)
            {
                yy = rect.bottom - sGlobalRect.height;
                if(yy < rect.y)
                    yy = rect.y;
            }
        }

        var pt:Point = this.parent.globalToLocal(xx, yy, sDragHelperPoint);
        this.setXY(Math.round(pt.x), Math.round(pt.y));
    }
    
    private function __dragEnd(evt : GTouchEvent) : Void
    {
        if (sDragging == this) 
        {
            stopDrag();
            
            var dragEvent : DragEvent = new DragEvent(DragEvent.DRAG_END);
            dragEvent.stageX = evt.stageX;
            dragEvent.stageY = evt.stageY;
            dragEvent.touchPointID = evt.touchPointID;
            dispatchEvent(dragEvent);
        }
    }
}

