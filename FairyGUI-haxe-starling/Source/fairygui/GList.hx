package fairygui;

import fairygui.GObject;
import fairygui.GObjectPool;
import fairygui.GRoot;
import fairygui.Margin;

import openfl.events.MouseEvent;
import openfl.geom.Point;

import fairygui.event.ItemEvent;
import fairygui.event.GTouchEvent;

@:meta(Event(name="itemClick",type="fairygui.event.ItemEvent"))

class GList extends GComponent
{
    public var layout(get, set) : Int;
    public var lineGap(get, set) : Int;
    public var columnGap(get, set) : Int;
    public var defaultItem(get, set) : String;
    public var autoResizeItem(get, set) : Bool;
    public var selectionMode(get, set) : Int;
    public var itemPool(get, never) : GObjectPool;
    public var selectedIndex(get, set) : Int;

    private var _layout : Int;
    private var _lineGap : Int;
    private var _columnGap : Int;
    private var _defaultItem : String;
    private var _autoResizeItem : Bool;
    private var _selectionMode : Int;
    private var _lastSelectedIndex : Int;
    private var _pool : GObjectPool;
    private var _selectionHandled : Bool;
    
    public function new()
    {
        super();
        
        _trackBounds = true;
        _pool = new GObjectPool();
        _layout = ListLayoutType.SingleColumn;
        _autoResizeItem = true;
        _lastSelectedIndex = -1;
    }
    
    override public function dispose() : Void
    {
        _pool.clear();
        super.dispose();
    }
    
    @:final private function get_layout() : Int
    {
        return _layout;
    }
    
    @:final private function set_layout(value : Int) : Int
    {
        if (_layout != value) 
        {
            _layout = value;
            setBoundsChangedFlag();
        }
        return value;
    }
    
    @:final private function get_lineGap() : Int
    {
        return _lineGap;
    }
    
    @:final private function set_lineGap(value : Int) : Int
    {
        if (_lineGap != value) 
        {
            _lineGap = value;
            setBoundsChangedFlag();
        }
        return value;
    }
    
    @:final private function get_columnGap() : Int
    {
        return _columnGap;
    }
    
    @:final private function set_columnGap(value : Int) : Int
    {
        if (_columnGap != value) 
        {
            _columnGap = value;
            setBoundsChangedFlag();
        }
        return value;
    }
    
    @:final private function get_defaultItem() : String
    {
        return _defaultItem;
    }
    
    @:final private function set_defaultItem(val : String) : String
    {
        _defaultItem = val;
        return val;
    }
    
    @:final private function get_autoResizeItem() : Bool
    {
        return _autoResizeItem;
    }
    
    @:final private function set_autoResizeItem(value : Bool) : Bool
    {
        _autoResizeItem = value;
        return value;
    }
    
    @:final private function get_selectionMode() : Int
    {
        return _selectionMode;
    }
    
    @:final private function set_selectionMode(value : Int) : Int
    {
        _selectionMode = value;
        return value;
    }
    
    private function get_itemPool() : GObjectPool
    {
        return _pool;
    }
    
    public function getFromPool(url : String = null) : GObject
    {
        if (url == null) 
            url = _defaultItem;
        
        return _pool.getObject(url);
    }
    
    public function returnToPool(obj : GObject) : Void
    {
        _pool.returnObject(obj);
    }
    
    override public function addChildAt(child : GObject, index : Int) : GObject
    {
        if (_autoResizeItem) 
        {
            if (_layout == ListLayoutType.SingleColumn) 
                child.width = this.viewWidth
            else if (_layout == ListLayoutType.SingleRow) 
                child.height = this.viewHeight;
        }
        
        super.addChildAt(child, index);
        
        if (Std.is(child, GButton)) 
        {
            var button : GButton = cast((child), GButton);
            button.selected = false;
            button.changeStateOnClick = false;
        }
        child.addEventListener(GTouchEvent.BEGIN, __mouseDownItem);
        child.addEventListener(GTouchEvent.CLICK, __clickItem);
        child.addEventListener(MouseEvent.RIGHT_CLICK, __rightClickItem);
        
        return child;
    }
    
