package fairygui;

import fairygui.GObject;
import openfl.errors.Error;

class GObjectPool
{
    public var initCallback(get, set) : Dynamic;
    public var count(get, never) : Int;

    private var _pool : Dynamic;
    private var _count : Int;
    private var _initCallback : Dynamic;
    
    public function new()
    {
        _pool = { };
    }
    
    private function get_initCallback() : Dynamic
    {
        return _initCallback;
    }
    
    private function set_initCallback(value : Dynamic) : Dynamic
    {
        _initCallback = value;
        return value;
    }
    
    public function clear() : Void
    {
        for (arr/* AS3HX WARNING could not determine type for var: arr exp: EIdent(_pool) type: Dynamic */ in _pool)
        {
            var cnt : Int = arr.length;
            for (i in 0...cnt){arr[i].dispose();
            }
        }
        _pool = { };
        _count = 0;
    }
    
    private function get_count() : Int
    {
        return _count;
    }
    
    public function getObject(url : String) : GObject
    {
        var arr : Array<GObject> = Reflect.field(_pool, url);
        if (arr == null) 
        {
            arr = new Array<GObject>();
            Reflect.setField(_pool, url, arr);
        }
        
        if (arr.length) 
        {
            _count--;
            return arr.pop();
        }
        
        var child : GObject = UIPackage.createObjectFromURL(url);
        if (child == null) 
            throw new Error(url + " not exists");
        
        if (_initCallback != null) 
            _initCallback(child);
        
        return child;
    }
    
    public function returnObject(obj : GObject) : Void
    {
        var url : String = obj.resourceURL;
        if (url == null) 
            return;
        
        var arr : Array<GObject> = Reflect.field(_pool, url);
        if (arr == null) 
            return;
        
        _count++;
        arr.push(obj);
    }
}
