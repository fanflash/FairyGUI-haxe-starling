package fairygui;


class PageOptionSet
{
    public var controller(never, set) : Controller;
    public var empty(get, never) : Bool;

    private var _controller : Controller;
    private var _items : Array<String>;
    
    public function new()
    {
        
    }
    
    private function set_controller(val : Controller) : Controller
    {
        _controller = val;
        return val;
    }
    
    public function add(pageIndex : Int) : Void
    {
        if (_items == null) 
            _items = new Array<String>();
        var id : String = _controller.getPageId(pageIndex);
        var i : Int = Lambda.indexOf(_items, id);
        if (i == -1) 
            _items.push(id);
    }
    
    public function remove(pageIndex : Int) : Void
    {
        if (_items == null) 
            return;
        var id : String = _controller.getPageId(pageIndex);
        var i : Int = Lambda.indexOf(_items, id);
        if (i != -1) 
            _items.splice(i, 1);
    }
    
    public function addByName(pageName : String) : Void
    {
        if (_items == null) 
            _items = new Array<String>();
        var id : String = _controller.getPageIdByName(pageName);
        var i : Int = Lambda.indexOf(_items, id);
        if (i != -1) 
            _items.push(id);
    }
    
    public function removeByName(pageName : String) : Void
    {
        if (_items == null) 
            return;
        var id : String = _controller.getPageIdByName(pageName);
        var i : Int = Lambda.indexOf(_items, id);
        if (i != -1) 
            _items.splice(i, 1);
    }
    
    public function clear() : Void
    {
        if (_items == null) 
            return;
        _items.length = 0;
    }
    
    private function get_empty() : Bool
    {
        return !_items || _items.length == 0;
    }
    
    public function addById(id : String) : Void
    {
        if (_items == null) 
            _items = new Array<String>();
        
        _items.push(id);
    }
    
    public function containsId(id : String) : Bool
    {
        return _items && Lambda.indexOf(_items, id) != -1;
    }
}
