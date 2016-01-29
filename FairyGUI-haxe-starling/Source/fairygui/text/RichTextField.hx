package fairygui.text;

import fairygui.text.RichTextObjectFactory;

import openfl.geom.Rectangle;
import openfl.net.URLRequest;
import openfl.text.AntiAliasType;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextLineMetrics;

import fairygui.PackageItem;
import fairygui.UIConfig;
import fairygui.UIPackage;
import fairygui.display.TextCanvas;
import fairygui.event.TextEvent;
import fairygui.utils.CharSize;
import fairygui.utils.ToolSet;

import starling.core.RenderSupport;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Sprite;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

class RichTextField extends Sprite
{
    public var nativeTextField(get, never) : TextField;
    public var text(get, set) : String;
    public var autoSize(get, set) : String;
    public var defaultTextFormat(get, set) : TextFormat;
    public var ALinkFormat(get, set) : TextFormat;
    public var multiline(get, set) : Bool;
    public var wordWrap(get, set) : Bool;
    public var selectable(get, set) : Bool;
    public var border(get, set) : Bool;
    public var textHeight(get, never) : Float;
    public var textWidth(get, never) : Float;
    public var numLines(get, never) : Int;

    private var _canvas : TextCanvas;
    private var _textField : TextField;
    private var _ALinkFormat : TextFormat;
    private var _defaultTextFormat : TextFormat;
    private var _lineInfo : Array<Dynamic>;
    private var _linkButtonCache : Array<LinkButton>;
    private var _nodeCache : Array<HtmlNode>;
    private var _needRebuild : Bool;
    
    private static var PLACEHOLDER_FONT : String = "SimSun," + UIConfig.defaultFont;
    
    public static var objectFactory : IRichTextObjectFactory = new RichTextObjectFactory();
    
    public function new()
    {
        super();
        
        _linkButtonCache = new Array<LinkButton>();
        _nodeCache = new Array<HtmlNode>();
        _ALinkFormat = new TextFormat();
        _ALinkFormat.underline = true;
        
        _lineInfo = [];
        
        _canvas = new TextCanvas();
        addChild(_canvas);
        
        _textField = new TextField();
        _textField.wordWrap = true;
        _textField.selectable = false;
        _textField.antiAliasType = AntiAliasType.ADVANCED;
    }
    
    override private function set_width(value : Float) : Float
    {
        if (_textField.height != value) 
        {
            _textField.width = value;
            _needRebuild = true;
        }
        return value;
    }
    
    override private function set_height(value : Float) : Float
    {
        if (_textField.height != value) 
        {
            _textField.height = value;
            _needRebuild = true;
            adjustNodes();
        }
        return value;
    }
    
    override private function get_width() : Float
    {
        return _textField.width;
    }
    
    override private function get_height() : Float
    {
        return _textField.height;
    }
    
    private function get_nativeTextField() : TextField
    {
        return _textField;
    }
    
    private function get_text() : String
    {
        return _textField.text;
    }
    
    private function set_text(val : String) : String
    {
        clear();
        if (val.length) 
            appendText(val)
        else 
        fixTextSize();
        return val;
    }
    
    private function set_autoSize(val : String) : String
    {
        _textField.autoSize = val;
        return val;
    }
    
    private function get_autoSize() : String
    {
        return _textField.autoSize;
    }
    
    private function set_defaultTextFormat(val : TextFormat) : TextFormat
    {
        _defaultTextFormat = val;
        if (_defaultTextFormat != null) 
        {
            if (_defaultTextFormat.underline == null) 
                _defaultTextFormat.underline = false;
            if (_defaultTextFormat.letterSpacing == null) 
                _defaultTextFormat.letterSpacing = 0;
            if (_defaultTextFormat.kerning == null) 
                _defaultTextFormat.kerning = false;
        }
        _textField.defaultTextFormat = val;
        _needRebuild = true;
        return val;
    }
    
    private function get_defaultTextFormat() : TextFormat
    {
        return _textField.defaultTextFormat;
    }
    
