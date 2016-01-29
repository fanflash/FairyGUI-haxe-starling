package fairygui;

import fairygui.UserClass;
import fairygui.ZipUIPackageReader;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.LoaderInfo;
import openfl.events.Event;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.media.Sound;
import openfl.utils.ByteArray;


import fairygui.display.Frame;
import fairygui.text.BMGlyph;
import fairygui.text.BitmapFont;
import fairygui.utils.GTimers;
import fairygui.utils.ToolSet;

import starling.textures.Texture;


import openfl.display.Loader;

import fairygui.PackageItem;


class UIPackage
{
    public var id(get, never) : String;
    public var name(get, never) : String;
    public var customId(get, set) : String;

    private var _id : String;
    private var _name : String;
    private var _basePath : String;
    private var _items : Array<PackageItem>;
    private var _itemsById : Dynamic;
    private var _itemsByName : Dynamic;
    private var _customId : String;
    private var _sprites : Dynamic;
    
    private var _reader : IUIPackageReader;
    
    @:allow(fairygui)
    private static var _constructing : Int;
    
    private static var _packageInstById : Dynamic = { };
    private static var _packageInstByName : Dynamic = { };
    private static var _bitmapFonts : Dynamic = { };
    private static var _loadingQueue : Array<Dynamic> = [];
    private static var _stringsSource : Dynamic = null;
    
    private static var sep0 : String = ",";
    private static var sep1 : String = "\n";
    private static var sep2 : String = " ";
    private static var sep3 : String = "=";
    
    public function new()
    {
        _items = new Array<PackageItem>();
        _sprites = { };
    }
    
    public static function getById(id : String) : UIPackage
    {
        return Reflect.field(_packageInstById, id);
    }
    
    public static function getByName(name : String) : UIPackage
    {
        return Reflect.field(_packageInstByName, name);
    }
    
    public static function addPackage(desc : ByteArray, res : ByteArray) : UIPackage
    {
        var pkg : UIPackage = new UIPackage();
        var reader : ZipUIPackageReader = new ZipUIPackageReader(desc, res);
        pkg.create(reader);
        _packageInstById[pkg.id] = pkg;
        _packageInstByName[pkg.name] = pkg;
        return pkg;
    }
    
    public static function addPackage2(reader : IUIPackageReader) : UIPackage
    {
        var pkg : UIPackage = new UIPackage();
        pkg.create(reader);
        _packageInstById[pkg.id] = pkg;
        _packageInstByName[pkg.name] = pkg;
        return pkg;
    }
    
    public static function removePackage(packageId : String) : Void
    {
        var pkg : UIPackage = Reflect.field(_packageInstById, packageId);
        pkg.dispose();
        ;
        if (pkg._customId != null) 
            ;
        ;
    }
    
    public static function createObject(pkgName : String, resName : String, userClass : Class<Dynamic> = null) : GObject
    {
        var pkg : UIPackage = getByName(pkgName);
        if (pkg != null) 
            return pkg.createObject(resName, userClass)
        else 
        return null;
    }
    
    public static function createObjectFromURL(url : String, userClass : Class<Dynamic> = null) : GObject
    {
        var pi : PackageItem = getItemByURL(url);
        if (pi != null) 
            return pi.owner.createObject2(pi, userClass)
        else 
        return null;
    }
    
    public static function getItemURL(pkgName : String, resName : String) : String
    {
        var pkg : UIPackage = getByName(pkgName);
        if (pkg == null) 
            return null;
        
        var pi : PackageItem = pkg._itemsByName[resName];
        if (pi == null) 
            return null;
        
        return "ui://" + pkg.id + pi.id;
    }
    
    public static function getItemByURL(url : String) : PackageItem
    {
        if (ToolSet.startsWith(url, "ui://")) 
        {
            var pkgId : String = url.substr(5, 8);
            var srcId : String = url.substr(13);
            var pkg : UIPackage = getById(pkgId);
            if (pkg != null) 
                return pkg.getItemById(srcId);
        }
        return null;
    }
    