    public function addItem(url : String = null) : GObject
    {
        if (url == null) 
            url = _defaultItem;
        
        return addChild(UIPackage.createObjectFromURL(url));
    }
    
    public function addItemFromPool(url : String = null) : GObject
    {
        return addChild(getFromPool(url));
    }
    
    override public function removeChildAt(index : Int, dispose : Bool = false) : GObject
    {
        var child : GObject = super.removeChildAt(index, dispose);
        child.removeEventListener(GTouchEvent.BEGIN, __mouseDownItem);
        child.removeEventListener(GTouchEvent.CLICK, __clickItem);
        child.removeEventListener(MouseEvent.RIGHT_CLICK, __rightClickItem);
        
        return child;
    }
    
    public function removeChildToPoolAt(index : Int) : Void
    {
        var child : GObject = super.removeChildAt(index);
        returnToPool(child);
    }
    
    public function removeChildToPool(child : GObject) : Void
    {
        super.removeChild(child);
        returnToPool(child);
    }
    
    public function removeChildrenToPool(beginIndex : Int = 0, endIndex : Int = -1) : Void
    {
        if (endIndex < 0 || endIndex >= numChildren) 
            endIndex = numChildren - 1;
        
        for (i in beginIndex...endIndex + 1){removeChildToPoolAt(beginIndex);
        }
    }
    
    private function get_selectedIndex() : Int
    {
        var cnt : Int = _children.length;
        for (i in 0...cnt){
            var obj : GButton = _children[i].asButton;
            if (obj != null && obj.selected) 
                return i;
        }
        return -1;
    }
    
    private function set_selectedIndex(value : Int) : Int
    {
        clearSelection();
        if (value >= 0 && value < _children.length) 
            addSelection(value);
        return value;
    }
    
    public function getSelection() : Array<Int>
    {
        var ret : Array<Int> = new Array<Int>();
        var cnt : Int = _children.length;
        for (i in 0...cnt){
            var obj : GButton = _children[i].asButton;
            if (obj != null && obj.selected) 
                ret.push(i);
        }
        return ret;
    }
    
    public function addSelection(index : Int, scrollItToView : Bool = false) : Void
    {
        if (_selectionMode == ListSelectionMode.None) 
            return;
        
        if (_selectionMode == ListSelectionMode.Single) 
            clearSelection();
        
        var obj : GButton = getChildAt(index).asButton;
        if (obj != null) 
        {
            if (!obj.selected) 
                obj.selected = true;
            if (scrollItToView && _scrollPane != null) 
                _scrollPane.scrollToView(obj);
        }
    }
    
    public function removeSelection(index : Int) : Void
    {
        if (_selectionMode == ListSelectionMode.None) 
            return;
        
        var obj : GButton = getChildAt(index).asButton;
        if (obj != null && obj.selected) 
            obj.selected = false;
    }
    
    public function clearSelection() : Void
    {
        var cnt : Int = _children.length;
        for (i in 0...cnt){
            var obj : GButton = _children[i].asButton;
            if (obj != null) 
                obj.selected = false;
        }
    }
    
    public function selectAll() : Void
    {
        var cnt : Int = _children.length;
        for (i in 0...cnt){
            var obj : GButton = _children[i].asButton;
            if (obj != null) 
                obj.selected = true;
        }
    }
    
    public function selectNone() : Void
    {
        var cnt : Int = _children.length;
        for (i in 0...cnt){
            var obj : GButton = _children[i].asButton;
            if (obj != null) 
                obj.selected = false;
        }
    }
    
    public function selectReverse() : Void
    {
        var cnt : Int = _children.length;
        for (i in 0...cnt){
            var obj : GButton = _children[i].asButton;
            if (obj != null) 
                obj.selected = !obj.selected;
        }
    }
    
