package fairygui.text;


import fairygui.display.Shape;

class LinkButton extends Shape
{
    public var owner : HtmlNode;
    
    @:allow(fairygui.text)
    private function new()
    {
        super();
        drawRect(0, 0, 0, 0, 0);
    }
}
