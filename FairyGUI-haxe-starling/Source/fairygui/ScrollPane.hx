package fairygui;

import openfl.Lib;
import motion.Actuate;
import motion.EaseLookup;

import openfl.events.MouseEvent;
import openfl.geom.Point;
import openfl.geom.Rectangle;

import fairygui.event.GTouchEvent;
import fairygui.utils.GTimers;

import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Sprite;

class ScrollPane
{
	private var _owner:GComponent;
	private var _container:Sprite;
	private var _maskHolder:Sprite;
	private var _maskContentHolder:Sprite;

	private var _maskWidth:Float;
	private var _maskHeight:Float;
	private var _contentWidth:Float;
	private var _contentHeight:Float;

	private var _scrollType:Int;
	private var _scrollSpeed:Int;
	private var _mouseWheelSpeed:Int;
	private var _margin:Margin;
	private var _scrollBarMargin:Margin;
	private var _bouncebackEffect:Bool;
	private var _touchEffect:Bool;
	private var _scrollBarDisplayAuto:Bool;
	private var _vScrollNone:Bool;
	private var _hScrollNone:Bool;
	
	private var _displayOnLeft:Bool;
	private var _snapToItem:Bool;
	private var _displayInDemand:Bool;
	private var _mouseWheelEnabled:Bool;
	
	private var _yPerc:Float;
	private var _xPerc:Float;
	private var _vScroll:Bool;
	private var _hScroll:Bool;
	
	private static var _easeTypeFunc:Dynamic;
	private var _throwTween:ThrowTween;
	private var _tweening:Int;
	
	private var _time1:Int;
	private var _time2:Int;
	private var _y1:Float;
	private var _y2:Float;
	private var _yOverlap:Float;
	private var _yOffset:Float;
	private var _x1:Float;
	private var _x2:Float;
	private var _xOverlap:Float;
	private var _xOffset:Float;
	
	private var _isMouseMoved:Bool;
	private var _holdAreaPoint:Point;
	private var _isHoldAreaDone:Bool;
	private var _holdArea:Float;
	private var _aniFlag:Bool;
	private var _scrollBarVisible:Bool;
	
	private var _hzScrollBar:GScrollBar;
	private var _vtScrollBar:GScrollBar;
	
	public static inline var SCROLL:String="scrollEvent";
	
	private static var sHelperPoint:Point=new Point();
	