    private function get_ALinkFormat() : TextFormat
    {
        return _ALinkFormat;
    }
    
    private function set_ALinkFormat(val : TextFormat) : TextFormat
    {
        _ALinkFormat = val;
        return val;
    }
    
    private function set_multiline(val : Bool) : Bool
    {
        if (_textField.multiline != val) 
        {
            _textField.multiline = val;
            _needRebuild = true;
        }
        return val;
    }
    
    private function get_multiline() : Bool
    {
        return _textField.multiline;
    }
    
    private function set_wordWrap(val : Bool) : Bool
    {
        if (_textField.wordWrap = val) 
        {
            _textField.wordWrap = val;
            _needRebuild = true;
        }
        return val;
    }
    
    private function get_wordWrap() : Bool
    {
        return _textField.wordWrap;
    }
    
    private function set_selectable(val : Bool) : Bool
    {
        _textField.selectable = val;
        _textField.mouseEnabled = val;
        return val;
    }
    
    private function get_selectable() : Bool
    {
        return _textField.selectable;
    }
    
    private function set_border(val : Bool) : Bool
    {
        if (_textField.border = val) 
        {
            _textField.border = val;
            _needRebuild = true;
        }
        return val;
    }
    
    private function get_border() : Bool
    {
        return _textField.border;
    }
    
    private function get_textHeight() : Float
    {
        return _textField.textHeight;
    }
    
    private function get_textWidth() : Float
    {
        return _textField.textWidth;
    }
    
    private function get_numLines() : Int
    {
        return _textField.numLines;
    }
    
    public function getLinkCount() : Int
    {
        var rcnt : Int = 0;
        var cnt : Int = _lineInfo.length;
        for (i in 0...cnt){
            var lineInfo : Array<HtmlNode> = _lineInfo[i];
            if (lineInfo != null) 
            {
                var cnt2 : Int = lineInfo.length;
                for (j in 0...cnt2){
                    if (lineInfo[j].element.type == HtmlElement.LINK) 
                        rcnt++;
                }
            }
        }
        return rcnt;
    }
    
    public function getImageCount() : Int
    {
        var rcnt : Int = 0;
        var cnt : Int = _lineInfo.length;
        for (i in 0...cnt){
            var lineInfo : Array<HtmlNode> = _lineInfo[i];
            if (lineInfo != null) 
            {
                var cnt2 : Int = lineInfo.length;
                for (j in 0...cnt2){
                    if (lineInfo[j].element.type == HtmlElement.IMAGE) 
                        rcnt++;
                }
            }
        }
        return rcnt;
    }
    
    public function getObjectRect(objId : String, targetCoordinate : DisplayObject) : Rectangle
    {
        var cnt : Int = _lineInfo.length;
        for (i in 0...cnt){
            var lineInfo : Array<HtmlNode> = _lineInfo[i];
            if (lineInfo != null) 
            {
                var cnt2 : Int = lineInfo.length;
                for (j in 0...cnt2){
                    var node : HtmlNode = lineInfo[j];
                    if (node.element.id == objId && node.displayObject != null) 
                    {
                        return node.displayObject.getBounds(targetCoordinate);
                    }
                }
            }
        }
        return null;
    }
    
    public function getLinkRectByOrder(ord : Int, targetCoordinate : DisplayObject) : Rectangle
    {
        var cnt : Int = _lineInfo.length;
        for (i in 0...cnt){
            var lineInfo : Array<HtmlNode> = _lineInfo[i];
            if (lineInfo != null) 
            {
                var cnt2 : Int = lineInfo.length;
                for (j in 0...cnt2){
                    var node : HtmlNode = lineInfo[j];
                    if (node.element.type == HtmlElement.LINK && node.displayObject != null && ord-- == 0) 
                    {
                        return node.displayObject.getBounds(targetCoordinate);
                    }
                }
            }
        }
        return null;
    }
    
