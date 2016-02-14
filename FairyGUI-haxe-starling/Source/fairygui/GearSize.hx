package fairygui;

import com.greensock.TweenLite;
import motion.Actuate;

class GearSize extends GearBase
{
	private var _storage:Dynamic;
	private var _default:GearSizeValue;
	private var _tweenValue:GearSizeValue;
	private var _tweener:Actuate;
	
	public function new(owner:GObject)
	{
		super(owner);
	}

	override private function init():Void
	{
		_default=new GearSizeValue(_owner.width, _owner.height, _owner.scaleX, _owner.scaleY);
		_storage={};
	}
	
	override private function addStatus(pageId:String, value:String):Void
	{
		var arr:Array<Dynamic>=value.split(",");
		var gv:GearSizeValue;
		if(pageId==null)
			gv=_default;
		else
		{
			gv=new GearSizeValue();
			_storage[pageId]=gv;
		}
		gv.width=Std.parseInt(arr[0]);
		gv.height=Std.parseInt(arr[1]);
		if(arr.length>2)
		{
			gv.scaleX=Std.parseFloat(arr[2]);
			gv.scaleY=Std.parseFloat(arr[3]);
		}
	}
	
	override public function apply():Void
	{
		_owner._gearLocked=true;
		
		var gv:GearSizeValue;
		var ct:Bool=this.connected;
		if(ct)
		{
			gv=_storage[_controller.selectedPageId];
			if(!gv)
				gv=_default;
		}
		else
			gv=_default;
		
		if(_tweener!=null)
		{
			if(_tweener.vars.onUpdateParams[0])
				_owner.setSize(_tweener.vars.width, _tweener.vars.height, _owner.gearXY.controller==_controller);
			if(_tweener.vars.onUpdateParams[1])
				_owner.setScale(_tweener.vars.scaleX, _tweener.vars.scaleY);
			_tweener.kill();
			_tweener=null;
			_owner.internalVisible--;
		}
		
		if(_tween && !UIPackage._constructing
			&& ct && _pageSet.containsId(_controller.previousPageId))
		{
			var a:Bool=gv.width !=_owner.width || gv.height !=_owner.height;
			var b:Bool=gv.scaleX !=_owner.scaleX || gv.scaleY !=_owner.scaleY;
			if(a || b)
			{
				_owner.internalVisible++;
				var vars:Dynamic=
						{
							width:gv.width,
							height:gv.height,
							scaleX:gv.scaleX,
							scaleY:gv.scaleY,
							ease:_easeType,
							overwrite:0
						};
				vars.onUpdate=__tweenUpdate;
				vars.onUpdateParams=[a,b];
				vars.onComplete=__tweenComplete;
				if(_tweenValue==null)
					_tweenValue=new GearSizeValue(0,0,0,0);
				_tweenValue.width=_owner.width;
				_tweenValue.height=_owner.height;
				_tweenValue.scaleX=_owner.scaleX;
				_tweenValue.scaleY=_owner.scaleY;
				_tweener=Actuate.tween(_tweenValue, _tweenTime, vars);
			}
		}
		else
		{
			_owner.setSize(gv.width, gv.height, _owner.gearXY.controller==_controller);
			_owner.setScale(gv.scaleX, gv.scaleY);
		}
		
		_owner._gearLocked=false;
	}
	
	private function __tweenUpdate(a:Bool, b:Bool):Void
	{
		_owner._gearLocked=true;
		if(a)
			_owner.setSize(_tweenValue.width, _tweenValue.height, _owner.gearXY.controller==_controller);
		if(b)
			_owner.setScale(_tweenValue.scaleX, _tweenValue.scaleY);
		_owner._gearLocked=false;							
	}
	
	private function __tweenComplete():Void
	{
		_owner.internalVisible--;
		_tweener=null;
	}
	
	override public function updateState():Void
	{
		if(_owner._gearLocked)
			return;
		
		var gv:GearSizeValue;
		if(connected)
		{
			gv=_storage[_controller.selectedPageId];
			if(!gv)
			{
				gv=new GearSizeValue();
				_storage[_controller.selectedPageId]=gv;
			}
		}
		else
		{
			gv=_default;
		}
		
		gv.width=_owner.width;
		gv.height=_owner.height;
		gv.scaleX=_owner.scaleX;
		gv.scaleY=_owner.scaleY;
	}
}



class GearSizeValue
{
public var width:Float;
public var height:Float;
public var scaleX:Float;
public var scaleY:Float;

public function newValue(width:Float=0, height:Float=0, scaleX:Float=0, scaleY:Float=0)
{
	this.width=width;
	this.height=height;
	this.scaleX=scaleX;
	this.scaleY=scaleY;
}
}