	public function new(owner:GComponent, 
							   scrollType:Int,
							   margin:Margin,
							   scrollBarMargin:Margin,
							   scrollBarDisplay:Int,
							   flags:Int):Void
	{	
		if(_easeTypeFunc==null)
			_easeTypeFunc=EaseLookup.find("Cubic.easeOut");
		_throwTween=new ThrowTween();
		
		_owner=owner;
		_container=_owner._rootContainer;
		
		_maskHolder=new Sprite();
		_container.addChild(_maskHolder);

		_maskContentHolder=_owner._container;
		_maskContentHolder.x=0;
		_maskContentHolder.y=0;
		_maskHolder.addChild(_maskContentHolder);

		if(GRoot.touchScreen)
			_holdArea=20;
		else
			_holdArea=5;
		_holdAreaPoint=new Point();
		_margin=margin;
		_scrollBarMargin=scrollBarMargin;
		_bouncebackEffect=UIConfig.defaultScrollBounceEffect;
		_touchEffect=UIConfig.defaultScrollTouchEffect;
		_xPerc=0;
		_yPerc=0;
		_aniFlag=true;
		_scrollBarVisible=true;
		_scrollSpeed=UIConfig.defaultScrollSpeed;
		_mouseWheelSpeed=_scrollSpeed*2;
		_displayOnLeft=(flags & 1)!=0;
		_snapToItem=(flags & 2)!=0;
		_displayInDemand=(flags & 4)!=0;
		_scrollType=scrollType;
		_mouseWheelEnabled=true;
		
		if(scrollBarDisplay==ScrollBarDisplayType.Default)
			scrollBarDisplay=UIConfig.defaultScrollBarDisplay;
		
		if(scrollBarDisplay!=ScrollBarDisplayType.Hidden)
		{
			if(_scrollType==ScrollType.Both || _scrollType==ScrollType.Vertical)
			{
				if(UIConfig.verticalScrollBar)
				{
					_vtScrollBar= cast UIPackage.createObjectFromURL(UIConfig.verticalScrollBar);
					if(!_vtScrollBar)
						throw new Dynamic("cannot create scrollbar from " + UIConfig.verticalScrollBar);
					_vtScrollBar.setScrollPane(this, true);
					_container.addChild(_vtScrollBar.displayObject);
				}
			}
			if(_scrollType==ScrollType.Both || _scrollType==ScrollType.Horizontal)
			{
				if(UIConfig.horizontalScrollBar)
				{
					_hzScrollBar= cast UIPackage.createObjectFromURL(UIConfig.horizontalScrollBar);
					if(!_hzScrollBar)
						throw new Dynamic("cannot create scrollbar from " + UIConfig.horizontalScrollBar);
					_hzScrollBar.setScrollPane(this, false);
					_container.addChild(_hzScrollBar.displayObject);
				}
			}
			
			_scrollBarDisplayAuto=scrollBarDisplay==ScrollBarDisplayType.Auto;
			if(_scrollBarDisplayAuto)
			{
				_scrollBarVisible=false;
				if(_vtScrollBar)
					_vtScrollBar.displayObject.visible=false;
				if(_hzScrollBar)
					_hzScrollBar.displayObject.visible=false;
#if flash
				var supportsCursor:Bool = flash.ui.Mouse.supportsCursor;
#else
				var supportsCursor:Bool = false;
#end
				if(supportsCursor)
				{
					_owner.addEventListener(GTouchEvent.ROLL_OVER, __rollOver);
					_owner.addEventListener(GTouchEvent.ROLL_OUT, __rollOut);
				}
			}
		}
		else
			_mouseWheelEnabled=false;
		
		if(_displayOnLeft && _vtScrollBar)
			_maskHolder.x=Std.int(_margin.left + _vtScrollBar.width);
		else
			_maskHolder.x=_margin.left;
		_maskHolder.y=_margin.top;
		
		_contentWidth=0;
		_contentHeight=0;
		setSize(owner.width, owner.height);
		setContentSize(owner.bounds.width, owner.bounds.height);
		
		Starling.current.nativeStage.addEventListener(MouseEvent.MOUSE_WHEEL, __mouseWheel);
		_owner.addEventListener(GTouchEvent.BEGIN, __mouseDown);
		_owner.addEventListener(GTouchEvent.END, __mouseUp);
	}
	
	public function dispose():Void
	{
		Starling.current.nativeStage.removeEventListener(MouseEvent.MOUSE_WHEEL, __mouseWheel);
		
		_owner.removeEventListener(GTouchEvent.BEGIN, __mouseDown);
		_owner.removeEventListener(GTouchEvent.DRAG, __mouseMove);
		_owner.removeEventListener(GTouchEvent.END, __mouseUp);
		_owner.removeEventListener(GTouchEvent.ROLL_OVER, __rollOver);
		_owner.removeEventListener(GTouchEvent.ROLL_OUT, __rollOut);
		_container.removeChildren();
		_maskContentHolder.x=0;
		_maskContentHolder.y=0;
		_container.addChild(_maskContentHolder);
	}
	
	public var owner(get, never):GComponent;
 	private function get_owner():GComponent
	{
		return _owner;
	}
	
	public var bouncebackEffect(get, set):Bool;
 	private function get_bouncebackEffect():Bool
	{
		return _bouncebackEffect;
	}
	
	private function set_bouncebackEffect(sc:Bool):Void
	{
		_bouncebackEffect=sc;
	}
	
	public var touchEffect(get, set):Bool;
 	private function get_touchEffect():Bool
	{
		return _touchEffect;
	}
	
	private function set_touchEffect(sc:Bool):Void
	{
		_touchEffect=sc;
	}
	
	private function set_scrollSpeed(val:Int):Void
	{
		_scrollSpeed=val;
		if(_scrollSpeed==0)
			_scrollSpeed=UIConfig.defaultScrollSpeed;
		_mouseWheelSpeed=_scrollSpeed*2;
	}
	
	public var scrollSpeed(get, set):Int;
 	private function get_scrollSpeed():Int
	{
		return _scrollSpeed;
	}
	
	public var snapToItem(get, set):Bool;
 	private function get_snapToItem():Bool
	{
		return _snapToItem;
	}
	
	private function set_snapToItem(value:Bool):Void
	{
		_snapToItem=value;
	}
	
	public var mouseWheelEnabled(get, set):Bool;
 	private function get_mouseWheelEnabled():Bool
	{
		return _mouseWheelEnabled;
	}
	
	private function set_mouseWheelEnabled(value:Bool):Void
	{
		_mouseWheelEnabled=value;
	}
	
