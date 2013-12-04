

dlg_beast_train = {};
local p = dlg_beast_train;

p.layer = nil;
p.id = nil;
p.pet = nil;
p.index = nil;

local ui = ui_beast_incubate;

function p.ShowUI( id )
	local source = beast_mgr.GetSource();
	p.id = id;
	for i,v in pairs(source.pet) do
		if v.id == p.id then
			p.pet = v;
			p.index = i;
			break;
		end
	end
	
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		p.InitInfo();
		return;
	end
	
	local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end

	layer:NoMask();
    layer:Init();
    GetUIRoot():AddDlg( layer );
    LoadDlg ("beast_incubate.xui" , layer , nil );

	p.layer = layer;
    p.SetDelegate();
	p.InitInfo();
	p.ShowBeastInfo();
end

function p.SetDelegate()
	--返回
	local back = GetButton( p.layer, ui.ID_CTRL_BUTTON_5 );
	back:SetLuaDelegate( p.OnBtnClick );
	
	--开始培养
	local train = GetButton( p.layer, ui.ID_CTRL_BUTTON_85 );
	train:SetLuaDelegate( p.OnBtnClick );
end

--初始化召唤兽信息
function p.InitInfo()
	if p.pet == nil then
		return;
	end
	
	local source = beast_mgr.GetSource();
	
	--数量显示
	local numLabel = GetLabel( p.layer, ui.ID_CTRL_TEXT_NUM );
	local num = 0;
	if source.pet and type(source.pet) == "table" then
		num = table.getn( source.pet );
	end
	numLabel:SetText( string.format("%d/%d", num , source.pet_bag or 0 ) );
	
	local LevLabel = GetLabel( p.layer, ui.ID_CTRL_TEXT_46 );
	local LevLabel1 = GetLabel( p.layer, ui.ID_CTRL_TEXT_59 );
	LevLabel:SetText( string.format("Lv %d", p.pet.Level) );
	LevLabel1:SetText( tostring( p.pet.Level ) );
	
	local nameLabel = GetLabel( p.layer, ui.ID_CTRL_TEXT_47 );
	nameLabel:SetText( SelectRowInner( T_PET, "pet_type", tostring(p.pet.Pet_type), "name" ) );
	
	local atkLabel = GetLabel( p.layer, ui.ID_CTRL_TEXT_74 );
	local atkLabel1 = GetLabel( p.layer, ui.ID_CTRL_TEXT_61 );
	atkLabel:SetText( tostring( p.pet.Atk ) );
	atkLabel1:SetText( tostring( p.pet.Atk ) );
	
	local spLabel = GetLabel( p.layer, ui.ID_CTRL_TEXT_75 );
	local spLabel1 = GetLabel( p.layer, ui.ID_CTRL_TEXT_62 );
	spLabel:SetText( tostring( p.pet.Sp ) );
	spLabel1:SetText( tostring( p.pet.Sp ) );
	
	local expLabel = GetLabel( p.layer, ui.ID_CTRL_TEXT_58 );
	expLabel:SetText( tostring( p.pet.Exp ) );
	
	local pic = GetImage( p.layer, ui.ID_CTRL_PICTURE_BEAST );
	local picData = GetPictureByAni( SelectCell( T_PET_RES, SelectRowInner( T_PET, "pet_type", tostring( p.pet.Pet_type ), "id" ), "card_pic" ), 0 );
	if picData then
		pic:SetPicture( picData );
	end
	
	p.InfoAfterTrain();
end

--培养结果数据预览
function p.InfoAfterTrain()
	local addLev, remainExp = beast_mgr.CheckUpLevel( p.pet.Level, p.pet.Exp);
	
	local expLabel = GetLabel( p.layer, ui.ID_CTRL_TEXT_68 );
	expLabel:SetText( tostring( remainExp ) );
	
	local LevLabel = GetLabel( p.layer, ui.ID_CTRL_TEXT_69 );
	LevLabel:SetText( tostring( p.pet.Level+addLev ) );
	
	local atkLabel = GetLabel( p.layer, ui.ID_CTRL_TEXT_71 );
	atkLabel:SetText( tostring( p.pet.Atk + tonumber(SelectRowInner( T_PET, "pet_type", tostring(p.pet.Pet_type), "atk_grow" ))*addLev ));
	
	local spLabel = GetLabel( p.layer, ui.ID_CTRL_TEXT_72 );
	spLabel:SetText( tostring( p.pet.Sp + tonumber(SelectRowInner( T_PET, "pet_type", tostring(p.pet.Pet_type), "sp_grow" ))*addLev ) );
	
	local idNumLabel = GetLabel( p.layer, ui.ID_CTRL_TEXT_82 );
	idNumLabel:SetText( string.format( "%d/5", table.getn( beast_mgr.GetIDList() ) ));
	
	local hasLabel = GetLabel( p.layer, ui.ID_CTRL_TEXT_84 );
	hasLabel:SetText( tostring( msg_cache.msg_player.Money ) );	--玩家现有金币从全局获取
	
	local costLabel = GetLabel( p.layer, ui.ID_CTRL_TEXT_83 );
	costLabel:SetText( tostring( beast_mgr.GetTotalCostMoney() ) );
	costLabel:SetFontColor( tonumber( beast_mgr.GetTotalCostMoney() ) > tonumber( msg_cache.msg_player.Money ) and ccc4(255,0,0,255) or ccc4(255,255,255,255) );
