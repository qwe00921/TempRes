--------------------------------------------------------------
-- FileName: 	dlg_collect_pet_detail.lua
-- author:		xyd, 2013年8月12日
-- purpose:		宠物图鉴详细
--------------------------------------------------------------

dlg_collect_pet_detail = {}
local p = dlg_collect_pet_detail;
local ui = ui_collect_pet_detail;

p.layer = nil;
p.masterCard = nil;

p.rareTag = {
	ui.ID_CTRL_PICTURE_RARE1,
	ui.ID_CTRL_PICTURE_RARE2,
	ui.ID_CTRL_PICTURE_RARE3,
	ui.ID_CTRL_PICTURE_RARE4,
	ui.ID_CTRL_PICTURE_RARE5,
	ui.ID_CTRL_PICTURE_RARE6,
	ui.ID_CTRL_PICTURE_RARE7,
};
p.rarePics = {};

function p.ShowUI(masterCard)

    if p.layer == nil then    
        local layer = createNDUIDialog();
        if layer == nil then
            return false;
        end

        layer:Init();       
        GetUIRoot():AddDlg(layer);
        LoadDlg("collect_pet_detail.xui", layer, nil);
        p.layer = layer;
        p.masterCard = masterCard;
        p.init();
        p.SetDelegate();
    end 
end

function p.init()
    
    local cardItem = SelectRow(T_CARD,p.masterCard.collect_id);
    if cardItem == nil then
    	return;
    end
    
    -- 宠物icon
    local pet_icon = GetImage( p.layer, ui.ID_CTRL_PICTURE_CARD );
    pet_icon:SetPicture( collect_mgr.GetCardPicture(p.masterCard.collect_id) );

    -- 技能名称
    local pet_name = GetLabel( p.layer,ui.ID_CTRL_TEXT_CARDNAME );
    pet_name:SetText(tostring(cardItem.name));

    -- 稀有度
    local rare = tonumber(cardItem.rare);
    for i=1,#p.rareTag do
    	p.rarePics[i] = GetImage( p.layer, p.rareTag[i] );
    end
    p.SetRareStatus(rare);
    

    -- 生命
    local hp = GetLabel( p.layer,ui.ID_CTRL_TEXT_HP );
    hp:SetText(tostring(cardItem.hp_min));
    
    -- 暴击
    local critical = GetLabel( p.layer,ui.ID_CTRL_TEXT_CRITICAL );
    critical:SetText(tostring(""));
    
    -- 攻击
    local atk = GetLabel( p.layer,ui.ID_CTRL_TEXT_ATK );
    atk:SetText(tostring(cardItem.attack_min));
    
    -- 防御
    local def = GetLabel( p.layer,ui.ID_CTRL_TEXT_DEF );
    def:SetText(tostring(cardItem.defence_min));

    -- 技能名称   
    local skillName = GetLabel( p.layer,ui.ID_CTRL_TEXT_SKILL_NAME )
    skillName:SetText(tostring(""));
   
   	-- 技能说明
    local skillDescript = GetLabel( p.layer,ui.ID_CTRL_TEXT_SKILL_DESCRIPTION )
    skillDescript:SetText(tostring(""));
    
    -- 人物描述   
    local petDescript = GetLabel( p.layer,ui.ID_CTRL_TEXT_CHARACTER )
    petDescript:SetText(tostring(cardItem.description));

end

function p.SetRareStatus(rare)

	for i=1,#p.rarePics do
    	if i <= rare then
    		p.rarePics[i]:SetVisible(true);
    	else
    		p.rarePics[i]:SetVisible(false);
    	end
    end
    
end

--设置事件处理
function p.SetDelegate(layer)
	local pBtnBack = GetButton(p.layer,ui.ID_CTRL_BUTTON_BACK);
    pBtnBack:SetLuaDelegate(p.OnUIEvent); 
end

--事件处理
function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
        if ( ui.ID_CTRL_BUTTON_BACK == tag ) then
        	-- 返回
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
    	p.masterCard = nil;
    	p.rarePics = {};
	    p.layer:LazyClose();
        p.layer = nil;
    end
end