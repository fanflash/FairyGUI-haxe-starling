package fairygui;


interface IUISource
{
    
    
    public var fileName : String;

    public var loaded(default, never) : Bool;

    function load(callback : Dynamic) : Void;
}
