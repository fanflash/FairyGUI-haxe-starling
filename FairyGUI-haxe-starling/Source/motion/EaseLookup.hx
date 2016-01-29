package motion;

import motion.easing.Back;
import motion.easing.Bounce;
import motion.easing.Cubic;
import motion.easing.Elastic;
import motion.easing.Expo;
import motion.easing.Linear;
import motion.easing.Quad;
import motion.easing.Quart;
import motion.easing.Quint;
import motion.easing.Sine;


class EaseLookup {
    public function new() {
    }

/** @private **/
    private static var _lookup:Dynamic;

    /**
		 * Finds the easing function associated with a particular name (String), like "strongEaseOut". This can be useful when
		 * loading in XML data that comes in as Strings but needs to be translated to native function references. You can pass in
		 * the name with or without the period, and it is case insensitive, so any of the following will find the Strong.easeOut function: <br /><br /><code>
		 * EaseLookup.find("Strong.easeOut") <br />
		 * EaseLookup.find("strongEaseOut") <br />
		 * EaseLookup.find("strongeaseout") <br /><br /></code>
		 *
		 * You can translate Strings directly when tweening, like this: <br /><code>
		 * TweenLite.to(mc, 1, {x:100, ease:EaseLookup.find(myString)});<br /><br /></code>
		 *
		 * @param $name The name of the easing function, with or without the period and case insensitive (i.e. "Strong.easeOut" or "strongEaseOut")
		 * @return The easing function associated with the name
		 */
    public static function find($name:String):Dynamic {
        if (_lookup == null) {
            buildLookup();
        }
        return _lookup[$name.toLowerCase()];
    }

    /** @private **/
    private static function buildLookup():Void {
        _lookup = {};

        addInOut(Back, ["back"]);
        addInOut(Bounce, ["bounce"]);
//        addInOut(Circ, ["circ", "circular"]);
        addInOut(Cubic, ["cubic"]);
        addInOut(Elastic, ["elastic"]);
        addInOut(Expo, ["expo", "exponential"]);
        addInOut(Linear, ["linear"]);
        addInOut(Quad, ["quad", "quadratic"]);
        addInOut(Quart, ["quart","quartic"]);
        addInOut(Quint, ["quint", "quintic", "strong"]);
        addInOut(Sine, ["sine"]);

        _lookup["linear.easenone"] = _lookup["lineareasenone"] = Linear.easeNone;
    }

    /** @private **/
    private static function addInOut($class:Class, $names:Array):Void {
        var name:String;
        var i:Int = $names.length;
        while (i-- > 0) {
            name = $names[i].toLowerCase();
            _lookup[name + ".easein"] = _lookup[name + "easein"] = $class.easeIn;
            _lookup[name + ".easeout"] = _lookup[name + "easeout"] = $class.easeOut;
            _lookup[name + ".easeinout"] = _lookup[name + "easeinout"] = $class.easeInOut;
        }
    }
}