    public function handleArrowKey(dir : Int) : Void
    {
        var index : Int = this.selectedIndex;
        if (index == -1) 
            return;
        
        switch (dir)
        {
            case 1:  //up  
            if (_layout == ListLayoutType.SingleColumn || _layout == ListLayoutType.FlowVertical) 
            {
                index--;
                if (index >= 0) 
                {
                    clearSelection();
                    addSelection(index, true);
                }
            }
            else if (_layout == ListLayoutType.FlowHorizontal) 
            {
                var current : GObject = _children[index];
                var k : Int = 0;
                var i : Int = index - 1;
                while (i >= 0){
                    var obj : GObject = _children[i];
                    if (obj.y != current.y) 
                    {
                        current = obj;
                        break;
                    }
                    k++;
                    i--;
                }
                                while (i >= 0){
                    obj = _children[i];
                    if (obj.y != current.y) 
                    {
                        clearSelection();
                        addSelection(i + k + 1, true);
                        break;
                    }
                    i--;
                }
            }
            
            case 3:  //right  
            if (_layout == ListLayoutType.SingleRow || _layout == ListLayoutType.FlowHorizontal) 
            {
                index++;
                if (index < _children.length) 
                {
                    clearSelection();
                    addSelection(index, true);
                }
            }
            else if (_layout == ListLayoutType.FlowVertical) 
            {
                current = _children[index];
                k = 0;
                var cnt : Int = _children.length;
                for (i in index + 1...cnt){
                    obj = _children[i];
                    if (obj.x != current.x) 
                    {
                        current = obj;
                        break;
                    }
                    k++;
                }
                                while (i < cnt){
                    obj = _children[i];
                    if (obj.x != current.x) 
                    {
                        clearSelection();
                        addSelection(i - k - 1, true);
                        break;
                    }
                    i++;
                }
            }
            
            case 5:  //down  
            if (_layout == ListLayoutType.SingleColumn || _layout == ListLayoutType.FlowVertical) 
            {
                index++;
                if (index < _children.length) 
                {
                    clearSelection();
                    addSelection(index, true);
                }
            }
            else if (_layout == ListLayoutType.FlowHorizontal) 
            {
                current = _children[index];
                k = 0;
                cnt = _children.length;
                for (i in index + 1...cnt){
                    obj = _children[i];
                    if (obj.y != current.y) 
                    {
                        current = obj;
                        break;
                    }
                    k++;
                }
                                while (i < cnt){
                    obj = _children[i];
                    if (obj.y != current.y) 
                    {
                        clearSelection();
                        addSelection(i - k - 1, true);
                        break;
                    }
                    i++;
                }
            }
            
            case 7:  //left  
            if (_layout == ListLayoutType.SingleRow || _layout == ListLayoutType.FlowHorizontal) 
            {
                index--;
                if (index >= 0) 
                {
                    clearSelection();
                    addSelection(index, true);
                }
            }
            else if (_layout == ListLayoutType.FlowVertical) 
            {
                current = _children[index];
                k = 0;
                i = index - 1;
                while (i >= 0){
                    obj = _children[i];
                    if (obj.x != current.x) 
                    {
                        current = obj;
                        break;
                    }
                    k++;
                    i--;
                }
                                while (i >= 0){
                    obj = _children[i];
                    if (obj.x != current.x) 
                    {
                        clearSelection();
                        addSelection(i + k + 1, true);
                        break;
                    }
                    i--;
                }
            }
        }
    }
    
    private function __mouseDownItem(evt : GTouchEvent) : Void
    {
        var item : GButton = try cast(evt.currentTarget, GButton) catch(e:Dynamic) null;
        if (item == null || _selectionMode == ListSelectionMode.None) 
            return;
        
        _selectionHandled = false;
        
        if (UIConfig.defaultScrollTouchEffect && this.scrollPane != null) 
            return;
        
        if (_selectionMode == ListSelectionMode.Single) 
        {
            setSelectionOnEvent(item);
        }
        else 
        {
            if (!item.selected) 
                setSelectionOnEvent(item);  //如果item.selected，这里不处理selection，因为可能用户在拖动  ;
        }
    }
    
    private function __clickItem(evt : GTouchEvent) : Void
    {
        var item : GObject = cast((evt.currentTarget), GObject);
        if (!_selectionHandled) 
            setSelectionOnEvent(item);
        _selectionHandled = false;
        
        if (scrollPane != null) 
            scrollPane.scrollToView(item, true);
        
        var ie : ItemEvent = new ItemEvent(ItemEvent.CLICK, item);
        ie.stageX = evt.stageX;
        ie.stageY = evt.stageY;
        ie.clickCount = evt.clickCount;
        this.dispatchEvent(ie);
    }
    
