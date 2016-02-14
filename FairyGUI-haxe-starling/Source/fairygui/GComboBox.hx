package fairygui;

import fairygui.GComponent;
import fairygui.GList;
import fairygui.GObject;
import fairygui.GRoot;
import fairygui.GTextField;

import fairygui.event.ItemEvent;
import fairygui.event.GTouchEvent;
import fairygui.event.StateChangeEvent;
import fairygui.utils.GTimers;
import fairygui.utils.ToolSet;

import starling.events.Event;

import haxe.xml.Fast;

@:meta(Event(name="stateChanged",type="fairygui.event.StateChangeEvent"))

class GComboBox extends GComponent
{
    public var titleColor(get, set) : Int;
    public var visibleItemCount(get, set) : Int;
    public var items(get, set) : Array<Dynamic>;
    public var values(get, set) : Array<Dynamic>;
    public var selectedIndex(get, set) : Int;
    public var value(get, set) : String;

    private var _titleObject : GTextField;
    private var _dropdownObject : GComponent;
    private var _list : GList;
    
    private var _visibleItemCount : Int;
    private var _items : Array<Dynamic>;
    private var _values : Array<Dynamic>;
    private var _itemsUpdated : Bool;
    private var _selectedIndex : Int;
    private var _buttonController : Controller;
    private var _over : Bool;
    
    public function new()
    {
        super();
        _visibleItemCount = UIConfig.defaultComboBoxVisibleItemCount;
        _itemsUpdated = true;
        _selectedIndex = -1;
        _items = [];
        _values = [];
    }
    
    @:final override private function get_text() : String
    {
        if (_titleObject != null) 
            return _titleObject.text
        else 
        return null;
    }
    
    override private function set_text(value : String) : String
    {
        if (_titleObject != null) 
            _titleObject.text = value;
        return value;
    }
    
    @:final private function get_titleColor() : Int
    {
        if (_titleObject != null) 
            return _titleObject.color
        else 
        return 0;
    }
    
    private function set_titleColor(value : Int) : Int
    {
        if (_titleObject != null) 
            _titleObject.color = value;
        return value;
    }
    
    @:final private function get_visibleItemCount() : Int
    {
        return _visibleItemCount;
    }
    
    private function set_visibleItemCount(value : Int) : Int
    {
        _visibleItemCount = value;
        return value;
    }
    
    @:final private function get_items() : Array<Dynamic>
    {
        return _items;
    }
    
    private function set_items(value : Array<Dynamic>) : Array<Dynamic>
    {
        if (value == null) 
            _items.length = 0
        else 
        _items = value.concat();
        if (_items.length > 0) 
        {
            if (_selectedIndex >= _items.length) 
                _selectedIndex = _items.length - 1
            else if (_selectedIndex == -1) 
                _selectedIndex = 0;
            
            this.text = _items[_selectedIndex];
        }
        else 
        this.text = "";
        _itemsUpdated = true;
        return value;
    }
    
    @:final private function get_values() : Array<Dynamic>
    {
        return _values;
    }
    
    private function set_values(value : Array<Dynamic>) : Array<Dynamic>
    {
        if (value == null) 
            _values.length = 0
        else 
        _values = value.concat();
        return value;
    }
    
    @:final private function get_selectedIndex() : Int
    {
        return _selectedIndex;
    }
    
    private function set_selectedIndex(val : Int) : Int
    {
        if (_selectedIndex == val) 
            return;
        
        _selectedIndex = val;
        if (selectedIndex >= 0 && selectedIndex < _items.length) 
            this.text = _items[_selectedIndex]
        else 
        this.text = "";
        return val;
    }
    
    private function get_value() : String
    {
        return _values[_selectedIndex];
    }
    
    private function set_value(val : String) : String
    {
        this.selectedIndex = Lambda.indexOf(_values, val);
        return val;
    }
    
    private function setState(val : String) : Void
    {
        if (_buttonController != null) 
            _buttonController.selectedPage = val;
    }
    
