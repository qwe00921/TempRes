
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
	ui.ID_CTRL_BUTTON_TARGET1,
	ui.ID_CTRL_BUTTON_TARGET2,
	ui.ID_CTRL_BUTTON_TARGET3,
	ui.ID_CTRL_BUTTON_TARGET4,
	ui.ID_CTRL_BUTTON_TARGET5,
	ui.ID_CTRL_BUTTON_TARGET6,
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
p.boxImage = nil;
p.useitemMask = nil;
p.itemMask = nil;

p.CheckHasDrop = false;
p.Index = 1;
p.BoxScale = false;

p.pickCallBack = nil;

--������ؿؼ��б�
p.objList = {};

p.dropList = {};
p.tempList = {};

p.CanUseItem = true;

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
		ui.ID_CTRL_PICTURE_157,
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
		ui.ID_CTRL_PICTURE_158,
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
		ui.ID_CTRL_PICTURE_159,
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
		ui.ID_CTRL_PICTURE_160,
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
		ui.ID_CTRL_PICTURE_161,
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
		ui.ID_CTRL_PICTURE_162,
	},
};

--��ʹ�õĵ��߿ؼ��б�
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
	
	--��ʼ���ؼ�
	p.InitController();
	p.RefreshUI();
	
	--ս��
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
	
	for i = 1,#targetBtn do
		local btn = GetButton( p.battleLayer, targetBtn[i] );
		btn:SetId( i );
		btn:SetLuaDelegate( p.OnBtnClick );
	end
	
	--�˵�
	local menuBtn = GetButton( p.battleLayer, ui.ID_CTRL_BUTTON_75 );
	menuBtn:SetLuaDelegate( p.OnBtnClick );
	
	--����ͼƬ
	p.boxImage = GetImage( p.battleLayer, ui.ID_CTRL_PICTURE_BOX );
	p.boxImage:SetZOrder(1);
	
	--ʹ����Ʒ������
	p.useitemMask = GetImage( p.battleLayer, ui.ID_CTRL_PICTURE_IMPORTANT );
	p.useitemMask:SetVisible( false );
	
	--�޷�ʹ����Ʒʱ������
	p.itemMask = GetImage( p.battleLayer, ui.ID_CTRL_PICTURE_172 );
	p.itemMask:SetVisible( false );
end

--�ɲ������������Ϣ
function p.GetCardTable( index )
	local temp = {};
	local tag = objs[index];
	
	local ctrller = GetButton( p.battleLayer, tag[BTN_INDEX] );
	temp[BTN_INDEX] = ctrller;
	ctrller:SetLuaDelegate( p.OnBtnClick );
	ctrller:SetEnableDrag( true );
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
	
	ctrller = GetImage( p.battleLayer, tag[DAMAGE_INDEX] );
	temp[DAMAGE_INDEX] = ctrller;
	ctrller:SetVisible( false );
	
	return temp;
end

--��ʹ�õ����б�
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
	--ˢ�¿�����ʾ
	local cardList = w_battle_db_mgr.GetPlayerCardList();
	if cardList ~= nil then
		for i = 1, 6 do
			local ctrllers = p.objList[i];
			
			if ctrllers then
				local flag = false;
				local index = 0;
				--����λ�����Ƿ��п���
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
					ctrllers[BTN_INDEX]:SetEnabled( true );
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
					
					local attrpic = GetPictureByAni( "card_element.".. tostring(data.element), 0 );
					if attrpic then
						ctrllers[ATTR_INDEX]:SetPicture( attrpic );
					end
					
					if tonumber(data.Hp) == 0 then
						ctrllers[MASK_INDEX]:SetVisible( true );
						ctrllers[BTN_INDEX]:SetVisible( false );
					end
				else
					p.SetVisible( ctrllers, false );
					ctrllers[MASK_INDEX]:SetVisible( true );
				end
			end
		end
	end
	--CTRL_PICTURE_115 486
	--ˢ����Ʒ��ʾ
	local itemList = w_battle_db_mgr.GetItemList();
	if itemList ~= nil then
		for i = 1, 5 do
			local ctrllers = p.useItemList[i];
			local item = itemList[i];
			if ctrllers ~= nil then
				if item ~= nil then
					p.SetVisible( ctrllers, true );
					
					local name = SelectCell( T_MATERIAL, item.item_id, "name" );	
					ctrllers[ITEM_NAME_INDEX]:SetText( name );
					
					local path = SelectCell( T_MATERIAL, item.item_id, "item_pic" ) or "";
					local picData = GetPictureByAni( path, 0 );
					if picData then
						ctrllers[ITEM_IMAGE_INDEX]:SetPicture( picData );
					end
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