    public static function getBitmapFontByURL(url : String) : BitmapFont
    {
        return Reflect.field(_bitmapFonts, url);
    }
    
    public static function setStringsSource(source : FastXML) : Void
    {
        _stringsSource = { };
        var list : FastXMLList = source.node.string.innerData;
        for (xml in list)
        {
            var key : String = xml.att.name;
            var text : String = Std.string(xml);
            var i : Int = key.indexOf("-");
            if (i == -1) 
                continue;
            
            var key2 : String = key.substr(0, i);
            var key3 : String = key.substr(i + 1);
            var col : Dynamic = Reflect.field(_stringsSource, key2);
            if (col == null) 
            {
                col = { };
                Reflect.setField(_stringsSource, key2, col);
            }
            Reflect.setField(col, key3, text);
        }
    }
    
    public static function loadingCount() : Int
    {
        return _loadingQueue.length;
    }
    
    public static function waitToLoadCompleted(callback : Dynamic) : Void
    {
        GTimers.inst.add(10, 0, checkComplete, callback);
    }
    
    private static function checkComplete(callback : Dynamic) : Void
    {
        if (_loadingQueue.length == 0) 
        {
            GTimers.inst.remove(checkComplete);
            callback();
        }
    }
    
    private function create(reader : IUIPackageReader) : Void
    {
        _reader = reader;
        
        var ba : ByteArray;
        var str : String;
        var arr : Array<Dynamic>;
        
        ba = _reader.readResFile("sprites.bytes");
        str = ba.readUTFBytes(ba.length);
        arr = str.split(sep1);
        var cnt : Int = arr.length;
        for (i in 1...cnt){
            str = arr[i];
            if (str == null) 
                {i++;continue;
            };
            
            var arr2 : Array<Dynamic> = str.split(sep2);
            
            var sprite : AtlasSprite = new AtlasSprite();
            var itemId : String = arr2[0];
            var binIndex : Int = parseInt(arr2[1]);
            if (binIndex >= 0) 
                sprite.atlas = "atlas" + binIndex
            else 
            {
                var pos : Int = itemId.indexOf("_");
                if (pos == -1) 
                    sprite.atlas = "atlas_" + itemId
                else 
                sprite.atlas = "atlas_" + itemId.substr(0, pos);
            }
            sprite.rect.x = parseInt(arr2[2]);
            sprite.rect.y = parseInt(arr2[3]);
            sprite.rect.width = parseInt(arr2[4]);
            sprite.rect.height = parseInt(arr2[5]);
            sprite.rotated = arr2[6] == "1";
            Reflect.setField(_sprites, itemId, sprite);
        }
        
        str = _reader.readDescFile("package.xml");
        
        var ignoreWhitespace : Bool = FastXML.ignoreWhitespace;
        FastXML.ignoreWhitespace = true;
        var xml : FastXML = new FastXML(str);
        FastXML.ignoreWhitespace = ignoreWhitespace;
        
        _id = xml.att.id;
        _name = xml.att.name;
        
        var resources : FastXMLList = xml.node.resources.innerData.node.elements.innerData();
        
        _itemsById = { };
        _itemsByName = { };
        var pi : PackageItem;
        var cxml : FastXML;
        
        for (cxml in resources)
        {
            pi = new PackageItem();
            pi.type = PackageItemType.parseType(cxml.node.name.innerData().localName);
            pi.id = cxml.att.id;
            pi.name = cxml.att.name;
            pi.file = cxml.att.file;
            str = cxml.att.size;
            arr = str.split(sep0);
            pi.width = Int(arr[0]);
            pi.height = Int(arr[1]);
            var _sw7_ = (pi.type);            

            switch (_sw7_)
            {
                case PackageItemType.Image:
                {
                    str = cxml.att.scale;
                    if (str == "9grid") 
                    {
                        pi.scale9Grid = new Rectangle();
                        str = cxml.att.scale9grid;
                        arr = str.split(sep0);
                        pi.scale9Grid.x = arr[0];
                        pi.scale9Grid.y = arr[1];
                        pi.scale9Grid.width = arr[2];
                        pi.scale9Grid.height = arr[3];
                    }
                    else if (str == "tile") 
                    {
                        pi.scaleByTile = true;
                    }
                    str = cxml.att.smoothing;
                    pi.smoothing = str != "false";
                }
            }
            
            pi.owner = this;
            _items.push(pi);
            _itemsById[pi.id] = pi;
            if (pi.name != null) 
                _itemsByName[pi.name] = pi;
        }
        
        cnt = _items.length;
        for (i in 0...cnt){
            pi = _items[i];
            if (pi.type == PackageItemType.Font) 
            {
                loadFont(pi);
                _bitmapFonts[pi.bitmapFont.id] = pi.bitmapFont;
            }
        }
    }
    
