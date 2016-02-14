package fairygui;

import fairygui.GObject;
import fairygui.IColorGear;

import openfl.filters.DropShadowFilter;
import openfl.geom.Point;
import openfl.text.AntiAliasType;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;

import fairygui.display.TextCanvas;
import fairygui.display.UITextField;
import fairygui.text.BMGlyph;
import fairygui.text.BitmapFont;
import fairygui.utils.CharSize;
import fairygui.utils.ToolSet;

import starling.events.Event;

import haxe.xml.Fast;

class GTextField extends GObject implements IColorGear
{
    public var font(get, set) : String;
    public var fontSize(get, set) : Int;
    public var color(get, set) : Int;
    public var align(get, set) : Int;
    public var verticalAlign(get, set) : Int;
    public var leading(get, set) : Int;
    public var letterSpacing(get, set) : Int;
    public var underline(get, set) : Bool;
    public var bold(get, set) : Bool;
    public var italic(get, set) : Bool;
    public var singleLine(get, set) : Bool;
    public var stroke(get, set) : Bool;
    public var strokeColor(get, set) : Int;
    public var ubbEnabled(get, set) : Bool;
    public var autoSize(get, set) : Int;
    public var displayAsPassword(get, set) : Bool;
    public var textWidth(get, never) : Int;
    public var gearColor(get, never) : GearColor;

    private var _ubbEnabled : Bool;
    private var _autoSize : Int;
    private var _widthAutoSize : Bool;
    private var _heightAutoSize : Bool;
    private var _textFormat : TextFormat;
    private var _text : String;
    private var _font : String;
    private var _fontSize : Int;
    private var _align : Int;
    private var _verticalAlign : Int;
    private var _color : Int;
    private var _leading : Int;
    private var _letterSpacing : Int;
    private var _underline : Bool;
    private var _bold : Bool;
    private var _italic : Bool;
    private var _singleLine : Bool;
    private var _stroke : Bool;
    private var _strokeColor : Int;
    private var _displayAsPassword : Bool;
    private var _textFilters : Array<Dynamic>;
    
    private var _gearColor : GearColor;
    
    private var _canvas : TextCanvas;
    
    private var _updatingSize : Bool;
    private var _requireRender : Bool;
    private var _sizeDirty : Bool;
    private var _yOffset : Int;
    private var _textWidth : Int;
    private var _textHeight : Int;
    private var _fontAdjustment : Int;
    private var _minHeight : Int;
    
    private var _bitmapFont : BitmapFont;
    private var _lines : Array<LineInfo>;
    
    private static var renderTextField : TextField = new TextField();
    private static var sHelperPoint : Point = new Point();
    
    private static inline var GUTTER_X : Int = 2;
    private static inline var GUTTER_Y : Int = 2;
    
    public function new()
    {
        super();
        
        _textFormat = new TextFormat();
        _fontSize = 12;
        _color = 0;
        _align = AlignType.Left;
        _verticalAlign = VertAlignType.Top;
        _text = "";
        _leading = 3;
        
        _autoSize = AutoSizeType.Both;
        _widthAutoSize = true;
        _heightAutoSize = true;
        
        _gearColor = new GearColor(this);
    }
    
    override private function createDisplayObject() : Void
    {
        _canvas = new UITextField(this);
        setDisplayObject(_canvas);
        _canvas.addEventListener(Event.REMOVED_FROM_STAGE, __removeFromStage);
        _canvas.renderCallback = onRender;
    }
    
    override public function dispose() : Void
    {
        super.dispose();
        
        _requireRender = false;
        _bitmapFont = null;
    }
    
    override private function set_text(value : String) : String
    {
        _text = value;
        if (_text == null) 
            _text = "";
        
        if (parent != null && parent._underConstruct) 
            renderNow()
        else 
        render();
        return value;
    }
    
    override private function get_text() : String
    {
        return _text;
    }
    
    @:final private function get_font() : String
    {
        return _font;
    }
    
    private function set_font(value : String) : String
    {
        if (_font != value) 
        {
            _font = value;
            updateTextFormat();
        }
        return value;
    }
    
    @:final private function get_fontSize() : Int
    {
        return _fontSize;
    }
    