	public var percX(get, set):Float;
 	private function get_percX():Float
	{
		return _xPerc;
	}
	
	private function set_percX(sc:Float):Void
	{
		setPercX(sc, false);
	}
	
	public function setPercX(sc:Float, ani:Bool=false):Void
	{
		if(sc>1)
			sc=1;
		else if(sc<0)
			sc=0;
		if(sc !=_xPerc)
		{
			_xPerc=sc;
			posChanged(ani);
		}
	}
	
	public var percY(get, set):Float;
 	private function get_percY():Float
	{
		return _yPerc;
	}
	
	private function set_percY(sc:Float):Void
	{
		setPercY(sc, false);
	}
	
	public function setPercY(sc:Float, ani:Bool=false):Void
	{
		if(sc>1)
			sc=1;
		else if(sc<0)
			sc=0;
		if(sc !=_yPerc)
		{
			_yPerc=sc;
			posChanged(ani);
		}
	}
	
	public var posX(get, set):Float;
 	private function get_posX():Float
	{
		return _xPerc*Math.max(0, _contentWidth-_maskWidth);
	}
	
	private function set_posX(val:Float):Void 
	{
		setPosX(val, false);
	}
	
	public function setPosX(val:Float, ani:Bool=false):Void
	{
		if(_contentWidth>_maskWidth)
			this.setPercX(val/(_contentWidth-_maskWidth), ani);
		else
			this.setPercX(0, ani);
	}
	
	public var posY(get, set):Float;
 	private function get_posY():Float 
	{
		return _yPerc*Math.max(0, _contentHeight-_maskHeight);
	}
	
	private function set_posY(val:Float):Void
	{
		setPosY(val, false);
	}
	
	public function setPosY(val:Float, ani:Bool=false):Void
	{
		if(_contentHeight>_maskHeight)
			this.setPercY(val/(_contentHeight-_maskHeight), ani);
		else
			this.setPercY(0, ani);
	}

	public var isBottomMost(get, never):Bool;
 	private function get_isBottomMost():Bool
	{
		return _yPerc==1 || _contentHeight<=_maskHeight;
	}
	
	public var isRightMost(get, never):Bool;
 	private function get_isRightMost():Bool
	{
		return _xPerc==1 || _contentWidth<=_maskWidth;
	}
	
	public var contentWidth(get, never):Float;
 	private function get_contentWidth():Float
	{
		_owner.ensureBoundsCorrect();
		return _contentWidth;
	}
	
	public var contentHeight(get, never):Float;
 	private function get_contentHeight():Float
	{
		_owner.ensureBoundsCorrect();
		return _contentHeight;
	}
	
	public var viewWidth(get, set):Int;
 	private function get_viewWidth():Int
	{
		return _maskWidth;
	}
	
	private function set_viewWidth(value:Int):Void
	{
		value=value + _margin.left + _margin.right;
		if(_vtScrollBar !=null)
			value +=_vtScrollBar.width;
		_owner.width=value;
	}
	
	public var viewHeight(get, set):Int;
 	private function get_viewHeight():Int
	{
		return _maskHeight;
	}
	
	private function set_viewHeight(value:Int):Void
	{
		value=value + _margin.top + _margin.bottom;
		if(_hzScrollBar !=null)
			value +=_hzScrollBar.height;
		_owner.height=value;
	}
	
	private function getDeltaX(move:Float):Float
	{
		return move/(_contentWidth-_maskWidth);
	}
	
	private function getDeltaY(move:Float):Float
	{
		return move/(_contentHeight-_maskHeight);
	}
	
	public function scrollTop(ani:Bool=false):Void 
	{
		this.setPercY(0, ani);
	}
	
	public function scrollBottom(ani:Bool=false):Void 
	{
		this.setPercY(1, ani);
	}
	
	public function scrollUp(speed:Float=1, ani:Bool=false):Void 
	{
		this.setPercY(_yPerc - getDeltaY(_scrollSpeed*speed), ani);
	}
	
	public function scrollDown(speed:Float=1, ani:Bool=false):Void
	{
		this.setPercY(_yPerc + getDeltaY(_scrollSpeed*speed), ani);
	}
	
	public function scrollLeft(speed:Float=1, ani:Bool=false):Void
	{
		this.setPercX(_xPerc - getDeltaX(_scrollSpeed*speed), ani);
	}
	
	public function scrollRight(speed:Float=1, ani:Bool=false):Void
	{
		this.setPercX(_xPerc + getDeltaX(_scrollSpeed*speed), ani);
	}
	
