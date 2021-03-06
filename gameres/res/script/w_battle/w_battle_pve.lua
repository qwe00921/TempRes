
w_battle_pve = {};
local p = w_battle_pve;
local ui = ui_n_battle_pve;

local enemyUIArray = {
	ui.ID_CTRL_LEFT_SPRITE_1,
	ui.ID_CTRL_LEFT_SPRITE_2,
	ui.ID_CTRL_LEFT_SPRITE_3,
	ui.ID_CTRL_LEFT_SPRITE_4,
	ui.ID_CTRL_LEFT_SPRITE_5,
	ui.ID_CTRL_LEFT_SPRITE_6,
};

local heroUIArray = {
	ui.ID_CTRL_RIGHT_SPRITE_1,
	ui.ID_CTRL_RIGHT_SPRITE_2,
	ui.ID_CTRL_RIGHT_SPRITE_3,
	ui.ID_CTRL_RIGHT_SPRITE_4,
	ui.ID_CTRL_RIGHT_SPRITE_5,
	ui.ID_CTRL_RIGHT_SPRITE_6,
};

local targetBtn = {
	211,
	212,
	213,
	214,
	215,
	216,
};

local targetSecImg = {
	ui.ID_CTRL_PICTURE_TARGET1,
	ui.ID_CTRL_PICTURE_TARGET2,
	ui.ID_CTRL_PICTURE_TARGET3,
	ui.ID_CTRL_PICTURE_TARGET4,
	ui.ID_CTRL_PICTURE_TARGET5,
	ui.ID_CTRL_PICTURE_TARGET6,
};

p.battleLayer = nil;

p.battleType = W_BATTLE_PVE;

p.targetHp = nil;
p.targetName = nil;
p.targetAttr = nil;
p.targetHpText = nil;
p.boxImage = nil;
p.useitemMask = nil;
p.itemMask = nil;

p.CheckHasDrop = false;
p.Index = 1;
p.BoxScale = false;

p.pickCallBack = nil;

--卡牌相关控件列表
p.objList = {};

p.dropList = {};

p.CanUseItem = true;

p.heroList = nil;
p.sortList = nil;
p.firstHp = true;
p.skillImage = nil;

p.rooknode = {};



local BTN_INDEX = 1;
local ATTR_INDEX = 2;
local NAME_INDEX = 3;
local HPTEXT_INDEX = 4;
local HPNUM_INDEX = 5;
local HPEXPBG_INDEX = 6;
local HPEXP_INDEX = 7;
local SPTEXT_INDEX = 8;
local SPEXPBG_INDEX = 9;
local SPEXP_INDEX = 10;
local FACE_INDEX = 11;
local MASK_INDEX = 12;
local DAMAGE_INDEX = 13;
local DEAD_INDEX = 14;
local SKILL_INDEX = 15;

