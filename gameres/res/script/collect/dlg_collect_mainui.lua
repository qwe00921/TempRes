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
p.cur_category = nil;							--当前分类
p.starShow = nil;

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

p.cur_page = nil;								--当前页
p.cur_rare = nil;								--当前星级
p.temp_list = nil;
p.textPage = nil;								--分页数

p.curBtnNode = nil;

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
		SetTimerOnce( collect_mgr.LoadCard, 0.5f );
	end
end

function p.Init()

	p.cur_option = COLLECT_OPTION_PET;
	p.cur_category = -1;
	p.cur_page = 1;
	
	p.starShow = false;
	p.listBox = GetListBoxVert(p.layer ,ui.ID_CTRL_VERTICAL_LIST_CONTENT);
	p.collectType = GetLabel( p.layer,ui.ID_CTRL_TEXT_COLLECT_TYPE );
	p.collectNum = GetLabel( p.layer,ui.ID_CTRL_TEXT_COLLECT_NUM );
	p.collectEfficiency = GetLabel( p.layer,ui.ID_CTRL_TEXT_EFFICIENCY );
	p.textPage = GetLabel( p.layer,ui.ID_CTRL_TEXT_PAGE );
	
	collect_mgr.InitBaseCardList();
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
	
	--星级
	local btnStar = GetButton(p.layer,ui.ID_CTRL_BUTTON_STAR);
	btnStar:SetLuaDelegate(p.OnUIEventCollect);

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
	
	--上一页
	local btnPageBack = GetButton(p.layer,ui.ID_CTRL_BUTTON_PAGE_BACK);
	btnPageBack:SetLuaDelegate(p.OnUIEventCollect);
	
	--下一页
	local btnPageNext = GetButton(p.layer,ui.ID_CTRL_BUTTON_PAGE_NEXT);
	btnPageNext:SetLuaDelegate(p.OnUIEventCollect);
	
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
			p.SetBtnCheckedHidden();
			collect_mgr.LoadCardByCategory(COLLECT_OPTION_PET);
			p.SetBtnStatus();
		elseif ( ui.ID_CTRL_BUTTON_EQUIPMENT == tag ) then
			-- 装备图鉴
			WriteCon("装备图鉴");
			p.SetBtnCheckedHidden();
			collect_mgr.LoadCardByCategory(COLLECT_OPTION_EQUIP);
			p.SetBtnStatus();
		elseif ( ui.ID_CTRL_BUTTON_SKILL == tag ) then
			-- 角色技能
			WriteCon("角色技能");
			p.SetBtnCheckedHidden();
			collect_mgr.LoadCardByCategory(COLLECT_OPTION_SKILL);
			p.SetBtnStatus();
		elseif ( ui.ID_CTRL_BUTTON_STAR == tag ) then
			-- 星级
			WriteCon("星级");
			if not p.starShow then
				collect_star_menu.ShowUI(uiNode);
				p.starShow = true;
			else
				collect_star_menu.CloseUI(uiNode);
				p.starShow = false;
			end
			
		elseif ( ui.ID_CTRL_BUTTON_ALL == tag ) then
			-- 全部
			WriteCon("全部");
			p.SetBtnCheckedFX(uiNode);
			if p.cur_category ~= -1 then
				collect_mgr.LoadCardByCategory( p.cur_option );
			end
		elseif ( ui.ID_CTRL_BUTTON_DRAGON == tag ) then
			-- 龙
			WriteCon("龙");
			p.SetBtnCheckedFX(uiNode);
			collect_mgr.LoadCardByChildCategory(COLLECT_OPTION_PET,COLLECT_PET_DRAGON);
		elseif ( ui.ID_CTRL_BUTTON_DEMON == tag ) then
			-- 恶魔
			WriteCon("恶魔");
			p.SetBtnCheckedFX(uiNode);
			collect_mgr.LoadCardByChildCategory(COLLECT_OPTION_PET,COLLECT_PET_DEMON);
		elseif ( ui.ID_CTRL_BUTTON_NATURE == tag ) then
			-- 自然
			WriteCon("自然");
			p.SetBtnCheckedFX(uiNode);
			collect_mgr.LoadCardByChildCategory(COLLECT_OPTION_PET,COLLECT_PET_NATURE);
		elseif ( ui.ID_CTRL_BUTTON_ANIMAL == tag ) then
			-- 动物
			WriteCon("动物");
			p.SetBtnCheckedFX(uiNode);
			collect_mgr.LoadCardByChildCategory(COLLECT_OPTION_PET,COLLECT_PET_ANIMAL);
		elseif ( ui.ID_CTRL_BUTTON_FLY == tag ) then
			-- 飞行
			WriteCon("飞行");
			p.SetBtnCheckedFX(uiNode);
			collect_mgr.LoadCardByChildCategory(COLLECT_OPTION_PET,COLLECT_PET_FLY);
		elseif ( ui.ID_CTRL_BUTTON_PLANT == tag ) then
			-- 植物
			WriteCon("植物");
			p.SetBtnCheckedFX(uiNode);
			collect_mgr.LoadCardByChildCategory(COLLECT_OPTION_PET,COLLECT_PET_PLANT);
		elseif ( ui.ID_CTRL_BUTTON_MATTER == tag ) then
			-- 物质
			WriteCon("物质");
			p.SetBtnCheckedFX(uiNode);
			collect_mgr.LoadCardByChildCategory(COLLECT_OPTION_PET,COLLECT_PET_MATTER);
		elseif ( ui.ID_CTRL_BUTTON_WEAPON == tag ) then
			-- 武器
			WriteCon("武器");
			p.SetBtnCheckedFX(uiNode);
			collect_mgr.LoadCardByChildCategory(COLLECT_OPTION_EQUIP,COLLECT_EQUIP_WEAPON);
		elseif ( ui.ID_CTRL_BUTTON_ARMOR == tag ) then
			-- 防具
			WriteCon("防具");
			p.SetBtnCheckedFX(uiNode);
			collect_mgr.LoadCardByChildCategory(COLLECT_OPTION_EQUIP,COLLECT_EQUIP_ARMOR);
		elseif ( ui.ID_CTRL_BUTTON_ACC == tag ) then
			-- 饰品
			WriteCon("饰品");
			p.SetBtnCheckedFX(uiNode);
			collect_mgr.LoadCardByChildCategory(COLLECT_OPTION_EQUIP,COLLECT_EQUIP_ACC);
		elseif ( ui.ID_CTRL_BUTTON_ACTIVE_SKILL == tag ) then
			-- 主动技能
			WriteCon("主动技能");
			p.SetBtnCheckedFX(uiNode);
			collect_mgr.LoadCardByChildCategory(COLLECT_OPTION_SKILL,COLLECT_SKILL_ACTIVE);
		elseif ( ui.ID_CTRL_BUTTON_PASSIVE_SKILL == tag ) then
			-- 被动技能
			WriteCon("被动技能");
			p.SetBtnCheckedFX(uiNode);
			collect_mgr.LoadCardByChildCategory(COLLECT_OPTION_SKILL,COLLECT_SKILL_PASSIVE);
		elseif ( ui.ID_CTRL_BUTTON_PAGE_BACK == tag ) then
			-- 上一页
			WriteCon("上一页");
			p.backPage()
		elseif ( ui.ID_CTRL_BUTTON_PAGE_NEXT == tag ) then
			-- 上一页
			WriteCon("下一页");
			p.nextPage();
		end
	end
