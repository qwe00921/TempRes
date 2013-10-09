--------------------------------------------------------------
-- FileName: 	dlg_encounter_money.lua
-- author:		xyd, 2013/07/25
-- purpose:		‘‚”ˆªı±“
--------------------------------------------------------------

dlg_encounter_money = {}
local p = dlg_encounter_money;

p.layer = nil;

--œ‘ æUI
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
	layer:SetSwallowTouch(false);
	layer:SetFrameRectFull();

	GetUIRoot():AddChild(layer);	
    LoadDlg("dlg_encounter_props.xui", layer, nil);
	
	p.layer = layer;
	
	p.Init(layer);
	
end


function p.Init(layer)	

	local money_img = GetImage( layer, ui_dlg_encounter_props.ID_CTRL_PICTURE_1 );
	money_img:SetPicture( GetPictureByAni("lancer.encounter_money", 0) );
	
	local money_bg = GetImage( layer, ui_dlg_encounter_props.ID_CTRL_PICTURE_2 );
	money_bg:SetPicture( GetPictureByAni("lancer.encounter_money", 1) );

end


function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end