--------------------------------------------------------------
-- FileName: 	dlg_user_skill_exp_detail.lua
-- author:		xyd, 2013年8月12日
-- purpose:		经验卡片详细
--------------------------------------------------------------

dlg_user_skill_exp_detail = {}
local p = dlg_user_skill_exp_detail;

p.layer = nil;
p.masterCard = nil;

function p.ShowUI(masterCard)

    if p.layer == nil then    
        local layer = createNDUIDialog();
        if layer == nil then
            return false;
        end

        layer:Init();       
        GetUIRoot():AddDlg(layer);
        LoadDlg("dlg_user_skill_exp_detail.xui", layer, nil);
        p.layer = layer;
        p.masterCard = masterCard;
        p.init();
        p.SetDelegate();
    end 
end

function p.init()
    
    -- 经验卡icon
    local skill_icon = GetImage( p.layer, ui_dlg_user_skill_exp_detail.ID_CTRL_PICTURE_ICON );
    skill_icon:SetPicture( user_skill_mgr.GetCardPicture(p.masterCard.skill_id) );

    -- 经验卡名称
    local skill_name = GetLabel( p.layer,ui_dlg_user_skill_exp_detail.ID_CTRL_TEXT_TITLE );
    skill_name:SetText(SelectCell( T_SKILL, p.masterCard.skill_id, "name" ));

    -- 经验卡说明    
    local skill_descript = GetLabel( p.layer,ui_dlg_user_skill_exp_detail.ID_CTRL_TEXT_DESCRIPT )
    skill_descript:SetText(SelectCell( T_SKILL, p.masterCard.skill_id, "description" ));

end

--设置事件处理
function p.SetDelegate(layer)

	local pBtnBack = GetButton(p.layer,ui_dlg_user_skill_exp_detail.ID_CTRL_BUTTON_BACK);
    pBtnBack:SetLuaDelegate(p.OnUIEvent);

end

--事件处理
function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
        if ( ui_dlg_user_skill_exp_detail.ID_CTRL_BUTTON_BACK == tag ) then	
            p.CloseUI();
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
        p.masterCard = nil;
    end
end