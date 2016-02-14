package fairygui;

import fairygui.GGroup;
import fairygui.GObject;
import fairygui.GTextInput;
import fairygui.Margin;
import fairygui.PackageItem;
import fairygui.ScrollPane;
import fairygui.Transition;
import fairygui.UIPackage;
import fairygui.display.UISprite;

import openfl.errors.ArgumentError;
import openfl.errors.Error;
import openfl.errors.RangeError;
import openfl.geom.Point;
import openfl.geom.Rectangle;

import haxe.xml.Fast;

import starling.display.DisplayObjectContainer;
import starling.display.Sprite;
import starling.utils.Max;

@:meta(Event(name="scrollEvent",type="starling.events.Event"))

@:meta(Event(name="dropEvent",type="fairygui.event.DropEvent"))

class GComponent extends GObject
{
    public var displayListContainer(get, never) : DisplayObjectContainer;
    public var numChildren(get, never) : Int;
    public var controllers(get, never) : Array<Controller>;
    public var scrollPane(get, never) : ScrollPane;
    public var opaque(get, set) : Bool;
    public var bounds(get, never) : Rectangle;
    public var viewWidth(get, set) : Int;
    public var viewHeight(get, set) : Int;

    private var _boundsChanged : Bool;
    private var _bounds : Rectangle;
    private var _sortingChildCount : Int;
    private var _opaque : Bool;
    
    private var _margin : Margin;
    private var _trackBounds : Bool;
    
    @:allow(fairygui)
    private var _buildingDisplayList : Bool;
    @:allow(fairygui)
    private var _children : Array<GObject>;
    @:allow(fairygui)
    private var _controllers : Array<Controller>;
    @:allow(fairygui)
    private var _transitions : Array<Transition>;
    @:allow(fairygui)
    private var _rootContainer : UISprite;
    @:allow(fairygui)
    private var _container : Sprite;
    @:allow(fairygui)
    private var _scrollPane : ScrollPane;
    
    public function new()
    {
        super();
        _bounds = new Rectangle();
        _children = new Array<GObject>();
        _controllers = new Array<Controller>();
        _transitions = new Array<Transition>();
        _margin = new Margin();
        this.opaque = true;
    }
    
    override private function createDisplayObject() : Void
    {
        _rootContainer = new UISprite(this);
        setDisplayObject(_rootContainer);
        _rootContainer.renderCallback = onRender;
        _container = _rootContainer;
    }
    
    override public function dispose() : Void
    {
        var numChildren : Int = _children.length;
        var i : Int = numChildren - 1;
        while (i >= 0){_children[i].dispose();
            --i;
        }
        
        if (_scrollPane != null) 
            _scrollPane.dispose();
        
        super.dispose();
    }
    
    @:final private function get_displayListContainer() : DisplayObjectContainer
    {
        return _container;
    }
    
    public function addChild(child : GObject) : GObject
    {
        addChildAt(child, _children.length);
        return child;
    }
    
    public function addChildAt(child : GObject, index : Int) : GObject
    {
        if (child == null) 
            throw new Error("child is null");
        
        var numChildren : Int = _children.length;
        
        if (index >= 0 && index <= numChildren) 
        {
            if (child.parent == this) 
            {
                setChildIndex(child, index);
            }
            else 
            {
                child.removeFromParent();
                child.parent = this;
                
                var cnt : Int = _children.length;
                if (child.sortingOrder != 0) 
                {
                    _sortingChildCount++;
                    index = getInsertPosForSortingChild(child);
                }
                else if (_sortingChildCount > 0) 
                {
                    if (index > (cnt - _sortingChildCount)) 
                        index = cnt - _sortingChildCount;
                }
                
                if (index == cnt) 
                    _children.push(child)
                else 
                _children.splice(index, 0, child);
                
                childStateChanged(child);
                setBoundsChangedFlag();
            }
            
            return child;
        }
        else 
        {
            throw new RangeError("Invalid child index");
        }
    }
    
