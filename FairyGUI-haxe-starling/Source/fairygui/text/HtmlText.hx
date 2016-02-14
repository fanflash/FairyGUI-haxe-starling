package fairygui.text;


import openfl.text.TextField;
import openfl.text.TextFormat;

class HtmlText
{
    public var parsedText : String;
    public var elements : Array<HtmlElement>;
    
    public function new(val : String)
    {
        elements = new Array<HtmlElement>();
        try{
            val = val.replace(new EReg('\\r\\n', "g"), "\n");
            val = val.replace(new EReg('\\r', "g"), "\n");
            var ignoreWhitespace : Bool = FastXML.ignoreWhitespace;
            FastXML.ignoreWhitespace = false;
            var xml : FastXML = new FastXML("<dummy>" + val + "</dummy>");
            FastXML.ignoreWhitespace = ignoreWhitespace;
            var list : FastXMLList = xml.node.children.innerData();
            parsedText = "";
            parseXML(list);
        }
        catch (e : Dynamic){
            parsedText = val;
            elements.length = 0;
            trace(e);
        }
    }
    
    public function appendTo(textField : TextField) : Void
    {
        var pos : Int = textField.text.length;
        textField.replaceText(pos, pos, parsedText);
        var i : Int = elements.length - 1;
        while (i >= 0){
            var e : HtmlElement = elements[i];
            textField.setTextFormat(e.textformat, pos + e.start, pos + e.end + 1);
            i--;
        }
    }
    
    private function parseXML(list : FastXMLList) : Void
    {
        var cnt : Int = list.length();
        var tag : String;
        var attr : FastXMLList;
        var node : FastXML;
        var tf : TextFormat;
        var start : Int;
        var element : HtmlElement;
        for (i in 0...cnt){
            node = list.get(i);
            tag = node.node.name.innerData();
            if (tag == "font") {
                tf = new TextFormat();
                attr = node.node.attribute.innerData("size");
                if (attr.length()) 
                    tf.size = Int(attr.get(0));
                attr = node.node.attribute.innerData("color");
                if (attr.length()) 
                    tf.color = parseInt(attr.get(0).node.substr.innerData(1), 16);
                attr = node.node.attribute.innerData("italic");
                if (attr.length()) 
                    tf.italic = attr.get(0) == "true";
                attr = node.node.attribute.innerData("underline");
                if (attr.length()) 
                    tf.underline = attr.get(0) == "true";
                attr = node.node.attribute.innerData("face");
                if (attr.length()) 
                    tf.font = attr.get(0);
                
                start = parsedText.length;
                if (node.node.hasSimpleContent.innerData()) 
                    parsedText += node.node.text.innerData()
                else 
                parseXML(node.node.children.innerData());
                if (parsedText.length > start) 
                {
                    element = new HtmlElement();
                    element.start = start;
                    element.end = parsedText.length - 1;
                    element.textformat = tf;
                    elements.push(element);
                }
            }
            else if (tag == "a") {
                tf = new TextFormat();
                tf.underline = true;
                tf.url = "#";
                
                start = parsedText.length;
                if (node.node.hasSimpleContent.innerData()) 
                    parsedText += node.node.text.innerData()
                else 
                parseXML(node.node.children.innerData());
                if (parsedText.length > start) 
                {
                    element = new HtmlElement();
                    element.type = 1;
                    element.start = start;
                    element.end = parsedText.length - 1;
                    element.textformat = tf;
                    element.id = Std.string(node.node.attribute.innerData("id"));
                    element.href = Std.string(node.node.attribute.innerData("href"));
                    element.target = Std.string(node.node.attribute.innerData("target"));
                    elements.push(element);
                }
            }
            else if (tag == "img") {
                start = parsedText.length;
                tf = new TextFormat();
                parsedText += "　";
                
                element = new HtmlElement();
                element.type = 2;
                element.id = Std.string(node.node.attribute.innerData("id"));
                element.src = Std.string(node.node.attribute.innerData("src"));
                element.width = Int(Std.string(node.node.attribute.innerData("width")));
                element.height = Int(Std.string(node.node.attribute.innerData("height")));
                element.start = start;
                element.end = parsedText.length - 1;
                element.textformat = tf;
                elements.push(element);
            }
            else if (tag == "b") {
                tf = new TextFormat();
                tf.bold = true;
                start = parsedText.length;
                if (node.node.hasSimpleContent.innerData()) 
                    parsedText += node.node.text.innerData()
                else 
                parseXML(node.node.children.innerData());
                if (parsedText.length > start) 
                {
                    element = new HtmlElement();
                    element.start = start;
                    element.end = parsedText.length - 1;
                    element.textformat = tf;
                    elements.push(element);
                }
            }
            else if (tag == "i") {
                tf = new TextFormat();
                tf.italic = true;
                start = parsedText.length;
                if (node.node.hasSimpleContent.innerData()) 
                    parsedText += node.node.text.innerData()
                else 
                parseXML(node.node.children.innerData());
                if (parsedText.length > start) 
                {
                    element = new HtmlElement();
                    element.start = start;
                    element.end = parsedText.length - 1;
                    element.textformat = tf;
                    elements.push(element);
                }
            }
            else if (tag == "u") {
                tf = new TextFormat();
                tf.underline = true;
                start = parsedText.length;
                if (node.node.hasSimpleContent.innerData()) 
                    parsedText += node.node.text.innerData()
                else 
                parseXML(node.node.children.innerData());
                if (parsedText.length > start) 
                {
                    element = new HtmlElement();
                    element.start = start;
                    element.end = parsedText.length - 1;
                    element.textformat = tf;
                    elements.push(element);
                }
            }
            else if (tag == "br") {
                parsedText += "\n";
            }
            else if (node.node.nodeKind.innerData() == "text") {
                var str : String = Std.string(node);
                
                parsedText += str;
            }
            else {
                parseXML(node.node.children.innerData());
            }
        }
    }
}


