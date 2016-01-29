package fairygui.text;


import starling.textures.Texture;

class BitmapFont
{
    public var id : String;
    public var lineHeight : Int;
    public var ttf : Bool;
    public var mainTexture : Texture;
    public var glyphs : Dynamic;
    
    public function new()
    {
        glyphs = { };
    }
}



