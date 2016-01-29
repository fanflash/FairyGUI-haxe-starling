package fairygui;


import openfl.utils.ByteArray;

interface IUIPackageReader
{

    public function readDescFile(fileName : String) : String;
    public function readResFile(fileName : String) : ByteArray;
}