    private function set_fontSize(value : Int) : Int
    {
        if (value < 0) 
            return;
        
        if (_fontSize != value) 
        {
            _fontSize = value;
            updateTextFormat();
        }
        return value;
    }
    
    @:final private function get_color() : Int
    {
        return _color;
    }
    
    private function set_color(value : Int) : Int
    {
        if (_color != value) 
        {
            _color = value;
            if (_gearColor.controller) 
                _gearColor.updateState();
            
            updateTextFormat();
        }
        return value;
    }
    
    @:final private function get_align() : Int
    {
        return _align;
    }
    
    private function set_align(value : Int) : Int
    {
        if (_align != value) 
        {
            _align = value;
            updateTextFormat();
        }
        return value;
    }
    
    @:final private function get_verticalAlign() : Int
    {
        return _verticalAlign;
    }
    
    private function set_verticalAlign(value : Int) : Int
    {
        if (_verticalAlign != value) 
        {
            _verticalAlign = value;
            doAlign();
        }
        return value;
    }
    
    @:final private function get_leading() : Int
    {
        return _leading;
    }
    
    private function set_leading(value : Int) : Int
    {
        if (_leading != value) 
        {
            _leading = value;
            updateTextFormat();
        }
        return value;
    }
    
    @:final private function get_letterSpacing() : Int
    {
        return _letterSpacing;
    }
    
    private function set_letterSpacing(value : Int) : Int
    {
        if (_letterSpacing != value) 
        {
            _letterSpacing = value;
            updateTextFormat();
        }
        return value;
    }
    
    @:final private function get_underline() : Bool
    {
        return _underline;
    }
    
    private function set_underline(value : Bool) : Bool
    {
        if (_underline != value) 
        {
            _underline = value;
            updateTextFormat();
        }
        return value;
    }
    
    @:final private function get_bold() : Bool
    {
        return _bold;
    }
    
    private function set_bold(value : Bool) : Bool
    {
        if (_bold != value) 
        {
            _bold = value;
            updateTextFormat();
        }
        return value;
    }
    
    @:final private function get_italic() : Bool
    {
        return _italic;
    }
    
    private function set_italic(value : Bool) : Bool
    {
        if (_italic != value) 
        {
            _italic = value;
            updateTextFormat();
        }
        return value;
    }
    
    private function get_singleLine() : Bool
    {
        return _singleLine;
    }
    
    private function set_singleLine(value : Bool) : Bool
    {
        if (_singleLine != value) 
        {
            _singleLine = value;
            render();
        }
        return value;
    }
    
    @:final private function get_stroke() : Bool
    {
        return _stroke;
    }
    
    private function set_stroke(value : Bool) : Bool
    {
        if (_stroke != value) 
        {
            _stroke = value;
            if (_stroke) 
                _textFilters = createStrokeFilters(_strokeColor)
            else 
            _textFilters = null;
            render();
        }
        return value;
    }
    
    private static function createStrokeFilters(color : Int) : Array<Dynamic>
    {
        return [new DropShadowFilter(1, 45, color, 1, 1, 1, 5, 1), 
        new DropShadowFilter(1, 222, color, 1, 1, 1, 5, 1)];
    }
    
    @:final private function get_strokeColor() : Int
    {
        return _strokeColor;
    }
    
    private function set_strokeColor(value : Int) : Int
    {
        if (_strokeColor != value) 
        {
            _strokeColor = value;
            if (_stroke) 
                _textFilters = createStrokeFilters(_strokeColor);
            render();
        }
        return value;
    }
    
    private function set_ubbEnabled(value : Bool) : Bool
    {
        if (_ubbEnabled != value) 
        {
            _ubbEnabled = value;
            render();
        }
        return value;
    }
    
    @:final private function get_ubbEnabled() : Bool
    {
        return _ubbEnabled;
    }
    
    private function set_autoSize(value : Int) : Int
    {
        if (_autoSize != value) 
        {
            _autoSize = value;
            _widthAutoSize = value == AutoSizeType.Both;
            _heightAutoSize = value == AutoSizeType.Both || value == AutoSizeType.Height;
            render();
        }
        return value;
    }
    
    @:final private function get_autoSize() : Int
    {
        return _autoSize;
    }
    
    @:final private function get_displayAsPassword() : Bool
    {
        return _displayAsPassword;
    }
    
