--------------------------------------------------------------
-- FileName: 	dlg_drama.lua
-- author:		
-- purpose:		剧情界面
--------------------------------------------------------------

dlg_drama = {}
local p = dlg_drama;

p.layer = nil;

--显示UI
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

--初始化控件
function p.Init()
end

--设置事件
function p.SetDelegate()
end

--隐藏UI
function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end

--关闭UI
function p.CloseUI()
end

