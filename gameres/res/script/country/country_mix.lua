
country_mix = {};
local p = country_mix;

p.layer = nil;
p.drug_mix_id = nil;

local ui = ui_item_produce;

local IMAGE_INDEX = 1;
local NAME_INEDX = 2;
local NEED_INDEX = 3;
local HAS_INDE = 4;

local needItemTag = {
	{ ui.ID_CTRL_PICTURE_42, ui.ID_CTRL_TEXT_46, ui.ID_CTRL_TEXT_50, ui.ID_CTRL_TEXT_54 },
	{ ui.ID_CTRL_PICTURE_44, ui.ID_CTRL_TEXT_47, ui.ID_CTRL_TEXT_51, ui.ID_CTRL_TEXT_55 },
	{ ui.ID_CTRL_PICTURE_43, ui.ID_CTRL_TEXT_48, ui.ID_CTRL_TEXT_52, ui.ID_CTRL_TEXT_56 },
	{ ui.ID_CTRL_PICTURE_45, ui.ID_CTRL_TEXT_49, ui.ID_CTRL_TEXT_53, ui.ID_CTRL_TEXT_57 },
};

function p.ShowUI( drug_mix_id )
	p.drug_mix_id = drug_mix_id;
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		return;
	end
	
	local layer = createNDUIDialog();
	if layer == nil then
		return false;
	end
	
	layer:NoMask();
	layer:Init();
	layer:SetSwallowTouch( true );
	layer:SetFrameRectFull();
	GetUIRoot():AddChild(layer);

	LoadDlg( "item_produce.xui" , layer, nil );
	
	p.layer = layer;
	
	p.SetDelegate();
	
	p.SetControllers();
end

function p.SetDelegate()
	local btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_RETURN );
	btn:SetLuaDelegate( p.OnBtnClick );
	
	btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_8 );
	btn:SetLuaDelegate( p.OnBtnClick );
end