local objs = {
	{ 
		ui.ID_CTRL_BUTTON_63,
		ui.ID_CTRL_PICTURE_139,
		ui.ID_CTRL_TEXT_NAME1,
		ui.ID_CTRL_TEXT_90,
		ui.ID_CTRL_TEXT_HP1,
		ui.ID_CTRL_PICTURE_195,
		ui.ID_CTRL_EXP_HP1,
		ui.ID_CTRL_TEXT_116,
		ui.ID_CTRL_PICTURE_198,
		ui.ID_CTRL_EXP_SP1,
		ui.ID_CTRL_PICTURE_CHA1,
		ui.ID_CTRL_PICTURE_115,
		ui.ID_CTRL_PICTURE_157,
		ui.ID_CTRL_PICTURE_DEAD1,
		ui.ID_CTRL_PICTURE_SKILL1,
	},
	{
		ui.ID_CTRL_BUTTON_65,
		ui.ID_CTRL_PICTURE_143,
		ui.ID_CTRL_TEXT_NAME2,
		ui.ID_CTRL_TEXT_92,
		ui.ID_CTRL_TEXT_HP2,
		ui.ID_CTRL_PICTURE_199,
		ui.ID_CTRL_EXP_HP2,
		ui.ID_CTRL_TEXT_112,
		ui.ID_CTRL_PICTURE_200,
		ui.ID_CTRL_EXP_SP2,
		ui.ID_CTRL_PICTURE_CHA2,
		ui.ID_CTRL_PICTURE_116,
		ui.ID_CTRL_PICTURE_158,
		ui.ID_CTRL_PICTURE_DEAD2,
		ui.ID_CTRL_PICTURE_SKILL2,
	},
	{
		ui.ID_CTRL_BUTTON_66,
		ui.ID_CTRL_PICTURE_144,
		ui.ID_CTRL_TEXT_NAME3,
		ui.ID_CTRL_TEXT_94,
		ui.ID_CTRL_TEXT_HP3,
		ui.ID_CTRL_PICTURE_203,
		ui.ID_CTRL_EXP_HP3,
		ui.ID_CTRL_TEXT_108,
		ui.ID_CTRL_PICTURE_204,
		ui.ID_CTRL_EXP_SP3,
		ui.ID_CTRL_PICTURE_CHA3,
		ui.ID_CTRL_PICTURE_117,
		ui.ID_CTRL_PICTURE_159,
		ui.ID_CTRL_PICTURE_DEAD3,
		ui.ID_CTRL_PICTURE_SKILL3,
	},
	{
		ui.ID_CTRL_BUTTON_64,
		ui.ID_CTRL_PICTURE_141,
		ui.ID_CTRL_TEXT_NAME4,
		ui.ID_CTRL_TEXT_91,
		ui.ID_CTRL_TEXT_HP4,
		ui.ID_CTRL_PICTURE_196,
		ui.ID_CTRL_EXP_HP4,
		ui.ID_CTRL_TEXT_118,
		ui.ID_CTRL_PICTURE_197,
		ui.ID_CTRL_EXP_SP4,
		ui.ID_CTRL_PICTURE_CHA4,
		ui.ID_CTRL_PICTURE_118,
		ui.ID_CTRL_PICTURE_160,
		ui.ID_CTRL_PICTURE_DEAD4,
		ui.ID_CTRL_PICTURE_SKILL4,
	},
	{
		ui.ID_CTRL_BUTTON_67,
		ui.ID_CTRL_PICTURE_142,
		ui.ID_CTRL_TEXT_NAME5,
		ui.ID_CTRL_TEXT_93,
		ui.ID_CTRL_TEXT_HP5,
		ui.ID_CTRL_PICTURE_201,
		ui.ID_CTRL_EXP_HP5,
		ui.ID_CTRL_TEXT_114,
		ui.ID_CTRL_PICTURE_202,
		ui.ID_CTRL_EXP_SP5,
		ui.ID_CTRL_PICTURE_CHA5,
		ui.ID_CTRL_PICTURE_119,
		ui.ID_CTRL_PICTURE_161,
		ui.ID_CTRL_PICTURE_DEAD5,
		ui.ID_CTRL_PICTURE_SKILL5,
	},
	{
		ui.ID_CTRL_BUTTON_68,
		ui.ID_CTRL_PICTURE_145,
		ui.ID_CTRL_TEXT_NAME6,
		ui.ID_CTRL_TEXT_95,
		ui.ID_CTRL_TEXT_HP6,
		ui.ID_CTRL_PICTURE_205,
		ui.ID_CTRL_EXP_HP6,
		ui.ID_CTRL_TEXT_110,
		ui.ID_CTRL_PICTURE_206,
		ui.ID_CTRL_EXP_SP6,
		ui.ID_CTRL_PICTURE_CHA6,
		ui.ID_CTRL_PICTURE_120,
		ui.ID_CTRL_PICTURE_162,
		ui.ID_CTRL_PICTURE_DEAD6,
		ui.ID_CTRL_PICTURE_SKILL6,
	},
};

--可使用的道具控件列表
p.useItemList = {};

local ITEM_BTN_INDEX = 1;
local ITEM_NAME_INDEX = 2;
local ITEM_NAMEBG_INDEX = 3;
local ITEM_IMAGE_INDEX = 4;
local ITEM_NUM_INDEX = 5;
local items = {
	{
		ui.ID_CTRL_BUTTON_ITEM1,
		ui.ID_CTRL_TEXT_ITEM1,
		ui.ID_CTRL_PICTURE_328,
		ui.ID_CTRL_PICTURE_70,
		ui.ID_CTRL_TEXT_ITEMNUM1,
	},
	{
		ui.ID_CTRL_BUTTON_ITEM2,
		ui.ID_CTRL_TEXT_ITEM2,
		ui.ID_CTRL_PICTURE_329,
		ui.ID_CTRL_PICTURE_71,
		ui.ID_CTRL_TEXT_ITEMNUM2,
	},
	{
		ui.ID_CTRL_BUTTON_ITEM3,
		ui.ID_CTRL_TEXT_ITEM3,
		ui.ID_CTRL_PICTURE_330,
		ui.ID_CTRL_PICTURE_72,
		ui.ID_CTRL_TEXT_ITEMNUM3,
	},
	{
		ui.ID_CTRL_BUTTON_ITEM4,
		ui.ID_CTRL_TEXT_ITEM4,
		ui.ID_CTRL_PICTURE_331,
		ui.ID_CTRL_PICTURE_73,
		ui.ID_CTRL_TEXT_ITEMNUM4,
	},
	{
		ui.ID_CTRL_BUTTON_ITEM5,
		ui.ID_CTRL_TEXT_ITEM5,
		ui.ID_CTRL_PICTURE_332,
		ui.ID_CTRL_PICTURE_74,
		ui.ID_CTRL_TEXT_ITEMNUM5,
	},
};