    public function getLinkRectByHref(href : String, targetCoordinate : DisplayObject) : Rectangle
    {
        var cnt : Int = _lineInfo.length;
        for (i in 0...cnt){
            var lineInfo : Array<HtmlNode> = _lineInfo[i];
            if (lineInfo != null) {
                var cnt2 : Int = lineInfo.length;
                for (j in 0...cnt2){
                    var node : HtmlNode = lineInfo[j];
                    if (node.element.type == HtmlElement.LINK && node.displayObject != null && node.element.href == href) 
                    {
                        return node.displayObject.getBounds(targetCoordinate);
                    }
                }
            }
        }
        return null;
    }
    
    public function getLinkHref(ord : Int) : String
    {
        var cnt : Int = _lineInfo.length;
        for (i in 0...cnt){
            var lineInfo : Array<HtmlNode> = _lineInfo[i];
            if (lineInfo != null) 
            {
                var cnt2 : Int = lineInfo.length;
                for (j in 0...cnt2){
                    var node : HtmlNode = lineInfo[j];
                    if (node.element.type == HtmlElement.LINK && ord-- == 0) 
                    {
                        return node.element.href;
                    }
                }
            }
        }
        return null;
    }
    
    public function appendText(val : String) : Void
    {
        appendParsedText(new HtmlText(val));
    }
    
    public function appendParsedText(ht : HtmlText) : Void
    {
        if (_defaultTextFormat != null) 
            _textField.defaultTextFormat = _defaultTextFormat;
        var startPos : Int = _textField.text.length;
        var text : String = ht.parsedText;
        _textField.replaceText(startPos, startPos, text);
        var i : Int;
        var cnt : Int = ht.elements.length;
        i = cnt - 1;
        while (i >= 0){
            var e : HtmlElement = ht.elements[i];
            if (e.type == HtmlElement.LINK) 
            {
                if (_ALinkFormat != null) 
                    _textField.setTextFormat(_ALinkFormat, startPos + e.start, startPos + e.end + 1);
            }
            else if (e.type == HtmlElement.IMAGE) 
            {
                var imageWidth : Int = 20;
                var imageHeight : Int = 20;
                if (ToolSet.startsWith(e.src, "ui://")) 
                {
                    var item : PackageItem = UIPackage.getItemByURL(e.src);
                    if (item != null) 
                    {
                        imageWidth = item.width;
                        imageHeight = item.height;
                    }
                }
                if (e.width == 0) 
                    e.realWidth = imageWidth
                else 
                e.realWidth = e.width;
                if (e.height == 0) 
                    e.realHeight = imageHeight
                else 
                e.realHeight = e.height;
                e.realWidth += 4;
                e.textformat.font = PLACEHOLDER_FONT;
                e.textformat.size = e.realHeight + 2;
                e.textformat.underline = false;
                e.textformat.letterSpacing = e.realWidth - CharSize.getWidth(e.realHeight + 2, PLACEHOLDER_FONT);
                _textField.setTextFormat(e.textformat, startPos + e.start, startPos + e.end + 1);
            }
            else 
            _textField.setTextFormat(e.textformat, startPos + e.start, startPos + e.end + 1);
            i--;
        }
        fixTextSize();
        
        for (i in 0...cnt){
            e = ht.elements[i];
            if (e.type == HtmlElement.LINK) 
                addLink(startPos, e)
            else if (e.type == HtmlElement.IMAGE) 
                addImage(startPos, e);
        }
        
        _needRebuild = true;
        if (_textField.parent != null) 
            Starling.current.nativeStage.removeChild(_textField);
    }
    