    public function loadAllImages() : Void
    {
        var cnt : Int = _items.length;
        for (i in 0...cnt){
            var pi : PackageItem = _items[i];
            if (pi.type == PackageItemType.Image) 
            {
                if (pi.texture != null || pi.loading) 
                    {i++;continue;
                };
                
                loadImage(pi);
            }
            else if (pi.type == PackageItemType.Atlas) 
            {
                if (pi.texture != null || pi.loading) 
                    {i++;continue;
                };
                
                loadAtlas(pi);
            }
        }
    }
    
    public function dispose() : Void
    {
        var cnt : Int = _items.length;
        for (i in 0...cnt){
            var pi : PackageItem = _items[i];
            var texture : Texture = pi.texture;
            if (texture != null) 
                texture.dispose()
            else if (pi.frames != null) 
            {
                var frameCount : Int = pi.frames.length;
                for (j in 0...frameCount){
                    texture = pi.frames[j].texture;
                    if (texture != null) 
                        texture.dispose();
                }
            }
            else if (pi.bitmapFont != null) 
            {
                ;
            }
        }
    }
    
    private function get_id() : String
    {
        return _id;
    }
    
    private function get_name() : String
    {
        return _name;
    }
    
    private function get_customId() : String
    {
        return _customId;
    }
    
    private function set_customId(value : String) : String
    {
        if (_customId != null) 
            ;
        _customId = value;
        if (_customId != null) 
            Reflect.setField(_packageInstById, _customId, this);
        return value;
    }
    
    public function createObject(resName : String, userClass : Class<Dynamic> = null) : GObject
    {
        var pi : PackageItem = Reflect.field(_itemsByName, resName);
        if (pi != null) 
            return createObject2(pi, userClass)
        else 
        return null;
    }
    
    @:allow(fairygui)
    private function createObject2(pi : PackageItem, userClass : Class<Dynamic> = null) : GObject
    {
        var g : GObject;
        if (pi.type == PackageItemType.Component) 
        {
            if (userClass != null) 
                g = Type.createInstance(userClass, [])
            else 
            g = UIObjectFactory.newObject(pi);
        }
        else 
        g = UIObjectFactory.newObject(pi);
        
        if (g == null) 
            return null;
        
        _constructing++;
        g.constructFromResource(pi);
        _constructing--;
        return g;
    }
    
    public function getItemById(itemId : String) : PackageItem
    {
        return Reflect.field(_itemsById, itemId);
    }
    
    public function getItemByName(resName : String) : PackageItem
    {
        return Reflect.field(_itemsByName, resName);
    }
    
    private function getXMLDesc(file : String) : FastXML
    {
        var ignoreWhitespace : Bool = FastXML.ignoreWhitespace;
        FastXML.ignoreWhitespace = true;
        var ret : FastXML = new FastXML(_reader.readDescFile(file));
        FastXML.ignoreWhitespace = ignoreWhitespace;
        return ret;
    }
    
    public function getItemRaw(item : PackageItem) : ByteArray
    {
        return _reader.readResFile(item.file);
    }
    