function p.ShowUI()
	if p.battleLayer ~= nil then
		p.battleLayer:SetVisible( true );
		GetBattleShow():EnableTick( true );
		return;
	end

	local layer = createNDUILayer();
    if layer == nil then
        return false;
    end

	--layer:NoMask();
	layer:Init();
	layer:SetSwallowTouch(false);
	layer:SetFrameRectFull();
	GetUIRoot():AddChild( layer );

    LoadDlg("n_battle_pve.xui", layer, nil);

	--layer:SetFramePosXY(0,0);
	p.battleLayer = layer;
	
	p.pBgImage = GetImage( p.battleLayer, ui.ID_CTRL_PICTURE_82 );
	
	--初始化控件
	p.InitController();
	p.RefreshUI();
	
	--战斗
	p.InitBattle();
	return true;
end

function p.InitController()
	p.targetHp = GetExp( p.battleLayer, ui.ID_CTRL_EXP_HP );
	p.targetName = GetLabel( p.battleLayer, ui.ID_CTRL_TEXT_365 );
	p.targetAttr = GetImage( p.battleLayer, ui.ID_CTRL_PICTURE_140 );
	p.targetHpText = GetLabel( p.battleLayer, ui.ID_CTRL_TEXT_HP );
	
	p.skillImage = GetImage( p.battleLayer, ui.ID_CTRL_PICTURE_SKILL_DO );
	p.skillImage:SetVisible( false );
	
	p.targetHp:SetTextStyle( 2 );
	
	for i = 1, 6 do
		local tCard = p.GetCardTable( i );
		p.objList[i] = tCard;
	end
	
	for i = 1,5 do
		local tItem = p.GetItemTable( i );
		p.useItemList[i] = tItem;
	end
	
	for i = 1,#targetBtn do
		local btn = GetButton( p.battleLayer, targetBtn[i] );
		btn:SetId( i );
		btn:SetLuaDelegate( p.OnBtnClick );
	end
	
	--菜单
	local menuBtn = GetButton( p.battleLayer, ui.ID_CTRL_BUTTON_75 );
	menuBtn:SetLuaDelegate( p.OnBtnClick );
	
	--宝箱图片
	p.boxImage = GetImage( p.battleLayer, ui.ID_CTRL_PICTURE_BOX );
	p.boxImage:SetZOrder(E_BATTLE_Z_HERO_FIGHTER);
	
	--使用物品的遮罩
	p.useitemMask = GetImage( p.battleLayer, ui.ID_CTRL_PICTURE_IMPORTANT );
	p.useitemMask:SetVisible( false );
	
	--无法使用物品时的遮罩
	p.itemMask = GetImage( p.battleLayer, ui.ID_CTRL_PICTURE_172 );
	p.itemMask:SetVisible( false );
	
	local lbtn = GetButton(	p.battleLayer ,ui.ID_CTRL_BUTTON_75);
	if w_battle_guid.IsGuid == true then
		lbtn:SetVisible(false)
	else
		lbtn:SetVisible(true)
	end
end

function p.OnSetTargetId( uiNode, uiEventType, param )
	--p.CheckSelectTarget( tag ) then
	
	WriteCon( "**选择目标，位置为".. tostring( uiNode:GetId() ) .."**" );
	w_battle_mgr.SetPVETargerID( uiNode:GetId() );
	--btn:SetEnabled( true );
end

--可操作卡牌相关信息
function p.GetCardTable( index )
	local temp = {};
	local tag = objs[index];
	
	local ctrller = GetButton( p.battleLayer, tag[BTN_INDEX] );
	temp[BTN_INDEX] = ctrller;
	ctrller:SetLuaDelegate( p.OnBtnClick );
	ctrller:SetEnableSwapDrag( true );
	ctrller:SetId( index );
	
	p.rooknode[index] = ctrller;
	
	
	ctrller = GetImage( p.battleLayer, tag[ATTR_INDEX] );
	temp[ATTR_INDEX] = ctrller;
	
	ctrller = GetLabel( p.battleLayer, tag[NAME_INDEX] );
	temp[NAME_INDEX] = ctrller;
	
	ctrller = GetLabel( p.battleLayer, tag[HPTEXT_INDEX] );
	temp[HPTEXT_INDEX] = ctrller;
	
	ctrller = GetLabel( p.battleLayer, tag[HPNUM_INDEX] );
	temp[HPNUM_INDEX] = ctrller;
	
	ctrller = GetImage( p.battleLayer, tag[HPEXPBG_INDEX] );
	temp[HPEXPBG_INDEX] = ctrller;
	
	ctrller = GetExp( p.battleLayer, tag[HPEXP_INDEX] );
	ctrller:SetTextStyle( 2 );
	temp[HPEXP_INDEX] = ctrller;
	
	ctrller = GetLabel( p.battleLayer, tag[SPTEXT_INDEX] );
	temp[SPTEXT_INDEX] = ctrller;
	
	ctrller = GetImage( p.battleLayer, tag[SPEXPBG_INDEX] );
	temp[SPEXPBG_INDEX] = ctrller;
	
	ctrller = GetExp( p.battleLayer, tag[SPEXP_INDEX] );
	ctrller:SetTextStyle( 2 );
	temp[SPEXP_INDEX] = ctrller;
	
	ctrller = GetImage( p.battleLayer, tag[FACE_INDEX] );
	temp[FACE_INDEX] = ctrller;
	
	ctrller = GetImage( p.battleLayer, tag[MASK_INDEX] );
	temp[MASK_INDEX] = ctrller;
	
	ctrller = GetImage( p.battleLayer, tag[DAMAGE_INDEX] );
	temp[DAMAGE_INDEX] = ctrller;
	ctrller:SetVisible( false );
	
	ctrller = GetImage( p.battleLayer, tag[DEAD_INDEX] );
	temp[DEAD_INDEX] = ctrller;
	ctrller:SetVisible( false );
	
	ctrller = GetImage( p.battleLayer, tag[SKILL_INDEX] );
	temp[SKILL_INDEX] = ctrller;
	ctrller:SetVisible( false );
	
	return temp;