    private function getInsertPosForSortingChild(target : GObject) : Int
    {
        var cnt : Int = _children.length;
        var i : Int;
        for (i in 0...cnt){
            var child : GObject = _children[i];
            if (child == target) 
                {i++;continue;
            };
            
            if (target.sortingOrder < child.sortingOrder) 
                break;
        }
        return i;
    }
    
    public function removeChild(child : GObject, dispose : Bool = false) : GObject
    {
        var childIndex : Int = Lambda.indexOf(_children, child);
        if (childIndex != -1) 
        {
            removeChildAt(childIndex, dispose);
        }
        return child;
    }
    
    public function removeChildAt(index : Int, dispose : Bool = false) : GObject
    {
        if (index >= 0 && index < numChildren) 
        {
            var child : GObject = _children[index];
            child.parent = null;
            
            if (child.sortingOrder != 0) 
                _sortingChildCount--;
            
            _children.splice(index, 1);
            if (child.inContainer) 
                _container.removeChild(child.displayObject);
            
            if (dispose) 
                child.dispose();
            
            setBoundsChangedFlag();
            
            return child;
        }
        else 
        {
            throw new RangeError("Invalid child index");
        }
    }
    
    public function removeChildren(beginIndex : Int = 0, endIndex : Int = -1, dispose : Bool = false) : Void
    {
        if (endIndex < 0 || endIndex >= numChildren) 
            endIndex = numChildren - 1;
        
        for (i in beginIndex...endIndex + 1){removeChildAt(beginIndex, dispose);
        }
    }
    
    public function getChildAt(index : Int) : GObject
    {
        if (index >= 0 && index < numChildren) 
            return _children[index]
        else 
        throw new RangeError("Invalid child index");
    }
    
    public function getChild(name : String) : GObject
    {
        var cnt : Int = _children.length;
        for (i in 0...cnt){
            if (_children[i].name == name) 
                return _children[i];
        }
        
        return null;
    }
    
    public function getVisibleChild(name : String) : GObject
    {
        var cnt : Int = _children.length;
        for (i in 0...cnt){
            var child : GObject = _children[i];
            if (child.finalVisible && child.name == name) 
                return child;
        }
        
        return null;
    }
    
    public function getChildInGroup(name : String, group : GGroup) : GObject
    {
        var cnt : Int = _children.length;
        for (i in 0...cnt){
            var child : GObject = _children[i];
            if (child.group == group && child.name == name) 
                return child;
        }
        
        return null;
    }
    
    @:allow(fairygui)
    private function getChildById(id : String) : GObject
    {
        var cnt : Int = _children.length;
        for (i in 0...cnt){
            if (_children[i]._id == id) 
                return _children[i];
        }
        
        return null;
    }
    
    public function getChildIndex(child : GObject) : Int
    {
        return Lambda.indexOf(_children, child);
    }
    
    public function setChildIndex(child : GObject, index : Int) : Void
    {
        var oldIndex : Int = Lambda.indexOf(_children, child);
        if (oldIndex == -1) 
            throw new ArgumentError("Not a child of this container");
        
        if (child.sortingOrder != 0)               //no effect  
        return;
        
        var cnt : Int = _children.length;
        if (_sortingChildCount > 0) 
        {
            if (index > (cnt - _sortingChildCount - 1)) 
                index = cnt - _sortingChildCount - 1;
        }
        
        _setChildIndex(child, oldIndex, index);
    }
    
    private function _setChildIndex(child : GObject, oldIndex : Int, index : Int) : Void
    {
        var cnt : Int = _children.length;
        if (index > cnt) 
            index = cnt;
        
        if (oldIndex == index) 
            return;
        
        _children.splice(oldIndex, 1);
        _children.splice(index, 0, child);
        
        if (child.inContainer) 
        {
            var displayIndex : Int;
            for (i in 0...index){
                var g : GObject = _children[i];
                if (g.inContainer) 
                    displayIndex++;
            }
            if (displayIndex == _container.numChildren) 
                displayIndex--;
            _container.setChildIndex(child.displayObject, displayIndex);
            
            setBoundsChangedFlag();
        }
    }
    
