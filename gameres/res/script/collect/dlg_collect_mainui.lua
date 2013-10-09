--------------------------------------------------------------
-- FileName:    dlg_collect_mainui.lua
-- author:      xyd, 2013/09/11
-- purpose:     图鉴主界面
--------------------------------------------------------------

dlg_collect_mainui = {}
local p = dlg_collect_mainui;
local ui = ui_dlg_collect_mainui;
local ui_pet = ui_collect_pet_view;
local ui_equip = ui_collect_item_view;
local ui_skill = ui_collect_skill_view;

p.layer = nil;
p.cur_option = nil;								--当前选项

--宠物图鉴
p.petBtnCategorys = {};
p.petCategorys = {
	ui.ID_CTRL_BUTTON_DRAGON,					--龙
	ui.ID_CTRL_BUTTON_DEMON,					--恶魔
	ui.ID_CTRL_BUTTON_NATURE,					--自然
	ui.ID_CTRL_BUTTON_ANIMAL,					--动物
	ui.ID_CTRL_BUTTON_FLY,						--飞行
	ui.ID_CTRL_BUTTON_PLANT,					--植物
	ui.ID_CTRL_BUTTON_MATTER					--物质
};
--装备图鉴
p.equipCategorys = {
	ui.ID_CTRL_BUTTON_WEAPON,					--武器
	ui.ID_CTRL_BUTTON_ARMOR,					--防具
	ui.ID_CTRL_BUTTON_ACC						--饰品
};
p.equipBtnCategorys = {};

--角色技能
p.skillCategorys = {
	ui.ID_CTRL_BUTTON_ACTIVE_SKILL,				--主动技能
	ui.ID_CTRL_BUTTON_PASSIVE_SKILL				--被动技能
};
p.skillBtnCategorys = {};

p.listBox = nil;								--滑动列表容器
p.collectType = nil;							--图鉴当前分类名称
p.collectNum = nil;								--当前图鉴数量
p.collectEfficiency = nil;						--收集率

function p.ShowUI()

	if p.layer == nil then
		local layer = createNDUIDialog();
		if layer == nil then
			return false;
		end
		layer:Init();
		GetUIRoot():AddDlg(layer);
		LoadDlg("dlg_collect_mainui.xui", layer, nil);
		p.layer = layer;
		p.Init();
		p.SetDelegate();
		--SetTimerOnce( collect_mgr.LoadCard, 0.5f );
	end
end

function p.Init()
	p.cur_option = COLLECT_OPTION_PET;
	p.listBox = GetListBoxVert(p.layer ,ui.ID_CTRL_VERTICAL_LIST_CONTENT);
	p.collectType = GetLabel( p.layer,ui.ID_CTRL_TEXT_COLLECT_TYPE );
	p.collectNum = GetLabel( p.layer,ui.ID_CTRL_TEXT_COLLECT_NUM );
	p.collectEfficiency = GetLabel( p.layer,ui.ID_CTRL_TEXT_EFFICIENCY );
end

function p.SetDelegate()

	--宠物图鉴
	local btnPet = GetButton(p.layer,ui.ID_CTRL_BUTTON_PET);
	btnPet:SetLuaDelegate(p.OnUIEventCollect);
	
	--装备图鉴
	local btnEquip = GetButton(p.layer,ui.ID_CTRL_BUTTON_EQUIPMENT);
	btnEquip:SetLuaDelegate(p.OnUIEventCollect);
	
	--角色技能
	local btnSkill = GetButton(p.layer,ui.ID_CTRL_BUTTON_SKILL);
	btnSkill:SetLuaDelegate(p.OnUIEventCollect);

	--返回
	local btnBack = GetButton(p.layer,ui.ID_CTRL_BUTTON_BACK);
	btnBack:SetLuaDelegate(p.OnUIEventCollect);
	
	--全部
	local btnAll = GetButton(p.layer,ui.ID_CTRL_BUTTON_ALL);
	btnAll:SetLuaDelegate(p.OnUIEventCollect);
	
	--宠物图鉴按钮分类
	for i=1,#p.petCategorys do
		local btn = GetButton(p.layer,p.petCategorys[i]);
		btn:SetLuaDelegate(p.OnUIEventCollect);
		p.petBtnCategorys[i] = btn;
	end
	
	--装备图鉴按钮分类
	for i=1,#p.equipCategorys do
		local btn = GetButton(p.layer,p.equipCategorys[i]);
		btn:SetLuaDelegate(p.OnUIEventCollect);
		p.equipBtnCategorys[i] = btn;
	end
	
	--角色技能按钮分类
	for i=1,#p.skillCategorys do
		local btn = GetButton(p.layer,p.skillCategorys[i]);
		btn:SetLuaDelegate(p.OnUIEventCollect);
		p.skillBtnCategorys[i] = btn;
	end
	
	-- 设置按钮显示状态
	p.SetBtnStatus();
end