end

--显示卡牌列表
function p.ShowCardList(cardList,baseCardList)
	
	--更新标题
	p.SetTitleText(cardList);
	p.listBox:ClearView();
	
	if baseCardList == nil or #baseCardList <= 0 then
		WriteCon("ShowCardList():baseCardList is null");
		return ;
	end
	
	p.temp_list = cardList;
	local listLenght = #baseCardList;
	local row = math.ceil(listLenght / 4);
	
	for i = 1,row do
		local view = p.CreateScrollView();
		local start_index = (i-1)*4+1;
		local end_index = start_index + 3;
		--设置列表项信息，一行四张卡牌
		for j = start_index,end_index do
			if j <= listLenght then
				if cardList ~= nil and #cardList > 0 then
					if COLLECT_OPTION_PET == p.cur_option then
						p.SetItemInfo( view, baseCardList[j], end_index - j, ui_pet, cardList);
					elseif COLLECT_OPTION_EQUIP == p.cur_option then
						p.SetItemInfo( view, baseCardList[j], end_index - j, ui_equip, cardList);
					elseif COLLECT_OPTION_SKILL == p.cur_option then
						p.SetItemInfo( view, baseCardList[j], end_index - j, ui_skill, cardList);
					end
				end
				
			end
		end
		
		p.listBox:AddView( view );
	end

end

