
country_mixhouse = {};
local p = country_mixhouse;

p.layer = nil;
p.drug_mix_list = {};
p.showSort = false;
p.mixData = {};	--合成临时数据
p.costMaterial = {};
p.costMoney = 0;

CHOOSE_TYPE_ALL = 0;	--全部
CHOOSE_TYPE_TREAT = 1;--回复类
CHOOSE_TYPE_STATUS = 2;	--解状态
CHOOSE_TYPE_ATTR = 3;	--属性类

p.ChooseType = CHOOSE_TYPE_ALL;

local ui = ui_country_produce_list;

function p.ShowUI()
	
	--dlg_menu.SetNewUI( p );
	
	if p.layer ~= nil then
		--合成屋界面，特殊处理userinfo，生成msg_player副本，金钱值需要计算临时数据
		local user = CopyTable(msg_cache.msg_player);
		user.Money = math.max(tonumber(user.Money) - p.costMoney, 0);
		dlg_userinfo.ShowUI( user );
		p.layer:SetVisible( true );
		return;
	end
	
	local layer = createNDUIDialog();
	if layer == nil then
		return false;
	end
	--合成屋界面，特殊处理userinfo，生成msg_player副本，金钱值需要计算临时数据
	local user = CopyTable(msg_cache.msg_player);
	user.Money = math.max(tonumber(user.Money) - p.costMoney, 0);
	dlg_userinfo.ShowUI( user );
	
	layer:NoMask();
	layer:Init();
	layer:SetSwallowTouch(false);
	layer:SetFrameRectFull();
	
	GetUIRoot():AddDlg(layer);

	LoadDlg( "country_produce_list.xui" , layer, nil );
	
	p.layer = layer;
	
	p.SetDelegate();
	--p.InitController();
	
--	local flag = country_collect.SendCollectMsg();
--	if not flag then
	p.SendRequestMaterial();
--	end
end

function p.SendRequestMaterial()
	local uid = GetUID();
    if uid == 0 or uid == nil then
        return ;
    end
	
	--材料列表
    SendReq("Collect", "Material", uid, "");
end

function p.SetDelegate()
	--返回
	local btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_RETURN );
	btn:SetLuaDelegate( p.OnBtnClick );
	
	--合成
	btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_14 );
	btn:SetLuaDelegate( p.OnBtnClick );
end

--[[
function p.InitController()
end--]]

function p.RefreshUI( )
	if p.layer == nil then
		return;
	end
	
	local materialCache = msg_cache.msg_material_list or {};
	local materials =  materialCache.Material or {};
	
	local list = GetListBoxVert( p.layer, ui.ID_CTRL_VERTICAL_LIST_16 );
	if list == nil then
		return;
	end
	
	list:ClearView();
	
	local cache = msg_cache.msg_count_data or {};
	local builds = cache.builds or {};
	local buildType = 3;
	local build = builds["B".. buildType];
	local buildLevel = tonumber(build.build_level) or -1;
	if buildLevel < 0 then
		return;
	end
	
	local mixList = {};
	for i = 1, buildLevel do
		local temp = SelectRowList( T_DRUG_MIX, "level", i );
		if temp ~= nil and #temp > 0 then
			for j, v in pairs( temp ) do
				if p.ChooseType == CHOOSE_TYPE_ALL or p.ChooseType == tonumber( SelectCell(T_MATERIAL, v.drug_id, "sub_type") ) then
					table.insert( mixList, temp[j] );
				end
			end
		end
	end
	
	for i = 1, #mixList do
		local view = createNDUIXView();
		view:Init();
		LoadUI( "country_produce_lsit_list.xui", view, nil );
		
		local bg = GetUiNode( view, ui_country_produce_lsit_list.ID_CTRL_PICTURE_6 );
		view:SetViewSize( bg:GetFrameSize() );
		
		local btn = GetButton( view, ui_country_produce_lsit_list.ID_CTRL_BUTTON_17 );
		btn:SetLuaDelegate( p.SelectFormula );
		btn:SetId( tonumber(mixList[i].id) );
		
		p.SetFormulaNode( view, mixList[i], materials );

		list:AddView( view );
	end