end

function p.GuidUseItem1()
	if p.rookItemNode ~= nil then
		p.OnBtnClick(p.rookItemNode, NUIEventType.TE_TOUCH_CLICK, nil)
	end
end;

--可使用道具列表
function p.GetItemTable( index )
	local temp = {};
	local tag = items[index];
	
	local ctrller = GetButton( p.battleLayer, tag[ITEM_BTN_INDEX] );
	temp[ITEM_BTN_INDEX] = ctrller;
	ctrller:SetLuaDelegate( p.OnBtnClick );
	ctrller:SetId( index );
	
	if index == 1 then
		p.rookItemNode = ctrller;
	end;
	
	ctrller = GetLabel( p.battleLayer, tag[ITEM_NAME_INDEX] );
	temp[ITEM_NAME_INDEX] = ctrller;
	
	ctrller = GetImage( p.battleLayer, tag[ITEM_NAMEBG_INDEX] );
	temp[ITEM_NAMEBG_INDEX] = ctrller;
	
	ctrller = GetImage( p.battleLayer, tag[ITEM_IMAGE_INDEX] );
	temp[ITEM_IMAGE_INDEX] = ctrller;
	
	ctrller = GetLabel( p.battleLayer, tag[ITEM_NUM_INDEX] );
	temp[ITEM_NUM_INDEX] = ctrller;
	return temp;
end

function p.CancelSel()
	for i = 1, 6 do
		local ctrllers = p.objList[i];
		if ctrllers then
			ctrllers[MASK_INDEX]:SetVisible( true );
			ctrllers[BTN_INDEX]:SetVisible( false );	
		end
	end;
end;

function p.RefreshUI( pIsRoundStar )
	p.RefreshCardInfo( pIsRoundStar );
	p.RefreshItemInfo( pIsRoundStar );
end

function p.RefreshCardInfo( pIsRoundStar )
	--刷新卡牌显示
	local cardList = w_battle_db_mgr.GetPlayerCardList();
	if pIsRoundStar == true then
		cardList = w_battle_mgr.heroCamp.fighters;
	end;
	if cardList ~= nil then
		for i = 1, 6 do
			local ctrllers = p.objList[i];
			
			if ctrllers then
				local flag = false;
				local index = 0;
				--检测该位置上是否有卡牌
				for j, v in pairs( cardList ) do
					if tonumber(v.Position) and tonumber(v.Position) == i then
						flag = true;
						index = j;
						break;
					end
				end
				
				if flag then
					local isVisible = ctrllers[DAMAGE_INDEX]:IsVisible();
					
					p.SetVisible( ctrllers, true );
					ctrllers[MASK_INDEX]:SetVisible( false );
					ctrllers[BTN_INDEX]:SetEnabled( true );
					
					if pIsRoundStar then
						ctrllers[DAMAGE_INDEX]:SetVisible( isVisible );
					else
						ctrllers[DAMAGE_INDEX]:SetVisible( false );
					end
					
					local data = cardList[index];
					
					local path = SelectRowInner( T_CHAR_RES, "card_id", data.CardID, "head_pic" );
					if path then
						local picData = GetPictureByAni( path, 0 );
						if picData then
							ctrllers[FACE_INDEX]:SetPicture( picData );
						end
					end
					
					local name = SelectCell( T_CARD, data.CardID, "name" );
					if name then
						ctrllers[NAME_INDEX]:SetText( name );
					end
					
					ctrllers[HPNUM_INDEX]:SetText( string.format( "%d/%d", data.Hp, data.maxHp ) );
					if not pIsRoundStar then
						ctrllers[HPEXP_INDEX]:SetValue( 0, tonumber(data.maxHp), tonumber(data.Hp) );
						ctrllers[SPEXP_INDEX]:SetValue( 0, tonumber(data.maxSp), tonumber(data.Sp) );
					end

					--local attrpic = GetPictureByAni( "common_ui.cardBagTypeBox", tonumber(data.element) );
					--if attrpic then
					ctrllers[ATTR_INDEX]:SetPicture( nil );
					--end
					
					ctrllers[DEAD_INDEX]:SetVisible( tonumber(data.Hp) <= 0 );
					ctrllers[SKILL_INDEX]:SetVisible( tonumber(data.Sp) >= 100 and tonumber(data.Hp) > 0 );
					
					if not (tonumber(data.Hp) > 0 and data.HasTurn) then
						ctrllers[MASK_INDEX]:SetVisible( true );
						ctrllers[BTN_INDEX]:SetVisible( false );
					else
						ctrllers[MASK_INDEX]:SetVisible( false );
						ctrllers[BTN_INDEX]:SetVisible( true );
					end
				else
					p.SetVisible( ctrllers, false );
					ctrllers[MASK_INDEX]:SetVisible( true );
				end
			end
		end
	end