function p.SetBtnStatus()
	if COLLECT_OPTION_PET == p.cur_option then
		--宠物图鉴
		p.SetPetBtnStatus(true);
		p.SetEquipBtnStatus(false);
		p.SetSkillBtnStatus(false);
	elseif COLLECT_OPTION_EQUIP == p.cur_option then
		--装备图鉴
		p.SetPetBtnStatus(false);
		p.SetEquipBtnStatus(true);
		p.SetSkillBtnStatus(false);
	elseif COLLECT_OPTION_SKILL == p.cur_option then
		--角色技能
		p.SetPetBtnStatus(false);
		p.SetEquipBtnStatus(false);
		p.SetSkillBtnStatus(true);
	end
end

-- 设置宠物图鉴按钮状态
function p.SetPetBtnStatus(flag)
	for i=1,#p.petBtnCategorys do
		p.petBtnCategorys[i]:SetVisible(flag);
	end
end

-- 设置装备图鉴按钮状态
function p.SetEquipBtnStatus(flag)
	for i=1,#p.equipBtnCategorys do
		p.equipBtnCategorys[i]:SetVisible(flag);
	end
end

-- 设置角色技能按钮状态
function p.SetSkillBtnStatus(flag)
	for i=1,#p.skillBtnCategorys do
		p.skillBtnCategorys[i]:SetVisible(flag);
	end
end