    public function swapChildren(child1 : GObject, child2 : GObject) : Void
    {
        var index1 : Int = Lambda.indexOf(_children, child1);
        var index2 : Int = Lambda.indexOf(_children, child2);
        if (index1 == -1 || index2 == -1) 
            throw new ArgumentError("Not a child of this container");
        swapChildrenAt(index1, index2);
    }
    
    public function swapChildrenAt(index1 : Int, index2 : Int) : Void
    {
        var child1 : GObject = _children[index1];
        var child2 : GObject = _children[index2];
        
        setChildIndex(child1, index2);
        setChildIndex(child2, index1);
    }
    
    @:final private function get_numChildren() : Int
    {
        return _children.length;
    }
    
    public function addController(controller : Controller) : Void
    {
        _controllers.push(controller);
        controller._parent = this;
        applyController(controller);
    }
    
    public function getControllerAt(index : Int) : Controller
    {
        return _controllers[index];
    }
    
    public function getController(name : String) : Controller
    {
        var cnt : Int = _controllers.length;
        for (i in 0...cnt){
            var c : Controller = _controllers[i];
            if (c.name == name) 
                return c;
        }
        
        return null;
    }
    
    public function removeController(c : Controller) : Void
    {
        var index : Int = Lambda.indexOf(_controllers, c);
        if (index == -1) 
            throw new Error("controller not exists");
        
        c._parent = null;
        _controllers.splice(index, 1);
        
        for (child in _children)
        child.handleControllerChanged(c);
    }
    
    @:final private function get_controllers() : Array<Controller>
    {
        return _controllers;
    }
    
    @:allow(fairygui)
    private function childStateChanged(child : GObject) : Void
    {
        if (_buildingDisplayList) 
            return;
        
        if (Std.is(child, GGroup)) 
        {
            for (g in _children)
            {
                if (g.group == child) 
                    childStateChanged(g);
            }
            return;
        }
        
        if (!child.displayObject) 
            return;
        
        if (child.finalVisible) 
        {
            if (!child.displayObject.parent) 
            {
                var index : Int;
                for (g in _children)
                {
                    if (g == child) 
                        break;
                    
                    if (g.displayObject && g.displayObject.parent) 
                        index++;
                }
                _container.addChildAt(child.displayObject, index);
            }
        }
        else 
        {
            if (child.displayObject.parent) 
                _container.removeChild(child.displayObject);
        }
    }
    
    @:allow(fairygui)
    private function applyController(c : Controller) : Void
    {
        var child : GObject;
        for (child in _children)
        child.handleControllerChanged(c);
    }
    
    @:allow(fairygui)
    private function applyAllControllers() : Void
    {
        var cnt : Int = _controllers.length;
        for (i in 0...cnt){
            applyController(_controllers[i]);
        }
    }
    
    @:allow(fairygui)
    private function adjustRadioGroupDepth(obj : GObject, c : Controller) : Void
    {
        var cnt : Int = _children.length;
        var i : Int;
        var child : GObject;
        var myIndex : Int = -1;
        var maxIndex : Int = -1;
        for (i in 0...cnt){
            child = _children[i];
            if (child == obj) 
            {
                myIndex = i;
            }
            else if ((Std.is(child, GButton))
                && cast((child), GButton).relatedController == c) 
            {
                if (i > maxIndex) 
                    maxIndex = i;
            }
        }
        if (myIndex < maxIndex) 
            this.swapChildrenAt(myIndex, maxIndex);
    }
    
    public function getTransitionAt(index : Int) : Transition
    {
        return _transitions[index];
    }
    