    private function set_displayAsPassword(val : Bool) : Bool
    {
        if (_displayAsPassword != val) 
        {
            _displayAsPassword = val;
            render();
        }
        return val;
    }
    
    private function get_textWidth() : Int
    {
        this.ensureSizeCorrect();
        return _textWidth;
    }
    
    override public function ensureSizeCorrect() : Void
    {
        if (_sizeDirty && _requireRender) 
            renderNow();
    }
    
    @:final private function get_gearColor() : GearColor
    {
        return _gearColor;
    }
    
    override public function handleControllerChanged(c : Controller) : Void
    {
        super.handleControllerChanged(c);
        
        if (_gearColor.controller == c) 
            _gearColor.apply();
    }
    
    private function updateTextFormat() : Void
    {
        _textFormat.size = _fontSize;
        if (ToolSet.startsWith(_font, "ui://")) 
        {
            _bitmapFont = UIPackage.getBitmapFontByURL(_font);
            _fontAdjustment = 0;
            _minHeight = Int.MAX_VALUE;
        }
        else 
        {
            _bitmapFont = null;
            
            if (_font != null) 
                _textFormat.font = _font
            else 
            _textFormat.font = UIConfig.defaultFont;
            
            var v : Int = CharSize.getHeight(Int(_textFormat.size), _textFormat.font, _bold);
            _minHeight = v + 4 - _fontAdjustment;
            
            //像微软雅黑这样的字体，默认的渲染顶部会产生很大的空间，这里加一个调整值，消除这些多余的空间
            v = v - Int(_textFormat.size);
            if (v > 3) 
                _fontAdjustment = Math.ceil(v / 2);
        }
        
        if (this.grayed) 
            _textFormat.color = 0xAAAAAA
        else 
        _textFormat.color = _color;
        _textFormat.align = Std.string(AlignType);
        _textFormat.leading = _leading - _fontAdjustment;
        if (_textFormat.leading < 0) 
            _textFormat.leading = 0;
        _textFormat.letterSpacing = _letterSpacing;
        _textFormat.bold = _bold;
        _textFormat.underline = _underline;
        _textFormat.italic = _italic;
        
        if (!_underConstruct) 
            render();
    }
    
    private function render() : Void
    {
        _requireRender = true;
        if (_widthAutoSize || _heightAutoSize) 
        {
            _sizeDirty = true;
            _dispatcher.dispatch(this, GObject.SIZE_DELAY_CHANGE);
        }
    }
    
    private function onRender() : Void
    {
        if (_requireRender) 
            renderNow();
    }
    
    private function __removeFromStage(evt : Event) : Void
    {
        clearCanvas();
    }
    
    private function renderNow(updateBounds : Bool = true) : Void
    {
        _requireRender = false;
        _sizeDirty = false;
        
        if (_bitmapFont != null) 
        {
            renderWithBitmapFont(updateBounds);
            return;
        }
        
        renderTextField.defaultTextFormat = _textFormat;
        renderTextField.selectable = false;
        if (_widthAutoSize) 
        {
            renderTextField.autoSize = TextFieldAutoSize.LEFT;
            renderTextField.wordWrap = false;
        }
        else 
        {
            renderTextField.autoSize = TextFieldAutoSize.NONE;
            renderTextField.wordWrap = !_singleLine;
        }
        renderTextField.width = this.width;
        renderTextField.height = Math.max(this.height, Int(_textFormat.size));
        renderTextField.multiline = !_singleLine;
        renderTextField.antiAliasType = AntiAliasType.ADVANCED;
        renderTextField.filters = _textFilters;
        
        updateTextFieldText();
        
        var renderSingleLine : Bool = renderTextField.numLines <= 1;
        
        _textWidth = Math.ceil(renderTextField.textWidth);
        if (_textWidth > 0) 
            _textWidth += 5;
        _textHeight = Math.ceil(renderTextField.textHeight);
        if (_textHeight > 0) 
        {
            if (renderSingleLine) 
                _textHeight += 1
            else 
            _textHeight += 4;
        }
        
        var w : Int;
        var h : Int;
        if (_widthAutoSize) 
            w = _textWidth
        else 
        w = this.width;
        
        if (_heightAutoSize) 
        {
            h = _textHeight;
            if (!_widthAutoSize) 
                renderTextField.height = _textHeight + _fontAdjustment + 3;
        }
        else 
        {
            h = this.height;
            var h2 : Int = Math.ceil(h);
            if (h2 > 0 && h2 < _minHeight) 
            {
                h2 = _minHeight;
                h = h2;
            }
            if (_textHeight > h2) 
                _textHeight = h2;
            renderTextField.height = _textHeight + _fontAdjustment + 3;
        }
        
        if (updateBounds) 
        {
            _updatingSize = true;
            this.setSize(w, h);
            _updatingSize = false;
            
            doAlign();
        }
        
        _canvas.renderText(renderTextField, _textWidth, _textHeight, _fontAdjustment, clearCanvas);
        renderTextField.text = "";
    }
    
