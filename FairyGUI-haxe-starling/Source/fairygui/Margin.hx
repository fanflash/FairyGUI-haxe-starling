package fairygui;


class Margin
{
    public var left : Int;
    public var right : Int;
    public var top : Int;
    public var bottom : Int;
    
    public function new()
    {
        
    }
    
    public function parse(str : String) : Void
    {
        var arr : Array<Dynamic> = str.split(",");
        if (arr.length == 1) 
        {
            var k : Int = Int(arr[0]);
            top = k;
            bottom = k;
            left = k;
            right = k;
        }
        else 
        {
            top = Int(arr[0]);
            bottom = Int(arr[1]);
            left = Int(arr[2]);
            right = Int(arr[3]);
        }
    }
    
    public function copy(source : Margin) : Void
    {
        top = source.top;
        bottom = source.bottom;
        left = source.left;
        right = source.right;
    }
}