    public function getTransition(transName : String) : Transition
    {
        var cnt : Int = _transitions.length;
        for (i in 0...cnt){
            var trans : Transition = _transitions[i];
            if (trans.name == transName) 
                return trans;
        }
        
        return null;
    }
    
    @:final private function get_scrollPane() : ScrollPane
    {
        return _scrollPane;
    }
    
    @:final private function get_opaque() : Bool
    {
        return _rootContainer.hitArea != null;
    }
    
    private function set_opaque(value : Bool) : Bool
    {
        if (_opaque != value) 
        {
            _opaque = value;
            if (_opaque) 
                updateOpaque()
            else 
            _rootContainer.hitArea = null;
        }
        return value;
    }
    
    private function updateOpaque() : Void
    {
        if (_rootContainer.hitArea == null) 
            _rootContainer.hitArea = new Rectangle();
        
        _rootContainer.hitArea.width = this.width;
        _rootContainer.hitArea.height = this.height;
    }
    
    private function updateMask() : Void
    {
        if (_rootContainer.clipRect == null) 
            _rootContainer.clipRect = new Rectangle();
        
        var left : Float = _margin.left;
        var top : Float = _margin.top;
        var w : Float = this.width - (_margin.left + _margin.right);
        var h : Float = this.height - (_margin.top + _margin.bottom);
        _rootContainer.clipRect.setTo(left, top, w, h);
    }
    
    private function setupOverflowAndScroll(overflow : Int,
            scrollBarMargin : Margin,
            scroll : Int,
            scrollBarDisplay : Int,
            flags : Int) : Void
    {
        if (overflow == OverflowType.Hidden) 
        {
            _container = new Sprite();
            _rootContainer.addChild(_container);
            updateMask();
            _container.x = _margin.left;
            _container.y = _margin.top;
        }
        else if (overflow == OverflowType.Scroll) 
        {
            _container = new Sprite();
            _rootContainer.addChild(_container);
            _scrollPane = new ScrollPane(this, scroll, _margin, scrollBarMargin, scrollBarDisplay, flags);
        }
        else if (_margin.left != 0 || _margin.top != 0) 
        {
            _container = new Sprite();
            _rootContainer.addChild(_container);
            _container.x = _margin.left;
            _container.y = _margin.top;
        }
        
        setBoundsChangedFlag();
    }
    
    public function isChildInView(child : GObject) : Bool
    {
        if (_rootContainer.clipRect != null) 
        {
            return child.x + child.width >= 0 && child.x <= this.width && child.y + child.height >= 0 && child.y <= this.height;
        }
        else if (_scrollPane != null) 
        {
            return _scrollPane.isChildInView(child);
        }
        else 
        return true;
    }
    
    override private function handleSizeChanged() : Void
    {
        if (_scrollPane != null) 
            _scrollPane.setSize(this.width, this.height)
        else if (_rootContainer.clipRect != null) 
            updateMask();
        
        if (_opaque) 
            updateOpaque();
        
        _rootContainer.scaleX = this.scaleX;
        _rootContainer.scaleY = this.scaleY;
    }
    
    override private function handleGrayChanged() : Void
    {
        var c : Controller = getController("grayed");
        if (c != null) 
        {
            c.selectedIndex = (this.grayed) ? 1 : 0;
            return;
        }
        
        var v : Bool = this.grayed;
        var cnt : Int = _children.length;
        for (i in 0...cnt){
            _children[i].grayed = v;
        }
    }
    
    public function setBoundsChangedFlag() : Void
    {
        if (_scrollPane == null && !_trackBounds) 
            return;
        
        _boundsChanged = true;
    }
    
    private function onRender() : Void
    {
        if (_boundsChanged) 
            updateBounds();
    }
    
    public function ensureBoundsCorrect() : Void
    {
        if (_boundsChanged) 
            updateBounds();
    }
    