	public function scrollToView(obj:GObject, ani:Bool=false):Void
	{
		_owner.ensureBoundsCorrect();
		if(GTimers.inst.exists(refresh))
			refresh();
		
		if(_vScroll)
		{
			var top:Float=(_contentHeight-_maskHeight)*_yPerc;
			var bottom:Float=top+_maskHeight;
			if(obj.y<top)
				this.setPosY(obj.y, ani);
			else if(obj.y+obj.height>bottom)
			{
				if(obj.y + obj.height * 2>=top)
					this.setPosY(obj.y+obj.height*2-_maskHeight, ani);
				else
					this.setPosY(obj.y+obj.height-_maskHeight, ani);
			}
		}
		if(_hScroll)
		{
			var left:Float=(_contentWidth-_maskWidth)*_xPerc;
			var right:Float=left+_maskWidth;
			if(obj.x<left)
				this.setPosX(obj.x, ani);
			else if(obj.x+obj.width>right)
			{
				if(obj.x + obj.width * 2>=left)
					this.setPosX(obj.x+obj.width*2-_maskWidth, ani);
				else
					this.setPosX(obj.x+obj.width-_maskWidth, ani);
			}
		}
		
		if(!ani && GTimers.inst.exists(refresh))
			refresh();
	}
	
	public function isChildInView(obj:GObject):Bool
	{
		if(_vScroll)
		{
			var top:Float=(_contentHeight-_maskHeight)*_yPerc;
			var bottom:Float=top+_maskHeight;
			if(obj.y+obj.height<top || obj.y>bottom)
				return false;
		}
		
		if(_hScroll)
		{
			var left:Float=(_contentWidth-_maskWidth)*_xPerc;
			var right:Float=left+_maskWidth;
			if(obj.x+obj.width<left || obj.x>right)
				return false;
		}
		
		return true;
	}

	private function setSize(aWidth:Float, aHeight:Float):Void 
	{
		var w:Float, h:Float;
		w=aWidth;
		h=aHeight;
		if(_hzScrollBar)
		{
			if(!_hScrollNone)
				h -=_hzScrollBar.height;
			_hzScrollBar.y=h;
			if(_vtScrollBar && !_vScrollNone)
			{
				_hzScrollBar.width=w - _vtScrollBar.width - _scrollBarMargin.left - _scrollBarMargin.right;
				if(_displayOnLeft)
					_hzScrollBar.x=_scrollBarMargin.left + _vtScrollBar.width;
				else
					_hzScrollBar.x=_scrollBarMargin.left;
			}
			else
			{
				_hzScrollBar.width=w - _scrollBarMargin.left - _scrollBarMargin.right;
				_hzScrollBar.x=_scrollBarMargin.left;
			}
		}
		if(_vtScrollBar)
		{
			if(!_vScrollNone)
				w -=_vtScrollBar.width;
			if(!_displayOnLeft)
				_vtScrollBar.x=w;
			_vtScrollBar.height=h - _scrollBarMargin.top - _scrollBarMargin.bottom;
			_vtScrollBar.y=_scrollBarMargin.top;
		}
		w -=(_margin.left+_margin.right);
		h -=(_margin.top+_margin.bottom);
		
		_maskWidth=Math.max(1, w);
		_maskHeight=Math.max(1, h);
		
		handleSizeChanged();
		posChanged(false);
	}

	private function setContentSize(aWidth:Float, aHeight:Float):Void
	{
		if(_contentWidth==aWidth && _contentHeight==aHeight)
			return;
		
		_contentWidth=aWidth;
		_contentHeight=aHeight;
		handleSizeChanged();
		_aniFlag=false;
		refresh();
	}
	
