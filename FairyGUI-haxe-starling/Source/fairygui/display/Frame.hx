package fairygui.display;


import openfl.geom.Rectangle;

import starling.textures.Texture;

class Frame
{
    public var rect : Rectangle;
    public var addDelay : Int;
    public var texture : Texture;
    
    public function new()
    {
        rect = new Rectangle();
    }
}
