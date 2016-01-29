package fairygui;

import fairygui.GObject;

import fairygui.utils.ToolSet;

class GLabel extends GComponent
{
    public var icon(get, set) : String;
    public var title(get, set) : String;
    public var titleColor(get, set) : Int;
    public var editable(get, set) : Bool;

    private var _titleObject : GObject;
    private var _iconObject : GObject;
    
    public function new()
    {
        super();
    }
    
    @:final private function get_icon() : String
    {
        if (Std.is(_iconObject, GLoader)) 
            return cast((_iconObject), GLoader).url
        else if (Std.is(_iconObject, GLabel)) 
            return cast((_iconObject), GLabel).icon
        else if (Std.is(_iconObject, GButton)) 
            return cast((_iconObject), GButton).icon
        else 
        return null;
    }
    
    private function set_icon(value : String) : String
    {
        if (Std.is(_iconObject, GLoader)) 
            cast((_iconObject), GLoader).url = value
        else if (Std.is(_iconObject, GLabel)) 
            cast((_iconObject), GLabel).icon = value
        else if (Std.is(_iconObject, GButton)) 
            cast((_iconObject), GButton).icon = value;
        return value;
    }
    
    @:final private function get_title() : String
    {
        if (_titleObject != null) 
            return _titleObject.text
        else 
        return null;
    }
    
    private function set_title(value : String) : String
    {
        if (_titleObject != null) 
            _titleObject.text = value;
        return value;
    }
    
    @:final override private function get_text() : String
    {
        return this.title;
    }
    
    override private function set_text(value : String) : String
    {
        this.title = value;
        return value;
    }
    
    @:final private function get_titleColor() : Int
    {
        if (Std.is(_titleObject, GTextField)) 
            return cast((_titleObject), GTextField).color
        else if (Std.is(_titleObject, GLabel)) 
            return cast((_titleObject), GLabel).titleColor
        else if (Std.is(_titleObject, GButton)) 
            return cast((_titleObject), GButton).titleColor
        else 
        return 0;
    }
    
    private function set_titleColor(value : Int) : Int
    {
        if (Std.is(_titleObject, GTextField)) 
            cast((_titleObject), GTextField).color = value
        else if (Std.is(_titleObject, GLabel)) 
            cast((_titleObject), GLabel).titleColor = value
        else if (Std.is(_titleObject, GButton)) 
            cast((_titleObject), GButton).titleColor = value;
        return value;
    }
    
    private function set_editable(val : Bool) : Bool
    {
        if (Std.is(_titleObject, GTextInput)) 
            _titleObject.asTextInput.editable = val;
        return val;
    }
    
    private function get_editable() : Bool
    {
        if (Std.is(_titleObject, GTextInput)) 
            return _titleObject.asTextInput.editable
        else 
        return false;
    }
    
    override private function constructFromXML(xml : FastXML) : Void
    {
        super.constructFromXML(xml);
        
        _titleObject = getChild("title");
        _iconObject = getChild("icon");
    }
    
    override public function setup_afterAdd(xml : FastXML) : Void
    {
        super.setup_afterAdd(xml);
        
        xml = xml.nodes.Label.get(0);
        if (xml != null) 
        {
            this.text = xml.att.title;
            this.icon = xml.att.icon;
            var str : String;
            str = xml.att.titleColor;
            if (str != null) 
                this.titleColor = ToolSet.convertFromHtmlColor(str);
        }
    }
}


