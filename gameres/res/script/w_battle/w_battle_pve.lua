


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
}

local heroUIArray = {
	ui.ID_CTRL_RIGHT_SPRITE_1,
	ui.ID_CTRL_RIGHT_SPRITE_2,
	ui.ID_CTRL_RIGHT_SPRITE_3,
	ui.ID_CTRL_RIGHT_SPRITE_4,
	ui.ID_CTRL_RIGHT_SPRITE_5,
	ui.ID_CTRL_RIGHT_SPRITE_6,
}

p.battleLayer = nil;

p.battleType = W_BATTLE_PVE;

p.targetHp = nil;
p.targetName = nil;
p.boxImage = nil;
p.useitemMask = nil;
p.itemMask = nil;

--卡牌相关控件列表
p.objList = {};

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

local objs = {
	{ 
		ui.ID_CTRL_BUTTON_63,
		ui.ID_CTRL_PICTURE_NATURE1,
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
	},
	{
		ui.ID_CTRL_BUTTON_65,
		ui.ID_CTRL_PICTURE_NATURE2,
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
	},
	{
		ui.ID_CTRL_BUTTON_66,
		ui.ID_CTRL_PICTURE_NATURE3,
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
	},
	{
		ui.ID_CTRL_BUTTON_64,
		ui.ID_CTRL_PICTURE_NATURE4,
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
	},
	{
		ui.ID_CTRL_BUTTON_67,
		ui.ID_CTRL_PICTURE_NATURE5,
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
	},
	{
		ui.ID_CTRL_BUTTON_68,
		ui.ID_CTRL_PICTURE_NATURE6,
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
	},
};

--可使用的道具控件列表
p.useItemList = {};

local ITEM_BTN_INDEX = 1;
local ITEM_NAME_INDEX = 2;
local ITEM_NAMEBG_INDEX = 3;
local ITEM_IMAGE_INDEX = 4;
--local ITEM_FRAME_INDEX = 5;
local items = {
	{
		ui.ID_CTRL_BUTTON_ITEM1,
		ui.ID_CTRL_TEXT_ITEM1,
		ui.ID_CTRL_PICTURE_328,
		ui.ID_CTRL_PICTURE_70,
	},
	{
		ui.ID_CTRL_BUTTON_ITEM2,
		ui.ID_CTRL_TEXT_ITEM2,
		ui.ID_CTRL_PICTURE_329,
		ui.ID_CTRL_PICTURE_71,
	},
	{
		ui.ID_CTRL_BUTTON_ITEM3,
		ui.ID_CTRL_TEXT_ITEM3,
		ui.ID_CTRL_PICTURE_330,
		ui.ID_CTRL_PICTURE_72,
	},
	{
		ui.ID_CTRL_BUTTON_ITEM4,
		ui.ID_CTRL_TEXT_ITEM4,
		ui.ID_CTRL_PICTURE_331,
		ui.ID_CTRL_PICTURE_73,
	},
	{
		ui.ID_CTRL_BUTTON_ITEM5,
		ui.ID_CTRL_TEXT_ITEM5,
		ui.ID_CTRL_PICTURE_332,
		ui.ID_CTRL_PICTURE_74,
	},
};

function p.ShowUI()
	if p.battleLayer ~= nil then
		p.battleLayer:SetVisible( true );
		GetBattleShow():EnableTick( true );
		return;
	end

	local layer = createCardBattleUILayer();
    if layer == nil then
        return false;
    end

	layer:Init();
	layer:SetSwallowTouch(false);
	layer:SetFrameRectFull();
	GetRunningScene():AddChild( layer );

    LoadUI("n_battle_pve.xui", layer, nil);

	layer:SetFramePosXY(0,0);
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
	
	for i = 1, 6 do
		local tCard = p.GetCardTable( i );
		p.objList[i] = tCard;
	end
	
	for i = 1,5 do
		local tItem = p.GetItemTable( i );
		p.useItemList[i] = tItem;
	end
	
	--菜单
	local menuBtn = GetButton( p.battleLayer, ui.ID_CTRL_BUTTON_75 );
	menuBtn:SetLuaDelegate( p.OnBtnClick );
	
	--宝箱图片
	p.boxImage = GetImage( p.battleLayer, ui.ID_CTRL_PICTURE_BOX );
	
	--使用物品的遮罩
	p.useitemMask = GetImage( p.battleLayer, ui.ID_CTRL_PICTURE_IMPORTANT );
	p.useitemMask:SetVisible( false );
	
	--无法使用物品时的遮罩
	p.itemMask = GetImage( p.battleLayer, ui.ID_CTRL_PICTURE_172 );
	p.itemMask:SetVisible( false );
end

