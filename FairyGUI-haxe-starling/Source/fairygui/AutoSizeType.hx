package fairygui;


class AutoSizeType
{
    public static inline var None : Int = 0;
    public static inline var Both : Int = 1;
    public static inline var Height : Int = 2;
    
    public function new()
    {
        
    }
    
    public static function parse(value : String) : Int
    {
        switch (value)
        {
            case "none":
                return None;
            case "both":
                return Both;
            case "height":
                return Height;
            default:
                return None;
        }
    }
}
