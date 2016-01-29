package fairygui.display;

import fairygui.display.QuadExt;

import openfl.geom.Rectangle;

import fairygui.FlipType;

import starling.core.RenderSupport;
import starling.display.QuadBatch;
import starling.textures.Texture;
import starling.textures.TextureSmoothing;

class ImageExt extends FixedSizeObject
{
    public var texture(get, set) : Texture;
    public var color(get, set) : Int;
    public var flip(get, set) : Int;
    public var smoothing(get, set) : String;
    public var scale9Grid(get, set) : Rectangle;
    public var scaleByTile(get, set) : Bool;

    private var _texture : Texture;
    private var _batch : QuadBatch;
    private var _smoothing : String;
    private var _color : Int;
    private var _flip : Int;
    
    private var _scaleByTile : Bool;
    private var _scale9Grid : Rectangle;
    
    public function new()
    {
        super();
        
        //ImageExt is by default touchable
        this.touchable = false;
        
        _batch = new QuadBatch();
        _batch.capacity = 1;
        _width = 0;
        _height = 0;
        _color = 0xFFFFFF;
        _smoothing = TextureSmoothing.BILINEAR;
    }
    
    override public function dispose() : Void
    {
        _batch.dispose();
        
        super.dispose();
    }
    
    private function get_texture() : Texture
    {
        return _texture;
    }
    
    private function set_texture(value : Texture) : Texture
    {
        if (_texture != value) 
        {
            _texture = value;
            if (_texture != null) 
                setSize(_texture.width, _texture.height)
            else 
            setSize(0, 0);
            _needRebuild = true;
        }
        return value;
    }
    
    private function get_color() : Int
    {
        return _color;
    }
    
    private function set_color(value : Int) : Int
    {
        if (_color != value) 
        {
            _color = value;
            _needRebuild = true;
        }
        return value;
    }
    
    private function get_flip() : Int
    {
        return _flip;
    }
    
    private function set_flip(value : Int) : Int
    {
        if (_flip != value) 
        {
            _flip = value;
            _needRebuild = true;
        }
        return value;
    }
    
    private function get_smoothing() : String
    {
        return _smoothing;
    }
    
    private function set_smoothing(value : String) : String
    {
        if (_smoothing != value) 
        {
            _smoothing = value;
            _needRebuild = true;
        }
        return value;
    }
    
    override private function set_blendMode(value : String) : String
    {
        super.blendMode = value;
        _batch.blendMode = value;
        return value;
    }
    
    private function get_scale9Grid() : Rectangle
    {
        return _scale9Grid;
    }
    
    private function set_scale9Grid(value : Rectangle) : Rectangle
    {
        _scale9Grid = value;
        _needRebuild = true;
        return value;
    }
    
    private function get_scaleByTile() : Bool
    {
        return _scaleByTile;
    }
    
    private function set_scaleByTile(value : Bool) : Bool
    {
        if (_scaleByTile != value) 
        {
            _scaleByTile = value;
            _needRebuild = true;
        }
        return value;
    }
    
    override public function render(support : RenderSupport, parentAlpha : Float) : Void
    {
        if (_needRebuild) 
            rebuild();
        
        if (_batch.numQuads > 0) 
            support.batchQuadBatch(_batch, this.alpha * parentAlpha);
    }
    