    private function __rightClickItem(evt : MouseEvent) : Void
    {
        var item : GObject = cast((evt.currentTarget), GObject);
        if ((Std.is(item, GButton)) && !cast((item), GButton).selected) 
            setSelectionOnEvent(item);
        
        if (scrollPane != null) 
            scrollPane.scrollToView(item, true);
        
        var ie : ItemEvent = new ItemEvent(ItemEvent.CLICK, item);
        ie.stageX = evt.stageX;
        ie.stageY = evt.stageY;
        ie.rightButton = true;
        this.dispatchEvent(ie);
    }
    
    private function setSelectionOnEvent(item : GObject) : Void
    {
        if (!(Std.is(item, GButton)) || _selectionMode == ListSelectionMode.None) 
            return;
        
        _selectionHandled = true;
        var dontChangeLastIndex : Bool = false;
        var button : GButton = cast((item), GButton);
        var index : Int = getChildIndex(item);
        
        if (_selectionMode == ListSelectionMode.Single) 
        {
            if (!button.selected) 
            {
                clearSelectionExcept(button);
                button.selected = true;
            }
        }
        else 
        {
            var r : GRoot = this.root;
            if (r.shiftKeyDown) 
            {
                if (!button.selected) 
                {
                    if (_lastSelectedIndex != -1) 
                    {
                        var min : Int = Math.min(_lastSelectedIndex, index);
                        var max : Int = Math.max(_lastSelectedIndex, index);
                        max = Math.min(max, this.numChildren - 1);
                        for (i in min...max + 1){
                            var obj : GButton = getChildAt(i).asButton;
                            if (obj != null && !obj.selected) 
                                obj.selected = true;
                        }
                        
                        dontChangeLastIndex = true;
                    }
                    else 
                    {
                        button.selected = true;
                    }
                }
            }
            else if (r.ctrlKeyDown || _selectionMode == ListSelectionMode.Multiple_SingleClick) 
            {
                button.selected = !button.selected;
            }
            else 
            {
                if (!button.selected) 
                {
                    clearSelectionExcept(button);
                    button.selected = true;
                }
                else 
                clearSelectionExcept(button);
            }
        }
        
        if (!dontChangeLastIndex) 
            _lastSelectedIndex = index;
    }
    
    private function clearSelectionExcept(obj : GObject) : Void
    {
        var cnt : Int = _children.length;
        for (i in 0...cnt){
            var button : GButton = _children[i].asButton;
            if (button != null && button != obj && button.selected) 
                button.selected = false;
        }
    }
    
    public function resizeToFit(itemCount : Int = Int.MAX_VALUE, minSize : Int = 0) : Void
    {
        ensureBoundsCorrect();
        
        var curCount : Int = this.numChildren;
        if (itemCount > curCount) 
            itemCount = curCount;
        
        if (itemCount == 0) 
        {
            if (_layout == ListLayoutType.SingleColumn || _layout == ListLayoutType.FlowHorizontal) 
                this.viewHeight = minSize
            else 
            this.viewWidth = minSize;
        }
        else 
        {
            var i : Int = itemCount - 1;
            var obj : GObject = null;
            while (i >= 0)
            {
                obj = this.getChildAt(i);
                if (obj.visible) 
                    break;
                i--;
            }
            if (i < 0) 
            {
                if (_layout == ListLayoutType.SingleColumn || _layout == ListLayoutType.FlowHorizontal) 
                    this.viewHeight = minSize
                else 
                this.viewWidth = minSize;
            }
            else 
            {
                var size : Int;
                if (_layout == ListLayoutType.SingleColumn || _layout == ListLayoutType.FlowHorizontal) 
                {
                    size = obj.y + obj.height;
                    if (size < minSize) 
                        size = minSize;
                    this.viewHeight = size;
                }
                else 
                {
                    size = obj.x + obj.width;
                    if (size < minSize) 
                        size = minSize;
                    this.viewWidth = size;
                }
            }
        }
    }
    