--��ʼ��ս��
function p.InitBattle()
	w_battle_mgr.uiLayer = p.battleLayer;
	w_battle_mgr.heroUIArray = heroUIArray;
	w_battle_mgr.enemyUIArray = enemyUIArray;
	w_battle_mgr.enemyUILockArray = targetSecImg;
	
	--��ʼ��һ��ս����������w_battle_mgr�м�¼
	w_battle_mgr.starFighter();
end

--����Ŀ��������Լ�Ѫ����ʾ
function p.SetHp( maxHp, curHp, name )
	if p.targetHp == nil then
		p.targetHp = GetExp( p.battleLayer, ui.ID_CTRL_EXP_HP );
	end
	p.targetHp:SetValue( 0, tonumber( maxHp ), tonumber( curHp ) );
	p.targetName:SetText( name );
end

--�»غϿ�ʼ��ˢ��UI
function p.RoundStar()
	p.CanUseItem = true;
	p.itemMask:SetVisible( false );
	p.useitemMask:SetVisible( false );
	
	p.RefreshUI();
	--p.BeginPick();
end

--ʰȡ�׶ο�ʼ
function p.PickStep( pCallBack )
	p.pickCallBack = pCallBack;
	
	p.BeginPick();
end

--������ս������,֪ͨUI
--[[
	winFlag
	true:��һ��
	false:ʧ��
--]]
function p.FighterOver( winFlag )
	if winFlag then
		--��������
		w_battle_pass_bg.ShowUI();
	end
end

--����UI����ʶ���������pEvent�ǻص�������Ŀǰ���ô��Σ�ֻ�гɹ�ʱ�ŵ���
function p.MissionOver( pEvent )
	--UI��ش���
	p.CloseUI();
	
	--�ص��ӿ�
	if pEvent then
		pEvent();
	end
end

--��������
function p.HideUI()
	if p.battleLayer ~= nil then
		p.battleLayer:SetVisible( false );
		GetBattleShow():EnableTick( false );
	end
end

--�ر�
function p.CloseUI()
	if p.battleLayer ~= nil then	
		p.battleLayer:LazyClose();
		p.battleLayer = nil;

		p.battleType = W_BATTLE_PVE;

		p.targetHp = nil;
		p.targetName = nil;
		p.boxImage = nil;
		p.useitemMask = nil;
		p.itemMask = nil;

		p.CheckHasDrop = false;
		p.Index = 1;
		p.BoxScale = false;

		p.pickCallBack = nil;

		--������ؿؼ��б�
		p.objList = {};

		p.dropList = {};
		p.tempList = {};
		
		p.CanUseItem = true;
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

--��ť����
function p.OnBtnClick( uiNode, uiEventType, param )
	WriteCon( tostring(uiEventType) );
	
	if IsClickEvent( uiEventType ) then
		local tag = uiNode:GetTag();
		local btn = ConverToButton( uiNode );
		btn:SetEnabled( false );
		if ui.ID_CTRL_BUTTON_75 == tag then
			WriteCon( "**�˵�**" );
			btn:SetEnabled( true );
		elseif p.CheckUseItem( tag ) then
			WriteCon( "**ʹ����Ʒ**" );
			p.UseItem( btn );
		elseif p.CheckAtkTarget( tag ) then
			WriteCon( "**����**" );
			p.SetAtk( btn );
		elseif p.CheckSelectTarget( tag ) then
			WriteCon( "**ѡ��Ŀ�꣬λ��Ϊ".. tostring( uiNode:GetId() ) .."**" );
			w_battle_mgr.SetPVETargerID( uiNode:GetId() );
		end
	elseif IsDragUp( uiEventType ) then
		WriteCon("IsDragUp");
	elseif IsDragLeft( uiEventType ) then
		WriteCon("IsDragLeft");
	elseif IsDragRight( uiEventType ) then
		WriteCon("IsDragRight");
		w_battle_mgr.SetPVESkillAtkID( id );
	elseif IsDragDown( uiEventType ) then
		WriteCon("IsDragDown");
	end
end