function p.SetControllers()
	local drug_id = tonumber(SelectCell( T_DRUG_MIX, p.drug_mix_id, "drug_id" )) or 0;
	if drug_id == 0 then
		return;
	end
	
	local itempic = GetButton( p.layer, ui.ID_CTRL_BUTTON_ITEM1 );
	local path = SelectCell( T_MATERIAL, drug_id, "item_pic" );
	if path then
		itempic:SetImage( GetPictureByAni( path, 0 ) );
	end
	
	local itemname = GetLabel( p.layer, ui.ID_CTRL_TEXT_ITEMNAME1 );
	itemname:SetText( SelectCell( T_MATERIAL, drug_id, "name" ) );
	
	local itemname1 = GetLabel( p.layer, ui.ID_CTRL_TEXT_34 );
	itemname1:SetText( SelectCell( T_MATERIAL, drug_id, "name" ) );

	local iteminfo = GetLabel( p.layer, ui.ID_CTRL_TEXT_35);
	iteminfo:SetText( SelectCell( T_MATERIAL, drug_id, "description" ) );
	
	local materialCache = msg_cache.msg_material_list or {};
	local materials = materialCache.Material or {};
	
	local num = 0;
	for i = 1, #materials do
		local temp = materials[i] or {};
		temp.material_id = tonumber(temp.material_id) or 0;
		temp.num = tonumber(temp.num) or 0;
		if tonumber( temp.material_id ) == tonumber( drug_id ) then
			num = temp.num;
			break;
		end
	end
	--计算临时数据
	local totalNum = num;
	if country_mixhouse.mixData[tonumber(drug_id)] ~= nil and country_mixhouse.mixData[tonumber(drug_id)] ~= 0 then
		totalNum = totalNum + country_mixhouse.mixData[tonumber(drug_id)];
	end
	
	local numText = GetLabel( p.layer, ui.ID_CTRL_TEXT_37 );
	numText:SetText( tostring(totalNum) );
	
	local drugList = SelectRowList( T_DRUG_MIX, "id", p.drug_mix_id );
	local drug = {};
	if drugList ~= nil and drugList[1] ~= nil then
		drug = drugList[1];
	end

	local flag = true;
	for i = 1, 4 do
		local itemImage = GetImage( p.layer, needItemTag[i][IMAGE_INDEX] );
		local nameText = GetLabel( p.layer, needItemTag[i][NAME_INEDX] );
		local needNum = GetLabel( p.layer, needItemTag[i][NEED_INDEX] );
		local hasNum = GetLabel( p.layer, needItemTag[i][HAS_INDE] );
		
		local material_id = tonumber(drug["material_id"..i]) or 0;
		local need_num = tonumber(drug["num"..i]) or 0;
		
		if material_id == 0 or need_num == 0 then
			itemImage:SetVisible( false );
			nameText:SetVisible( false );
			needNum:SetVisible( false );
			hasNum:SetVisible( false );
		else
			itemImage:SetVisible( true );
			nameText:SetVisible( true );
			needNum:SetVisible( true );
			hasNum:SetVisible( true );
			
			local path = SelectCell( T_MATERIAL, material_id, "item_pic" );
			if path then
				itemImage:SetPicture( GetPictureByAni( path, 0 ) );
			end
			nameText:SetText( tostring(SelectCell( T_MATERIAL, material_id, "name" )) );
			needNum:SetText( tostring(need_num) );
			
			local has = 0;
			for j = 1, #materials do
				local temp = materials[j] or {};
				temp.material_id = tonumber(temp.material_id) or 0;
				temp.num = tonumber(temp.num) or 0;
				if tonumber( temp.material_id ) == tonumber( material_id ) then
					has = temp.num;
					break;
				end
			end
			--计算临时数据
			local remainNum = has;
			if country_mixhouse.costMaterial[material_id] ~= nil and country_mixhouse.costMaterial[material_id] ~= 0 then
				remainNum = math.max(remainNum - country_mixhouse.costMaterial[material_id], 0);
			end
			hasNum:SetText( tostring(remainNum) );
			
			hasNum:SetFontColor( remainNum >= need_num and ccc4(255,255,255,255) or ccc4(255,0,0,255) );
			itemImage:SetMaskColor(remainNum >= need_num and ccc4(255,255,255,255) or ccc4(100,100,100,255));
			flag = flag and remainNum >= need_num;
		end
	end
	
	local needMoney = tonumber(drug.money or 0);
	local cache = msg_cache.msg_player or {};
	local money = tonumber(cache.Money) or 0;
	money = math.max(money - country_mixhouse.costMoney, 0);
	local needMoneyText = GetLabel( p.layer, ui.ID_CTRL_TEXT_58 );
	needMoneyText:SetText( string.format( "消耗金币：%d", needMoney ) );
	needMoneyText:SetFontColor( money >= needMoney and ccc4(255,255,255,255) or ccc4(255,0,0,255) );
	flag = flag and money >= needMoney;
	
	local btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_8 );
	btn:SetEnabled( flag );
end

function p.OnBtnClick( uiNode, uiEventType, param )
	if IsClickEvent( uiEventType ) then
		local tag = uiNode:GetTag();
		if ui.ID_CTRL_BUTTON_RETURN == tag then
			country_mixhouse.SendMixRequest( p.drug_mix_id );
			p.CloseUI();
			country_mixhouse.ShowUI();
		elseif ui.ID_CTRL_BUTTON_8 == tag then
			uiNode:SetEnabled( false );
			country_mixhouse.DidMix( p.drug_mix_id, uiNode, p.MixCallBack );
		end
	end
end

function p.MixCallBack( )
	p.SetControllers();
end

function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end

function p.CloseUI()
	if p.layer ~= nil then
		p.layer:LazyClose( false );
		p.layer = nil;
		p.drug_mix_id = nil;
	end
end