    override private function constructFromXML(xml : Fast) : Void
    {
        super.constructFromXML(xml);
        
        xml = xml.nodes.ComboBox.get(0);
        
        var str : String;
        
        _buttonController = getController("button");
        _titleObject = try cast(getChild("title"), GTextField) catch(e:Dynamic) null;
        str = xml.att.dropdown;
        if (str != null) 
        {
            _dropdownObject = try cast(UIPackage.createObjectFromURL(str), GComponent) catch(e:Dynamic) null;
            if (_dropdownObject == null) 
            {
                trace("下拉框必须为元件");
                return;
            }
            
            _list = _dropdownObject.getChild("list").asList;
            if (_list == null) 
            {
                trace(this.resourceURL + ": 下拉框的弹出元件里必须包含名为list的列表");
                return;
            }
            _list.addEventListener(ItemEvent.CLICK, __clickItem);
            
            _list.addRelation(_dropdownObject, RelationType.Width);
            _list.removeRelation(_dropdownObject, RelationType.Height);
            
            _dropdownObject.addRelation(_list, RelationType.Height);
            _dropdownObject.removeRelation(_list, RelationType.Width);
            
            _dropdownObject.displayObject.addEventListener(Event.REMOVED_FROM_STAGE, __popupWinClosed);
        }
        
        if (!GRoot.touchScreen) 
        {
            this.addEventListener(GTouchEvent.ROLL_OVER, __rollover);
            this.addEventListener(GTouchEvent.ROLL_OUT, __rollout);
        }
        
        this.addEventListener(GTouchEvent.BEGIN, __mousedown);
        this.addEventListener(GTouchEvent.END, __mouseup);
    }
    
    override public function setup_afterAdd(xml : Fast) : Void
    {
        super.setup_afterAdd(xml);
        
        xml = xml.nodes.ComboBox.get(0);
        if (xml != null) 
        {
            var str : String;
            str = xml.att.titleColor;
            if (str != null) 
                this.titleColor = ToolSet.convertFromHtmlColor(str);
            str = xml.att.visibleItemCount;
            if (str != null) 
                _visibleItemCount = Std.parseInt(str);
            
            var col : FastXMLList = xml.node.item.innerData;
            for (cxml in col)
            {
                _items.push(Std.string(cxml.att.title));
                _values.push(Std.string(cxml.att.value));
            }
            
            str = xml.att.title;
            if (str != null) 
            {
                this.text = str;
                _selectedIndex = Lambda.indexOf(_items, str);
            }
            else if (_items.length > 0) 
            {
                _selectedIndex = 0;
                this.text = _items[0];
            }
            else 
            _selectedIndex = -1;
        }
    }
    
    private function showDropdown() : Void
    {
        if (_itemsUpdated) 
        {
            _itemsUpdated = false;
            
            _list.removeChildren();
            var cnt : Int = _items.length;
            for (i in 0...cnt){
                var item : GObject = _list.addItemFromPool();
                item.name = i < (_values.length) ? _values[i] : "";
                item.text = _items[i];
            }
            _list.resizeToFit(_visibleItemCount);
        }
        _list.selectedIndex = -1;
        _dropdownObject.width = this.width;
        
        var r : GRoot = this.root;
        if (r != null) 
            r.togglePopup(_dropdownObject, this, true);
        if (_dropdownObject.parent) 
            setState(GButton.DOWN);
    }
    
    private function __popupWinClosed(evt : Event) : Void
    {
        if (_over) 
            setState(GButton.OVER)
        else 
        setState(GButton.UP);
    }
    
    private function __clickItem(evt : ItemEvent) : Void
    {
        //延时消失使按钮的按下状态有显示的机会
        GTimers.inst.add(100, 1, __clickItem2, _list.getChildIndex(evt.itemObject));
    }
    
    private function __clickItem2(index : Int) : Void
    {
        if (Std.is(_dropdownObject.parent, GRoot)) 
            cast((_dropdownObject.parent), GRoot).hidePopup(_dropdownObject);
        _selectedIndex = index;
        if (_selectedIndex >= 0) 
            this.text = _items[_selectedIndex]
        else 
        this.text = "";
        dispatchEvent(new StateChangeEvent(StateChangeEvent.CHANGED));
    }
    
    private function __rollover(evt : GTouchEvent) : Void
    {
        _over = true;
        if (this.isDown || _dropdownObject != null && _dropdownObject.parent) 
            return;
        
        setState(GButton.OVER);
    }
    
    private function __rollout(evt : GTouchEvent) : Void
    {
        _over = false;
        if (this.isDown || _dropdownObject != null && _dropdownObject.parent) 
            return;
        
        setState(GButton.UP);
    }
    
    private function __mousedown(evt : GTouchEvent) : Void
    {
        if (_dropdownObject != null) 
            showDropdown();
    }
    
    private function __mouseup(evt : GTouchEvent) : Void
    {
        if (_dropdownObject != null && !_dropdownObject.parent) 
        {
            if (_over) 
                setState(GButton.OVER)
            else 
            setState(GButton.UP);
        }
    }
}