end

function p.RefreshItemInfo( pIsRoundStar )
	--刷新物品显示
	local itemList = w_battle_db_mgr.GetItemList();
	if itemList ~= nil then
		for i = 1, 5 do
			local ctrllers = p.useItemList[i];
			local item = itemList[i];
			if ctrllers ~= nil then
				if item ~= nil and item.item_id ~= 0 and item.num ~= 0 then
					p.SetVisible( ctrllers, true );
					
					local name = SelectCell( T_MATERIAL, item.item_id, "name" );	
					ctrllers[ITEM_NAME_INDEX]:SetText( name );
					local path = SelectCell( T_MATERIAL, item.item_id, "item_pic" ) or "";
					local picData = GetPictureByAni( path, 0 );
					if picData then
						ctrllers[ITEM_IMAGE_INDEX]:SetPicture( picData );
					end
					ctrllers[ITEM_NUM_INDEX]:SetText( tostring( item.num ) );
				else
					p.SetVisible( ctrllers, false );
				end
			end
		end
	end
end

function p.SetVisible( ctrllers, bValue )
	for _, v in pairs(ctrllers) do
		v:SetVisible( bValue );
	end	
end

--初始化战斗
function p.InitBattle()
	w_battle_mgr.uiLayer = p.battleLayer;
	w_battle_mgr.heroUIArray = heroUIArray;
	w_battle_mgr.enemyUIArray = enemyUIArray;
	w_battle_mgr.enemyUILockArray = targetSecImg;
	
	--开始新一波战斗，波次在w_battle_mgr中记录
	w_battle_mgr.starFighter();
end

--设置目标的名字以及血条显示
function p.SetHp( fighter )
	p.targetHp = p.targetHp or GetExp( p.battleLayer, ui.ID_CTRL_EXP_HP );
	p.targetName = p.targetName or GetLabel( p.battleLayer, ui.ID_CTRL_TEXT_365 );
	p.targetAttr = p.targetAttr or GetImage( p.battleLayer, ui.ID_CTRL_PICTURE_140 );
	p.targetHpText = p.targetHpText or GetLabel( p.battleLayer, ui.ID_CTRL_TEXT_HP );
	
	p.targetHp:SetTextStyle( 2 );
	p.targetHp:SetValue( 0, tonumber( fighter.maxHp ), tonumber( fighter.Hp ) );
	
	p.targetHpText:SetText( string.format( "%d/%d", tonumber( fighter.Hp ), tonumber( fighter.maxHp ) ) );	
	
	p.targetName:SetText( "" );
	local cardID = fighter.CardID or 0;
	if cardID ~= 0 then
		local name = SelectCell( T_CARD, cardID, "name" );
		p.targetName:SetText( tostring(name) );
	end
	
	local element = fighter.element or 0;
	local attrpic = GetPictureByAni( "card_element.".. tostring(element), 0 );
	if attrpic then
		p.targetAttr:SetPicture( attrpic );
	end
end

--设置玩家卡牌属性
function p.SetHeroCardAttr( pos, fighter )
	if pos == nil or fighter == nil then
		return;
	end
	
	local ctrllers = p.objList[pos];
	if ctrllers ~= nil then
		ctrllers[HPEXP_INDEX]:SetValue( 0, tonumber( fighter.maxHp ), tonumber( fighter.Hp ) );
		ctrllers[HPNUM_INDEX]:SetText( string.format( "%d/%d", tonumber( fighter.Hp ), tonumber( fighter.maxHp ) ) );
		
		if tonumber(fighter.Hp) <= 0 then
			ctrllers[MASK_INDEX]:SetVisible( true );
			ctrllers[BTN_INDEX]:SetVisible( false );
		end
		
		ctrllers[DEAD_INDEX]:SetVisible( tonumber(fighter.Hp) <= 0 );
		ctrllers[SKILL_INDEX]:SetVisible( tonumber(fighter.Sp) >= 100 and tonumber(fighter.Hp) > 0 );
		
		ctrllers[SPEXP_INDEX]:SetValue( 0, tonumber( fighter.maxSp ), tonumber( fighter.Sp ) );
	end