    private function updateBounds() : Void
    {
        var ax : Int;
        var ay : Int;
        var aw : Int;
        var ah : Int;
        if (_children.length > 0) 
        {
            ax = Max.INT_MAX_VALUE;
            ay = Max.INT_MAX_VALUE;
            var ar : Int = Max.INT_MIN_VALUE;
            var ab : Int = Max.INT_MIN_VALUE;
            var tmp : Int;
            
            for (child in _children)
            {
                child.ensureSizeCorrect();
            }
            
            for (child in _children)
            {
                tmp = child.x;
                if (tmp < ax) 
                    ax = tmp;
                tmp = child.y;
                if (tmp < ay) 
                    ay = tmp;
                tmp = child.x + child.actualWidth;
                if (tmp > ar) 
                    ar = tmp;
                tmp = child.y + child.actualHeight;
                if (tmp > ab) 
                    ab = tmp;
            }
            aw = ar - ax;
            ah = ab - ay;
        }
        else 
        {
            ax = 0;
            ay = 0;
            aw = 0;
            ah = 0;
        }
        if (ax != _bounds.x || ay != _bounds.y || aw != _bounds.width || ah != _bounds.height) 
            setBounds(ax, ay, aw, ah)
        else 
        _boundsChanged = false;
    }
    
    private function setBounds(ax : Int, ay : Int, aw : Int, ah : Int) : Void
    {
        _boundsChanged = false;
        _bounds.x = ax;
        _bounds.y = ay;
        _bounds.width = aw;
        _bounds.height = ah;
        
        if (_scrollPane != null) 
            _scrollPane.setContentSize(_bounds.x + _bounds.width, _bounds.y + _bounds.height);
    }
    
    private function get_bounds() : Rectangle
    {
        if (_boundsChanged) 
            updateBounds();
        return _bounds;
    }
    
    private function get_viewWidth() : Int
    {
        if (_scrollPane != null) 
            return _scrollPane.viewWidth
        else 
        return this.width - _margin.left - _margin.right;
    }
    
    private function set_viewWidth(value : Int) : Int
    {
        if (_scrollPane != null) 
            _scrollPane.viewWidth = value
        else 
        this.width = value + _margin.left + _margin.right;
        return value;
    }
    
    private function get_viewHeight() : Int
    {
        if (_scrollPane != null) 
            return _scrollPane.viewHeight
        else 
        return this.height - _margin.top - _margin.bottom;
    }
    
    private function set_viewHeight(value : Int) : Int
    {
        if (_scrollPane != null) 
            _scrollPane.viewHeight = value
        else 
        this.height = value + _margin.top + _margin.bottom;
        return value;
    }
    
    public function findObjectNear(xValue : Float, yValue : Float, resultPoint : Point = null) : Point
    {
        if (resultPoint == null) 
            resultPoint = new Point();
        
        resultPoint.x = xValue;
        resultPoint.y = yValue;
        return resultPoint;
    }
    
    @:allow(fairygui)
    private function childSortingOrderChanged(child : GObject, oldValue : Int, newValue : Int) : Void
    {
        if (newValue == 0) 
        {
            _sortingChildCount--;
            setChildIndex(child, _children.length);
        }
        else 
        {
            if (oldValue == 0) 
                _sortingChildCount++;
            
            var oldIndex : Int = Lambda.indexOf(_children, child);
            var index : Int = getInsertPosForSortingChild(child);
            if (oldIndex < index) 
                _setChildIndex(child, oldIndex, index - 1)
            else 
            _setChildIndex(child, oldIndex, index);
        }
    }
    
    override public function constructFromResource(pkgItem : PackageItem) : Void
    {
        _packageItem = pkgItem;
        constructFromXML(_packageItem.owner.getComponentData(_packageItem));
    }
    
