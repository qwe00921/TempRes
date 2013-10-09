--------------------------------------------------------------
-- FileName: 	dlg_encounter_goods.lua
-- author:		xyd, 2013/07/25
-- purpose:		‘‚”ˆªı±“
--------------------------------------------------------------

dlg_encounter_goods = {}
local p = dlg_encounter_goods;

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
    LoadDlg("dlg_encounter_goods.xui", layer, nil);
	
	p.layer = layer;
	
	p.Init(layer);
	
end


function p.Init(layer)	

	local card_img = GetImage( layer, ui_dlg_encounter_goods.ID_CTRL_PICTURE_1 );
	card_img:SetPicture( GetPictureByAni("lancer.encounter_goods", 0) );
	
	local card_name_bg = GetImage( layer, ui_dlg_encounter_goods.ID_CTRL_PICTURE_2 );
	card_name_bg:SetPicture( GetPictureByAni("lancer.encounter_goods", 1) );
	
	local card_property_bg = GetImage( layer, ui_dlg_encounter_goods.ID_CTRL_PICTURE_4 );
	card_property_bg:SetPicture( GetPictureByAni("lancer.encounter_goods", 2) );

end


function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end