--------------------------------------------------------------
-- FileName:    dlg_user_skill.lua
-- author:      xyd, 2013/08/02
-- purpose:     技能卡包界面
--------------------------------------------------------------

dlg_user_skill = {}
local p = dlg_user_skill;
local ui = ui_dlg_user_skill;
local sl_ui = ui_user_skill_view;

p.layer = nil;
p.title = nil;                                  --标题
p.tip = nil;                                    --提示
p.resetBtn = nil;                               --重置按钮
p.checkBtn = nil;                               --确认按钮
p.pTextCardNum = nil;                           --卡包数量

p.intent = nil;                                 --意图标识
p.sort_flag = nil;                 				--排序标识
p.cur_category = nil;                			--当前分类标识
p.caller = nil;
p.curBtnNode = nil;


function p.ShowUI(intent,caller)

	if p.layer == nil then
		local layer = createNDUIDialog();
		if layer == nil then
			return false;
		end
		layer:Init();
		GetUIRoot():AddDlg(layer);
		LoadDlg("dlg_user_skill.xui", layer, nil);
		p.intent = intent;
		p.layer = layer;
		p.Init();
		p.SetDelegate();
		SetTimerOnce( user_skill_mgr.LoadCard, 0.5f );
	end

	if caller ~= nil then
		p.caller = caller;
	end
end

function p.Init()

	p.sort_flag = SKILL_SORT_LEVEL;
	p.cur_category = SKILL_PIERCE_4;
	
	p.title = GetLabel( p.layer, ui.ID_CTRL_TEXT_TITLE );
	p.tip = GetLabel( p.layer, ui.ID_CTRL_TEXT_TIP );
	p.title:SetText(GetStr("user_skill_preview"));
end

function p.SetDelegate()
	--返回
	local pUserSkillBtn01 = GetButton(p.layer,ui.ID_CTRL_BUTTON_BACK);
	pUserSkillBtn01:SetLuaDelegate(p.OnUIEventUserSkill);

	--排序
	local pUserSkillBtn02 = GetButton(p.layer,ui.ID_CTRL_BUTTON_SORT);
	pUserSkillBtn02:SetLuaDelegate(p.OnUIEventUserSkill);

	--全部
	local pUserSkillBtn03 = GetButton(p.layer,ui.ID_CTRL_BUTTON_ALL);
	pUserSkillBtn03:SetLuaDelegate(p.OnUIEventUserSkill);

	--分类：主动技能
	local pUserSkillBtn04 = GetButton(p.layer,ui.ID_CTRL_BUTTON_INITIATIVE_SKILL);
	pUserSkillBtn04:SetLuaDelegate(p.OnUIEventUserSkill);

	--分类：被动技能
	local pUserSkillBtn05 = GetButton(p.layer,ui.ID_CTRL_BUTTON_PASSIVITY_SKILL);
	pUserSkillBtn05:SetLuaDelegate(p.OnUIEventUserSkill);

	--分类：经验卡片
	local pUserSkillBtn06 = GetButton(p.layer,ui.ID_CTRL_BUTTON_EXP);
	pUserSkillBtn06:SetLuaDelegate(p.OnUIEventUserSkill);

	--确认选择
	local pUserSkillBtn07 = GetButton(p.layer,ui.ID_CTRL_BUTTON_CONFIRM);
	pUserSkillBtn07:SetLuaDelegate(p.OnUIEventUserSkill);
	p.checkBtn = pUserSkillBtn07;

	--重置
	local pUserSkillBtn08 = GetButton(p.layer,ui.ID_CTRL_BUTTON_RESET);
	pUserSkillBtn08:SetLuaDelegate(p.OnUIEventUserSkill);
	p.resetBtn = pUserSkillBtn08;

	if SKILL_INTENT_PREVIEW == p.intent then
		p.SetBtnVisible(false);
	elseif SKILL_INTENT_GETLIST == p.intent then
		p.SetBtnVisible(false);
	elseif SKILL_INTENT_GETONE == p.intent then
		p.SetBtnVisible(true);
	end

end