    public function deleteLines(from : Int, count : Int) : Void{
        if (from + count > _textField.numLines) {
            count = _textField.numLines - from;
            if (count <= 0) 
                return;
        }
        
        var offset1 : Int = _textField.getLineOffset(from);
        var offset2 : Int;
        if (from == _textField.numLines - 1) 
            offset2 = _textField.text.length
        else if (count != 1) {
            var end : Int = from + count - 1;
            offset2 = _textField.getLineOffset(end) + _textField.getLineLength(end);
        }
        else 
        offset2 = _textField.getLineLength(from);
        var deleteCount : Int = offset2 - offset1;
        if (offset1 != 0 && _textField.text.charCodeAt(offset1 - 1) != 13) {
            _textField.replaceText(offset1, offset2, "\r");
            deleteCount--;
        }
        else 
        _textField.replaceText(offset1, offset2, "");
        
        var i : Int;
        var j : Int;
        var lineInfo : Array<HtmlNode>;
        var node : HtmlNode;
        for (i in 0...count){
            lineInfo = _lineInfo[from + i];
            if (lineInfo != null) {
                for (j in 0...lineInfo.length){
                    node = lineInfo[j];
                    destroyNode(node);
                }
            }
        }
        _lineInfo.splice(from, count);
        
        for (i in from..._lineInfo.length){
            lineInfo = _lineInfo[i];
            if (lineInfo != null) 
            {
                var v : Bool = isLineVisible(i);
                for (j in 0...lineInfo.length){
                    node = lineInfo[j];
                    node.charStart -= deleteCount;
                    node.charEnd -= deleteCount;
                    node.lineIndex -= count;
                    node.posUpdated = false;
                    if (v) 
                        showNode(node)
                    else 
                    hideNode(node);
                }
            }
        }
        _needRebuild = true;
        
        if (_textField.parent != null) 
            Starling.current.nativeStage.removeChild(_textField);
    }
    
    private function adjustNodes() : Void
    {
        var cnt1 : Int = _lineInfo.length;
        for (i in 0...cnt1){
            var lineInfo : Dynamic = _lineInfo[i];
            if (lineInfo != null) 
            {
                var cnt2 : Int = lineInfo.length;
                if (isLineVisible(i)) 
                {
                    for (j in 0...cnt2){
                        var node : HtmlNode = lineInfo[j];
                        showNode(node);
                    }
                }
                else 
                {
                    for (j in 0...cnt2){
                        node = lineInfo[j];
                        hideNode(node);
                    }
                }
            }
        }
        
        if (_textField.parent != null) 
            Starling.current.nativeStage.removeChild(_textField);
    }
    
    private function clear() : Void
    {
        var cnt : Int = _lineInfo.length;
        for (i in 0...cnt){
            var lineInfo : Array<HtmlNode> = _lineInfo[i];
            if (lineInfo != null) 
            {
                for (j in 0...lineInfo.length){
                    var node : HtmlNode = lineInfo[j];
                    destroyNode(node);
                }
            }
        }
        _lineInfo.length = 0;
        
        _textField.htmlText = "";
        if (_defaultTextFormat != null) 
            _textField.defaultTextFormat = _defaultTextFormat;
        
        _canvas.clear();
        _needRebuild = false;
    }
    
    private function fixTextSize() : Void
    {
        //--for update text field width/height
        _textField.textWidth;
        _textField.height;
    }
    
    private function isLineVisible(line : Int) : Bool
    {
        return true;
    }
    
    private function createNode(line : Int) : HtmlNode
    {
        var lineInfo : Array<HtmlNode> = _lineInfo[line];
        if (lineInfo == null) 
        {
            lineInfo = new Array<HtmlNode>();
            _lineInfo[line] = lineInfo;
        }
        var node : HtmlNode;
        if (_nodeCache.length) 
            node = _nodeCache.pop()
        else 
        node = new HtmlNode();
        node.lineIndex = line;
        node.nodeIndex = lineInfo.length;
        lineInfo.push(node);
        return node;
    }
    
    private function destroyNode(node : HtmlNode) : Void
    {
        if (node.displayObject != null) {
            if (node.displayObject.parent != null) 
                removeChild(node.displayObject);
            if (node.element.type == HtmlElement.LINK) 
                _linkButtonCache.push(node.displayObject)
            else if (node.element.type == HtmlElement.IMAGE) 
                objectFactory.freeObject(node.displayObject);
        }
        node.reset();
        _nodeCache.push(node);
    }
    