end

--新回合开始，刷新UI
function p.RoundStar()
	p.ClearDropNodeList();
	
	p.CanUseItem = true;
	p.itemMask:SetVisible( false );
	p.useitemMask:SetVisible( false );
	
	
	p.RefreshUI(true);
	--p.BeginPick();
end

--拾取阶段开始
function p.PickStep( pCallBack )
	p.pickCallBack = pCallBack;
	
	p.BeginPick();
end

--本波次战斗结束,通知UI
--[[
	winFlag
	true:下一波
	false:失败
--]]
function p.FighterOver( winFlag )
	if winFlag then
		--过场动画
		w_battle_pass_bg.ShowUI();
	end
end

--调用UI，标识任务结束，pEvent是回调函数，目前不用传参，只有成功时才调用
function p.MissionOver( pEvent )
	--UI相关处理
	p.CloseUI();
	
	--回调接口
	if pEvent then
		pEvent();
	end
end

--设置隐藏
function p.HideUI()
	if p.battleLayer ~= nil then
		p.battleLayer:SetVisible( false );
		GetBattleShow():EnableTick( false );
	end
end

--关闭
function p.CloseUI()
	if p.battleLayer ~= nil then	
		p.battleLayer:LazyClose();
		p.battleLayer = nil;

		p.battleType = W_BATTLE_PVE;

		p.targetHp = nil;
		p.targetName = nil;
		p.targetAttr = nil;
		p.boxImage = nil;
		p.useitemMask = nil;
		p.itemMask = nil;

		p.CheckHasDrop = false;
		p.Index = 1;
		p.BoxScale = false;

		p.pickCallBack = nil;

		--卡牌相关控件列表
		p.objList = {};

		if #p.dropList > 0 then
			for _,v in ipairs( p.dropList ) do
								v:Remove();
			end
		end
		p.dropList = {};
		
		p.CanUseItem = true;
		p.heroList = nil;
		p.sortList = nil;
		
		if p.skillImage ~= nil then
			p.skillImage:RemoveFromParent( true );
		end
		p.skillImage = nil;
		p.rooknode = {};
	end
	GetBattleShow():EnableTick( false );
end

function p.CheckUseItem( tag )
	for _, v in pairs( items ) do
		if tag == v[ITEM_BTN_INDEX] then
			return true;
		end
	end
	return false;
end

function p.CheckAtkTarget( tag )
	for _, v in pairs( objs ) do
		if tag == v[BTN_INDEX] then
			return true;
		end
	end
	return false;
end

function p.CheckSelectTarget( tag )
	for _, v in pairs( targetBtn ) do
		if tag == v then
			return true;
		end
	end
	return false;
end

function p.setBtnClick(id)
	local uiNode = p.rooknode[id];
	if uiNode ~= nil then
		p.OnBtnClick(uiNode, NUIEventType.TE_TOUCH_CLICK, nil);
	end
end;

function p.setBtnSkillClick(id)
	local uiNode = p.rooknode[id];
	if uiNode ~= nil then
		p.OnBtnClick(uiNode, NUIEventType.TE_TOUCH_BTN_DRAG_UP, nil);
	end
end;


--按钮交互
function p.OnBtnClick( uiNode, uiEventType, param )
	WriteCon( tostring(uiEventType) );
	
	local btn = ConverToButton( uiNode );
	--WriteConErr( uiEventType .. " " .. uiNode:GetId() );
	if IsClickEvent( uiEventType ) then
		local tag = uiNode:GetTag();
		
		btn:SetEnabled( false );
		if ui.ID_CTRL_BUTTON_75 == tag then
			WriteCon( "**菜单**" );
			btn:SetEnabled( true );
			--if w_battle_guid.IsGuid == false then
			w_battle_mgr.SetLockZorder(0);
			dlg_msgbox.ShowYesNo("",GetStr("battle_quit"), w_battle_mgr.OnMsgQuitBoxCallback, p.battleLayer);
			--end;
		elseif p.CheckUseItem( tag ) then
			WriteCon( "**使用物品**" );
			p.UseItem( btn );
		elseif p.CheckAtkTarget( tag ) then
			WriteCon( "**攻击**" );
			p.SetAtk( btn );
		elseif p.CheckSelectTarget( tag ) then
			WriteCon( "**选择目标，位置为".. tostring( uiNode:GetId() ) .."**" );
			w_battle_mgr.SetPVETargerID( uiNode:GetId() );
			btn:SetEnabled( true );
		end
	elseif IsDragUp( uiEventType ) then
		WriteCon("IsDragUp");
		p.SetSkillAtk( btn );
	elseif IsDragLeft( uiEventType ) then
		WriteCon("IsDragLeft");
	elseif IsDragRight( uiEventType ) then
		WriteCon("IsDragRight");
	elseif IsDragDown( uiEventType ) then
		WriteCon("IsDragDown");
	elseif IsDragBegin( uiEventType ) then
		WriteCon("IsDragBegin");
		
		if p.skillImage == nil then
			WriteConErr( "no skillimage" );
			return;
		end
		
		local cardList = w_battle_mgr.heroCamp.fighters;
		local id = uiNode:GetId();
		if cardList ~= nil then
			for _,v in ipairs(cardList) do
				if v.Position == id then
					if tonumber(v.Sp) >= 100 then
						local size = p.skillImage:GetFrameSize();
						
						p.skillImage:SetFramePosXY( tonumber(param.x), tonumber(param.y)-size.h+15*GetUIScale() );
						p.skillImage:SetVisible( true );
						
						p.skillImage:RemoveFromParent(false);
						GetUIRoot():AddChildZ( p.skillImage, 10001 );
					end
					break;
				end
			end
		end
		do return end;
	elseif IsDragEnd( uiEventType ) then
		WriteCon("IsDragEnd");
	end
	
	if not IsDraging(uiEventType) then
		if p.skillImage ~= nil then
			p.skillImage:SetVisible( false );
		end
	end;