end

function p.SetFormulaNode( view, data, materials )
	if view == nil or data == nil or materials == nil then
		return;
	end
	
	local itempic = GetImage( view, ui_country_produce_lsit_list.ID_CTRL_PICTURE_8 );
	local path = SelectCell( T_MATERIAL, data.drug_id, "item_pic" );
	if path then
		itempic:SetPicture( GetPictureByAni( path, 0 ) );
	end
	
	local nameText = GetLabel( view, ui_country_produce_lsit_list.ID_CTRL_TEXT_ITEMNAME );
	nameText:SetText( tostring( SelectCell( T_MATERIAL, data.drug_id, "name" ) ) );
	
	local InfoText = GetLabel( view, ui_country_produce_lsit_list.ID_CTRL_TEXT_13 );
	InfoText:SetText( tostring( SelectCell( T_MATERIAL, data.drug_id, "description" ) ) );
	
	local num = 0;
	for i = 1, #materials do
		local temp = materials[i] or {};
		temp.material_id = tonumber(temp.material_id) or 0;
		temp.num = tonumber(temp.num) or 0;
		if tonumber( temp.material_id ) == tonumber( data.drug_id ) then
			num = temp.num;
			break;
		end
	end
	--计算临时数据
	local totalNum = num;
	if p.mixData[tonumber(data.drug_id)] ~= nil and p.mixData[tonumber(data.drug_id)] ~= 0 then
		totalNum = totalNum + p.mixData[tonumber(data.drug_id)];
	end
	
	local numText = GetLabel( view, ui_country_produce_lsit_list.ID_CTRL_TEXT_15 );
	numText:SetText( tostring( totalNum ) );
	
	local mask = GetImage( view, ui_country_produce_lsit_list.ID_CTRL_PICTURE_MASK );
	local needMaterial = GetLabel( view, ui_country_produce_lsit_list.ID_CTRL_TEXT_19 );
	local flag = p.CanMix( data, materials );
	mask:SetVisible( not flag );
	needMaterial:SetVisible( not flag );
end

function p.CanMix( data, materials )
	if data == nil or materials == nil then
		return false;
	end
	
	for i = 1, 4 do
		local material_id = tonumber( data["material_id"..i] );
		local num = tonumber( data["num"..i] );
		
		if material_id ~= 0 and num ~= 0 then
			local flag = false;
			for j = 1,#materials do
				local material = materials[j];
				material.material_id = tonumber(material.material_id) or 0;
				material.num = tonumber(material.num) or 0;
				
				local remainNum = material.num;
				if p.costMaterial[material.material_id] ~= nil and p.costMaterial[material.material_id] ~= 0 then
					remainNum = math.max(remainNum - p.costMaterial[material.material_id], 0);
				end
				
				if material_id == material.material_id then
					if remainNum >= num then
						flag = true;
					else
						flag = false;
					end
					break;
				end
			end
			if not flag then
				return false;
			end
		end
	end
	return true;
end

function p.SelectFormula( uiNode, uiEventType, param )
	if IsClickEvent( uiEventType ) then
		local id = uiNode:GetId();
		p.HideUI();
		country_mix.ShowUI( id );
	end
end

function p.OnBtnClick( uiNode, uiEventType, param )
	if IsClickEvent( uiEventType ) then
		local tag = uiNode:GetTag();
		if ui.ID_CTRL_BUTTON_RETURN == tag then
			WriteCon( "关闭" );
			p.CloseUI();
			country_main.ShowUI();
		elseif ui.ID_CTRL_BUTTON_14 == tag then
			WriteCon( "筛选" );
			if p.showSort then
				p.showSort = false;
				country_mix_sort.HideUI();
				country_mix_sort.CloseUI();
			else
				p.showSort = true;
				country_mix_sort.ShowUI( p.SortCallBack );
			end
		end
	end
end

function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
		--dlg_userinfo.HideUI();
	end
end

