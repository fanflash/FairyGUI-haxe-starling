package fairygui.display;


import openfl.geom.Rectangle;

import starling.display.Quad;
import starling.textures.Texture;

class QuadExt extends Quad
{
    private static var sHelperTexCoords : Array<Float> = new Array<Float>();
    private static var FULL_UV : Array<Dynamic> = [0, 0, 1, 0, 0, 1, 1, 1];
    
    public function new()
    {
        super(1, 1);
    }
    
    public function setPremultipliedAlpha(value : Bool) : Void
    {
        mVertexData.setPremultipliedAlpha(value, false);
    }
    
    public function fillVertsByRect(vertRect : Rectangle) : Void
    {
        mVertexData.setPosition(0, vertRect.x, vertRect.y);
        mVertexData.setPosition(1, vertRect.right, vertRect.y);
        mVertexData.setPosition(2, vertRect.x, vertRect.bottom);
        mVertexData.setPosition(3, vertRect.right, vertRect.bottom);
    }
    
    public function fillVertsWithScale(x : Float, y : Float, width : Float, height : Float, sx : Float, sy : Float) : Void
    {
        mVertexData.setPosition(0, x * sx, y * sy);
        mVertexData.setPosition(1, (x + width) * sx, y * sy);
        mVertexData.setPosition(2, x * sx, (y + height) * sy);
        mVertexData.setPosition(3, (x + width) * sx, (y + height) * sy);
    }
    
    public function fillVerts(x : Float, y : Float, width : Float, height : Float) : Void
    {
        mVertexData.setPosition(0, x, y);
        mVertexData.setPosition(1, x + width, y);
        mVertexData.setPosition(2, x, y + height);
        mVertexData.setPosition(3, x + width, y + height);
    }
    
    public function fillUVByRect(uvRect : Rectangle) : Void
    {
        mVertexData.setTexCoords(0, uvRect.x, uvRect.y);
        mVertexData.setTexCoords(1, uvRect.right, uvRect.y);
        mVertexData.setTexCoords(2, uvRect.x, uvRect.bottom);
        mVertexData.setTexCoords(3, uvRect.right, uvRect.bottom);
    }
    
    public function fillUVOfTexture(texture : Texture) : Void
    {
        for (i in 0...8){sHelperTexCoords[i] = FULL_UV[i];
        }
        texture.adjustTexCoords(sHelperTexCoords);
        for (i in 0...4){mVertexData.setTexCoords(i, sHelperTexCoords[i * 2], sHelperTexCoords[i * 2 + 1]);
        }
    }
    
    public function fillUV(texCoords : Array<Float>, texture : Texture) : Void
    {
        for (i in 0...8){sHelperTexCoords[i] = texCoords[i];
        }
        texture.adjustTexCoords(sHelperTexCoords);
        for (i in 0...4){mVertexData.setTexCoords(i, sHelperTexCoords[i * 2], sHelperTexCoords[i * 2 + 1]);
        }
    }
    
    public function fillUVWithScale(texCoords : Array<Float>, texture : Texture, percX : Float, percY : Float) : Void
    {
        for (i in 0...8){sHelperTexCoords[i] = texCoords[i];
        }
        
        if (sHelperTexCoords[2] > sHelperTexCoords[0]) 
            sHelperTexCoords[2] = sHelperTexCoords[0] + (sHelperTexCoords[2] - sHelperTexCoords[0]) * percX
        else 
        sHelperTexCoords[2] = sHelperTexCoords[2] + (sHelperTexCoords[0] - sHelperTexCoords[2]) * (1 - percX);
        sHelperTexCoords[6] = sHelperTexCoords[2];
        
        if (sHelperTexCoords[5] > sHelperTexCoords[1]) 
            sHelperTexCoords[5] = sHelperTexCoords[1] + (sHelperTexCoords[5] - sHelperTexCoords[1]) * percY
        else 
        sHelperTexCoords[5] = sHelperTexCoords[5] + (sHelperTexCoords[1] - sHelperTexCoords[5]) * (1 - percY);
        sHelperTexCoords[7] = sHelperTexCoords[5];
        
        texture.adjustTexCoords(sHelperTexCoords);
        for (i in 0...4){mVertexData.setTexCoords(i, sHelperTexCoords[i * 2], sHelperTexCoords[i * 2 + 1]);
        }
    }
}