    private function addLink(startPos : Int, element : HtmlElement) : Void
    {
        var start : Int = startPos + element.start;
        var end : Int = startPos + element.end;
        var line1 : Int = _textField.getLineIndexOfChar(start);
        var line2 : Int = _textField.getLineIndexOfChar(end);
        if (line1 == line2) 
        {  //single line  
            addLinkButton(line1, start, end, element);
        }
        else 
        {
            var lineOffset : Int = _textField.getLineOffset(line1);
            addLinkButton(line1, start, lineOffset + _textField.getLineLength(line1) - 1, element);
            for (j in line1 + 1...line2){
                lineOffset = _textField.getLineOffset(j);
                addLinkButton(j, lineOffset, lineOffset + _textField.getLineLength(j) - 1, element);
            }
            addLinkButton(line2, _textField.getLineOffset(line2), end, element);
        }
    }
    
    private function addLinkButton(line : Int, charStart : Int, charEnd : Int, element : HtmlElement) : Void
    {
        charStart = skipLeftCR(charStart, charEnd);
        charEnd = skipRightCR(charStart, charEnd);
        
        var node : HtmlNode = createNode(line);
        node.charStart = charStart;
        node.charEnd = charEnd;
        node.element = element;
        if (isLineVisible(line)) 
            showNode(node);
    }
    
    private function addImage(startPos : Int, element : HtmlElement) : Void
    {
        var start : Int = startPos + element.start;
        var line : Int = _textField.getLineIndexOfChar(start);
        
        var node : HtmlNode = createNode(line);
        node.charStart = start;
        node.charEnd = start;
        node.element = element;
        if (isLineVisible(line)) 
            showNode(node);
    }
    
    private function getCharBoundaries(charIndex : Int) : Rectangle
    {
        //如果RichTextField不在舞台，那么getCharBoundaries返回的字符的位置会错误（flash 问题），所以这里使用里奇怪的方法。。。
        if (_textField.parent == null) 
            Starling.current.nativeStage.addChild(_textField);
        return _textField.getCharBoundaries(charIndex);
    }
    
    private function showNode(node : HtmlNode) : Void
    {
        var element : HtmlElement = node.element;
        if (element.type == HtmlElement.LINK) {
            if (node.displayObject == null) 
            {
                var btn : LinkButton;
                if (_linkButtonCache.length) 
                    btn = _linkButtonCache.pop()
                else 
                {
                    btn = new LinkButton();
                    btn.addEventListener(TouchEvent.TOUCH, __touchLink);
                }
                btn.owner = node;
                node.displayObject = btn;
            }
            
            if (!node.posUpdated) 
            {
                var rect1 : Rectangle = getCharBoundaries(node.charStart);
                if (rect1 == null) 
                    return;
                var rect2 : Rectangle = getCharBoundaries(node.charEnd);
                if (rect2 == null) 
                    return;
                
                var w : Int = rect2.right - rect1.left;
                if (rect1.left + w > _textField.width - 2) 
                    w = _textField.width - rect1.left - 2;
                var h : Int = Math.max(rect1.height, rect2.height);
                node.displayObject.x = rect1.left;
                cast((node.displayObject), LinkButton).setSize(w, h);
                if (rect1.top < rect2.top) 
                    node.topY = 0
                else 
                node.topY = rect2.top - rect1.top;
                node.posUpdated = true;
            }
            else 
            {
                rect1 = getCharBoundaries(node.charStart);
                if (rect1 == null) 
                    return;
            }
            
            node.displayObject.y = rect1.top + node.topY;
            if (node.displayObject.parent == null) 
                addChild(node.displayObject);
        }
        else if (element.type == HtmlElement.IMAGE) 
        {
            if (node.displayObject == null) 
            {
                if (objectFactory != null) 
                    node.displayObject = objectFactory.createObject(element.src, element.width, element.height);
                if (node.displayObject == null) 
                    return;
            }
            
            rect1 = getCharBoundaries(node.charStart);
            if (rect1 == null) 
                return;
            
            var tm : TextLineMetrics = _textField.getLineMetrics(node.lineIndex);
            if (tm == null) 
                return;
            
            node.displayObject.x = rect1.left + 2;
            if (element.realHeight < tm.ascent) 
                node.displayObject.y = rect1.top + tm.ascent - element.realHeight
            else 
            node.displayObject.y = rect1.bottom - element.realHeight;
            if (node.displayObject.x + node.displayObject.width < _textField.width - 2) 
            {
                if (node.displayObject.parent == null) 
                    addChildAt(node.displayObject, this.numChildren);
            }
        }
    }
    
