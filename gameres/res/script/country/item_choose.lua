
item_choose = {};
local p = item_choose;

p.layer = nil;

p.itemCtrllers = {};
p.battle_items = {};

p.edit = false;--判断是否编辑过
p.curNode = nil;

p.missionId = nil;
p.stageId = nil;
p.nowTeamId = nil;
		
local ui = ui_item_choose;

local MAX_NUM = 10;--一类药水最大数量

local NAME_INDEX = 1;
local NAMEBG_INDEX = 2;
local BTN_INDEX = 3;
local NUM_INDEX = 4;

local item_tag = {
	{ ui.ID_CTRL_TEXT_ITEMNAME1, ui.ID_CTRL_PICTURE_22, ui.ID_CTRL_BUTTON_ITEM1, ui.ID_CTRL_TEXT_NUM1 },
	{ ui.ID_CTRL_TEXT_ITEMNAME2, ui.ID_CTRL_PICTURE_23, ui.ID_CTRL_BUTTON_ITEM2, ui.ID_CTRL_TEXT_NUM2 },
	{ ui.ID_CTRL_TEXT_ITEMNAME3, ui.ID_CTRL_PICTURE_24, ui.ID_CTRL_BUTTON_ITEM3, ui.ID_CTRL_TEXT_NUM3 },
	{ ui.ID_CTRL_TEXT_ITEMNAME4, ui.ID_CTRL_PICTURE_25, ui.ID_CTRL_BUTTON_ITEM4, ui.ID_CTRL_TEXT_NUM4 },
	{ ui.ID_CTRL_TEXT_ITEMNAME5, ui.ID_CTRL_PICTURE_26, ui.ID_CTRL_BUTTON_ITEM5, ui.ID_CTRL_TEXT_NUM5 },
};

function p.GetBattleItem( index )
	local battle_item = p.battle_items[index];
	battle_item = battle_item or {};
	battle_item.item_id = battle_item.item_id or 0;
	battle_item.num = battle_item.num or 0;
	return battle_item;
end

function p.ShowUI( battle_items,missionId,stageId,nowTeamId )
	p.battle_items = battle_items;
	if missionId ~= nil and stageId ~= nil then
		p.missionId = missionId;
		p.stageId = stageId;
		p.nowTeamId = nowTeamId;
	end
	
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		if battle_items ~= nil then
			local flag = country_collect.SendCollectMsg();
			if not flag then
				country_storage.RequestData();
			end
		else
			p.RequestBattleItem();
		end
		return;
	end
	
	local layer = createNDUIDialog();
	if layer == nil then
		return false;
	end
	
	layer:NoMask();
	layer:Init();
	layer:SetSwallowTouch(true);
	layer:SetFrameRectFull();
	
	GetUIRoot():AddDlg(layer);

	LoadDlg( "item_choose.xui" , layer, nil );
	
	p.layer = layer;
	
	p.SetDelegate();
	p.InitController();
	
	if battle_items ~= nil then
		local flag = country_collect.SendCollectMsg();
		if not flag then
			country_storage.RequestData();
		end
	else
		p.RequestBattleItem();
	end
end

function p.SetDelegate()
	--返回
	local btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_RETURN );
	btn:SetLuaDelegate( p.OnBtnClick );
	
	--填满
	btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_8 );
	btn:SetLuaDelegate( p.OnBtnClick );
	
	--清空
	btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_9 );
	btn:SetLuaDelegate( p.OnBtnClick );
end

