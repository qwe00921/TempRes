--------------------------------------------------------------
-- FileName: 	ui_func.lua
-- author:		
-- purpose:		UI���ú�������
--------------------------------------------------------------

--ui�¼����Ͷ���
NUIEventType = 
{
	TE_NONE = 0,
	
	TE_TOUCH_CLICK					= 1, --����
	TE_TOUCH_DOUBLE_CLICK			= 2, --˫��
	
	TE_TOUCH_BTN_DRAG_IN			= 3, --����
	TE_TOUCH_BTN_DRAG_OUT			= 4, --�ϳ�
	TE_TOUCH_BTN_DRAG_OUT_COMPLETE	= 5, --�ϳ����

	--edit�¼�
	TE_TOUCH_EDIT_RETURN			= 6,
	TE_TOUCH_EDIT_TEXT_CHANGE		= 7,
	TE_TOUCH_EDIT_INPUT_FINISH		= 8,

	--ѡ��
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

--�б�ؼ���ѡ��ģʽ��Ĭ�ϵ�ѡ��
E_LIST_SEL_NONE = 0;
E_LIST_SEL_SINGLE = 1;
E_LIST_SEL_MUL = 2;


--��Ļ�ߴ�
WinSize = GetWinSize(); 
WinSizeInPixels = GetWinSizeInPixels(); 

--ȫ�ֱ�����ʱ�����
RESOURCE_SCALE_960 = 0.5 * GetResourceScale();
COORD_SCALE_X_960 = GetCoordScaleX_960();
COORD_SCALE_Y_960 = GetCoordScaleY_960();

WriteCon("");
WriteCon( string.format( "RESOURCE_SCALE_960=%f", RESOURCE_SCALE_960 ));
WriteCon( string.format( "COORD_SCALE_X_960=%f", COORD_SCALE_X_960 ));
WriteCon( string.format( "COORD_SCALE_Y_960=%f", COORD_SCALE_Y_960 ));
WriteCon("");

--ȡ��Ļ����λ��
function GetScreenCenter()
	local winSize = GetWinSizeInPixels();
	local x = 0.5*winSize.w;
	local y = 0.5*winSize.h;
	return x,y;
end

--ȡ��Ļ���
function GetScreenWidth()
    return GetWinSizeInPixels().w;
end

--ȡ��Ļ�߶�
function GetScreenHeight()
    return GetWinSizeInPixels().h;
end

--UIƫ������
function UIOffsetX(ofs)
	return ofs * COORD_SCALE_X_960;
end

function UIOffsetY(ofs)
	return ofs * COORD_SCALE_Y_960;
end

--UI�ߴ����䣨����Դ�����ȱ����ţ�
function UISize( size )
	size.w = size.w * RESOURCE_SCALE_960;
	size.h = size.h * RESOURCE_SCALE_960;
	return size;
end

--����ߴ�����
function FontSize( fontSize )
	return fontSize * RESOURCE_SCALE_960;
end

--�Ƿ񵥻��¼�
function IsClickEvent( uiEventType )
    return uiEventType == NUIEventType.TE_TOUCH_CLICK;
end

--�Ƿ�˫���¼�
function IsDoubleEvent( uiEventType )
    return uiEventType == NUIEventType.TE_TOUCH_DOUBLE_CLICK;
end

--�¼��ж���ѡ��
function IsSelectViewEvent( uiEventType )
	return uiEventType == NUIEventType.TE_TOUCH_SELECT_VIEW;
end

--�¼��ж���ȡ��ѡ��
function IsUnSelectViewEvent( uiEventType )
	return uiEventType == NUIEventType.TE_TOUCH_UNSELECT_VIEW;
end

--�¼��ж���View��Ϊ����SingleMode��Ч��
function IsActiveViewEvent( uiEventType )
	return uiEventType == NUIEventType.TE_TOUCH_ACTIVE_VIEW;
end

--�¼��ж������󻬶�����
function IsDragLeft( uiEventType )
	return uiEventType == NUIEventType.TE_TOUCH_BTN_DRAG_LEFT;
end

--�¼��ж������һ�������
function IsDragRight( uiEventType )
	return uiEventType == NUIEventType.TE_TOUCH_BTN_DRAG_RIGHT;
end

--�¼��ж������ϻ�������
function IsDragUp( uiEventType )
	return uiEventType == NUIEventType.TE_TOUCH_BTN_DRAG_UP;
end

--�¼��ж������»�������
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

--������Ч
function ShowLoading( flag )
	--[[
	if flag then
		dlg_loading.Show();
	else
		dlg_loading.CloseUI();
	end--]]
end