    private function hideNode(node : HtmlNode) : Void
    {
        if (node.displayObject && node.displayObject.parent) 
        {
            removeChild(node.displayObject);
        }
    }
    
    private function skipLeftCR(start : Int, end : Int) : Int
    {
        var text : String = _textField.text;
        for (i in start...end){
            var c : String = text.charAt(i);
            if (c != "\r" && c != "\n") 
                break;
        }
        return i;
    }
    
    private function skipRightCR(start : Int, end : Int) : Int
    {
        var text : String = _textField.text;
        var i : Int = end;
        while (i > start){
            var c : String = text.charAt(i);
            if (c != "\r" && c != "\n") 
                break;
            i--;
        }
        return i;
    }
    
    private function findLinkStart(linkNode : HtmlNode, hovered : Bool) : Int
    {
        var i : Int = linkNode.nodeIndex;
        var j : Int = linkNode.lineIndex;
        i--;
        var ne : HtmlNode;
        var se : HtmlNode;
        var lineInfo : Array<HtmlNode> = _lineInfo[j];
        
        while (true)
        {
            if (i < 0) 
            {
                if (se == linkNode) 
                    break;
                se = linkNode;
                j--;
                lineInfo = _lineInfo[j];
                if (lineInfo == null) 
                    break;
                i = lineInfo.length - 1;
            }
            ne = lineInfo[i];
            if (ne.element.type == HtmlElement.LINK) 
            {
                if (ne.element != linkNode.element) 
                    break;
                linkNode = ne;
            }
            i--;
        }
        return linkNode.charStart;
    }
    
    private function findLinkEnd(linkNode : HtmlNode, hovered : Bool) : Int
    {
        var i : Int = linkNode.nodeIndex;
        var j : Int = linkNode.lineIndex;
        i++;
        var ne : HtmlNode;
        var se : HtmlNode;
        var lineInfo : Array<HtmlNode> = _lineInfo[j];
        if (lineInfo == null) 
            return linkNode.charEnd;
        
        while (true){
            if (i > lineInfo.length - 1) 
            {
                if (se == linkNode) 
                    break;
                se = linkNode;
                j++;
                lineInfo = _lineInfo[j];
                if (lineInfo == null) 
                    break;
                i = 0;
            }
            ne = lineInfo[i];
            if (ne.element.type == HtmlElement.LINK) 
            {
                if (ne.element != linkNode.element) 
                    break;
                linkNode = ne;
            }
            i++;
        }
        return linkNode.charEnd;
    }
    
    private function __touchLink(evt : TouchEvent) : Void
    {
        var touch : Touch = evt.getTouch(cast((evt.currentTarget), DisplayObject));
        if (touch != null) 
        {
            evt.stopPropagation();
            if (touch.phase == TouchPhase.BEGAN) 
            {
                var node : HtmlNode = cast((evt.currentTarget), LinkButton).owner;
                var url : String = node.element.href;
                var i : Int = url.indexOf("event:");
                if (i == 0) 
                    this.dispatchEvent(new TextEvent(TextEvent.LINK, true, url.substring(6)))
                else 
                flash.net.navigateToURL(new URLRequest(url), node.element.target);
            }
        }
    }
    
    override public function render(support : RenderSupport, parentAlpha : Float) : Void
    {
        if (_needRebuild) 
        {
            _needRebuild = false;
            _canvas.renderText(_textField, _textField.width, _textField.textHeight + 10, 0, clearCanvas);
        }
        
        super.render(support, parentAlpha);
    }
    
    public function clearCanvas() : Void
    {
        if (_canvas.textureMemory > 0) 
        {
            _canvas.clear();
            _needRebuild = true;
        }
    }
}