--事件处理
function p.OnUIEventCollect(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
		if ( ui.ID_CTRL_BUTTON_BACK == tag ) then
			-- 返回
			p.CloseUI();
		elseif ( ui.ID_CTRL_BUTTON_PET == tag ) then
			-- 宠物图鉴
			WriteCon("宠物图鉴");
			collect_mgr.LoadCardByCategory(COLLECT_OPTION_PET);
			p.cur_option = COLLECT_OPTION_PET;
			p.SetBtnStatus();
		elseif ( ui.ID_CTRL_BUTTON_EQUIPMENT == tag ) then
			-- 装备图鉴
			WriteCon("装备图鉴");
			collect_mgr.LoadCardByCategory(COLLECT_OPTION_EQUIP);
			p.cur_option = COLLECT_OPTION_EQUIP;
			p.SetBtnStatus();
		elseif ( ui.ID_CTRL_BUTTON_SKILL == tag ) then
			-- 角色技能
			WriteCon("角色技能");
			collect_mgr.LoadCardByCategory(COLLECT_OPTION_SKILL);
			p.cur_option = COLLECT_OPTION_SKILL;
			p.SetBtnStatus();
		elseif ( ui.ID_CTRL_BUTTON_ALL == tag ) then
			-- 全部
			WriteCon("全部");
		elseif ( ui.ID_CTRL_BUTTON_DRAGON == tag ) then
			-- 龙
			WriteCon("龙");
			collect_mgr.LoadCardByChildCategory(COLLECT_OPTION_PET,COLLECT_PET_DRAGON);
		elseif ( ui.ID_CTRL_BUTTON_DEMON == tag ) then
			-- 恶魔
			WriteCon("恶魔");
			collect_mgr.LoadCardByChildCategory(COLLECT_OPTION_PET,COLLECT_PET_DEMON);
		elseif ( ui.ID_CTRL_BUTTON_NATURE == tag ) then
			-- 自然
			WriteCon("自然");
			collect_mgr.LoadCardByChildCategory(COLLECT_OPTION_PET,COLLECT_PET_NATURE);
		elseif ( ui.ID_CTRL_BUTTON_ANIMAL == tag ) then
			-- 动物
			WriteCon("动物");
			collect_mgr.LoadCardByChildCategory(COLLECT_OPTION_PET,COLLECT_PET_ANIMAL);
		elseif ( ui.ID_CTRL_BUTTON_FLY == tag ) then
			-- 飞行
			WriteCon("飞行");
			collect_mgr.LoadCardByChildCategory(COLLECT_OPTION_PET,COLLECT_PET_FLY);
		elseif ( ui.ID_CTRL_BUTTON_PLANT == tag ) then
			-- 植物
			WriteCon("植物");
			collect_mgr.LoadCardByChildCategory(COLLECT_OPTION_PET,COLLECT_PET_PLANT);
		elseif ( ui.ID_CTRL_BUTTON_MATTER == tag ) then
			-- 物质
			WriteCon("物质");
			collect_mgr.LoadCardByChildCategory(COLLECT_OPTION_PET,COLLECT_PET_MATTER);
		elseif ( ui.ID_CTRL_BUTTON_WEAPON == tag ) then
			-- 武器
			WriteCon("武器");
			collect_mgr.LoadCardByChildCategory(COLLECT_OPTION_EQUIP,COLLECT_EQUIP_WEAPON);
		elseif ( ui.ID_CTRL_BUTTON_ARMOR == tag ) then
			-- 防具
			WriteCon("防具");
			collect_mgr.LoadCardByChildCategory(COLLECT_OPTION_EQUIP,COLLECT_EQUIP_ARMOR);
		elseif ( ui.ID_CTRL_BUTTON_ACC == tag ) then
			-- 饰品
			WriteCon("饰品");
			collect_mgr.LoadCardByChildCategory(COLLECT_OPTION_EQUIP,COLLECT_EQUIP_ACC);
		elseif ( ui.ID_CTRL_BUTTON_ACTIVE_SKILL == tag ) then
			-- 主动技能
			WriteCon("主动技能");
			collect_mgr.LoadCardByChildCategory(COLLECT_OPTION_SKILL,COLLECT_SKILL_ACTIVE);
		elseif ( ui.ID_CTRL_BUTTON_PASSIVE_SKILL == tag ) then
			-- 被动技能
			WriteCon("被动技能");
			collect_mgr.LoadCardByChildCategory(COLLECT_OPTION_SKILL,COLLECT_SKILL_PASSIVE);
		end
	end
end


--显示卡牌列表
function p.ShowCardList( cardList, category , childCategory)
	
	--更新标题
	p.SetTitleText(cardList,category,childCategory);
	p.listBox:ClearView();
	if cardList == nil or #cardList <= 0 then
		WriteCon("ShowCardList():cardList is null");
		return ;
	end

	local listLenght = #cardList;
	local row = math.ceil(listLenght / 4);
	for i = 1,row do
		local view = p.CreateScrollView();
		local start_index = (i-1)*4+1;
		local end_index = start_index + 3;
		--设置列表项信息，一行四张卡牌
		for j = start_index,end_index do
			if j <= listLenght then
				if COLLECT_OPTION_PET == p.cur_option then
					p.SetItemInfo( view, cardList[j], end_index - j, ui_pet );
				elseif COLLECT_OPTION_EQUIP == p.cur_option then
					p.SetItemInfo( view, cardList[j], end_index - j, ui_equip );
				elseif COLLECT_OPTION_SKILL == p.cur_option then
					p.SetItemInfo( view, cardList[j], end_index - j, ui_skill );
				end
			end
		end
		p.listBox:AddView( view );
	end

end

-- 创建滑动视图
function p.CreateScrollView()

	local view = createNDUIXView();
	view:Init();
	if COLLECT_OPTION_PET == p.cur_option then
		--宠物图鉴
		LoadUI( "collect_pet_view.xui", view, nil );
		view:SetViewSize( GetUiNode( view, ui_pet.ID_CTRL_PICTURE_25 ):GetFrameSize());
	elseif COLLECT_OPTION_EQUIP == p.cur_option then
		--装备图鉴
		LoadUI( "collect_item_view.xui", view, nil );
		view:SetViewSize( GetUiNode( view, ui_equip.ID_CTRL_PICTURE_25 ):GetFrameSize());
	elseif COLLECT_OPTION_SKILL == p.cur_option then
		--角色技能
		LoadUI( "collect_skill_view.xui", view, nil );
		view:SetViewSize( GetUiNode( view, ui_skill.ID_CTRL_PICTURE_25 ):GetFrameSize());
	end
	return view;
end

function p.SetItemInfo( view, card, itemIndex, ui_flag )

	local cardPic;
	if itemIndex == 3 then
		cardPic = ui_flag.ID_CTRL_BUTTON_38;
	elseif itemIndex == 2 then
		cardPic = ui_flag.ID_CTRL_BUTTON_39;
	elseif itemIndex == 1 then
		cardPic = ui_flag.ID_CTRL_BUTTON_40;
	elseif itemIndex == 0 then
		cardPic = ui_flag.ID_CTRL_BUTTON_41;
	end

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

	local card = user_skill_mgr.GetCardById(tonumber(uiNode:GetId()));
	if COLLECT_OPTION_PET == p.cur_option then
		dlg_collect_pet_detail.ShowUI(card);
	elseif COLLECT_OPTION_EQUIP == p.cur_option then
		dlg_collect_item_detail.ShowUI(card);
	elseif COLLECT_OPTION_SKILL == p.cur_option then
		dlg_collect_skill_detail.ShowUI(card);
	end
end

--设置标题
function p.SetTitleText(cardList,category,childCategory)

	--更新标题
	if childCategory == -1 then
		p.SetTitle(GetStr("COLLECT_ALL"));
	else
		p.SetTitle(collect_mgr.GetTitleInfo(category,childCategory));
	end
	
	--更新数量,收集率
	local maxNum = collect_mgr.GetCardMaxNum(category,childCategory);
	if cardList == nil or #cardList <= 0 then
		local num = string.format("(%d/%d)",0,tonumber(maxNum));
		p.collectNum:SetText(num);
		p.collectEfficiency:SetText("0%");
	else
		local num = string.format("(%d/%d)",#cardList,tonumber(maxNum));
		local effic = #cardList / tonumber(maxNum);
		p.collectNum:SetText(num);
		p.collectEfficiency:SetText(tostring(effic).."%");
	end

end


function p.OnMsgBoxCallback()
end

function p.SetTitle(str)
	if str ~= nil then
		p.collectType:SetText( str );
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
		p.cur_option = nil;
		p.listBox = nil;
		p.collectType = nil;
		p.collectNum = nil;
		p.collectEfficiency = nil;
		collect_mgr.ClearData();
	end
end