end

--使用物品
function p.UseItem( uiNode )
	if not p.CanUseItem then
		return;
	end
	
	if p.itemMask == nil or p.itemMask:IsVisible() then
		uiNode:SetEnabled( true );
		return;
	end
	
	local id = uiNode:GetId() or 0;--索引位置
	if tonumber(id) == 0 then
		uiNode:SetEnabled( true );
		return;
	end
	
	local itemList = w_battle_db_mgr.GetItemList() or {};
	local item = itemList[id] or {};
	local itemid = 0;
	if item then
		itemid = item.item_id or 0;
	end
	
	if itemid == 0 then
		uiNode:SetEnabled( true );
		return;
	end
	
	local tid = w_battle_mgr.GetItemCanUsePlayer( id );
	if tid ~= nil and type(tid) == "table" then
		p.useitemMask:SetVisible( true );
		w_battle_useitem.ShowUI( itemid, id );
		
		for i = 1, #p.objList do
			local ctrllers = p.objList[i] or {};
			if ctrllers[MASK_INDEX] ~= nil then
				ctrllers[MASK_INDEX]:SetVisible( false );
			end
		end
	end
	uiNode:SetEnabled( true );
end

function p.EndUseItem()
	p.useitemMask:SetVisible( false );	
	p.RefreshUI( true );
end

--设置攻击
function p.SetAtk( uiNode )
	local id = uiNode:GetId();
	local ctrllers = p.objList[id];
	
	local flag = w_battle_mgr.SetPVEAtkID( id );
	if p.CanUseItem then
		p.CanUseItem = not flag;
	end
	if flag then
		p.itemMask:SetVisible( true );
		if ctrllers then
			ctrllers[MASK_INDEX]:SetVisible( true );
		end
	else
		if ctrllers then
			ctrllers[MASK_INDEX]:SetVisible( false );
			uiNode:SetEnabled( true );
		end
	end
end

function p.SetSkillAtk( uiNode )
	local id = uiNode:GetId();
	local ctrllers = p.objList[id];
	
	local flag = w_battle_mgr.SetPVESkillAtkID( id );
	if p.CanUseItem then
		p.CanUseItem = not flag;
	end
	if flag then
		p.itemMask:SetVisible( true );
		if ctrllers then
			ctrllers[MASK_INDEX]:SetVisible( true );
		end
	else
		if ctrllers then
			ctrllers[MASK_INDEX]:SetVisible( false );
			uiNode:SetEnabled( true );
		end
	end
end

--===================================掉落======================================--
--list为掉落的表
--{{droptype1, num1, position1, param1},{droptype2, num2, position2, param2},……}
--droptype为掉落类型
--[[
	E_DROP_HPBALL = 1;
	E_DROP_SPBALL = 2;
	E_DROP_MONEY = 3;
	E_DROP_BLUESOUL = 4;
	E_DROP_MATERIAL = 5;
	E_DROP_CARD = 6;
	E_DROP_EQUIP = 7;
--]]
--num为掉落数量
--position掉落物品的怪物位置
--param为额外的参数，当掉落类型为道具、卡片、装备时，表示掉落的类型ID，可以为空
function p.MonsterDrop( list )
	--WriteConWarning( FormatTableToJson(list) );
	if list == nil or #list == 0 then
		return;
	end

	for i = 1, #list do
		for j = 1, list[i][2] do
			local drop = w_drop:new();
			drop:Init( p.battleLayer, list[i][1], list[i][4] );
			local fighter = p.GetFighter( false, list[i][3] );
			drop:Drop( fighter, list[i][4] );
			--drop:Drop( GetPlayer( p.battleLayer, enemyUIArray[list[i][3]] ), list[i][4] );
			table.insert( p.dropList, drop );
		end
	end
