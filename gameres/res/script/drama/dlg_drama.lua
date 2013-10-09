--------------------------------------------------------------
-- FileName: 	dlg_drama.lua
-- author:		
-- purpose:		�������
--------------------------------------------------------------

dlg_drama = {}
local p = dlg_drama;

p.layer = nil;

--��ʾUI
function p.ShowUI()
    
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
    LoadDlg("dlg_drama.xui", layer, nil);
	
	p.layer = layer;
	p.Init();
	p.SetDelegate();
end

--��ʼ���ؼ�
function p.Init()
end

--�����¼�
function p.SetDelegate()
end

--����UI
function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end

--�ر�UI
function p.CloseUI()
end

