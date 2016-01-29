package fairygui.display;


import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;

import starling.display.DisplayObject;
import starling.utils.MatrixUtil;

class FixedSizeObject extends DisplayObject
{
    private var _width : Float;
    private var _height : Float;
    private var _scaleX : Float;
    private var _scaleY : Float;
    private var _needRebuild : Bool;
    
    private static var sHelperMatrix : Matrix = new Matrix();
    private static var sHelperPoint : Point = new Point();
    private static var sHelperRect : Rectangle = new Rectangle();
    
    public function new()
    {
        super();
        _width = 0;
        _height = 0;
        _scaleX = 1;
        _scaleY = 1;
    }
    
    override private function get_width() : Float
    {
        return _width;
    }
    
    public function setSize(aw : Float, ah : Float) : Void
    {
        if (_width != aw || _height != ah) 
        {
            _width = aw;
            _height = ah;
            _needRebuild = true;
        }
    }
    
    override private function get_scaleX() : Float
    {
        return _scaleX;
    }
    
    override private function set_scaleX(value : Float) : Float
    {
        if (_scaleX != value) 
        {
            _scaleX = value;
            _needRebuild = true;
        }
        return value;
    }
    
    override private function get_scaleY() : Float
    {
        return _scaleY;
    }
    
    override private function set_scaleY(value : Float) : Float
    {
        if (_scaleY != value) 
        {
            _scaleY = value;
            _needRebuild = true;
        }
        return value;
    }
    
    override public function getBounds(targetSpace : DisplayObject, resultRect : Rectangle = null) : Rectangle
    {
        if (resultRect == null) 
        {
            resultRect = new Rectangle();
        }
        
        if (targetSpace == this || _width == 0 || _height == 0)   // optimization  
        {
            resultRect.setTo(0, 0, _width * _scaleX, _height * _scaleY);
        }
        else if (targetSpace == parent && rotation == 0.0)   // optimization  
        {
            resultRect.setTo(x - pivotX, y - pivotY, _width * _scaleX, _height * _scaleY);
        }
        else 
        {
            getTransformationMatrix(targetSpace, sHelperMatrix);
            
            var minX : Float = Float.MAX_VALUE;
            var maxX : Float = -Float.MAX_VALUE;
            var minY : Float = Float.MAX_VALUE;
            var maxY : Float = -Float.MAX_VALUE;
            
            var ax : Float;
            var ay : Float;
            for (i in 0...4){
                switch (i)
                {
                    case 0:ax = 0;ay = 0;
                    case 1:ax = _width * _scaleX;ay = 0;
                    case 2:ax = 0;ay = _height * _scaleY;
                    case 3:ax = _width * _scaleX;ay = _height * _scaleY;
                }
                var transformedPoint : Point = MatrixUtil.transformCoords(sHelperMatrix, ax, ay, sHelperPoint);
                
                if (minX > transformedPoint.x)                     minX = transformedPoint.x;
                if (maxX < transformedPoint.x)                     maxX = transformedPoint.x;
                if (minY > transformedPoint.y)                     minY = transformedPoint.y;
                if (maxY < transformedPoint.y)                     maxY = transformedPoint.y;
            }
            
            resultRect.setTo(minX, minY, maxX - minX, maxY - minY);
        }
        
        return resultRect;
    }
}
