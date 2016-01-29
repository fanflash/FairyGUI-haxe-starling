package fairygui;

import com.greensock.TweenLite;

import flash.geom.Point;	

class GearXY extends GearBase
{
	private var _storage:Dynamic;
	private var _default:Point;
	private var _tweenValue:Point;
	private var _tweener:TweenLite;
	
	public function new(owner:GObject)
	{
		super(owner);
	}
	
	override private function init():Void
	{
		_default=new Point(_owner.x, _owner.y);
		_storage={};
	}
	
	override private function addStatus(pageId:String, value:String):Void
	{
		var arr:Array<Dynamic>=value.split(",");
		var pt:Point;
		if(pageId==null)
			pt=_default;
		else
		{
			pt=new Point();
			_storage[pageId]=pt;
		}
		pt.x=parseInt(arr[0]);
		pt.y=parseInt(arr[1]);
	}
	
	override public function apply():Void
	{
		_owner._gearLocked=true;
		
		var pt:Point;
		var ct:Bool=this.connected;
		if(ct)
		{
			pt=_storage[_controller.selectedPageId];
			if(!pt)
				pt=_default;
		}
		else
			pt=_default;
		
		if(_tweener!=null)
		{
			_owner.setXY(_tweener.vars.x, _tweener.vars.y);
			_tweener.kill();
			_tweener=null;
			_owner.internalVisible--;
		}
		
		if(_tween && !UIPackage._constructing
			&& ct && _pageSet.containsId(_controller.previousPageId))
		{
			if(_owner.x !=pt.x || _owner.y !=pt.y)
			{
				_owner.internalVisible++;
				var vars:Dynamic=
						{
							x:pt.x,
							y:pt.y,
							ease:_easeType,
							overwrite:0
						};
				vars.onUpdate=__tweenUpdate;
				vars.onComplete=__tweenComplete;
				if(_tweenValue==null)
					_tweenValue=new Point();
				_tweenValue.x=_owner.x;
				_tweenValue.y=_owner.y;
				_tweener=TweenLite.to(_tweenValue, _tweenTime, vars);
			}
		}
		else
			_owner.setXY(pt.x, pt.y);
		
		_owner._gearLocked=false;
	}
	
	private function __tweenUpdate():Void
	{
		_owner._gearLocked=true;
		_owner.setXY(_tweenValue.x, _tweenValue.y);
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
		
		if(connected)
		{
			var pt:Point=_storage[_controller.selectedPageId];
			if(!pt){
				pt=new Point();
				_storage[_controller.selectedPageId]=pt;
			}
		}
		else
		{
			pt=_default;
		}
		
		pt.x=_owner.x;
		pt.y=_owner.y;
	}
	
	public function updateFromRelations(dx:Float, dy:Float):Void
	{
		for(pt in _storage)
		{
			pt.x +=dx;
			pt.y +=dy;
		}
		_default.x +=dx;
		_default.y +=dy;
		
		updateState();
	}
}