    public function getComponentData(item : PackageItem) : FastXML
    {
        if (!item.componentData) 
        {
            var xml : FastXML = getXMLDesc(item.id + ".xml");
            
            if (_stringsSource != null) 
            {
                var col : Dynamic = _stringsSource[this.id + item.id];
                if (col != null) 
                    translateComponent(xml, col);
            }
            
            item.componentData = xml;
        }
        
        return item.componentData;
    }
    
    private function translateComponent(xml : FastXML, strings : Dynamic) : Void
    {
        var displayList : Dynamic = xml.node.displayList.innerData.node.elements.innerData();
        var value : Dynamic;
        for (cxml/* AS3HX WARNING could not determine type for var: cxml exp: EIdent(displayList) type: Dynamic */ in displayList)
        {
            var ename : String = cxml.name().localName;
            var elementId : String = cxml.att.id;
            
            if (cxml.att.tooltips.length() > 0) 
            {
                value = strings[elementId + "-tips"];
                if (value != null) 
                    cxml.setAttribute("tooltips", value);
            }
            
            if (ename == "text" || ename == "richtext") 
            {
                value = Reflect.field(strings, elementId);
                if (value != null) 
                    cxml.setAttribute("text", value);
            }
            else if (ename == "list") 
            {
                var items : FastXMLList = cxml.item;
                var j : Int = 0;
                for (exml in items)
                {
                    value = strings[elementId + "-" + j];
                    if (value != null) 
                        exml.setAttribute("title", value);
                    j++;
                }
            }
            else if (ename == "component") 
            {
                var dxml : FastXML = cxml.Button[0];
                if (dxml != null) 
                {
                    value = Reflect.field(strings, elementId);
                    if (value != null) 
                        dxml.setAttribute("title", value);
                    value = strings[elementId + "-0"];
                    if (value != null) 
                        dxml.setAttribute("selectedTitle", value);
                }
                else 
                {
                    dxml = cxml.Label[0];
                    if (dxml != null) 
                    {
                        value = Reflect.field(strings, elementId);
                        if (value != null) 
                            dxml.setAttribute("title", value);
                    }
                    else 
                    {
                        dxml = cxml.ComboBox[0];
                        if (dxml != null) 
                        {
                            value = Reflect.field(strings, elementId);
                            if (value != null) 
                                dxml.setAttribute("title", value);
                            
                            items = dxml.node.item.innerData;
                            j = 0;
                            for (exml in items)
                            {
                                value = strings[elementId + "-" + j];
                                if (value != null) 
                                    exml.setAttribute("title", value);
                                j++;
                            }
                        }
                    }
                }
            }
        }
    }
    
    public function getImage(resName : String) : Texture
    {
        var pi : PackageItem = Reflect.field(_itemsByName, resName);
        if (pi != null) 
            return pi.texture
        else 
        return null;
    }
    
    public function getSound(item : PackageItem) : Sound
    {
        if (!item.loaded) 
            loadSound(item);
        return item.sound;
    }
    
    public function addCallback(resName : String, callback : Dynamic) : Void
    {
        var pi : PackageItem = Reflect.field(_itemsByName, resName);
        if (pi != null) 
            addItemCallback(pi, callback);
    }
    
    public function removeCallback(resName : String, callback : Dynamic) : Void
    {
        var pi : PackageItem = Reflect.field(_itemsByName, resName);
        if (pi != null) 
            removeItemCallback(pi, callback);
    }
    
