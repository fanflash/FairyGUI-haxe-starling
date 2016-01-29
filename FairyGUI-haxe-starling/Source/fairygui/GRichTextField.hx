package fairygui;

import fairygui.GTextField;

import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;

import fairygui.display.UIRichTextField;
import fairygui.text.RichTextField;
import fairygui.utils.ToolSet;

import starling.events.Event;

class GRichTextField extends GTextField
{
    public var ALinkFormat(get, set) : TextFormat;

    private var _textField : RichTextField;
    
    public function new()
    {
        super();
    }
    
    override private function createDisplayObject() : Void
    {
        _textField = new UIRichTextField(this);
        setDisplayObject(_textField);
        _textField.addEventListener(Event.REMOVED_FROM_STAGE, __removeFromStage);
    }
    
    private function get_ALinkFormat() : TextFormat{
        return _textField.ALinkFormat;
    }
    
    private function set_ALinkFormat(val : TextFormat) : TextFormat{
        _textField.ALinkFormat = val;
        render();
        return val;
    }
    
    override private function render() : Void
    {
        renderNow(true);
    }
    
    override private function renderNow(updateBounds : Bool = true) : Void
    {
        if (_heightAutoSize) 
            _textField.autoSize = TextFieldAutoSize.LEFT
        else 
        _textField.autoSize = TextFieldAutoSize.NONE;
        _textField.nativeTextField.filters = _textFilters;
        _textField.defaultTextFormat = _textFormat;
        _textField.multiline = !_singleLine;
        if (_ubbEnabled) 
            _textField.text = ToolSet.parseUBB(_text)
        else 
        _textField.text = _text;
        
        var renderSingleLine : Bool = _textField.numLines <= 1;
        
        _textWidth = Math.ceil(_textField.textWidth);
        if (_textWidth > 0) 
            _textWidth += 5;
        _textHeight = Math.ceil(_textField.textHeight);
        if (_textHeight > 0) 
        {
            if (renderSingleLine) 
                _textHeight += 1
            else 
            _textHeight += 4;
        }
        
        if (_heightAutoSize) 
        {
            _textField.height = _textHeight + _fontAdjustment;
            
            _updatingSize = true;
            this.height = _textHeight;
            _updatingSize = false;
        }
    }
    
    override private function handleSizeChanged() : Void
    {
        if (!_updatingSize) 
        {
            _textField.width = this.width;
            _textField.height = this.height + _fontAdjustment;
        }
    }
    
    private function __removeFromStage(evt : Event) : Void
    {
        _textField.clearCanvas();
    }
}

