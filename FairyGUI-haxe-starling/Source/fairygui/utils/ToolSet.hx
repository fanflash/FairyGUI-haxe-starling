package fairygui.utils;

import fairygui.utils.UBBParser;

import openfl.display.BitmapData;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;

import fairygui.GObject;
import fairygui.display.UIDisplayObject;

import starling.display.DisplayObject;
import starling.display.Stage;

class ToolSet
{
    public static var GRAY_FILTERS_MATRIX : Array<Float> = [
                0.299, 0.587, 0.114, 0, 0, 
                0.299, 0.587, 0.114, 0, 0, 
                0.299, 0.587, 0.114, 0, 0, 
                0, 0, 0, 1, 0];
    
    public function new()
    {
        
    }
    
    public static function startsWith(source : String, str : String, ignoreCase : Bool = false) : Bool{
        if (source == null) 
            return false
        else if (source.length < str.length) 
            return false
        else {
            source = source.substring(0, str.length);
            if (!ignoreCase) 
                return source == str
            else 
            return source.toLowerCase() == str.toLowerCase();
        }
    }
    
    public static function endsWith(source : String, str : String, ignoreCase : Bool = false) : Bool{
        if (source == null) 
            return false
        else if (source.length < str.length) 
            return false
        else {
            source = source.substring(source.length - str.length);
            if (!ignoreCase) 
                return source == str
            else 
            return source.toLowerCase() == str.toLowerCase();
        }
    }
    
    public static function trim(targetString : String) : String{
        return trimLeft(trimRight(targetString));
    }
    
    public static function trimLeft(targetString : String) : String{
        var tempChar : String = "";
        for (i in 0...targetString.length){
            tempChar = targetString.charAt(i);
            if (tempChar != " " && tempChar != "\n" && tempChar != "\r") {
                break;
            }
        }
        return targetString.substr(i);
    }
    
    public static function trimRight(targetString : String) : String{
        var tempChar : String = "";
        var i : Int = targetString.length - 1;
        while (i >= 0){
            tempChar = targetString.charAt(i);
            if (tempChar != " " && tempChar != "\n" && tempChar != "\r") {
                break;
            }
            i--;
        }
        return targetString.substring(0, i + 1);
    }
    
    
    public static function convertToHtmlColor(argb : Int, hasAlpha : Bool = false) : String{
        var alpha : String;
        if (hasAlpha) 
            alpha = Std.string((argb >> 24 & 0xFF))
        else 
        alpha = "";
        var red : String = Std.string((argb >> 16 & 0xFF));
        var green : String = Std.string((argb >> 8 & 0xFF));
        var blue : String = Std.string((argb & 0xFF));
        if (alpha.length == 1) 
            alpha = "0" + alpha;
        if (red.length == 1) 
            red = "0" + red;
        if (green.length == 1) 
            green = "0" + green;
        if (blue.length == 1) 
            blue = "0" + blue;
        return "#" + alpha + red + green + blue;
    }
    
    public static function convertFromHtmlColor(str : String, hasAlpha : Bool = false) : Int{
        if (str.length < 1) 
            return 0;
        
        if (str.charAt(0) == "#") 
            str = str.substr(1);
        
        if (str.length == 8) 
            return (Std.parseInt(str.substr(0, 2), 16) << 24) + Std.parseInt(str.substr(2), 16)
        else if (hasAlpha) 
            return 0xFF000000 + Std.parseInt(str, 16)
        else 
        return Std.parseInt(str, 16);
    }
    
    public static function encodeHTML(str : String) : String{
        if (str == null) 
            return ""
        else 
        return str.replace(new EReg('&', "g"), "&amp;").replace(new EReg('<', "g"), "&lt;").replace(new EReg('>', "g"), "&gt;").replace(new EReg('\'', "g"), "&apos;");
    }
    
    public static var defaultUBBParser : UBBParser = new UBBParser();
    public static function parseUBB(text : String) : String{
        return defaultUBBParser.parse(text);
    }
    
    public static function scaleBitmapWith9Grid(source : BitmapData, scale9Grid : Rectangle,
            wantWidth : Int, wantHeight : Int, smoothing : Bool = false) : BitmapData{
        if (wantWidth == 0 || wantHeight == 0) 
        {
            return new BitmapData(1, 1, source.transparent, 0x00000000);
            return;
        }
        
        var bmpData : BitmapData = new BitmapData(wantWidth, wantHeight, source.transparent, 0x00000000);
        
        var rows : Array<Dynamic> = [0, scale9Grid.top, scale9Grid.bottom, source.height];
        var cols : Array<Dynamic> = [0, scale9Grid.left, scale9Grid.right, source.width];
        
        var dRows : Array<Dynamic> = [0, scale9Grid.top, wantHeight - (source.height - scale9Grid.bottom), wantHeight];
        var dCols : Array<Dynamic> = [0, scale9Grid.left, wantWidth - (source.width - scale9Grid.right), wantWidth];
        
        var origin : Rectangle;
        var draw : Rectangle;
        var mat : Matrix = new Matrix();
        
        for (cx in 0...3){
            for (cy in 0...3){
                origin = new Rectangle(cols[cx], rows[cy], cols[cx + 1] - cols[cx], rows[cy + 1] - rows[cy]);
                draw = new Rectangle(dCols[cx], dRows[cy], dCols[cx + 1] - dCols[cx], dRows[cy + 1] - dRows[cy]);
                mat.identity();
                mat.a = draw.width / origin.width;
                mat.d = draw.height / origin.height;
                mat.tx = draw.x - origin.x * mat.a;
                mat.ty = draw.y - origin.y * mat.d;
                bmpData.draw(source, mat, null, null, draw, smoothing);
            }
        }
        return bmpData;
    }
    
    public static function displayObjectToGObject(obj : DisplayObject) : GObject
    {
        while (obj != null && !(Std.is(obj, Stage)))
        {
            if (Std.is(obj, UIDisplayObject)) 
                return cast((obj), UIDisplayObject).owner;
            
            obj = obj.parent;
        }
        return null;
    }
}