--ʹ����Ʒ
function p.UseItem( uiNode )
	if not p.CanUseItem then
		return;
	end
	
	if p.itemMask == nil or p.itemMask:IsVisible() then
		uiNode:SetEnabled( true );
		return;
	end
	
	local id = uiNode:GetId() or 0;--����λ��
	if tonumber(id) == 0 then
		uiNode:SetEnabled( true );
		return;
	end
	
	local itemList = w_battle_db_mgr.GetItemList() or {};
	local item = itemList[id] or {};
	local itemid = 0;
	if item then
		itemid = item.itemtype or 0;
	end
	
	if itemid == 0 then
		uiNode:SetEnabled( true );
		return;
	end
	
	local tid = w_battle_mgr.GetItemCanUsePlayer( id );
	if tid ~= nil and type(tid) == "table" and #tid > 0 then
		p.useitemMask:SetVisible( true );
		w_battle_useitem.ShowUI( itemid, id );
	end
	uiNode:SetEnabled( true );
end

--���ù���
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

--===================================����======================================--
--listΪ����ı�
--{{droptype1, num1, position1, param1},{droptype2, num2, position2, param2},����}
--droptypeΪ��������
--[[
	E_DROP_MONEY = 1;	--���
	E_DROP_BLUESOUL = 2;	--����
	E_DROP_HPBALL = 3;	--HP��
	E_DROP_SPBALL = 4;	--SP��
	E_DROP_ITEM = 5;	--����
	E_DROP_CARD = 6;	--��Ƭ
	E_DROP_EQUIP = 7;	--װ��
--]]
--numΪ��������
--position������Ʒ�Ĺ���λ��
--paramΪ����Ĳ���������������Ϊ���ߡ���Ƭ��װ��ʱ����ʾ���������ID������Ϊ��
function p.MonsterDrop( list )
	if list == nil or #list == 0 then
		return;
	end

	for i = 1, #list do
		for j = 1, list[i][2] do
			local index = p.tempList[1] or 0;
			local drop = nil;
			if index ~= 0 then
				table.remove( p.tempList, 1 );
				drop = p.dropList[index];
			end
			if drop == nil then
				drop = w_drop:new();
				drop:Init( p.battleLayer, list[i][1], list[i][4] );
				table.insert( p.dropList, drop );
			end
			drop:Drop( GetPlayer( p.battleLayer, enemyUIArray[list[i][3]] ) );
		end
	end
end

--ע�Ὺʼʰȡ��Ʒ����ʱ
function p.BeginPick()
	if #p.dropList == 0 then
		if p.pickCallBack then
			p.pickCallBack();
			--p.pickCallBack = nil;
		end
		do return end;
	end

	p.Index = 1;
	SetTimer(p.Pick , 0.02 );
end

--��˳��ʰȡ��Ʒ
function p.Pick( nTimerId )
	local drop = p.dropList[p.Index];
	
	if drop == nil then
		KillTimer( nTimerId );
		SetTimerOnce( p.ReduceBoxImage, 0.3 );
		
		if p.pickCallBack then
			p.pickCallBack();
			--p.pickCallBack = nil;
		end
		
		do return end;
	end
	
	if drop:GetImageNode():IsVisible() then
		if drop:GetType() == E_DROP_HPBALL or drop:GetType() == E_DROP_SPBALL then
			drop:Pick( GetPlayer( p.battleLayer , heroUIArray[math.random(1, 5)] ) );
		else
			drop:Pick( p.boxImage, true );
			
			if not p.BoxScale then
				p.BoxScale = true;
				p.boxImage:AddActionEffect( "lancer.box_scaleup" );
			end
		end
		p.AddIndexToTable();
	end
	p.Index = p.Index + 1;
end

function p.AddIndexToTable()
	local bFlag = false;
	for i,v in pairs(p.tempList) do
		if v == p.Index then
			bFlag = true;
			break;
		end
	end
	if not bFlag then
		table.insert( p.tempList, p.Index );
	end
end

--������С
function p.ReduceBoxImage()
	if p.boxImage ~= nil then
		p.boxImage:AddActionEffect( "lancer.box_reduce" );
		p.BoxScale = false;
	end;
end

--==============================================================--
--�������Կ��ƹ�ϵ
function p.UpdateDamageBufftype( list )
	for i = 1, 6 do
		local obj = p.objList[i];
		if obj ~= nil then
			local index = 0;
			for j = 1, #list do
				if i == list[j][1] then
					index = j;
					break;
				end
			end
			if index ~= 0 then
				obj[DAMAGE_INDEX]:SetVisible( true );
				local damagetypeindex = 0;
				if list[j][2] == W_ELEMENT_ADD then
					damagetypeindex = 1;
				end
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