	private function handleSizeChanged():Void
	{
		if(_displayInDemand)
		{
			if(_vtScrollBar)
			{
				if(_contentHeight<=_maskHeight)
				{
					if(!_vScrollNone)
					{
						_vScrollNone=true;
						_maskWidth +=_vtScrollBar.width;
					}
				}
				else
				{
					if(_vScrollNone)
					{
						_vScrollNone=false;
						_maskWidth -=_vtScrollBar.width;
					}
				}
			}
			if(_hzScrollBar)
			{
				if(_contentWidth<=_maskWidth)
				{
					if(!_hScrollNone)
					{
						_hScrollNone=true;
						_maskHeight +=_vtScrollBar.height;
					}
				}
				else
				{
					if(_hScrollNone)
					{
						_hScrollNone=false;
						_maskHeight -=_vtScrollBar.height;
					}
				}
			}
		}
		
		if(_vtScrollBar)
		{
			if(_maskHeight<_vtScrollBar.minSize)
				//没有使用_vtScrollBar.visible是因为ScrollBar用了一个trick，它并不在owner的DisplayList里，因此_vtScrollBar.visible是无效的
				_vtScrollBar.displayObject.visible=false;
			else
			{
				_vtScrollBar.displayObject.visible=_scrollBarVisible && !_vScrollNone;
				if(_contentHeight==0)
					_vtScrollBar.displayPerc=0;
				else
					_vtScrollBar.displayPerc=Math.min(1, _maskHeight/_contentHeight);
			}
		}
		if(_hzScrollBar)
		{
			if(_maskWidth<_hzScrollBar.minSize)
				_hzScrollBar.displayObject.visible=false;
			else
			{
				_hzScrollBar.displayObject.visible=_scrollBarVisible && !_hScrollNone;
				if(_contentWidth==0)
					_hzScrollBar.displayPerc=0;
				else
					_hzScrollBar.displayPerc=Math.min(1, _maskWidth/_contentWidth);
			}
		}
		
		_maskHolder.clipRect=new Rectangle(0,0,_maskWidth,_maskHeight);
		
		_xOverlap=Math.ceil(Math.max(0, _contentWidth - _maskWidth));
		_yOverlap=Math.ceil(Math.max(0, _contentHeight - _maskHeight));
		
		switch(_scrollType)
		{
			case ScrollType.Both:
				
				if(_contentWidth>_maskWidth && _contentHeight<=_maskHeight)
				{
					_hScroll=true;
					_vScroll=false;
				}
				else if(_contentWidth<=_maskWidth && _contentHeight>_maskHeight)
				{
					_hScroll=false;
					_vScroll=true;
				}
				else if(_contentWidth>_maskWidth && _contentHeight>_maskHeight)
				{
					_hScroll=true;
					_vScroll=true;
				}
				else
				{
					_hScroll=false;
					_vScroll=false;
				}
				break;
			
			case ScrollType.Vertical:
				
				if(_contentHeight>_maskHeight)
				{
					_hScroll=false;
					_vScroll=true;
				}
				else
				{
					_hScroll=false;
					_vScroll=false;
				}
				break;
			
			case ScrollType.Horizontal:
				
				if(_contentWidth>_maskWidth)
				{
					_hScroll=true;
					_vScroll=false;
				}
				else
				{
					_hScroll=false;
					_vScroll=false;
				}
				break;
		}
	}
	
	private function posChanged(ani:Bool):Void
	{
		if(_aniFlag)
			_aniFlag=ani;
		GTimers.inst.callLater(refresh);
	}
	
	private function refresh():Void
	{
		if(_isMouseMoved)
		{
			GTimers.inst.callLater(refresh);
			return;
		}
		GTimers.inst.remove(refresh);
		
		var contentYLoc:Float;
		var contentXLoc:Float;

		if(_vScroll)
			contentYLoc=_yPerc *(_contentHeight - _maskHeight);
		if(_hScroll)
			contentXLoc=_xPerc *(_contentWidth - _maskWidth);
		
		if(_snapToItem)
		{
			var pt:Point=_owner.findObjectNear(_xPerc==1?0:contentXLoc, _yPerc==1?0:contentYLoc, sHelperPoint);
			if(_xPerc !=1 && pt.x!=contentXLoc)
			{
				_xPerc=pt.x /(_contentWidth - _maskWidth);
				if(_xPerc>1)
					_xPerc=1;
				contentXLoc=_xPerc *(_contentWidth - _maskWidth);
			}
			if(_yPerc !=1 && pt.y!=contentYLoc)
			{
				_yPerc=pt.y /(_contentHeight - _maskHeight);
				if(_yPerc>1)
					_yPerc=1;
				contentYLoc=_yPerc *(_contentHeight - _maskHeight);
			}
		}
		contentXLoc=Std.int(contentXLoc);
		contentYLoc=Std.int(contentYLoc);
		
		if(_aniFlag)
		{
			var toX:Float=_maskContentHolder.x;
			var toY:Float=_maskContentHolder.y;
			if(_vScroll)
			{
				toY=-contentYLoc;
			}
			else
			{
				if(_maskContentHolder.y!=0)
					_maskContentHolder.y=0;
			}
			if(_hScroll)
			{
				toX=-contentXLoc;
			}
			else
			{
				if(_maskContentHolder.x!=0)
					_maskContentHolder.x=0;
			}
			
			if(toX!=_maskContentHolder.x || toY!=_maskContentHolder.y)
			{
				killTweens();
				
				_maskHolder.touchable=false;
				_tweening=1;

				Actuate.tween(_maskContentHolder, 0.5, { x:toX, y:toY,
					onUpdate:__tweenUpdate, onComplete:__tweenComplete, 
					ease:_easeTypeFunc });
			}
		}
		else
		{
			killTweens();
			
			if(_vScroll)
				_maskContentHolder.y=-contentYLoc;
			else
				_maskContentHolder.y=0;
			if(_hScroll)
				_maskContentHolder.x=-contentXLoc;
			else
				_maskContentHolder.x=0;
			if(_vtScrollBar)
				_vtScrollBar.scrollPerc=_yPerc;
			if(_hzScrollBar)
				_hzScrollBar.scrollPerc=_xPerc;
		}
		
		_aniFlag=true;
	}
	