function p.InitController()
	for i = 1, 5 do
		local tags = item_tag[i];
		local ctrllers = {};
		local ctrl = GetLabel( p.layer, tags[NAME_INDEX] );
		ctrllers[NAME_INDEX] = ctrl;
		
		ctrl = GetImage( p.layer, tags[NAMEBG_INDEX] );
		ctrllers[NAMEBG_INDEX] = ctrl;
		
		ctrl = GetButton( p.layer, tags[BTN_INDEX] );
		ctrllers[BTN_INDEX] = ctrl;
		ctrl:SetLuaDelegate( p.OnItemClick );
		ctrl:SetId(i);
		
		ctrl = GetLabel( p.layer, tags[NUM_INDEX] );
		ctrllers[NUM_INDEX] = ctrl;
		
		p.itemCtrllers[i] = ctrllers;
	end
end

function p.RefreshUI( battle_items )
	if battle_items == nil and #p.battle_items == 0 then
		return;
	end
	
	if battle_items ~= nil then
		p.battle_items = battle_items;
	end
	
	--按照位置排序，固定为1-5
	table.sort( p.battle_items, function( a, b ) return tonumber(a.location) < tonumber(b.location); end );

	for i = 1, 5 do
		local item = p.GetBattleItem( i );
		local ctrllers = p.itemCtrllers[i];
		if item and item.item_id ~= 0 then
			ctrllers[NAME_INDEX]:SetVisible( true );
			ctrllers[NAMEBG_INDEX]:SetVisible( true );
			ctrllers[BTN_INDEX]:SetVisible( true );
			ctrllers[NUM_INDEX]:SetVisible( true );
			
			ctrllers[NAME_INDEX]:SetText( SelectCell( T_MATERIAL, item.item_id, "name" ) );
			ctrllers[NUM_INDEX]:SetText( tostring("X " .. item.num ) );
			
			local path = SelectCell( T_MATERIAL, item.item_id, "item_pic" );
			if path then
				local picData = GetPictureByAni( path, 0 );
				if picData then
					ctrllers[BTN_INDEX]:SetImage( picData );
				end
			end
		else
			ctrllers[NAME_INDEX]:SetVisible( false );
			ctrllers[NAMEBG_INDEX]:SetVisible( false );
			ctrllers[NUM_INDEX]:SetVisible( false );
		end
	end
end

function p.OnBtnClick( uiNode, uiEventType, param )
	if IsClickEvent( uiEventType ) then
		local tag = uiNode:GetTag();
		if ui.ID_CTRL_BUTTON_RETURN == tag then
			WriteCon( "关闭" );
			if p.edit then
				p.SendEditResult();
			end
			if (p.missionId ~= nil and p.stageId ~= nil) then
				quest_team_item.ShowUI(p.missionId,p.stageId,p.nowTeamId)
				p.missionId = nil;
				p.stageId = nil;
			end
			p.CloseUI();
		elseif ui.ID_CTRL_BUTTON_8 == tag then
			WriteCon( "填满" );
			p.FullData();
		elseif ui.ID_CTRL_BUTTON_9 == tag then
			WriteCon( "清空" );
			p.ClearAllData();
		end
	end
end

function p.OnItemClick( uiNode, uiEventType, param )
	if IsClickEvent( uiEventType ) then
		local id = uiNode:GetId() or 0;
		WriteCon( "asdasdasdasd" );
		local item = p.battle_items[id];
		if item then
			p.curNode = uiNode;
			item_choose_list.ShowUI( tonumber(item.item_id) );
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
		p.battle_items = {};
		p.itemCtrllers = {};
		p.edit = false;
	end
end

--请求物品编辑数据
function p.RequestBattleItem()
	local uid = GetUID();
	if uid == nil or uid == 0 then
		return;
	end
	
	SendReq( "Mission", "BattleItem", uid, "");
end

--发送物品编辑结果
function p.SendEditResult()
	local uid = GetUID();
	if uid == nil or uid == 0 then
		return;
	end
	
	local param = "&battleitem=";
	for i = 1,#p.battle_items do
		local battle_item = p.GetBattleItem( i );
		param = param .. battle_item.item_id .. "-" .. battle_item.num;
		if i ~= #p.battle_items then
			param = param .. "|";
		end
	end
	
	SendReq( "Mission", "SetBattleItem", uid, param );