function p.CloseUI()
	if p.layer ~= nil then
		p.layer:LazyClose();
		p.layer = nil;
		p.drug_mix_list = {};
		
		dlg_userinfo.HideUI();
		p.ChooseType = CHOOSE_TYPE_ALL;
		p.showSort = false;
		
		country_mix_sort.HideUI();
		country_mix_sort.CloseUI();
		
		p.mixData = {};	--合成临时数据
		p.costMaterial = {};
		p.costMoney = 0;
	end
end

function p.SortCallBack( choose_type )
	p.showSort = false;
	p.ChooseType = choose_type;
	p.RefreshUI();
end

--合成接口
function p.DidMix( drug_mix_id, uiNode, callback )
	local drugList = SelectRowList( T_DRUG_MIX, "id", drug_mix_id );
	local drug = {};
	if drugList ~= nil and drugList[1] ~= nil then
		drug = drugList[1];
	end
	local drug_id = tonumber(drug.drug_id) or 0;
	
	local flag = true;
	local materialCache = msg_cache.msg_material_list or {};
	local materials = materialCache.Material or {};
	
	for i = 1, 4 do
		local material_id = tonumber( drug["material_id"..i] );
		local neednum = tonumber( drug["num"..i] );
		local costnum = p.costMaterial[material_id] or 0;
		if material_id ~= 0 and neednum ~= 0 then
			for j = 1, #materials do
				local material = materials[i] or {};
				material.material_id = tonumber(material.material_id) or 0;
				material.num = tonumber(material.num) or 0;
				if material_id == material.material_id then
					if material.num - costnum < neednum then
						flag = false;
						break;
					end
				end
			end
		end
	end
	if flag then
		local cache = msg_cache.msg_player;
		local money = tonumber(cache.Money) or 0;
		local needMoney = tonumber(drug.money) or 0;
		if money - p.costMoney < needMoney then
			flag = false;
		end
	end
	
	if flag then
		if drug_id ~= 0 then
			p.mixData[drug_id] = p.mixData[drug_id] or 0;
			p.mixData[drug_id] = p.mixData[drug_id] + 1;
		end
		
		for i = 1, 4 do
			local material_id = tonumber( drug["material_id"..i] );
			local neednum = tonumber( drug["num"..i] );
			if material_id ~= 0 and neednum ~= 0 then
				p.costMaterial[material_id] = p.costMaterial[material_id] or 0;
				p.costMaterial[material_id] = p.costMaterial[material_id] + neednum;
			end
		end
		
		local needMoney = tonumber(drug.money) or 0;
		p.costMoney = p.costMoney + needMoney;
		
		--合成屋界面，特殊处理userinfo，生成msg_player副本，金钱值需要计算临时数据
		local user = CopyTable(msg_cache.msg_player);
		user.Money = math.max(tonumber(user.Money) - p.costMoney, 0);
		dlg_userinfo.ShowUI( user );
		
		p.RefreshUI();
	end
	
	if callback then
		callback();
	end
end

--发送合成消息
function p.SendMixRequest( drug_mix_id )
	local param = nil;
	local material_id = tonumber( SelectCell( T_DRUG_MIX, drug_mix_id, "drug_id" ) ) or 0;
	if material_id ~= 0 then
		if p.mixData[material_id] ~= nil and p.mixData[material_id] ~= 0 then
			param = "&id=".. drug_mix_id .. "&num=" ..p.mixData[material_id];
		end
	end
	if param == nil then
		return;
	end
	
	local uid = GetUID();
	if uid == nil or uid == 0 then
		return;
	end
	
	SendReq( "Collect", "Synthesis", uid, param );
end

function p.MixCallBack( bFlag )
	p.mixData = {};	--合成临时数据
	p.costMaterial = {};
	p.costMoney = 0;
	
	p.RefreshUI( );
	
	if not bFlag then
		local user = msg_cache.msg_player;
		dlg_userinfo.ShowUI( user );
	end
end

function p.UIDisappear()
	p.CloseUI();
	
	country_mix.CloseUI();
	--country_mix_sort.CloseUI();
	--maininterface.BecomeFirstUI();
end