    public function addItemCallback(pi : PackageItem, callback : Dynamic) : Void
    {
        pi.lastVisitTime = Math.round(haxe.Timer.stamp() * 1000);
        if (pi.type == PackageItemType.Image) 
        {
            if (pi.loaded) 
            {
                GTimers.inst.add(0, 1, callback);
                return;
            }
            
            pi.addCallback(callback);
            if (pi.loading) 
                return;
            
            loadImage(pi);
        }
        else if (pi.type == PackageItemType.Atlas) 
        {
            if (pi.loaded) 
            {
                GTimers.inst.add(0, 1, callback);
                return;
            }
            
            pi.addCallback(callback);
            if (pi.loading) 
                return;
            
            loadAtlas(pi);
        }
        else if (pi.type == PackageItemType.MovieClip) 
        {
            if (pi.loaded) 
            {
                GTimers.inst.add(0, 1, callback);
                return;
            }
            
            pi.addCallback(callback);
            if (pi.loading) 
                return;
            
            loadMovieClip(pi);
        }
        else if (pi.type == PackageItemType.Swf) 
        {
            //pi.addCallback(callback);
            //loadSwf(pi);
            
        }
        else if (pi.type == PackageItemType.Sound) 
        {
            if (!pi.loaded) 
                loadSound(pi);
            
            GTimers.inst.add(0, 1, callback);
        }
    }
    
    public function removeItemCallback(pi : PackageItem, callback : Dynamic) : Void
    {
        pi.removeCallback(callback);
    }
    
    private function loadImage(pi : PackageItem) : Void
    {
        var sprite : AtlasSprite = _sprites[pi.id];
        if (sprite == null) 
        {
            GTimers.inst.callLater(pi.completeLoading);
            return;
        }
        
        var atlasItem : PackageItem = _itemsById[sprite.atlas];
        if (atlasItem != null) 
        {
            pi.uvRect = new Rectangle(sprite.rect.x / atlasItem.width, sprite.rect.y / atlasItem.height, 
                    sprite.rect.width / atlasItem.width, sprite.rect.height / atlasItem.height);
            if (atlasItem.loaded) 
            {
                pi.texture = Texture.fromTexture(atlasItem.texture, sprite.rect);
            }
            else 
            {
                addItemCallback(atlasItem, pi.onAltasLoaded);
                pi.loading = true;
                return;
            }
        }
        GTimers.inst.callLater(pi.completeLoading);
    }
    