    public function getMaxItemWidth() : Int
    {
        var cnt : Int = numChildren;
        var max : Int = 0;
        for (i in 0...cnt){
            var child : GObject = getChildAt(i);
            if (child.width > max) 
                max = child.width;
        }
        return max;
    }
    
    override private function handleSizeChanged() : Void
    {
        super.handleSizeChanged();
        
        if (_autoResizeItem) 
            adjustItemsSize();
        
        if (_layout == ListLayoutType.FlowHorizontal || _layout == ListLayoutType.FlowVertical) 
            setBoundsChangedFlag();
    }
    
    public function adjustItemsSize() : Void
    {
        if (_layout == ListLayoutType.SingleColumn) 
        {
            var cnt : Int = numChildren;
            var cw : Int = this.viewWidth;
            for (i in 0...cnt){
                var child : GObject = getChildAt(i);
                child.width = cw;
            }
        }
        else if (_layout == ListLayoutType.SingleRow) 
        {
            cnt = numChildren;
            var ch : Int = this.viewHeight;
            for (i in 0...cnt){
                child = getChildAt(i);
                child.height = ch;
            }
        }
    }
    
    override public function findObjectNear(xValue : Float, yValue : Float, resultPoint : Point = null) : Point
    {
        if (resultPoint == null) 
            resultPoint = new Point();
        
        var cnt : Int = _children.length;
        if (cnt == 0) 
        {
            resultPoint.x = xValue;
            resultPoint.y = yValue;
            return resultPoint;
        }
        
        ensureBoundsCorrect();
        var obj : GObject = null;
        
        var i : Int = 0;
        if (yValue != 0) 
        {
                        while (i < cnt){
                obj = _children[i];
                if (yValue < obj.y) 
                {
                    if (i == 0) 
                    {
                        yValue = 0;
                        break;
                    }
                    else 
                    {
                        var prev : GObject = _children[i - 1];
                        if (yValue < prev.y + prev.actualHeight / 2)                               //inside item, top half part  
                        yValue = prev.y
                        else if (yValue < prev.y + prev.actualHeight)                               //inside item, bottom half part  
                        yValue = obj.y
                        //between two items
                        else 
                        yValue = obj.y + _lineGap / 2;
                        break;
                    }
                }
                i++;
            }
            
            if (i == cnt) 
                yValue = obj.y;
        }
        
        if (xValue != 0) 
        {
            if (i > 0) 
                i--;
                        while (i < cnt){
                obj = _children[i];
                if (xValue < obj.x) 
                {
                    if (i == 0) 
                    {
                        xValue = 0;
                        break;
                    }
                    else 
                    {
                        prev = _children[i - 1];
                        if (xValue < prev.x + prev.actualWidth / 2)                               //inside item, top half part  
                        xValue = prev.x
                        else if (xValue < prev.x + prev.actualWidth)                               //inside item, bottom half part  
                        xValue = obj.x
                        //between two items
                        else 
                        xValue = obj.x + _columnGap / 2;
                        break;
                    }
                }
                i++;
            }
            
            if (i == cnt) 
                xValue = obj.x;
        }
        
        resultPoint.x = xValue;
        resultPoint.y = yValue;
        return resultPoint;
    }
    
