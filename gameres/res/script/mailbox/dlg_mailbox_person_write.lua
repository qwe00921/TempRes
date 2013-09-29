--------------------------------------------------------------
-- FileName: 	dlg_mailbox_person_write.lua
-- author:		zjj, 2013/09/18
-- purpose:		д�ʼ�����
--------------------------------------------------------------

dlg_mailbox_person_write = {}
local p = dlg_mailbox_person_write;

p.layer = nil;
local ui = ui_dlg_mailbox_person_write;
p.action = nil;

p.normal = 1;
p.reply = 2;

--��ʾUI
function p.ShowUI( action )
	local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end
    
	layer:Init();	
	GetUIRoot():AddDlg(layer);
    LoadDlg("dlg_mailbox_person_write.xui", layer, nil);
	
	if action ~= nil then
	   p.action = action
	end
	p.layer = layer;
	p.SetDelegate();

end

--�����¼�����
function p.SetDelegate(layer)
	--����
	local backBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_BACK);
    backBtn:SetLuaDelegate(p.OnWriteMailUIEvent);
    
    --����
    local sendBtn = GetButton(p.layer,ui.ID_CTRL_BUTTON_SEND);
    sendBtn:SetLuaDelegate(p.OnWriteMailUIEvent);
    
end

--�¼�����
function p.OnWriteMailUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
        if ( ui.ID_CTRL_BUTTON_BACK == tag ) then	
			p.CloseUI();
			
	    elseif (ui.ID_CTRL_BUTTON_SEND == tag) then
	    
		end					
	end
end

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