    private function updateTextFieldText() : Void
    {
        if (_displayAsPassword) 
        {
            var str : String = "";
            var cnt : Int = _text.length;
            for (i in 0...cnt){str += "*";
            }
            renderTextField.text = str;
        }
        else if (_ubbEnabled) 
            renderTextField.htmlText = ToolSet.parseUBB(ToolSet.encodeHTML(_text))
        else 
        renderTextField.text = _text;
    }
    
    private function clearCanvas() : Void
    {
        if (_canvas.textureMemory > 0) 
        {
            _canvas.clear();
            _requireRender = true;
        }
    }
    
    private function renderWithBitmapFont(updateBounds : Bool) : Void
    {
        if (_lines == null) 
            _lines = new Array<LineInfo>()
        else 
        LineInfo.returnList(_lines);
        
        var letterSpacing : Int = _letterSpacing;
        var lineSpacing : Int = _leading - 1;
        var fontSize : Int = Int(_textFormat.size);
        var rectWidth : Int = this.width - GUTTER_X * 2;
        var lineWidth : Int = 0;
        var lineHeight : Int = 0;
        var lineTextHeight : Int = 0;
        var glyphWidth : Int = 0;
        var glyphHeight : Int = 0;
        var wordChars : Int = 0;
        var wordStart : Int = 0;
        var wordEnd : Int = 0;
        var lastLineHeight : Int = 0;
        var lineBuffer : String = "";
        var lineY : Int = GUTTER_Y;
        var line : LineInfo;
        var textWidth : Int;
        var textHeight : Int;
        var wordWrap : Bool = !_widthAutoSize && !_singleLine;
        
        var textLength : Int = _text.length;
        for (offset in 0...textLength){
            var ch : String = _text.charAt(offset);
            var cc : Int = ch.charCodeAt(offset);
            
            if (ch == "\n") 
            {
                lineBuffer += ch;
                line = LineInfo.borrow();
                line.width = lineWidth;
                if (lineTextHeight == 0) 
                {
                    if (lastLineHeight == 0) 
                        lastLineHeight = fontSize;
                    if (lineHeight == 0) 
                        lineHeight = lastLineHeight;
                    lineTextHeight = lineHeight;
                }
                line.height = lineHeight;
                lastLineHeight = lineHeight;
                line.textHeight = lineTextHeight;
                line.text = lineBuffer;
                line.y = lineY;
                lineY += (line.height + lineSpacing);
                if (line.width > textWidth) 
                    textWidth = line.width;
                _lines.push(line);
                
                lineBuffer = "";
                lineWidth = 0;
                lineHeight = 0;
                lineTextHeight = 0;
                wordChars = 0;
                wordStart = 0;
                wordEnd = 0;
                {++offset;continue;
                }
            }
            
            if (cc > 256 || cc <= 32) 
            {
                if (wordChars > 0) 
                    wordEnd = lineWidth;
                wordChars = 0;
            }
            else 
            {
                if (wordChars == 0) 
                    wordStart = lineWidth;
                wordChars++;
            }
            
            if (ch == " ") 
            {
                glyphWidth = fontSize / 2;
                glyphHeight = fontSize;
            }
            else 
            {
                var glyph : BMGlyph = _bitmapFont.glyphs[ch];
                if (glyph != null) 
                {
                    glyphWidth = glyph.advance;
                    glyphHeight = glyph.lineHeight;
                }
                else if (ch == " ") 
                {
                    glyphWidth = Math.ceil(_bitmapFont.lineHeight / 2);
                    glyphHeight = _bitmapFont.lineHeight;
                }
                else 
                {
                    glyphWidth = 0;
                    glyphHeight = 0;
                }
            }
            if (glyphHeight > lineTextHeight) 
                lineTextHeight = glyphHeight;
            
            if (glyphHeight > lineHeight) 
                lineHeight = glyphHeight;
            
            if (lineWidth != 0) 
                lineWidth += letterSpacing;
            lineWidth += glyphWidth;
            
            if (!wordWrap || lineWidth <= rectWidth) 
            {
                lineBuffer += ch;
            }
            else 
            {
                line = LineInfo.borrow();
                line.height = lineHeight;
                line.textHeight = lineTextHeight;
                
                if (lineBuffer.length == 0)   //the line cannt fit even a char  
                {
                    line.text = ch;
                }
                else if (wordChars > 0 && wordEnd > 0)   //if word had broken, move it to new line  
                {
                    lineBuffer += ch;
                    var len : Int = lineBuffer.length - wordChars;
                    line.text = ToolSet.trimRight(lineBuffer.substr(0, len));
                    line.width = wordEnd;
                    lineBuffer = lineBuffer.substr(len + 1);
                    lineWidth -= wordStart;
                }
                else 
                {
                    line.text = lineBuffer;
                    line.width = lineWidth - (glyphWidth + letterSpacing);
                    lineBuffer = ch;
                    lineWidth = glyphWidth;
                    lineHeight = glyphHeight;
                    lineTextHeight = glyphHeight;
                }
                line.y = lineY;
                lineY += (line.height + lineSpacing);
                if (line.width > textWidth) 
                    textWidth = line.width;
                
                wordChars = 0;
                wordStart = 0;
                wordEnd = 0;
                _lines.push(line);
            }
        }
        
        if (lineBuffer.length > 0 || _lines.length > 0 && ToolSet.endsWith(_lines[_lines.length - 1].text, "\n")) 
        {
            line = LineInfo.borrow();
            line.width = lineWidth;
            if (lineHeight == 0) 
                lineHeight = lastLineHeight;
            if (lineTextHeight == 0) 
                lineTextHeight = lineHeight;
            line.height = lineHeight;
            line.textHeight = lineTextHeight;
            line.text = lineBuffer;
            line.y = lineY;
            if (line.width > textWidth) 
                textWidth = line.width;
            _lines.push(line);
        }
        
        if (textWidth > 0) 
            textWidth += GUTTER_X * 2;
        
        var count : Int = _lines.length;
        if (count == 0) 
        {
            textHeight = 0;
        }
        else 
        {
            line = _lines[_lines.length - 1];
            textHeight = line.y + line.height + GUTTER_Y;
        }
        
        var w : Int;
        var h : Int;
        if (_widthAutoSize) 
        {
            if (textWidth == 0) 
                w = 0
            else 
            w = textWidth;
        }
        else 
        w = this.width;
        
        if (_heightAutoSize) 
        {
            if (textHeight == 0) 
                h = 0
            else 
            h = textHeight;
        }
        else 
        h = this.height;
        
        if (updateBounds) 
        {
            _updatingSize = true;
            this.setSize(w, h);
            _updatingSize = false;
            
            doAlign();
        }
        
        _canvas.clear();
        _canvas.setSize(w, h);
        
        if (w == 0 || h == 0) 
            return;
        
        var charX : Int = GUTTER_X;
        var lineIndent : Int;
        var charIndent : Int;
        
        var lineCount : Int = _lines.length;
        for (i in 0...lineCount){
            line = _lines[i];
            charX = GUTTER_X;
            
            if (_align == AlignType.Center) 
                lineIndent = (rectWidth - line.width) / 2
            else if (_align == AlignType.Right) 
                lineIndent = rectWidth - line.width
            else 
            lineIndent = 0;
            textLength = line.text.length;
            for (j in 0...textLength){
                ch = line.text.charAt(j);
                
                glyph = _bitmapFont.glyphs[ch];
                if (glyph != null) 
                {
                    charIndent = (line.height + line.textHeight) / 2 - glyph.lineHeight;
                    sHelperPoint.x = charX + lineIndent;
                    sHelperPoint.y = line.y + charIndent;
                    _canvas.drawChar(_bitmapFont, glyph, sHelperPoint, _color);
                    
                    charX += letterSpacing + glyph.advance;
                }
                else if (ch == " ") 
                {
                    charX += letterSpacing + Math.ceil(_bitmapFont.lineHeight / 2);
                }
                else 
                {
                    charX += letterSpacing;
                }
            }  //text loop  
        }  //line loop  
    }
    
