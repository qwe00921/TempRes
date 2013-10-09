--------------------------------------------------------------
-- FileName: 	dlg_user_skill_intensify.lua
-- author:		xyd, 2013��8��13��
-- purpose:		���ܿ���ȷ�Ͻ���
--------------------------------------------------------------

dlg_user_skill_intensify = {}
local p = dlg_user_skill_intensify;
local ui = ui_dlg_user_skill_intensify;

p.layer = nil;
p.materCardList = {};
p.masterCard = nil;

p.needMoney = nil;
p.allMoney = nil;
p.allExp = nil;

p.pBtnBack = nil;
p.pBtnEquip = nil;
p.pBtnIntensify = nil;
p.pTextNeedMoney = nil;
p.masterCardexp = nil;

p.materialIndex = {
	ui.ID_CTRL_PICTURE_MATERIAL1,
	ui.ID_CTRL_PICTURE_MATERIAL2,
	ui.ID_CTRL_PICTURE_MATERIAL3,
	ui.ID_CTRL_PICTURE_MATERIAL4
};

function p.ShowUI(masterCard)

	if p.layer == nil then
		local layer = createNDUIDialog();
		if layer == nil then
			return false;
		end
		layer:Init();
		GetUIRoot():AddDlg(layer);
		LoadDlg("dlg_user_skill_intensify.xui", layer, nil);
		p.layer = layer;
		p.masterCard = masterCard;
		p.init();
		p.SetDelegate();
	end
end

function p.init()

	local cardItem = SelectRow(T_SKILL,p.masterCard.skill_id);
	if cardItem == nil then
		return;
	end

	-- ����icon
	local masterCardIcon = GetImage( p.layer, ui.ID_CTRL_PICTURE_ICON );
	masterCardIcon:SetPicture( user_skill_mgr.GetCardPicture(p.masterCard.skill_id) );

	-- ��������
	local masterCardName = GetLabel( p.layer,ui.ID_CTRL_TEXT_NAME );
	masterCardName:SetText(tostring(cardItem.name));

	-- ϡ�ж�
	local masterCardRare = GetLabel( p.layer,ui.ID_CTRL_TEXT_RATE );
	local rare = string.format("%s:%s",GetStr("user_skill_rate"),tostring(cardItem.rare));
	masterCardRare:SetText(rare);

	-- �ȼ�
	local masterCardLevel = GetLabel( p.layer,ui.ID_CTRL_TEXT_LV );
	local level = string.format("%s:%s/%s",GetStr("user_skill_level"),tostring(p.masterCard.level),tostring(cardItem.level_max));
	masterCardLevel:SetText(level);

	-- ��Ǯ
	p.pTextNeedMoney = GetLabel( p.layer, ui.ID_CTRL_TEXT_ANGSTER );
	p.needMoney = SelectCellMatch( T_SKILL_GROW, "level", p.masterCard.level, "need_money" );
	p.pTextNeedMoney:SetText(GetStr("user_skill_needmoney_title"));

	-- ����ֵ
	p.masterCardexp = GetLabel( p.layer,ui.ID_CTRL_TEXT_EXP )
	local needexp = SelectCellMatch( T_SKILL_GROW,"level" , p.masterCard.level, "exp" );
	local exp = string.format("%s:%s/%s",GetStr("user_skill_exp"),tostring(p.masterCard.exp),tostring(needexp));
	p.masterCardexp:SetText(exp);

end

--�����¼�����
function p.SetDelegate()

	p.pBtnBack = GetButton(p.layer,ui.ID_CTRL_BUTTON_BACK);
	p.pBtnBack:SetLuaDelegate(p.OnUIEvent);

	p.pBtnEquip = GetButton(p.layer,ui.ID_CTRL_BUTTON_SELECT);
	p.pBtnEquip:SetLuaDelegate(p.OnUIEvent);

	p.pBtnIntensify = GetButton(p.layer,ui.ID_CTRL_BUTTON_INTENSIFY);
	p.pBtnIntensify:SetLuaDelegate(p.OnUIEvent);
	p.pBtnIntensify:SetEnabled(false);

end


--�¼�����
function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
		if ( ui.ID_CTRL_BUTTON_BACK == tag ) then
			--����
			p.CloseUI();
			dlg_user_skill.ShowUI(SKILL_INTENT_PREVIEW);
		elseif ( ui.ID_CTRL_BUTTON_SELECT == tag ) then
			--ѡ���زĿ�
			p.SelectMaterialCard();
		elseif ( ui.ID_CTRL_BUTTON_INTENSIFY == tag ) then
			-- ��ʼǿ��
			p.StartIntensify();
		end
	end
end

-- ѡ���زĿ�
function p.SelectMaterialCard()
	p.ClearMaterialCard();
	user_skill_mgr.masterCardId = p.masterCard.id;
	dlg_user_skill.ShowUI(SKILL_INTENT_GETLIST);
end

-- ��ʼǿ��
function p.StartIntensify()
	local playerGold = tonumber(msg_cache.msg_player.gold);
	if (tonumber(p.allMoney) <= playerGold) then
		dlg_user_skill_intensify_result.ShowUI(p.masterCard,p.materCardList,p.allMoney);
		p.CloseUI();
	else
		dlg_msgbox.ShowOK( GetStr( "user_skill_msg_title" ), GetStr( "user_skill_gold" ), p.OnMsgBoxCallback );
	end
end

-- ����زĿ�
function p.ClearMaterialCard()
	if p.materCardList ~= nil and #p.materCardList > 0 then
		for i=1,#p.materCardList do
			-- ����زĿ�
			p.materCardList[i] = GetImage( p.layer, p.materialIndex[i]);
			p.materCardList[i]:SetPicture( GetPictureByAni("card.card_box_db", -1) );
		end
	end
end


-- �����زĿ�
function p.ShowMaterialCard(mCardList)

	if mCardList~= nil then
		local cardNum = #mCardList;
		p.allExp = 0;
		for i=1,cardNum do
			p.materCardList[i] = GetImage( p.layer, p.materialIndex[i]);
			p.materCardList[i]:SetPicture( user_skill_mgr.GetCardPicture(mCardList[i].skill_id) );
			p.materCardList[i]:SetId( tonumber(mCardList[i].id));
			-- ���㾭��
			local skill_level = tonumber(mCardList[i].level);
			local skill_exp = tonumber(SelectCell( T_SKILL, mCardList[i].skill_id, "exp" ));
			local skill_ratio = tonumber(SelectCellMatch( T_CONFIG, "name" , "skill_exp_exchange_param", "config"));
			p.allExp = tonumber(p.allExp) + (skill_exp * (1 + (skill_level * skill_ratio)));
		end

		-- �����Ǯ
		p.allMoney = cardNum *  tonumber(p.needMoney);
		p.pTextNeedMoney:SetText(GetStr("user_skill_needmoney")..":"..p.allMoney);

		-- ��ʾ����
		local masterExp = SelectCellMatch( T_SKILL_GROW,"level" , p.masterCard.level, "exp" );
		local exp = string.format("%s:%s+(%s)/%s",GetStr("user_skill_exp"),tostring(p.masterCard.exp),tostring(p.allExp),tostring(masterExp));
		p.masterCardexp:SetText(exp)

		p.materCardList = mCardList;
		p.pBtnIntensify:SetEnabled(true);
	end

end

function p.OnMsgBoxCallback()

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