	private function killTweens():Void
	{
		if(_tweening==1)
		{
			Actuate.stop(_maskContentHolder);
			__tweenComplete();
		}
		else if(_tweening==2)
		{
			Actuate.stop(_throwTween);
			_throwTween.value=1;
			__tweenUpdate2();
			__tweenComplete2();
		}
		_tweening=0;
	}
	
	private function calcYPerc():Float
	{
		if(!_vScroll)
			return 0;
		
		var diff:Float=_contentHeight - _maskHeight;
		var my:Float=_maskContentHolder.y;
		var currY:Float;
		if(my>0)
			currY=0;
		else if(-my>diff)
			currY=diff;
		else
			currY=-my;
		
		return currY / diff;
	}
	
	private function calcXPerc():Float
	{
		if(!_hScroll)
			return 0;
		
		var diff:Float=_contentWidth - _maskWidth;
		var mx:Float=_maskContentHolder.x;
		var currX:Float;
		if(mx>0)
			currX=0;
		else if(-mx>diff)
			currX=diff;
		else
			currX=-mx;

		return currX / diff;
	}
	
	private function onScrolling():Void
	{
		if(_vtScrollBar)
		{
			_vtScrollBar.scrollPerc=calcYPerc();
			if(_scrollBarDisplayAuto)
				showScrollBar(true);
		}
		if(_hzScrollBar)
		{
			_hzScrollBar.scrollPerc=calcXPerc();
			if(_scrollBarDisplayAuto)
				showScrollBar(true);
		}
	}
	
	private function onScrollEnd():Void
	{
		if(_vtScrollBar)
		{
			if(_scrollBarDisplayAuto)
				showScrollBar(false);
		}
		if(_hzScrollBar)
		{
			if(_scrollBarDisplayAuto)
				showScrollBar(false);
		}
		_tweening=0;
		
		_owner.dispatchEventWith(SCROLL, false);
	}

	private function __mouseDown(evt:GTouchEvent):Void
	{
		if(!_touchEffect)
			return;
		
		killTweens();
		
		sHelperPoint.x=evt.stageX;
		sHelperPoint.y=evt.stageY;
		_container.globalToLocal(sHelperPoint, sHelperPoint);
		
		_x1=_x2=_maskContentHolder.x;
		_y1=_y2=_maskContentHolder.y;
		_xOffset=sHelperPoint.x - _maskContentHolder.x;	
		_yOffset=sHelperPoint.y - _maskContentHolder.y;		
		
		_time1=_time2=Lib.getTimer();
		_holdAreaPoint.x=sHelperPoint.x;
		_holdAreaPoint.y=sHelperPoint.y;
		_isHoldAreaDone=false;
		_isMouseMoved=false;
		
		_owner.addEventListener(GTouchEvent.DRAG, __mouseMove);
	}
	
