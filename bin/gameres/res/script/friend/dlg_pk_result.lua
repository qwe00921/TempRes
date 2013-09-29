--------------------------------------------------------------
-- FileName: 	dlg_pk_result.lua
-- author:		zjj, 2013/08/23
-- purpose:		pk结果界面
--------------------------------------------------------------

dlg_pk_result = {}
local p = dlg_pk_result;

p.layer = nil;
p.caller = nil;

--显示UI
function p.ShowUI(pkresult)
    
    if p.layer ~= nil then
		p.layer:SetVisible( true );
		return;
	end
	local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end
	
	layer:Init();	
	GetUIRoot():AddDlg(layer);
    LoadDlg("dlg_pk_result.xui", layer, nil);
	
	p.layer = layer;
	p.Init(pkresult);
    p.SetDelegate();
end

function p.Init(pkresult)
    local titleLab = GetLabel( p.layer, ui_dlg_pk_result.ID_CTRL_TEXT_TITLE );
    local resultLab = GetLabel( p.layer, ui_dlg_pk_result.ID_CTRL_TEXT_RESULT );
    if pkresult then
        titleLab:SetText( GetStr( "pk_success" ));
        resultLab:SetText( GetStr( "get_pt" ) .. "30" .. GetStr( "point" ));
    else 
        titleLab:SetText( GetStr( "pk_fail" ));
        resultLab:SetText( GetStr( "please_come_on" ) );
    end
	
end
--设置事件处理
function p.SetDelegate()
	
    local closeBtn = createNDUIButton();
    closeBtn:Init();
    closeBtn:SetFrameRectFull();
    p.layer:AddChildZ(closeBtn,5);
    closeBtn:SetLuaDelegate(p.OnPKResultUIEvent);
end

function p.OnPKResultUIEvent(uiNode, uiEventType, param)
    WriteCon( "dianji pk ui" );
    dlg_friend.SetPkBtn();
    p.CloseUI();
end

--设置可见
function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end

function p.CloseUI()
	if p.layer ~= nil then
	    p.layer:LazyClose();
        p.layer = nil;
    end
end