function p.SetItemInfo( view, baseCard, itemIndex, ui_flag, cardList)

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
	if (collect_mgr.checkCardIsCollect(baseCard.id,cardList)) then
		local cardPicNode = GetButton( view, cardPic );
		cardPicNode:SetImage( collect_mgr.GetCardPicture(baseCard.id,p.cur_option));
		cardPicNode:SetTouchDownImage( collect_mgr.GetCardPicture(baseCard.id,p.cur_option) );
		cardPicNode:SetId(tonumber(baseCard.id));
		--增加事件
		cardPicNode:SetLuaDelegate(p.OnBtnClicked);
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

--卡牌点击事件
function p.OnBtnClicked( uiNode, uiEventType, param )

	--local card = collect_mgr.GetCardById(tonumber(uiNode:GetId()),p.cur_option);
	if COLLECT_OPTION_PET == p.cur_option then
		dlg_collect_pet_detail.ShowUI(tonumber(uiNode:GetId()));
	elseif COLLECT_OPTION_EQUIP == p.cur_option then
		dlg_collect_item_detail.ShowUI(tonumber(uiNode:GetId()));
	elseif COLLECT_OPTION_SKILL == p.cur_option then
		dlg_collect_skill_detail.ShowUI(tonumber(uiNode:GetId()));
	end
end

-- 分页
function p.ShowPage(cardList)

	local baseCardList = nil;
	if p.cur_rare == nil then
		baseCardList = collect_mgr.GetBaseCardList(p.cur_option,p.cur_category);
	else
		baseCardList = collect_mgr.GetBaseRareCardList(p.cur_rare);
	end
	
	local totalPage = math.ceil(#baseCardList / COLLECT_PAGE_NUM);
	if totalPage > 1 then
	
		if p.cur_page > totalPage then
			p.cur_page = totalPage;
		elseif p.cur_page < 1 then
			p.cur_page = 1;
		end
		p.SetPage(p.cur_page,totalPage);
		
		local startIndex = (p.cur_page - 1) * COLLECT_PAGE_NUM + 1;
		local endIndex = 0;
		if totalPage == p.cur_page then
			endIndex = #baseCardList;
		else
			endIndex = startIndex + COLLECT_PAGE_NUM - 1;
		end
		if endIndex > startIndex then
			baseCardList = collect_mgr.GetCardListByPage(baseCardList,startIndex,endIndex);
		end 
	else
		p.SetPage(1,1)
	end
	
	p.ShowCardList(cardList,baseCardList)

end

function p.SetPage(cur_page,total_page)
	local page = string.format("%d/%d",tonumber(cur_page),tonumber(total_page));
	p.textPage:SetText(page);
end

--下一页
function p.nextPage()
	p.cur_page = p.cur_page + 1;
	p.ShowPage(p.temp_list);	
end

--上一页
function p.backPage()
	p.cur_page = p.cur_page - 1;
	p.ShowPage(p.temp_list);
end


--设置标题
function p.SetTitleText(cardList)

	--更新标题
	if p.cur_category == -1 then
		p.SetTitle(GetStr("COLLECT_ALL"));
	else
		p.SetTitle(collect_mgr.GetTitleInfo(p.cur_option,p.cur_category));
	end
	
	--更新数量,收集率
	local maxNum = 0;
	if p.cur_rare == nil then
		maxNum = #collect_mgr.GetBaseCardList(p.cur_option,p.cur_category);
	else
		maxNum = #collect_mgr.GetBaseRareCardList(p.cur_rare);
	end
	
	if cardList == nil or #cardList <= 0 then
		local num = string.format("(%d/%d)",0,tonumber(maxNum));
		p.collectNum:SetText(num);
		p.collectEfficiency:SetText("0%");
	else
		local num = string.format("(%d/%d)",#cardList,tonumber(maxNum));
		local effic = #cardList / tonumber(maxNum) * 100;
		p.collectNum:SetText(num);
		local efficStr = string.format("%.2f",effic);
		p.collectEfficiency:SetText(efficStr.."%");
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

function p.SetBtnCheckedFX( node )
    local btnNode = ConverToButton( node );
    if p.curBtnNode ~= nil then
    	p.curBtnNode:SetChecked( false );
    end
	btnNode:SetChecked( true );
	p.curBtnNode = btnNode;
end

function p.SetBtnCheckedHidden()
	if p.curBtnNode ~= nil then
    	p.curBtnNode:SetChecked( false );
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
		p.cur_page = nil;
		p.cur_rare = nil;
		p.temp_list = nil;
		p.textPage = nil;
		p.curBtnNode = nil;
		collect_mgr.ClearData();
		collect_star_menu.CloseUI();
	end
end