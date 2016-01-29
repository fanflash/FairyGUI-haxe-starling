package fairygui.display;


import openfl.display.BitmapData;
//import flash.display3d.Context3DTextureFormat;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.text.TextField;

import fairygui.text.BMGlyph;
import fairygui.text.BitmapFont;

import starling.core.RenderSupport;
import starling.display.QuadBatch;
import starling.textures.Texture;
import starling.textures.TextureSmoothing;
import starling.utils.GetNextPowerOfTwo;

class TextCanvas extends FixedSizeObject
{
    public var textureMemory(get, never) : Int;

    private var _batch : QuadBatch;
    private var _texture : Texture;
    
    public var renderCallback : Dynamic;
    
    private static var sHelperQuad : QuadExt;
    private static var sHelperRect : Rectangle = new Rectangle();
    private static var sHelperMatrix : Matrix = new Matrix();
//    private static var sDefaultTextureFormat : String =
//        Lambda.has(Context3DTextureFormat, "BGRA_PACKED") ? "bgraPacked4444" : "bgra";
    private static var sDefaultTextureFormat : String = "bgra";
    
    public static var textureMemoryTrack : Int = 0;
    
    public function new()
    {
        super();
        _batch = new QuadBatch();
        _batch.capacity = 1;
        
        //TextCanvas is by default touchable
        this.touchable = false;
        
        if (sHelperQuad == null) 
            sHelperQuad = new QuadExt();
    }
    
    override public function dispose() : Void
    {
        clear();
        _batch.dispose();
        renderCallback = null;
        
        super.dispose();
    }
    
    public function renderText(nativeTextField : TextField, textWidth : Int, textHeight : Int, fontAdjustment : Int, restoreFunc : Dynamic) : Void
    {
        var nw : Int = nativeTextField.width;
        if (textWidth == 0 || textHeight == 0 || nw == 0) 
        {
            clear();
        }
        else 
        {
            var bw : Int;
            var bh : Int;
            bw = getNextPowerOfTwo(nw);
            if (bw > 2048) 
                bw = 2048;
            bh = getNextPowerOfTwo(textHeight);
            if (bh > 2048) 
                bh = 2048;
            var bmd : BitmapData = new BitmapData(bw, bh, true, 0);
            
            //bmd.drawWithQuality(nativeTextField, null, null, null, null, false, StageQuality.MEDIUM);
            sHelperMatrix.ty = -fontAdjustment;
            bmd.draw(nativeTextField, sHelperMatrix);
            
            if (_texture == null) 
            {
                _texture = Texture.fromBitmapData(bmd, false, false, 1, sDefaultTextureFormat);
                textureMemoryTrack += _texture.width * _texture.height * 4;
            }
            else 
            {
                if (bw < _texture.width && bh < _texture.height) 
                    _texture.root.uploadBitmapData(bmd)
                else 
                {
                    textureMemoryTrack -= textureMemory;
                    _texture.dispose();
                    _texture = Texture.fromBitmapData(bmd, false, false, 1, sDefaultTextureFormat);
                    textureMemoryTrack += textureMemory;
                }
            }
            _texture.root.onRestore = restoreFunc;
            
            bmd.dispose();
            
            _batch.reset();
            sHelperQuad.fillVerts(0, 0, bw, bh);
            sHelperQuad.fillUVOfTexture(_texture);
            sHelperQuad.color = 0xffffff;
            _batch.addQuad(sHelperQuad, 1.0, _texture, TextureSmoothing.BILINEAR);
        }
    }
    
    private function get_textureMemory() : Int
    {
        if (_texture != null) 
            return _texture.width * _texture.height * 4
        else 
        return 0;
    }
    
    public function clear() : Void
    {
        _batch.reset();
        if (_texture != null) 
        {
            textureMemoryTrack -= textureMemory;
            _texture.dispose();
            _texture = null;
        }
    }
    
    public function drawChar(font : BitmapFont, glyph : BMGlyph, charPos : Point, color : Int) : Void
    {
        if (font.mainTexture == null) 
            return;
        
        charPos.x += glyph.offsetX;
        
        if (font.ttf) 
        {
            sHelperRect.x = charPos.x;
            sHelperRect.y = charPos.y;
            sHelperRect.width = glyph.width;
            sHelperRect.height = glyph.height;
            
            sHelperQuad.fillVertsByRect(sHelperRect);
            sHelperQuad.fillUVByRect(glyph.uvRect);
            sHelperQuad.color = Int(color);
            _batch.addQuad(sHelperQuad, 1.0, font.mainTexture);
        }
        else if (glyph.uvRect != null) 
        {
            sHelperRect.x = charPos.x;
            sHelperRect.y = charPos.y;
            sHelperRect.width = glyph.width;
            sHelperRect.height = glyph.height;
            
            sHelperQuad.fillVertsByRect(sHelperRect);
            sHelperQuad.fillUVByRect(glyph.uvRect);
            sHelperQuad.color = 0xffffff;
            _batch.addQuad(sHelperQuad, 1.0, font.mainTexture, TextureSmoothing.BILINEAR);
        }
    }
    
    override public function render(support : RenderSupport, parentAlpha : Float) : Void
    {
        if (renderCallback != null) 
            renderCallback();
        
        if (_batch.numQuads > 0) 
            support.batchQuadBatch(_batch, this.alpha * parentAlpha);
    }
}