--事件处理
function p.OnUIEventUserSkill(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
		if ( ui.ID_CTRL_BUTTON_BACK == tag ) then
			-- 返回
			p.CloseUI();
		elseif ( ui.ID_CTRL_BUTTON_SORT == tag ) then
			-- 排序
			p.LoadSortCard();
		elseif ( ui.ID_CTRL_BUTTON_ALL == tag ) then
			-- 全部
			p.SetBtnCheckedFX(uiNode);
			user_skill_mgr.ShowAllCards();
		elseif ( ui.ID_CTRL_BUTTON_INITIATIVE_SKILL == tag ) then
			-- 主动技能
			p.SetBtnCheckedFX(uiNode);
			p.LoadCardByCategory(SKILL_PIERCE_1);
		elseif ( ui.ID_CTRL_BUTTON_PASSIVITY_SKILL == tag ) then
			-- 被动技能
			p.SetBtnCheckedFX(uiNode);
			p.LoadCardByCategory(SKILL_PIERCE_2);
		elseif ( ui.ID_CTRL_BUTTON_EXP == tag ) then
			-- 经验卡牌
			p.SetBtnCheckedFX(uiNode);
			p.LoadCardByCategory(SKILL_PIERCE_3);
		elseif ( ui.ID_CTRL_BUTTON_CONFIRM == tag ) then
			-- 确认选择
			p.ConfirmSelectCard();
		elseif ( ui.ID_CTRL_BUTTON_RESET == tag ) then
			-- 重置
			p.ResetSelectCard();
		end
	end
end

-- 卡牌排序
function p.LoadSortCard()
	user_skill_mgr.sortCardList(p.sort_flag,p.cur_category);
	if p.sort_flag == SKILL_SORT_LEVEL then
		p.sort_flag = SKILL_SORT_RARE;
	elseif p.sort_flag == SKILL_SORT_RARE then
		p.sort_flag = SKILL_SORT_LEVEL;
	end
end

-- 卡牌分类
function p.LoadCardByCategory(category)
	p.cur_category = category;
	user_skill_mgr.LoadCardByCategory( category );
end

-- 确认
function p.ConfirmSelectCard()
	if SKILL_INTENT_GETLIST == p.intent then
		dlg_user_skill_intensify.ShowMaterialCard(user_skill_mgr.GetSelectCardList());
		p.CloseUI();
	elseif SKILL_INTENT_GETONE == p.intent then
		if user_skill_mgr.singleCard ~= nil and p.caller ~= nil then
			p.caller.LoadSelectData(user_skill_mgr.singleCard);
			p.CloseUI();
		end
	end
end

-- 重置
function p.ResetSelectCard()
	p.SetTip( GetStr( "user_skill_tip" ) );
	p.SetBtnVisible(false);
	user_skill_mgr.ClearSelectList();
end

--显示卡牌列表
function p.ShowCardList( cardList )

	local list = GetListBoxVert(p.layer ,ui.ID_CTRL_VERTICAL_LIST_15);
	list:ClearView();

	if cardList == nil or #cardList <= 0 then
		WriteCon("ShowCardList():cardList is null");
		return ;
	end

	local listLenght = #cardList;
	p.SetTitleText(listLenght);

	local row = math.ceil(listLenght / 4);
	for i = 1,row do
		local view = p.CreateScrollView();
		local start_index = (i-1)*4+1;
		local end_index = start_index + 3;
		--设置列表项信息，一行四张卡牌
		for j = start_index,end_index do
			if j <= listLenght then
				p.SetItemInfo( view, cardList[j], end_index - j );
			end
		end
		list:AddView( view );
	end

end

-- 创建滑动视图
function p.CreateScrollView()
	local view = createNDUIXView();
	view:Init();
	LoadUI( "user_skill_view.xui", view, nil );
	view:SetViewSize( GetUiNode( view, sl_ui.ID_CTRL_PICTURE_25 ):GetFrameSize());
	return view;
end

function p.SetItemInfo( view, card, itemIndex )

	local lv;
	local cardPic;
	if itemIndex == 3 then
		lv = sl_ui.ID_CTRL_TEXT_23;
		cardPic = sl_ui.ID_CTRL_BUTTON_38;
	elseif itemIndex == 2 then
		lv = sl_ui.ID_CTRL_TEXT_16;
		cardPic = sl_ui.ID_CTRL_BUTTON_39;
	elseif itemIndex == 1 then
		lv = sl_ui.ID_CTRL_TEXT_17;
		cardPic = sl_ui.ID_CTRL_BUTTON_40;
	elseif itemIndex == 0 then
		lv = sl_ui.ID_CTRL_TEXT_18;
		cardPic = sl_ui.ID_CTRL_BUTTON_41;
	end

	--等级
	local lvNode = GetLabel( view, lv );
	lvNode:SetText(GetStr("card_level")..tostring(card.level));

	--卡牌图片
	local cardPicNode = GetButton( view, cardPic );
	cardPicNode:SetImage( user_skill_mgr.GetCardPicture(card.skill_id) );
	cardPicNode:SetTouchDownImage( user_skill_mgr.GetCardPicture(card.skill_id) );
	cardPicNode:SetId( tonumber(card.id));

	--增加事件
	cardPicNode:SetLuaDelegate(p.OnBtnClicked);
end

--卡牌点击事件
function p.OnBtnClicked( uiNode, uiEventType, param )

	if SKILL_INTENT_PREVIEW == p.intent then
		--卡片详细
		local masterCard = user_skill_mgr.GetCardById(tonumber(uiNode:GetId()));
		if SKILL_OWNER_SKILL == tonumber(masterCard.skill_owner) then
			--技能卡牌
			dlg_user_skill_detail.ShowUI(masterCard);
		elseif SKILL_OWNER_EXP == tonumber(masterCard.skill_owner) then
			--技能经验卡
			dlg_user_skill_exp_detail.ShowUI(masterCard);
		end
	elseif SKILL_INTENT_GETLIST == p.intent then
		-- 选择素材卡
		p.checkCardIsSelect(uiNode);
	elseif SKILL_INTENT_GETONE == p.intent then
		-- 选择单张卡牌
		p.getSingleCard(uiNode);
	end
end

-- 选择单张卡牌
function p.getSingleCard(uiNode)

	if user_skill_mgr.singleCard == nil then
		uiNode:AddFgEffect("ui.card_select_fx");
		user_skill_mgr.singleCard = user_skill_mgr.GetCardById(tonumber(uiNode:GetId()));
		p.checkBtn:SetEnabled(true);
	else
		uiNode:DelAniEffect("ui.card_select_fx");
		user_skill_mgr.singleCard = nil;
		p.checkBtn:SetEnabled(false);
	end
end

-- 选择素材卡
function p.checkCardIsSelect(uiNode)

	if (user_skill_mgr.GetSelectCardNum() == 0) then
		uiNode:AddFgEffect("ui.card_select_fx");
		user_skill_mgr.selectCardList[1] = uiNode;
	else
		local result = user_skill_mgr.CheckCardIsSelect(tonumber(uiNode:GetId()));
		if (result ~= -1) then
			--已选中,删除
			uiNode:DelAniEffect("ui.card_select_fx");
			table.remove( user_skill_mgr.selectCardList, tonumber(result));
		else
			--未选中,添加
			if (user_skill_mgr.CheckSelectCardLimit()) then
				dlg_msgbox.ShowOK( ToUtf8( "提示" ), GetStr( "user_skill_material_msg_1" ), p.OnMsgBoxCallback );
			else
				uiNode:AddFgEffect("ui.card_select_fx");
				user_skill_mgr.selectCardList[user_skill_mgr.GetSelectCardNum() + 1] = uiNode;
			end
		end
	end

	-- 设置按钮状态
	local cur_num = tonumber(user_skill_mgr.GetSelectCardNum());
	local tipText = string.format("%s:%d/%d",GetStr("user_skill_tip"),cur_num,MATERIAL_SELECT_MAX_NUM);
	p.SetTip(tipText);
	p.SetBtnVisible(true);
end


-- 设置按钮显示状态
function p.SetBtnVisible(status)
	p.resetBtn:SetVisible( status );
	p.checkBtn:SetVisible( status );
end

function p.SetTitleText(cardNum)

	-- 更新标题
	if SKILL_INTENT_PREVIEW == p.intent then
		p.SetTitle(GetStr("user_skill_preview"));
	elseif SKILL_INTENT_GETLIST == p.intent then
		p.SetTitle(GetStr("user_skill_getlist"));
		p.SetTip(GetStr("user_skill_tip"));
	end

	-- 更新卡包数量
	p.pTextCardNum = GetLabel( p.layer, ui.ID_CTRL_TEXT_12 );
	local str = string.format("%s:%d/%d",GetStr("user_skill_cardnum"),tonumber(cardNum),SKILL_CARD_MAX_NUM);
	p.pTextCardNum:SetText(str);

end

function p.SetBtnCheckedFX( node )
    local btnNode = ConverToButton( node );
    if p.curBtnNode ~= nil then
    	p.curBtnNode:SetChecked( false );
    end
	btnNode:SetChecked( true );
	p.curBtnNode = btnNode;
end

function p.OnMsgBoxCallback()
end

function p.SetTitle(str)
	if str ~= nil then
		p.title:SetText( str );
	end
end

function p.SetTip(str)
	if str ~= nil then
		p.tip:SetText( str );
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
		p.title = nil;
		p.tip = nil;
		p.resetBtn = nil;
		p.checkBtn = nil;
		p.pTextCardNum = nil;
		user_skill_mgr.ClearData();
	end
end