    override private function handleXYChanged() : Void
    {
        displayObject.x = this.x;
        displayObject.y = this.y + _yOffset;
    }
    
    override private function handleSizeChanged() : Void
    {
        if (!_updatingSize) 
        {
            if (!_widthAutoSize) 
                render()
            else 
            doAlign();
        }
    }
    
    override private function handleGrayChanged() : Void
    {
        if (_bitmapFont != null) 
            super.handleGrayChanged();
        
        updateTextFormat();
    }
    
    private function doAlign() : Void
    {
        if (_verticalAlign == VertAlignType.Top || _textHeight == 0) 
            _yOffset = 0
        else 
        {
            var dh : Float = this.height - _textHeight;
            if (dh < 0) 
                dh = 0;
            if (_verticalAlign == VertAlignType.Middle) 
                _yOffset = Int(dh / 2) - _fontAdjustment
            else 
            _yOffset = Int(dh) - _fontAdjustment;
        }
        displayObject.y = this.y + _yOffset;
    }
    
    override public function setup_beforeAdd(xml : Fast) : Void
    {
        super.setup_beforeAdd(xml);
        
        var str : String;
        _displayAsPassword = xml.att.password == "true";
        str = xml.att.font;
        if (str != null) 
            _font = str;
        
        str = xml.att.fontSize;
        if (str != null) 
            _fontSize = parseInt(str);
        
        str = xml.att.color;
        if (str != null) 
            _color = ToolSet.convertFromHtmlColor(str);
        
        str = xml.att.align;
        if (str != null) 
            _align = AlignType.parse(str);
        
        str = xml.att.vAlign;
        if (str != null) 
            _verticalAlign = VertAlignType.parse(str);
        
        str = xml.att.leading;
        if (str != null) 
            _leading = Std.parseInt(str)
        else 
        _leading = 3;
        
        str = xml.att.letterSpacing;
        if (str != null) 
            _letterSpacing = Std.parseInt(str);
        
        _ubbEnabled = xml.att.ubb == "true";
        
        str = xml.att.autoSize;
        if (str != null) 
        {
            _autoSize = AutoSizeType.parse(str);
            _widthAutoSize = _autoSize == AutoSizeType.Both;
            _heightAutoSize = _autoSize == AutoSizeType.Both || _autoSize == AutoSizeType.Height;
        }
        
        _underline = xml.att.underline == "true";
        _italic = xml.att.italic == "true";
        _bold = xml.att.bold == "true";
        _singleLine = xml.att.singleLine == "true";
        str = xml.att.strokeColor;
        if (str != null) 
        {
            _strokeColor = ToolSet.convertFromHtmlColor(str);
            _stroke = true;
            _textFilters = createStrokeFilters(_strokeColor);
        }
    }
    
    override public function setup_afterAdd(xml : Fast) : Void
    {
        super.setup_afterAdd(xml);
        
        updateTextFormat();
        var str : String = xml.att.text;
        if (str != null) 
            this.text = str;
        _sizeDirty = false;
        
        var cxml : Fast = xml.nodes.gearColor.get(0);
        if (cxml != null) 
            _gearColor.setup(cxml);
    }
}


class LineInfo
{
    public var width : Int;
    public var height : Int;
    public var textHeight : Int;
    public var text : String;
    public var y : Int;
    
    private static var pool : Array<Dynamic> = [];
    
    public static function borrow() : LineInfo
    {
        if (pool.length) 
        {
            var ret : LineInfo = pool.pop();
            ret.width = 0;
            ret.height = 0;
            ret.textHeight = 0;
            ret.text = null;
            ret.y = 0;
            return ret;
        }
        else 
        return new LineInfo();
    }
    
    public static function returns(value : LineInfo) : Void
    {
        pool.push(value);
    }
    
    public static function returnList(value : Array<LineInfo>) : Void
    {
        for (li in value)
        {
            pool.push(li);
        }
        value.length = 0;
    }
    
    public function new()
    {
        
    }
}