--可操作卡牌相关信息
function p.GetCardTable( index )
	local temp = {};
	local tag = objs[index];
	
	local ctrller = GetButton( p.battleLayer, tag[BTN_INDEX] );
	temp[BTN_INDEX] = ctrller;
	ctrller:SetLuaDelegate( p.OnBtnClick );
	ctrller:SetId( index );
	
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
	return temp;
end

--可使用道具列表
function p.GetItemTable( index )
	local temp = {};
	local tag = items[index];
	
	local ctrller = GetButton( p.battleLayer, tag[ITEM_BTN_INDEX] );
	temp[ITEM_BTN_INDEX] = ctrller;
	ctrller:SetLuaDelegate( p.OnBtnClick );
	
	ctrller = GetLabel( p.battleLayer, tag[ITEM_NAME_INDEX] );
	temp[ITEM_NAME_INDEX] = ctrller;
	
	ctrller = GetImage( p.battleLayer, tag[ITEM_NAMEBG_INDEX] );
	temp[ITEM_NAMEBG_INDEX] = ctrller;
	
	ctrller = GetImage( p.battleLayer, tag[ITEM_IMAGE_INDEX] );
	temp[ITEM_IMAGE_INDEX] = ctrller;
	
	return temp;
end

function p.RefreshUI()
	--刷新卡牌显示
	local cardList = w_battle_db_mgr.GetPlayerCardList();
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
					p.SetVisible( ctrllers, true );
					ctrllers[MASK_INDEX]:SetVisible( false );
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
					ctrllers[HPEXP_INDEX]:SetValue( 0, tonumber(data.maxHp), tonumber(data.Hp) );
					ctrllers[SPEXP_INDEX]:SetValue( 0, tonumber(data.maxSp), tonumber(data.Sp) );
				else
					p.SetVisible( ctrllers, false );
					ctrllers[MASK_INDEX]:SetVisible( true );
				end
			end
		end
	end
	
	--[[
	--刷新物品显示
	local itemList = w_battle_db_mgr.GetItemList();
	if itemList ~= nil then
		for i = 1, 5 do
			local ctrllers = p.useItemList[i];
			if ctrllers then
				local flag = false;
				--检测该位置上是否有卡牌
				for _, v in pairs( itemList ) do
					if tonumber(v.Position) and tonumber(v.Position) == i then
						flag = true;
						break;
					end
				end
				
				if flag then
					p.SetVisible( ctrllers, true );
					
					
				else
					p.SetVisible( ctrllers, false );
				end
			end
		end
	end
	--]]
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
	
	--开始新一波战斗，波次在w_battle_mgr中记录
	--w_battle_mgr.starFighter();
end

--设置目标的名字以及血条显示
function p.SetHp( maxHp, curHp, name )
	if p.targetHp == nil then
		p.targetHp = GetExp( p.battleLayer, ui.ID_CTRL_EXP_HP );
	end
	p.targetHp:SetValue( 0, tonumber( maxHp ), tonumber( curHp ) );
	p.targetName:SetText( name );
end

--回合结束后,调用刷新界面,通知UI刷新
function p.RoundOver()
end

--本波次战斗结束,通知UI
--[[
	winFlag
	true:下一波
	false:失败
--]]
function p.FighterOver( winFlag )
	
end

--调用UI，标识任务结束，pEvent是回调函数，目前不用传参，只有成功时才调用
function p.MissionOver( pEvent )
	--UI相关处理
	
	
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
        p.pBgImage = nil;
        p.battleType = W_BATTLE_PVE;
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

--按钮交互
function p.OnBtnClick( uiNode, uiEventType, param )
	if IsClickEvent( uiEventType ) then
		local tag = uiNode:GetTag();
		local btn = ConverToButton( uiNode );
		btn:SetEnabled( false );
		if ui.ID_CTRL_BUTTON_75 == tag then
			WriteCon( "**菜单**" );
			btn:SetEnabled( true );
		elseif p.CheckUseItem( tag ) then
			WriteCon( "**使用物品**" );
			p.UseItem( uiNode );
		elseif p.CheckAtkTarget( tag ) then
			WriteCon( "**攻击**" );
			p.SetAtk( uiNode );
		end
	end
end

--使用物品
function p.UseItem( uiNode )
	if p.itemMask == nil or p.itemMask:IsVisible() then
		return;
	end
	
	local id = uiNode:GetId() or 0;--物品id
	if tonumber(id) == 0 then
		return;
	end
	
	local tid = w_battle_mgr.GetItemCanUsePlayer( id );
	if tid ~= nil and type(tid) == "table" and #tid > 0 then
		p.useitemMask:SetVisible( true );
		
	else
	
	end
end

--设置攻击
function p.SetAtk( uiNode )
	local id = uiNode:GetId();
	local ctrllers = p.objList[id];
	
	local flag = w_battle_mgr.SetPVEAtkID( id );
	if flag then
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


