package fairygui.display;


import fairygui.GObject;

interface UIDisplayObject
{
    
    var owner(default, never) : GObject;

}