	private function __mouseMove(evt:GTouchEvent):Void
	{
		var diff:Float;
		var sv:Bool, sh:Bool, st:Bool;

		sHelperPoint.x=evt.stageX;
		sHelperPoint.y=evt.stageY;
		_container.globalToLocal(sHelperPoint, sHelperPoint);
		
		if(_scrollType==ScrollType.Vertical)
		{
			if(!_isHoldAreaDone)
			{
				diff=Math.abs(_holdAreaPoint.y - sHelperPoint.y);
				if(diff<_holdArea)
					return;
			}
			
			sv=true;
		}
		else if(_scrollType==ScrollType.Horizontal)
		{
			if(!_isHoldAreaDone)
			{
				diff=Math.abs(_holdAreaPoint.x - sHelperPoint.x);
				if(diff<_holdArea)
					return;
			}
			
			sh=true;
		}
		else
		{
			if(!_isHoldAreaDone)
			{
				diff=Math.abs(_holdAreaPoint.y - sHelperPoint.y);
				if(diff<_holdArea)
				{
					diff=Math.abs(_holdAreaPoint.x - sHelperPoint.x);
					if(diff<_holdArea)
						return;
				}
			}
			
			sv=sh=true;
		}
		
		var t:Int=Lib.getTimer();
		if(t - _time2>50)
		{
			_time2=_time1;
			_time1=t;
			st=true;
		}

		if(sv)
		{
			var y:Int=sHelperPoint.y - _yOffset;
			if(y>0)
			{
				if(!_bouncebackEffect)
					_maskContentHolder.y=0;
				else
					_maskContentHolder.y=Std.int(y * 0.5);
			}
			else if(y<-_yOverlap)
			{
				if(!_bouncebackEffect)
					_maskContentHolder.y=-Std.int(_yOverlap);
				else
					_maskContentHolder.y=Std.int((y- _yOverlap)* 0.5);
			}
			else 
			{
				_maskContentHolder.y=y;
			}
			
			if(st)
			{
				_y2=_y1;
				_y1=_maskContentHolder.y;
			}
			
			_yPerc=calcYPerc();
		}
		
		if(sh)
		{
			var x:Int=sHelperPoint.x - _xOffset;
			if(x>0)
			{
				if(!_bouncebackEffect)
					_maskContentHolder.x=0;
				else
					_maskContentHolder.x=Std.int(x * 0.5);
			}
			else if(x<0 - _xOverlap)
			{
				if(!_bouncebackEffect)
					_maskContentHolder.x=-Std.int(_xOverlap);
				else
					_maskContentHolder.x=Std.int((x - _xOverlap)* 0.5);
			}
			else 
			{
				_maskContentHolder.x=x;
			}

			if(st)
			{
				_x2=_x1;
				_x1=_maskContentHolder.x;
			}
			
			_xPerc=calcXPerc();
		}
		
		_maskHolder.touchable=false;
		_isHoldAreaDone=true;
		if(!_isMouseMoved)
		{
			_isMouseMoved=true;
			//cancel children's click
			_owner.cancelChildrenClickEvent();
		}
		onScrolling();
		_owner.dispatchEventWith(SCROLL, false);
	}
	
	private function __mouseUp(evt:GTouchEvent):Void
	{
		if(!_touchEffect)
		{
			_isMouseMoved=false;
			return;
		}
		
		_owner.removeEventListener(GTouchEvent.DRAG, __mouseMove);
		
		if(!_isMouseMoved)
			return;

		_isMouseMoved=false;
		
		var time:Float=(Lib.getTimer()- _time2)/ 1000;
		if(time==0)
			time=0.001;
		var yVelocity:Float=(_maskContentHolder.y - _y2)/ time;
		var xVelocity:Float=(_maskContentHolder.x - _x2)/ time;
		var duration:Float=0.3;
		var xMin:Float=-_xOverlap;
		var yMin:Float=-_yOverlap;
		var xMax:Float=0;
		var yMax:Float=0;	

		_throwTween.start.x=_maskContentHolder.x;
		_throwTween.start.y=_maskContentHolder.y;
		
		var change1:Point=_throwTween.change1;
		var change2:Point=_throwTween.change2;
		var endX:Float=0;
		var endY:Float=0;
		
		if(_scrollType==ScrollType.Both || _scrollType==ScrollType.Horizontal)
		{
			change1.x=ThrowTween.calculateChange(xVelocity, duration);
			change2.x=0;
			endX=_maskContentHolder.x + change1.x;
		}
		else
			change1.x=change2.x=0;
		
		if(_scrollType==ScrollType.Both || _scrollType==ScrollType.Vertical)
		{
			change1.y=ThrowTween.calculateChange(yVelocity, duration);
			change2.y=0;
			endY=_maskContentHolder.y + change1.y;
		}
		else
			change1.y=change2.y=0;
		
		if(_snapToItem)
		{
			endX=-endX;
			endY=-endY;
			var pt:Point=_owner.findObjectNear(endX, endY, sHelperPoint);
			endX=-pt.x;
			endY=-pt.y;
			change1.x=endX - _maskContentHolder.x;
			change1.y=endY - _maskContentHolder.y;
		}
		
		if(xMax<endX)
			change2.x=xMax - _maskContentHolder.x - change1.x;
		else if(xMin>endX)
			change2.x=xMin - _maskContentHolder.x - change1.x;
		
		if(yMax<endY)
			change2.y=yMax - _maskContentHolder.y - change1.y;
		else if(yMin>endY)
			change2.y=yMin - _maskContentHolder.y - change1.y;
		
		_throwTween.value=0;
		_throwTween.change1=change1;
		_throwTween.change2=change2;
		
		killTweens();
		_tweening=2;

		Actuate.tween(_throwTween, duration, { value:1,
			onUpdate:__tweenUpdate2, onComplete:__tweenComplete2, 
			ease:_easeTypeFunc });
	}
	