end

function p.CheckEnabled( id )
	for i,v in pairs(p.battle_items) do
		if v.item_id == id then
			return false;
		end
	end	
	return true;
end

--清空所有
function p.ClearAllData()
	p.edit = true;
	
	p.battle_items = {};
	for i = 1, 5 do
		local battle_item = {};
		battle_item.item_id = 0;
		battle_item.num = 0;
		battle_item.location = i;
		
		p.battle_items[i] = battle_item;
		
		local ctrllers = p.itemCtrllers[i];
		local btn = ctrllers[BTN_INDEX];
		if btn then
			p.curNode = btn;
		end
		p.ChooseItemCallBack( 0, 0 );
	end
end

function p.GetMaterialData( sourceTable, itemid )
	for i = 1, #sourceTable do
		local item = sourceTable[i];
		if tonumber(itemid) == tonumber(item.material_id) then
			return item;
		end
	end
	return nil;
end

--填满操作
function p.FullData()
	local cache = msg_cache.msg_material_list or {};
	local materials = cache.Material;
	if materials == nil then
		return;
	end
	
	for i = 1, #p.battle_items do
		local itemid = p.battle_items[i].item_id;
		local item = p.GetMaterialData( materials, itemid );
		if item ~= nil then
			
			local ctrllers = p.itemCtrllers[i];
			local btn = ctrllers[BTN_INDEX];
			if btn then
				p.curNode = btn;
			end
			p.ChooseItemCallBack( itemid, math.min( MAX_NUM, tonumber(item.num) ) );
		end
	end
end

--移除操作
function p.ClearPostion()
	if p.curNode == nil then
		return;
	end
	
	p.edit = true;
	
	local id = p.curNode:GetId();
	local battle_item = p.battle_items[id] or {};
	battle_item.item_id = 0;
	battle_item.num = 0;
	p.battle_items[id] = battle_item;
	
	local ctrllers = p.itemCtrllers[id];
	ctrllers[NAME_INDEX]:SetVisible( false );
	ctrllers[NAMEBG_INDEX]:SetVisible( false );
	ctrllers[NUM_INDEX]:SetVisible( false );
	ctrllers[BTN_INDEX]:SetImage( nil );
	
	p.curNode = nil;
end

function p.ChooseItemCallBack( itemid, num )
	if p.curNode == nil then
		return;
	end
	
	p.edit = true;
	
	local id = p.curNode:GetId();
	local battle_item = p.battle_items[id] or {};
	battle_item.item_id = itemid;
	battle_item.num = num;
	p.battle_items[id] = battle_item;
	
	if itemid ~= 0 and num ~= 0 then
		local ctrllers = p.itemCtrllers[id];
		ctrllers[NAME_INDEX]:SetVisible( true );
		ctrllers[NAMEBG_INDEX]:SetVisible( true );
		ctrllers[BTN_INDEX]:SetVisible( true );
		ctrllers[NUM_INDEX]:SetVisible( true );
		
		ctrllers[NAME_INDEX]:SetText( SelectCell( T_MATERIAL, itemid, "name" ) );
		ctrllers[NUM_INDEX]:SetText( tostring("X " .. num ) );
		
		local path = SelectCell( T_MATERIAL, itemid, "item_pic" );
		if path then
			local picData = GetPictureByAni( path, 0 );
			if picData then
				ctrllers[BTN_INDEX]:SetImage( picData );
			end
		end
	else
		local ctrllers = p.itemCtrllers[id];
		ctrllers[NAME_INDEX]:SetVisible( false );
		ctrllers[NAMEBG_INDEX]:SetVisible( false );
		ctrllers[NUM_INDEX]:SetVisible( false );
		ctrllers[BTN_INDEX]:SetImage( nil );
	end
	
	p.curNode = nil;
end

function p.SetBattleCallBack()
	country_storage.RequestData();
end