    private function constructFromXML(xml : Fast) : Void
    {
        var str : String;
        var arr : Array<Dynamic>;
        
        _underConstruct = true;
        
        str = xml.att.resolve("size");
        arr = str.split(",");
        _sourceWidth = Int(arr[0]);
        _sourceHeight = Int(arr[1]);
        _initWidth = _sourceWidth;
        _initHeight = _sourceHeight;
        
        var overflow : Int;
        str = xml.att.resolve("overflow");
        if (str != null) 
            overflow = OverflowType.parse(str)
        else 
        overflow = OverflowType.Visible;
        
        var scroll : Int;
        str = xml.att.resolve("scroll");
        if (str != null) 
            scroll = ScrollType.parse(str)
        else 
        scroll = ScrollType.Vertical;
        
        var scrollBarDisplay : Int;
        str = xml.att.resolve("scrollBar");
        if (str != null) 
            scrollBarDisplay = ScrollBarDisplayType.parse(str)
        else 
        scrollBarDisplay = ScrollBarDisplayType.Default;
        var scrollBarFlags : Int = Std.parseInt(xml.att.scrollBarFlags);
        
        var scrollBarMargin : Margin;
        if (overflow == OverflowType.Scroll) 
        {
            scrollBarMargin = new Margin();
            str = xml.att.resolve("scrollBarMargin");
            if (str != null) 
                scrollBarMargin.parse(str);
        }
        
        str = xml.att.resolve("margin");
        if (str != null) 
            _margin.parse(str);
        
        setSize(_sourceWidth, _sourceHeight);
        setupOverflowAndScroll(overflow, scrollBarMargin, scroll, scrollBarDisplay, scrollBarFlags);
        
        _buildingDisplayList = true;

        var col : FastXMLList = xml.node.controller.innerData;
        var controller : Controller;
        for (cxml in col)
        {
            controller = new Controller();
            _controllers.push(controller);
            controller._parent = this;
            controller.setup(cxml);
        }
        
        col = xml.node.displayList.innerData.node.elements.innerData();
        var u : GObject;
        for (cxml in col)
        {
            u = constructChild(cxml);
            if (u == null) 
                continue;
            
            u._underConstruct = true;
            u._constructingData = cxml;
            u.setup_beforeAdd(cxml);
            addChild(u);
        }
        
        this.relations.setup(xml);
        
        var cnt : Int = _children.length;
        for (i in 0...cnt){
            u = _children[i];
            u.relations.setup(u._constructingData);
        }
        
        for (i in 0...cnt){
            u = _children[i];
            u.setup_afterAdd(u._constructingData);
            u._underConstruct = false;
            u._constructingData = null;
        }
        
        col = xml.node.transition.innerData;
        var trans : Transition;
        for (cxml in col)
        {
            trans = new Transition(this);
            _transitions.push(trans);
            trans.setup(cxml);
        }
        
        applyAllControllers();
        
        _buildingDisplayList = false;
        _underConstruct = false;
        
        for (child in _children)
        {
            if (child.displayObject != null && child.finalVisible) 
                _container.addChild(child.displayObject);
        }
    }
    
    private function constructChild(xml : Fast) : GObject
    {
        var pkgId : String = xml.att.resolve("pkg");
        var thisPkg : UIPackage = _packageItem.owner;
        var pkg : UIPackage;
        if (pkgId != null && pkgId != thisPkg.id) 
        {
            pkg = UIPackage.getById(pkgId);
            if (pkg == null) 
                return null;
        }
        else 
        pkg = thisPkg;
        
        var src : String = xml.att.resolve("src");
        if (src != null) 
        {
            var pi : PackageItem = pkg.getItemById(src);
            if (pi == null) 
                return null;
            
            var g : GObject = pkg.createObject2(pi);
            return g;
        }
        else 
        {
            var str : String = xml.node.name.innerData().localName;
            if (str == "text" && xml.att.resolve("input") == "true")
                g = new GTextInput()
            else 
            g = UIObjectFactory.newObject2(str);
            return g;
        }
    }
}