    override private function updateBounds() : Void
    {
        var cnt : Int = numChildren;
        var i : Int;
        var child : GObject;
        var curX : Int;
        var curY : Int;
        var maxWidth : Int;
        var maxHeight : Int;
        var cw : Int;
        var ch : Int;
        
        for (i in 0...cnt){
            child = getChildAt(i);
            child.ensureSizeCorrect();
        }
        
        if (_layout == ListLayoutType.SingleColumn) 
        {
            for (i in 0...cnt){
                child = getChildAt(i);
                if (!child.visible) 
                    {i++;continue;
                };
                
                if (curY != 0) 
                    curY += _lineGap;
                child.setXY(curX, curY);
                curY += child.height;
                if (child.width > maxWidth) 
                    maxWidth = child.width;
            }
            cw = curX + maxWidth;
            ch = curY;
        }
        else if (_layout == ListLayoutType.SingleRow) 
        {
            for (i in 0...cnt){
                child = getChildAt(i);
                if (!child.visible) 
                    {i++;continue;
                };
                
                if (curX != 0) 
                    curX += _columnGap;
                child.setXY(curX, curY);
                curX += child.width;
                if (child.height > maxHeight) 
                    maxHeight = child.height;
            }
            cw = curX;
            ch = curY + maxHeight;
        }
        else if (_layout == ListLayoutType.FlowHorizontal) 
        {
            cw = this.viewWidth;
            for (i in 0...cnt){
                child = getChildAt(i);
                if (!child.visible) 
                    {i++;continue;
                };
                
                if (curX != 0) 
                    curX += _columnGap;
                
                if (curX + child.width > cw && maxHeight != 0) 
                {
                    //new line
                    curX = 0;
                    curY += maxHeight + _lineGap;
                    maxHeight = 0;
                }
                child.setXY(curX, curY);
                curX += child.width;
                if (child.height > maxHeight) 
                    maxHeight = child.height;
            }
            ch = curY + maxHeight;
        }
        else 
        {
            ch = this.viewHeight;
            for (i in 0...cnt){
                child = getChildAt(i);
                if (!child.visible) 
                    {i++;continue;
                };
                
                if (curY != 0) 
                    curY += _lineGap;
                
                if (curY + child.height > ch && maxWidth != 0) 
                {
                    curY = 0;
                    curX += maxWidth + _columnGap;
                    maxWidth = 0;
                }
                child.setXY(curX, curY);
                curY += child.height;
                if (child.width > maxWidth) 
                    maxWidth = child.width;
            }
            cw = curX + maxWidth;
        }
        setBounds(0, 0, cw, ch);
    }
    
    override public function setup_beforeAdd(xml : Fast) : Void
    {
        super.setup_beforeAdd(xml);
        
        var str : String;
        str = xml.att.layout;
        if (str != null) 
            _layout = ListLayoutType.parse(str);
        
        var overflow : Int;
        str = xml.att.overflow;
        if (str != null) 
            overflow = OverflowType.parse(str)
        else 
        overflow = OverflowType.Visible;
        
        var scroll : Int;
        str = xml.att.scroll;
        if (str != null) 
            scroll = ScrollType.parse(str)
        else 
        scroll = ScrollType.Vertical;
        
        var scrollBarDisplay : Int;
        str = xml.att.scrollBar;
        if (str != null) 
            scrollBarDisplay = ScrollBarDisplayType.parse(str)
        else 
        scrollBarDisplay = ScrollBarDisplayType.Default;
        var scrollBarFlags : Int = parseInt(xml.att.scrollBarFlags);
        
        var scrollBarMargin : Margin;
        if (overflow == OverflowType.Scroll) 
        {
            scrollBarMargin = new Margin();
            str = xml.att.scrollBarMargin;
            if (str != null) 
                scrollBarMargin.parse(str);
        }
        
        str = xml.att.margin;
        if (str != null) 
            _margin.parse(str);
        
        setupOverflowAndScroll(overflow, scrollBarMargin, scroll, scrollBarDisplay, scrollBarFlags);
        
        str = xml.att.lineGap;
        if (str != null) 
            _lineGap = Std.parseInt(str)
        else 
        _lineGap = 0;
        
        str = xml.att.colGap;
        if (str != null) 
            _columnGap = Std.parseInt(str)
        else 
        _columnGap = 0;
        
        str = xml.att.defaultItem;
        if (str != null) 
            _defaultItem = str;
        
        str = xml.att.autoItemSize;
        _autoResizeItem = str != "false";
        
        var col : FastXMLList = xml.node.item.innerData;
        for (cxml in col)
        {
            var url : String = cxml.att.url;
            if (url == null) 
                url = _defaultItem;
            if (url == null) 
                continue;
            
            var obj : GObject = addChild(getFromPool(url));
            if (Std.is(obj, GButton)) 
            {
                cast((obj), GButton).title = Std.string(cxml.att.title);
                cast((obj), GButton).icon = Std.string(cxml.att.icon);
            }
            else if (Std.is(obj, GLabel)) 
            {
                cast((obj), GLabel).title = Std.string(cxml.att.title);
                cast((obj), GLabel).icon = Std.string(cxml.att.icon);
            }
        }
    }
}

