--------------------------------------------------------------
-- FileName: 	ui_func.lua
-- author:		
-- purpose:		UI常用函数定义
--------------------------------------------------------------

--ui事件类型定义
NUIEventType = 
{
	TE_NONE = 0,
	
	TE_TOUCH_CLICK					= 1, --单击
	TE_TOUCH_DOUBLE_CLICK			= 2, --双击
	
	TE_TOUCH_BTN_DRAG_IN			= 3, --拖入
	TE_TOUCH_BTN_DRAG_OUT			= 4, --拖出
	TE_TOUCH_BTN_DRAG_OUT_COMPLETE	= 5, --拖出完毕

	--edit事件
	TE_TOUCH_EDIT_RETURN			= 6,
	TE_TOUCH_EDIT_TEXT_CHANGE		= 7,
	TE_TOUCH_EDIT_INPUT_FINISH		= 8,

	--选中
	TE_TOUCH_SELECT_VIEW			= 9,
	TE_TOUCH_UNSELECT_VIEW			= 10,
	TE_TOUCH_ACTIVE_VIEW			= 11,

	TE_TOUCH_BTN_DRAG_LEFT			= 12,
	TE_TOUCH_BTN_DRAG_RIGHT			= 13,
	TE_TOUCH_BTN_DRAG_UP			= 14,
	TE_TOUCH_BTN_DRAG_DOWN			= 15,
	TE_TOUCH_BTN_DRAGING			= 16,
	TE_TOUCH_BTN_BEGIN			= 17,
	TE_TOUCH_BTN_END			= 18
};

UILoadType =
{
	UI_LT_DEFAULT = 0,
	UI_LT_SCALE = 1,
	UI_LT_LEFTFLY = 2,
	UI_LT_RIGHTFLY = 3,
	UI_LT_TOPFLY = 4,
	UI_LT_BOTTOMFLY = 5
};

UICloseType =
{
	UI_CT_DEFAULT = 0,
	UI_CT_SCALE = 1,
	UI_CT_LEFTFLY = 2,
	UI_CT_RIGHTFLY = 3,
	UI_CT_TOPFLY = 4,
	UI_CT_BOTTOMFLY = 5
};

--列表控件的选择模式（默认单选）
E_LIST_SEL_NONE = 0;
E_LIST_SEL_SINGLE = 1;
E_LIST_SEL_MUL = 2;


--屏幕尺寸
WinSize = GetWinSize(); 
WinSizeInPixels = GetWinSizeInPixels(); 

--全局变量暂时放这儿
RESOURCE_SCALE_960 = 0.5 * GetResourceScale();
COORD_SCALE_X_960 = GetCoordScaleX_960();
COORD_SCALE_Y_960 = GetCoordScaleY_960();

WriteCon("");
WriteCon( string.format( "RESOURCE_SCALE_960=%f", RESOURCE_SCALE_960 ));
WriteCon( string.format( "COORD_SCALE_X_960=%f", COORD_SCALE_X_960 ));
WriteCon( string.format( "COORD_SCALE_Y_960=%f", COORD_SCALE_Y_960 ));
WriteCon("");

--取屏幕中心位置
function GetScreenCenter()
	local winSize = GetWinSizeInPixels();
	local x = 0.5*winSize.w;
	local y = 0.5*winSize.h;
	return x,y;
end

--取屏幕宽度
function GetScreenWidth()
    return GetWinSizeInPixels().w;
end

--取屏幕高度
function GetScreenHeight()
    return GetWinSizeInPixels().h;
end

--UI偏移适配
function UIOffsetX(ofs)
	return ofs * COORD_SCALE_X_960;
end

function UIOffsetY(ofs)
	return ofs * COORD_SCALE_Y_960;
end

--UI尺寸适配（按资源比例等比缩放）
function UISize( size )
	size.w = size.w * RESOURCE_SCALE_960;
	size.h = size.h * RESOURCE_SCALE_960;
	return size;
end

--字体尺寸适配
function FontSize( fontSize )
	return fontSize * RESOURCE_SCALE_960;
end

--是否单击事件
function IsClickEvent( uiEventType )
    return uiEventType == NUIEventType.TE_TOUCH_CLICK;
end

--是否双击事件
function IsDoubleEvent( uiEventType )
    return uiEventType == NUIEventType.TE_TOUCH_DOUBLE_CLICK;
end

--事件判定：选中
function IsSelectViewEvent( uiEventType )
	return uiEventType == NUIEventType.TE_TOUCH_SELECT_VIEW;
end

--事件判定：取消选中
function IsUnSelectViewEvent( uiEventType )
	return uiEventType == NUIEventType.TE_TOUCH_UNSELECT_VIEW;
end

--事件判定：View变为活动项（仅SingleMode有效）
function IsActiveViewEvent( uiEventType )
	return uiEventType == NUIEventType.TE_TOUCH_ACTIVE_VIEW;
end

--事件判定：向左滑动手势
function IsDragLeft( uiEventType )
	return uiEventType == NUIEventType.TE_TOUCH_BTN_DRAG_LEFT;
end

--事件判定：向右滑动手势
function IsDragRight( uiEventType )
	return uiEventType == NUIEventType.TE_TOUCH_BTN_DRAG_RIGHT;
end

--事件判定：向上滑动手势
function IsDragUp( uiEventType )
	return uiEventType == NUIEventType.TE_TOUCH_BTN_DRAG_UP;
end

--事件判定：向下滑动手势
function IsDragDown( uiEventType )
	return uiEventType == NUIEventType.TE_TOUCH_BTN_DRAG_DOWN;
end

function IsDraging( uiEventType )
	return uiEventType == NUIEventType.TE_TOUCH_BTN_DRAGING;
end

function IsDragBegin( uiEventType )
	return uiEventType == NUIEventType.TE_TOUCH_BTN_BEGIN;
end

function IsDragEnd( uiEventType )
	return uiEventType == NUIEventType.TE_TOUCH_BTN_END;
end

--加载特效
function ShowLoading( flag )
	--[[
	if flag then
		dlg_loading.Show();
	else
		dlg_loading.CloseUI();
	end--]]
end