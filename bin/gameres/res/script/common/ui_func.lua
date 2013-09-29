--------------------------------------------------------------
-- FileName: 	ui_func.lua
-- author:		
-- purpose:		UI���ú�������
--------------------------------------------------------------

--ui�¼����Ͷ���
NUIEventType = 
{
	TE_NONE = 0,
	
	TE_TOUCH_CLICK			        = 1, --����
	TE_TOUCH_DOUBLE_CLICK	        = 2, --˫��
	
	TE_TOUCH_BTN_DRAG_IN		    = 3, --����
	TE_TOUCH_BTN_DRAG_OUT		    = 4, --�ϳ�
	TE_TOUCH_BTN_DRAG_OUT_COMPLETE  = 5, --�ϳ����

	--edit�¼�
	TE_TOUCH_EDIT_RETURN		    = 6,
	TE_TOUCH_EDIT_TEXT_CHANGE	    = 7,
	TE_TOUCH_EDIT_INPUT_FINISH      = 8,
	
	--ѡ��仯
	TE_TOUCH_SELECT_VIEW			= 9,
	TE_TOUCH_UNSELECT_VIEW			= 10,	
	TE_TOUCH_ACTIVE_VIEW            = 11,
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

--������Ч
function ShowLoading( flag )
	if flag then
		dlg_loading.Show();
	else
		dlg_loading.CloseUI();
	end
end