    private static var sHelperTexCoords : Array<Float> = new Array<Float>();
    private static var sHelperRect : Rectangle = new Rectangle();
    private static var sHelperQuad : QuadExt;
    private static var QUADS_9_GRID : Array<Dynamic> = [
        [0, 0, 1, 0, 0, 1, 1, 1], 
        [1, 0, 2, 0, 1, 1, 2, 1], 
        [2, 0, 3, 0, 2, 1, 3, 1], 
        
        [0, 1, 1, 1, 0, 2, 1, 2], 
        [1, 1, 2, 1, 1, 2, 2, 2], 
        [2, 1, 3, 1, 2, 2, 3, 2], 
        
        [0, 2, 1, 2, 0, 3, 1, 3], 
        [1, 2, 2, 2, 1, 3, 2, 3], 
        [2, 2, 3, 2, 2, 3, 3, 3]];
    private function rebuild() : Void
    {
        _needRebuild = false;
        
        this._batch.reset();
        if (_texture == null) 
            return;
        
        if (sHelperQuad == null) 
            sHelperQuad = new QuadExt();
        
        sHelperQuad.setPremultipliedAlpha(_texture.premultipliedAlpha);
        
        sHelperTexCoords.length = 0;
        if (_flip == FlipType.None) 
            sHelperTexCoords.push(0, 0, 1, 0, 0, 1, 1, 1);
        if (_flip == FlipType.Both) 
            sHelperTexCoords.push(1, 1, 0, 1, 1, 0, 0, 0)
        else if (_flip == FlipType.Horizontal) 
            sHelperTexCoords.push(1, 0, 0, 0, 1, 1, 0, 1)
        else 
        sHelperTexCoords.push(0, 1, 1, 1, 0, 0, 1, 0);
        
        if (_scaleByTile) 
        {
            var hc : Int = Math.ceil(_scaleX);
            var vc : Int = Math.ceil(_scaleY);
            var remainWidth : Float = _width * (_scaleX - (hc - 1));
            var remainHeight : Float = _height * (_scaleY - (vc - 1));
            
            _batch.capacity = hc * vc;
            
            for (i in 0...hc){
                for (j in 0...vc){
                    sHelperQuad.fillVerts(i * _width, j * _height,
                            i == hc - (1) ? remainWidth : _width, j == vc - (1) ? remainHeight : _height);
                    
                    if (i == hc - 1 && j == vc - 1) 
                        sHelperQuad.fillUVWithScale(sHelperTexCoords, _texture, _scaleX - hc + 1, _scaleY - vc + 1)
                    else if (i == hc - 1) 
                        sHelperQuad.fillUVWithScale(sHelperTexCoords, _texture, _scaleX - hc + 1, 1)
                    else if (j == vc - 1) 
                        sHelperQuad.fillUVWithScale(sHelperTexCoords, _texture, 1, _scaleY - vc + 1)
                    else 
                    sHelperQuad.fillUV(sHelperTexCoords, _texture);
                    
                    sHelperQuad.color = _color;
                    _batch.addQuad(sHelperQuad, 1.0, _texture, _smoothing);
                }
            }
        }
        else if (_scale9Grid == null || (_scaleX == 1 && _scaleY == 1)) 
        {
            sHelperQuad.fillVertsWithScale(0, 0, _width, _height, _scaleX, _scaleY);
            sHelperQuad.fillUV(sHelperTexCoords, _texture);
            sHelperQuad.color = _color;
            _batch.addQuad(sHelperQuad, 1.0, _texture, _smoothing);
        }
        else 
        {
            var scale9Width : Float = _width * _scaleX;
            var scale9Height : Float = _height * _scaleY;
            
            var rows : Array<Dynamic>;
            var cols : Array<Dynamic>;
            var dRows : Array<Dynamic>;
            var dCols : Array<Dynamic>;
            
            rows = [0, _scale9Grid.top, _scale9Grid.bottom, _height];
            cols = [0, _scale9Grid.left, _scale9Grid.right, _width];
            
            if (scale9Height >= (_height - _scale9Grid.height)) 
                dRows = [0, _scale9Grid.top, scale9Height - (_height - _scale9Grid.bottom), scale9Height]
            else 
            {
                var tmp : Float = _scale9Grid.top / (_height - _scale9Grid.bottom);
                tmp = scale9Height * tmp / (1 + tmp);
                dRows = [0, tmp, tmp, scale9Height];
            }
            
            if (scale9Width >= (_width - _scale9Grid.width)) 
                dCols = [0, _scale9Grid.left, scale9Width - (_width - _scale9Grid.right), scale9Width]
            else 
            {
                tmp = _scale9Grid.left / (_width - _scale9Grid.right);
                tmp = scale9Width * tmp / (1 + tmp);
                dCols = [0, tmp, tmp, scale9Width];
            }
            
            var texLeft : Float = sHelperTexCoords[0];
            var texTop : Float = sHelperTexCoords[1];
            var texWidth : Float = sHelperTexCoords[6] - sHelperTexCoords[0];
            var texHeight : Float = sHelperTexCoords[7] - sHelperTexCoords[1];
            
            _batch.capacity = 9;
            
            for (i in 0...9){
                j = 0;
                while (j < 8){
                    var cx : Int = QUADS_9_GRID[i][j];
                    var cy : Int = QUADS_9_GRID[i][j + 1];
                    
                    sHelperTexCoords[j] = texLeft + cols[cx] / _width * texWidth;
                    sHelperTexCoords[j + 1] = texTop + rows[cy] / _height * texHeight;
                    
                    switch (j)
                    {
                        case 0:
                            sHelperRect.x = dCols[cx];
                            sHelperRect.y = dRows[cy];
                        
                        case 2:
                            sHelperRect.right = dCols[cx];
                        
                        case 4:
                            sHelperRect.bottom = dRows[cy];
                    }
                    j += 2;
                }
                if (sHelperRect.width == 0 || sHelperRect.height == 0) 
                    {i++;continue;
                };
                
                sHelperQuad.fillVertsByRect(sHelperRect);
                sHelperQuad.fillUV(sHelperTexCoords, _texture);
                sHelperQuad.color = _color;
                _batch.addQuad(sHelperQuad, 1.0, _texture, _smoothing);
            }
        }
        
        _batch.blendMode = this.blendMode;
    }
}