	private function __mouseWheel(evt:MouseEvent):Void
	{
		if(!_mouseWheelEnabled)
			return;
		
		sHelperPoint.x=evt.stageX;
		sHelperPoint.y=evt.stageY;
		_container.globalToLocal(sHelperPoint, sHelperPoint);
		
		if(!_container.hitTest(sHelperPoint, true))
			return;
		
		var delta:Float=evt.delta;
		if(_hScroll && !_vScroll)
		{
			if(delta<0)
				this.setPercX(_xPerc + getDeltaX(_mouseWheelSpeed), false);
			else
				this.setPercX(_xPerc - getDeltaX(_mouseWheelSpeed), false);
		}
		else
		{
			if(delta<0)
				this.setPercY(_yPerc + getDeltaY(_mouseWheelSpeed), false);
			else
				this.setPercY(_yPerc - getDeltaY(_mouseWheelSpeed), false);
		}
	}
	
	private function __rollOver(evt:GTouchEvent):Void
	{
		showScrollBar(true);
	}
	
	private function __rollOut(evt:GTouchEvent):Void
	{
		showScrollBar(false);
	}
	
	private function showScrollBar(val:Bool):Void
	{
		if(val)
		{
			__showScrollBar(true);
			GTimers.inst.remove(__showScrollBar);
		}
		else
			GTimers.inst.add(500, 1, __showScrollBar, val);
	}
	
	private function __showScrollBar(val:Bool):Void
	{
		_scrollBarVisible=val && _maskWidth>0 && _maskHeight>0;
		if(_vtScrollBar)
			_vtScrollBar.displayObject.visible=_scrollBarVisible && !_vScrollNone;
		if(_hzScrollBar)
			_hzScrollBar.displayObject.visible=_scrollBarVisible && !_hScrollNone;
	}
	
	private function __tweenUpdate():Void
	{
		onScrolling();
	}
	
	private function __tweenComplete():Void
	{
		_maskHolder.touchable=true;
		onScrollEnd();
	}

	private function __tweenUpdate2():Void
	{
		_throwTween.update(_maskContentHolder);
		
		if(_scrollType==ScrollType.Vertical)
			_yPerc=calcYPerc();
		else if(_scrollType==ScrollType.Horizontal)
			_xPerc=calcXPerc();
		else
		{
			_yPerc=calcYPerc();
			_xPerc=calcXPerc();
		}
		
		onScrolling();
	}
	
	private function __tweenComplete2():Void
	{
		if(_scrollType==ScrollType.Vertical)
			_yPerc=calcYPerc();
		else if(_scrollType==ScrollType.Horizontal)
			_xPerc=calcXPerc();
		else
		{
			_yPerc=calcYPerc();
			_xPerc=calcXPerc();
		}

		_maskHolder.touchable=true;
		onScrollEnd();
	}
}

class ThrowTween
{
public var value:Float;
public var start:Point;
public var change1:Point;
public var change2:Point;

private static var checkpoint:Float=0.05;

public function ThrowTween()
{
	start=new Point();
	change1=new Point();
	change2=new Point();
}

public function update(obj:DisplayObject):Void
{
	obj.x=Std.int(start.x + change1.x * value + change2.x * value * value);
	obj.y=Std.int(start.y + change1.y * value + change2.y * value * value);
}

static public function calculateChange(velocity:Float, duration:Float):Float
{
	return(duration * checkpoint * velocity)/ easeOutCubic(checkpoint, 0, 1, 1);
}

static public function easeOutCubic(t:Float, b:Float, c:Float, d:Float):Float
{
	return c *((t=t / d - 1)* t * t + 1)+ b;
}
}