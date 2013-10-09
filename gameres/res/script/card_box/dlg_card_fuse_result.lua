--------------------------------------------------------------
-- FileName: 	dlg_card_fuse_result.lua
-- author:		zjj, 2013/07/22
-- purpose:		卡片融合结果界面
--------------------------------------------------------------

dlg_card_fuse_result = {}
local p = dlg_card_fuse_result;
p.layer = nil;
p.selectCardindex = 0;


--显示UI
function p.ShowUI(card)
	local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end
    
	layer:Init();	
	GetUIRoot():AddDlg(layer);
    LoadDlg("dlg_card_fuse_result.xui", layer, nil);
	
	p.SetDelegate(layer);
	p.layer = layer;
	p.RefreshUI(card)
end

--设置事件处理
function p.SetDelegate(layer)
	--首页按钮
	local topBtn = GetButton(layer,ui_dlg_card_fuse_result.ID_CTRL_BUTTON_14);
    topBtn:SetLuaDelegate(p.OnUIEventFuseResult);
	--返回
	local topBack = GetButton(layer,ui_dlg_card_fuse_result.ID_CTRL_BUTTON_15);
    topBack:SetLuaDelegate(p.OnUIEventFuseResult);
end

function p.OnBtnClicked()
    WriteCon( "on btn clicked" );
end

--事件处理
function p.OnUIEventFuseResult(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	WriteCon( "on btn clicked" .. tag );
	if IsClickEvent( uiEventType ) then
        if ( ui_dlg_card_fuse_result.ID_CTRL_BUTTON_14 == tag ) then	
			--task_map_mainui.ShowUI();
			p.CloseUI();
		elseif ( ui_dlg_card_fuse_result.ID_CTRL_BUTTON_15 == tag ) then
			dlg_card_fuse.RefreshUI();
			p.CloseUI();
		end					
	end
end

function p.RefreshUI(card)
		--卡牌名称
		local pCardNameLabel = GetLabel(p.layer, ui_dlg_card_fuse_result.ID_CTRL_TEXT_4);
		local cardName = SelectCell( T_CARD, card.card_id, "name" );
		pCardNameLabel:SetText(tostring(cardName));
		--稀有度
		local pRarityLabel = GetLabel(p.layer, ui_dlg_card_fuse_result.ID_CTRL_TEXT_5);
		pRarityLabel:SetText(tostring(card.rare));
		--等级
		local pLevelLabel = GetLabel(p.layer, ui_dlg_card_fuse_result.ID_CTRL_TEXT_6);
		pLevelLabel:SetText(tostring(card.level));
		--生命
		local pLifeLabel = GetLabel(p.layer, ui_dlg_card_fuse_result.ID_CTRL_TEXT_7);
		pLifeLabel:SetText(tostring(card.hp));
		--攻击
		local pAtkLabel = GetLabel(p.layer, ui_dlg_card_fuse_result.ID_CTRL_TEXT_8);
		pAtkLabel:SetText(tostring(card.attack));
		--防御
		local pDefLabel = GetLabel(p.layer, ui_dlg_card_fuse_result.ID_CTRL_TEXT_9);
		pDefLabel:SetText(tostring(card.defence));	
		if card.skill_id ~= 0 then
			--技能名称
			local pSkillNameLabel = GetLabel(p.layer, ui_dlg_card_fuse_result.ID_CTRL_TEXT_10);
			local skillName = SelectCell( T_SKILL, card.skill_id, "name" );
			pSkillNameLabel:SetText(tostring(skillName));
			--技能说明
			local pSkillLExplainLabel = GetLabel(p.layer, ui_dlg_card_fuse_result.ID_CTRL_TEXT_11);
			local skillExplain = SelectCell( T_SKILL, card.skill_id, "description" );
			pSkillLExplainLabel:SetText(tostring(skillExplain));
		end
		local pSkillNameLabel = GetLabel(p.layer, ui_dlg_card_fuse_result.ID_CTRL_TEXT_10);
		pSkillNameLabel:SetText("  ");
		--技能说明
		local pSkillLExplainLabel = GetLabel(p.layer, ui_dlg_card_fuse_result.ID_CTRL_TEXT_11);
		pSkillLExplainLabel:SetText("");
		--经验值
		local pExpLabel = GetLabel(p.layer, ui_dlg_card_fuse_result.ID_CTRL_TEXT_26);
		pExpLabel:SetText(tostring(card.exp));
	
		--卡牌图片
		local pCardImg = GetImage(p.layer,ui_dlg_card_fuse_result.ID_CTRL_PICTURE_3);
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