end

--显示召唤兽列表
function p.ShowBeastInfo()
	local list = GetListBoxVert( p.layer, ui.ID_CTRL_VERTICAL_LIST_48 );
	if list == nil then
		return;
	end
	
	list:ClearView();
	
	local source = beast_mgr.GetSource();
	
	--去除本身
	local petList = CopyTable( source.pet );
	if p.index then
		table.remove(petList, p.index);
	end
	
	local row = math.ceil((#source.pet-1) / 5);

	for i = 1, row do
		local view = createNDUIXView();
        view:Init();
		
        LoadUI( "beast_incubate_list.xui", view, nil );
        local bg = GetUiNode( view, ui_beast_incubate_list.ID_CTRL_PICTURE_BG );
        view:SetViewSize( bg:GetFrameSize());

		for j = 1, 5 do
			local pet = petList[(i-1)*5+j];
			
			local maskPic = GetImage( view, ui_beast_incubate_list["ID_CTRL_PICTURE_MASK_"..j]);
			local levLabel = GetLabel( view, ui_beast_incubate_list["ID_CTRL_TEXT_LEV_"..j] );
			local cardPic = GetImage( view, ui_beast_incubate_list["ID_CTRL_PICTURE_PIC_"..j]);
			local levBg = GetImage( view, ui_beast_incubate_list["ID_CTRL_PICTURE_LEVEL_BG_"..j]);
			local btn = GetButton( view, ui_beast_incubate_list["ID_CTRL_BUTTON_"..j]);
			local isFight = GetLabel( view, ui_beast_incubate_list["ID_CTRL_TEXT_FIGHT_FLAG_"..j] );
			
			maskPic:SetVisible( false );
			levLabel:SetVisible( pet ~= nil );
			cardPic:SetVisible( pet ~= nil );
			levBg:SetVisible( pet ~= nil );
			btn:SetVisible( pet ~= nil );
			isFight:SetVisible( pet ~= nil and beast_mgr.CheckIsFightPet( pet.id ) );
			
			if pet ~= nil then
				local pic = GetPictureByAni( SelectCell( T_PET_RES, SelectRowInner( T_PET, "pet_type", tostring( pet.Pet_type ), "id" ), "card_pic" ), 0 );
				cardPic:SetPicture( pic );
				levLabel:SetText( string.format( "LV %d", pet.Level ) );
				btn:SetId( pet.id );
				btn:SetLuaDelegate( p.OnListBtnClick );
			end
		end
		list:AddView( view );
	end
end

--按钮回调
function p.OnBtnClick( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
		if ui.ID_CTRL_BUTTON_5 == tag then
			--退出UI
			p.CloseUI();
		elseif ui.ID_CTRL_BUTTON_85 == tag then
			p.StartTrain();
		end
	end
end

--素材选择
function p.OnListBtnClick( uiNode, uiEventType, param )
	local nodeID = uiNode:GetId();
	if IsClickEvent( uiEventType ) then
		--[[
		local idList = beast_mgr.GetIDList();
		if #idList >= 5 then
			dlg_msgbox.ShowOK( ToUtf8("提示"), ToUtf8("一次最多只能选择5个召唤兽"), nil, p.layer );
			return;
		end
		--]]
		
		local selectFlag = beast_mgr.SelectPetID( nodeID, p.layer )
		if type(selectFlag) == "boolean" then
			local tag = uiNode:GetTag();
			local node = uiNode:GetParent();
			for i = 1, 5 do
				if ui_beast_incubate_list["ID_CTRL_BUTTON_"..i] == tag then
					local maskPic = GetImage( node, ui_beast_incubate_list["ID_CTRL_PICTURE_MASK_"..i] );
					if maskPic then
						maskPic:SetVisible( selectFlag );
					end
					break;
				end
			end
			
			--选择素材后刷新预览结果
			p.InfoAfterTrain();
		end
	end
end

--开始培养
function p.StartTrain()
	beast_mgr.RequestTrain( p.id );
end

--培养成功回调
function p.TrainCallBack()
	local source = beast_mgr.GetSource();
	for i,v in pairs(source.pet) do
		if v.id == p.id then
			p.pet = v;
			break;
		end
	end
	
	p.InitInfo();
	p.ShowBeastInfo();
end

--隐藏UI
function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end

--关闭UI
function p.CloseUI()
	if p.layer ~= nil then
		p.layer:LazyClose();
		p.layer = nil;
		p.id = nil;
		p.pet = nil;
		p.index = nil;
		
		beast_mgr.ClearIDList();
	end
end

function CopyTable( t )
	local temp = {}
	if t ~= nil and type(t) == "table" then
		for key , value in pairs(t) do
			if type(value) == "table" then
				local ret = CopyTable( value );
				temp[key] = ret;
			else
				temp[key] = value;
			end
		end
	end
	return temp;
end
