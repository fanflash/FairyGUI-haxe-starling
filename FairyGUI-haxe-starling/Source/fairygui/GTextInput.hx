package fairygui;


import openfl.display.Stage;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.geom.Rectangle;
import openfl.text.TextField;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;

import fairygui.utils.ToolSet;

import starling.core.Starling;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.utils.Max;

import haxe.xml.Fast;

class GTextInput extends GTextField
{
    public var nativeTextField(get, never) : TextField;
    public var editable(get, set) : Bool;
    public var maxLength(get, set) : Int;
    public var promptText(get, set) : String;

    private var _nativeTextField : TextField;
    private var _editable : Bool;
    private var _promptText : String;
    
    public function new()
    {
        super();
        
        this.focusable = true;
        _editable = true;
        _canvas.touchable = true;
        _nativeTextField = new TextField();
        _nativeTextField.type = TextFieldType.INPUT;
        _nativeTextField.addEventListener(FocusEvent.FOCUS_OUT, __focusOut);
        
        this.addEventListener(TouchEvent.TOUCH, __touch);
    }
    
    override public function dispose() : Void
    {
        if (_nativeTextField.parent) 
        {
            var stage : Stage = Starling.current.nativeStage;
            stage.removeChild(_nativeTextField);
        }
        super.dispose();
    }
    
    private function get_nativeTextField() : TextField
    {
        return _nativeTextField;
    }
    
    private function set_editable(val : Bool) : Bool
    {
        _editable = val;
        return val;
    }
    
    private function get_editable() : Bool
    {
        return _editable;
    }
    
    private function set_maxLength(val : Int) : Int
    {
        _nativeTextField.maxChars = val;
        return val;
    }
    
    private function get_maxLength() : Int
    {
        return _nativeTextField.maxChars;
    }
    
    private function get_promptText() : String
    {
        return _promptText;
    }
    
    private function set_promptText(value : String) : String
    {
        _promptText = value;
        renderNow();
        return value;
    }
    
    override private function handleSizeChanged() : Void
    {
        super.handleSizeChanged();
        
        _canvas.setSize(this.width, this.height + _fontAdjustment);
    }
    
    override private function updateTextFieldText() : Void
    {
        if (_text == null && _promptText != null) 
        {
            renderTextField.htmlText = ToolSet.parseUBB(ToolSet.encodeHTML(_promptText));
        }
        else if (_displayAsPassword) 
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
    
    override public function setup_beforeAdd(xml : Fast) : Void
    {
        super.setup_beforeAdd(xml);
        
        _promptText = xml.att.prompt;
    }
    
    override public function setup_afterAdd(xml : Fast) : Void
    {
        super.setup_afterAdd(xml);
        
        if (_text == null && _promptText != null) 
            renderNow();
    }
    
    private function __touch(evt : TouchEvent) : Void
    {
        if (!_editable) 
            return;
        
        var touch : Touch = evt.getTouch(displayObject);
        if (touch != null && touch.phase == TouchPhase.BEGAN) 
        {
            var textFormat : TextFormat;
            if (_nativeTextField.defaultTextFormat == null) 
                textFormat = new TextFormat()
            else 
            textFormat = _nativeTextField.defaultTextFormat;
            textFormat.font = _textFormat.font;
            textFormat.align = _textFormat.align;
            textFormat.bold = _textFormat.bold;
            textFormat.color = _textFormat.color;
            textFormat.italic = _textFormat.italic;
            textFormat.leading = Int(_textFormat.leading) * GRoot.contentScaleFactor;
            textFormat.letterSpacing = Int(_textFormat.letterSpacing) * GRoot.contentScaleFactor;
            textFormat.size = Int(_textFormat.size) * GRoot.contentScaleFactor;
            _nativeTextField.defaultTextFormat = textFormat;
            _nativeTextField.displayAsPassword = _displayAsPassword;
            _nativeTextField.wordWrap = !_singleLine;
            _nativeTextField.multiline = !_singleLine;
            _nativeTextField.text = _text;
            _nativeTextField.setSelection(0, Max.INT_MAX_VALUE);
            
            var rect : Rectangle = this.localToGlobalRect(0, -_yOffset - _fontAdjustment, this.width, this.height + _fontAdjustment);
            var stage : Stage = Starling.current.nativeStage;
            _nativeTextField.x = rect.x;
            _nativeTextField.y = rect.y;
            _nativeTextField.width = rect.width;
            _nativeTextField.height = rect.height;
            stage.addChild(_nativeTextField);
            stage.focus = _nativeTextField;
            
            _canvas.visible = false;
        }
    }
    
    private function __focusOut(evt : Event) : Void
    {
        if (_nativeTextField.parent) 
        {
            var stage : Stage = Starling.current.nativeStage;
            stage.removeChild(_nativeTextField);
            _canvas.visible = true;
            this.text = _nativeTextField.text;
        }
    }
}