    private function loadAtlas(pi : PackageItem) : Void
    {
        var ba : ByteArray = _reader.readResFile((pi.file) ? pi.file : (pi.id + ".png"));
        if (ba != null) 
        {
            var loader : PackageItemLoader = new PackageItemLoader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, __atlasLoaded);
            loader.loadBytes(ba);
            
            loader.item = pi;
            pi.loading = true;
            _loadingQueue.push(loader);
        }
        else 
        {
            ba = _reader.readResFile(pi.id + ".atf");
            if (ba != null) 
            {
                if (pi.texture != null) 
                    pi.texture.root.uploadAtfData(ba)
                else 
                {
                    pi.loading = true;
                    Texture.fromAtfData(ba, 1, false, function(texture : Texture) : Void
                            {
                                pi.texture = texture;
                                pi.texture.root.onRestore = function() : Void
                                        {
                                            loadAtlas(pi);
                                        };
                                ba.clear();
                                pi.completeLoading();
                            });
                }
            }
        }
    }
    
    private function __atlasLoaded(evt : Event) : Void
    {
        var loader : PackageItemLoader = cast((cast((evt.currentTarget), LoaderInfo).loader), PackageItemLoader);
        var i : Int = Lambda.indexOf(_loadingQueue, loader);
        if (i == -1) 
            return;
        
        _loadingQueue.splice(i, 1);
        
        var pi : PackageItem = loader.item;
        var bmd : BitmapData = cast((loader.content), Bitmap).bitmapData;
        if (pi.texture != null) 
            pi.texture.root.uploadBitmapData(bmd)
        else 
        {
            if (bmd.transparent) 
                pi.texture = Texture.fromBitmapData(bmd, false)
            else 
            pi.texture = Texture.fromBitmapData(bmd, false, false, 1, "bgrPacked565");
            pi.texture.root.onRestore = function() : Void
                    {
                        loadAtlas(pi);
                    };
        }
        bmd.dispose();
        pi.completeLoading();
    }
    
    @:allow(fairygui)
    private function notifyImageAtlasReady(pi : PackageItem, atlasItem : PackageItem) : Void
    {
        if (pi.type == PackageItemType.Image) 
        {
            var sprite : AtlasSprite = _sprites[pi.id];
            pi.texture = Texture.fromTexture(atlasItem.texture, sprite.rect);
            pi.completeLoading();
        }
        else if (pi.type == PackageItemType.MovieClip) 
        {
            var cnt : Int = pi.frames.length;
            for (i in 0...cnt){
                var frame : Frame = pi.frames[i];
                sprite = _sprites[pi.id + "_" + i];
                if (sprite != null) 
                    frame.texture = Texture.fromTexture(atlasItem.texture, sprite.rect);
            }
            pi.completeLoading();
        }
        else if (pi.type == PackageItemType.Font) 
        {
            pi.bitmapFont.mainTexture = atlasItem.texture;
            pi.completeLoading();
        }
    }
    
    private function loadMovieClip(item : PackageItem) : Void
    {
        var xml : FastXML = getXMLDesc(item.id + ".xml");
        item.pivot = new Point();
        var str : String = xml.att.pivot;
        if (str != null) 
        {
            var arr : Array<Dynamic> = str.split(sep0);
            item.pivot.x = Int(arr[0]);
            item.pivot.y = Int(arr[1]);
        }
        
        str = xml.att.interval;
        if (str != null) 
            item.interval = parseInt(str);
        str = xml.att.swing;
        if (str != null) 
            item.swing = str == "true";
        str = xml.att.repeatDelay;
        if (str != null) 
            item.repeatDelay = parseInt(str);
        
        var atlasItem : PackageItem;
        
        var frameCount : Int = parseInt(xml.att.frameCount);
        item.frames = new Array<Frame>();
        var frameNodes : FastXMLList = xml.node.frames.innerData.node.elements.innerData();
        for (i in 0...frameCount){
            var frame : Frame = new Frame();
            var frameNode : FastXML = frameNodes.get(i);
            str = frameNode.att.rect;
            arr = str.split(sep0);
            frame.rect = new Rectangle(parseInt(arr[0]), parseInt(arr[1]), parseInt(arr[2]), parseInt(arr[3]));
            str = frameNode.att.addDelay;
            frame.addDelay = parseInt(str);
            item.frames[i] = frame;
            
            var sprite : AtlasSprite = _sprites[item.id + "_" + i];
            if (sprite != null) 
            {
                if (atlasItem == null) 
                    atlasItem = _itemsById[sprite.atlas];
                if (atlasItem != null && atlasItem.loaded) 
                    frame.texture = Texture.fromTexture(atlasItem.texture, sprite.rect);
            }
        }
        
        if (atlasItem != null && !atlasItem.loaded) 
        {
            addItemCallback(atlasItem, item.onAltasLoaded);
        }
        else 
        GTimers.inst.callLater(item.completeLoading);
    }
    
    private function loadSound(item : PackageItem) : Void
    {
        var sound : Sound = new Sound();
        var ba : ByteArray = _reader.readResFile(item.file);
        sound.loadCompressedDataFromByteArray(ba, ba.length);
        item.sound = sound;
        item.loaded = true;
    }
    
    private function loadFont(item : PackageItem) : Void
    {
        var font : BitmapFont = new BitmapFont();
        font.id = "ui://" + this.id + item.id;
        var str : String = _reader.readDescFile(item.id + ".fnt");
        
        var lines : Array<Dynamic> = str.split(sep1);
        var lineCount : Int = lines.length;
        var i : Int;
        var kv : Dynamic = { };
        var ttf : Bool = false;
        var lineHeight : Int = 0;
        var xadvance : Int = 0;
        var atlasOffsetX : Int;
        var atlasOffsetY : Int;
        var atlasWidth : Int;
        var atlasHeight : Int;
        var mainTexture : Texture;
        
        for (i in 0...lineCount){
            str = lines[i];
            if (str.length == 0) 
                {i++;continue;
            };
            
            str = ToolSet.trim(str);
            var arr : Array<Dynamic> = str.split(sep2);
            for (j in 1...arr.length){
                var arr2 : Array<Dynamic> = arr[j].split(sep3);
                Reflect.setField(kv, Std.string(arr2[0]), arr2[1]);
            }
            
            str = arr[0];
            if (str == "char") 
            {
                var bg : BMGlyph = new BMGlyph();
                bg.x = kv.x;
                bg.y = kv.y;
                bg.offsetX = kv.xoffset;
                bg.offsetY = kv.yoffset;
                bg.width = kv.width;
                bg.height = kv.height;
                bg.advance = kv.xadvance;
                if (kv.chnl != null) 
                {
                    bg.channel = kv.chnl;
                    if (bg.channel == 15) 
                        bg.channel = 4
                    else if (bg.channel == 1) 
                        bg.channel = 3
                    else if (bg.channel == 2) 
                        bg.channel = 2
                    else 
                    bg.channel = 1;
                }
                
                if (!ttf) 
                {
                    if (kv.img) 
                    {
                        var charImg : PackageItem = _itemsById[kv.img];
                        if (charImg != null) 
                        {
                            if (charImg.loaded) 
                            {
                                if (mainTexture == null) 
                                    mainTexture = charImg.texture.root;
                            }
                            else 
                            {
                                loadImage(charImg);
                                if (mainTexture == null) 
                                    charImg.addCallback(item.onAltasLoaded);
                            }
                            
                            bg.width = charImg.width;
                            bg.height = charImg.height;
                            bg.uvRect = charImg.uvRect;
                        }
                    }
                }
                else 
                {
                    bg.uvRect = new Rectangle((bg.x + atlasOffsetX) / atlasWidth, (bg.y + atlasOffsetY) / atlasHeight, 
                            bg.width / atlasWidth, bg.height / atlasHeight);
                }
                
                if (ttf) 
                    bg.lineHeight = lineHeight
                else 
                {
                    if (bg.advance == 0) 
                    {
                        if (xadvance == 0) 
                            bg.advance = bg.offsetX + bg.width
                        else 
                        bg.advance = xadvance;
                    }
                    
                    bg.lineHeight = bg.offsetY < (0) ? bg.height : (bg.offsetY + bg.height);
                    if (bg.lineHeight < lineHeight) 
                        bg.lineHeight = lineHeight;
                }
                
                font.glyphs[String.fromCharCode(kv.id)] = bg;
            }
            else if (str == "info") 
            {
                ttf = kv.face != null;
                if (ttf) 
                {
                    var sprite : AtlasSprite = _sprites[item.id];
                    if (sprite != null) 
                    {
                        atlasOffsetX = sprite.rect.x;
                        atlasOffsetY = sprite.rect.y;
                        var atlasItem : PackageItem = _itemsById[sprite.atlas];
                        if (atlasItem != null) 
                        {
                            atlasWidth = atlasItem.width;
                            atlasHeight = atlasItem.height;
                            if (atlasItem.loaded) 
                                mainTexture = Texture.fromTexture(atlasItem.texture, sprite.rect)
                            else 
                            {
                                addItemCallback(atlasItem, item.onAltasLoaded);
                                item.loading = true;
                            }
                        }
                    }
                }
            }
            else if (str == "common") 
            {
                lineHeight = kv.lineHeight;
                xadvance = kv.xadvance;
            }
        }
        
        font.mainTexture = mainTexture;
        font.ttf = ttf;
        font.lineHeight = lineHeight;
        item.bitmapFont = font;
    }
}




class PackageItemLoader extends Loader
{
    public function new()
    {
        super();
        
        
    }
    public var item : PackageItem;
}

class FrameLoader extends Loader
{
    public function new()
    {
        super();
        
        
    }
    
    public var item : PackageItem;
    public var frame : Frame;
}

class AtlasSprite
{
    public function new()
    {
        rect = new Rectangle();
    }
    
    public var atlas : String;
    public var rect : Rectangle;
    public var rotated : Bool;
}