end

function p.GetFighter( isHero, pos )
	local list = isHero and w_battle_mgr.heroCamp.fighters or w_battle_mgr.enemyCamp.fighters;
	
	for i,v in pairs(list) do
		if v.Position == pos then
			return v;
		end
	end
	return nil;
end

--注册开始拾取物品倒计时
function p.BeginPick()
	if #p.dropList == 0 then
		if p.pickCallBack then
			p.pickCallBack();
			--p.pickCallBack = nil;
		end
		do return end;
	end
	
	p.Index = 1;
	p.firstHp = true;
	SetTimer(p.Pick , 0.02 );
end

--按顺序拾取物品
function p.Pick( nTimerId )
	local drop = p.dropList[p.Index];
	
	if drop == nil then
		KillTimer( nTimerId );
		SetTimerOnce( p.ReduceBoxImage, 0.3 );
		
		if p.pickCallBack then
			p.pickCallBack();
			--p.pickCallBack = nil;
			p.sortList = nil;
			p.firstHp = true;
		end
		
		do return end;
	end
	
	p.heroList = p.heroList or w_battle_mgr.getHeroFighterLst();
	if p.sortList == nil then
		p.sortList = CopyTable( p.heroList );
	end
	
	local aliveList = {};
	local hurtList = {};
	for i = 1, #p.sortList do
		local temp = p.sortList[i];
		if temp.Hp ~= 0 then
			table.insert( aliveList, temp );
		end
		if temp.Hp > 0 and temp.Hp < temp.maxHp then
			table.insert( hurtList, temp );
		end
	end
	table.sort( hurtList, function (a, b) return a.Hp < b.Hp end );

	if drop:GetImageNode():IsVisible() then
		if drop:GetType() == E_DROP_HPBALL then
			if #hurtList == 0 then
				local rand = #aliveList ~= 0 and math.random(1, #aliveList) or math.random(1, #p.heroList);
				local pos = #aliveList ~= 0 and aliveList[rand].Position or p.heroList[rand].Position;
				drop:Pick( GetPlayer( p.battleLayer , heroUIArray[pos] ), pos );
			else
				local rand = math.random( 1, #hurtList );
				if p.firstHp then
					p.firstHp = false;
					rand = 1;
				end
				local pos = hurtList[rand].Position;
				
				WriteConErr( string.format("HP:%d %d %d", #aliveList, rand, pos ));
				
				drop:Pick( GetPlayer( p.battleLayer , heroUIArray[pos] ), pos );
			end
		elseif drop:GetType() == E_DROP_SPBALL then
			local rand = #aliveList ~= 0 and math.random(1, #aliveList) or math.random(1, #p.heroList);
			local pos = #aliveList ~= 0 and aliveList[rand].Position or p.heroList[rand].Position;
			
			WriteConErr( string.format("SP:%d %d %d", #aliveList, rand, pos ) );
			drop:Pick( GetPlayer( p.battleLayer , heroUIArray[pos] ), pos );
		else
			drop:Pick( p.boxImage );
			
			if not p.BoxScale then
				p.BoxScale = true;
				p.boxImage:AddActionEffect( "lancer.box_scaleup" );
			end
		end
	end
	p.Index = p.Index + 1;
end

function p.ClearDropNodeList()
	if #p.dropList > 0 then
		for _,v in ipairs( p.dropList ) do
			v:Remove();
		end
	end
	p.dropList = {};
end

--包裹缩小
function p.ReduceBoxImage()
	if p.boxImage ~= nil then
		p.boxImage:AddActionEffect( "lancer.box_reduce" );
		p.BoxScale = false;
	end;
end

--==============================================================--
--更新属性克制关系
function p.UpdateDamageBufftype( list )
	for i = 1, 6 do
		local obj = p.objList[i];
		if obj ~= nil then
			local index = 0;
			for j = 1, #list do
				--if i == list[j][1] then
				if i == list[j] then
					index = j;
					break;
				end
			end
				
			if index ~= 0 then
				obj[DAMAGE_INDEX]:SetVisible( true );
				local damagetypeindex = 0;
				--if list[j][2] == W_ELEMENT_ADD then
					damagetypeindex = 1;
				--end
				local picData = GetPictureByAni( "w_battle_res.damagebufftype", damagetypeindex );
				if picData then
					obj[DAMAGE_INDEX]:SetPicture( picData );
				end
			else
				obj[DAMAGE_INDEX]:SetVisible( false );
			end
		end
	end
end

function p.SetBg(pMissionID)
	local lAni = SelectRowInner(T_MISSION_RES,"id",tostring(pMissionID),"bg")
	if lAni ~= nil then
		local lpic = GetPictureByAni(lAni,0);
		local bgImg = GetImage( p.battleLayer, ui.ID_CTRL_PICTURE_BG );
		bgImg:SetPicture(lpic);
	end;
	
end