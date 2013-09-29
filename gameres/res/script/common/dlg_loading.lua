--------------------------------------------------------------
-- FileName: 	dlg_loading.lua
-- author:		hst, 2013年8月13日
-- purpose:		正在加载
--------------------------------------------------------------

dlg_loading = {}
local p = dlg_loading;

p.layer = nil;
local loading_busy = false;

---------显示UI----------
function p.ShowUI()
	if not loading_busy then
		return ;
	end
	if p.layer ~= nil then
		p.layer:SetVisible( true );
	else
		local layer =createNDUIDialog();
    	if layer == nil then
        	return false;
   		end
		layer:NoMask();
		layer:NoAction();
		layer:Init();
		GetUIRoot():AddDlg(layer);
	
    	LoadDlg("dlg_loading.xui", layer, nil);
	
		p.layer = layer;
		p.Init();
	end
end

function p.Show()
    if not loading_busy then
	    loading_busy = true;
	    SetTimerOnce( p.ShowUI, 1.0f );
    end	   
end

function p.Init()
	local bg = GetImage( p.layer,ui_dlg_loading.ID_CTRL_PICTURE_BG );
	bg:SetPicture( GetPictureByAni("ui.loading", 0) );
end

function p.HideUI()
	loading_busy = false;
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end

function p.CloseUI()
	loading_busy = false;
    if p.layer ~= nil then
	    p.layer:LazyClose();
        p.layer = nil;
    end
end