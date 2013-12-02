--------------------------------------------------------------
-- FileName:    dlg_beast_main.lua
-- author:      crj,2013/11/12
-- purpose:     召唤兽主界面
--------------------------------------------------------------

dlg_beast_main = {};
local p = dlg_beast_main;

p.layer = nil;

local ui = ui_beast_mainui;

--显示UI
function p.ShowUI()
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
    GetUIRoot():AddDlg( layer );
    LoadDlg ("beast_mainui.xui" , layer , nil );

	p.layer = layer;
    p.SetDelegate();
	
    --加载数据
    beast_mgr.LoadData( p.layer );
end

--设置委托
function p.SetDelegate()
	local btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_BACK);
	btn:SetLuaDelegate( p.OnBtnClick );
end

--按钮交互
function p.OnBtnClick( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
		if ui.ID_CTRL_BUTTON_BACK == tag then
			--退出UI
			p.CloseUI();
			beast_mgr.ClearData();
		end
	end
end

function p.RefreshUI( source )
	local numLabel = GetLabel( p.layer, ui.ID_CTRL_TEXT_NUM );
	if numLabel then
		local num = 0;
		if source.pet and type(source.pet) == "table" then
			num = table.getn( source.pet );
		end
		numLabel:SetText( string.format("%d/%d", num , source.pet_bag or 0 ) );
	end
	
	p.ShowBeastList( source.pet );
end

--显示召唤兽列表
function p.ShowBeastList( petList )
	local list = GetListBoxVert( p.layer ,ui_beast_mainui.ID_CTRL_VERTICAL_LIST_7);
    list:ClearView();
    
    if petList == nil or #petList <= 0 then
        WriteCon("ShowBeastList():petList is null");
        return ;
    end
	
	local lenth = #petList;
	
	for i = 1, lenth do
		local view = createNDUIXView();
        view:Init();
		
        LoadUI( "beast_main_list.xui", view, nil );
        local bg = GetUiNode( view, ui_beast_main_list.ID_CTRL_PICTURE_LISTBG );
        view:SetViewSize( bg:GetFrameSize());

		p.ShowBeastInfo( view, petList[i] );
		
		list:AddView( view );
	end
end

--设置单个召唤兽视图
function p.ShowBeastInfo( view, pet )
	if view == nil or pet == nil then
		WriteCon("data error");
		return;
	end
	
	view:SetId( pet.id );
	
	local levLabel = GetLabel( view, ui_beast_main_list.ID_CTRL_TEXT_12 );
	if levLabel then
		levLabel:SetText( string.format("Lv %d", pet.Level) );
	end
	
	--[[
	local hpLabel = GetLabel( view, ui_beast_main_list.ID_CTRL_TEXT_HP2 );
	if hpLabel then
		hpLabel:SetText( pet.hp );
	end
	--]]
	
	local spLabel = GetLabel( view, ui_beast_main_list.ID_CTRL_TEXT_22 );
	if spLabel then
		spLabel:SetText( tostring(pet.Sp));
	end
	
	local atkLabel = GetLabel( view, ui_beast_main_list.ID_CTRL_TEXT_ATTACK2 );
	if atkLabel then
		atkLabel:SetText( tostring(pet.Atk) );
	end
	
	--名字显示，根据type读csv数据
	local pet_type = pet.Pet_type;
	local nameLabel = GetLabel( view, ui_beast_main_list.ID_CTRL_TEXT_14 );
	if nameLabel then
		nameLabel:SetText( SelectRowInner( T_PET, "pet_type", tostring( pet_type ), "name" ) );
	end
	
	local attrLabel = GetLabel( view, ui_beast_main_list.ID_CTRL_TEXT_ELEMENT );
	if attrLabel then
		--attrLabel:SetText( ... );
	end
	
	--培养按钮
	local trainBtn = GetButton( view, ui_beast_main_list.ID_CTRL_BUTTON_INCUBATE );
	trainBtn:SetLuaDelegate( p.OnListBtnClick );
	
	--出战按钮
	local fightBtn = GetButton( view, ui_beast_main_list.ID_CTRL_BUTTON_FIGHT );
	fightBtn:SetLuaDelegate( p.OnListBtnClick );
	local flag = beast_mgr.CheckIsFightPet( pet.id );
	fightBtn:SetChecked( flag );
	local str = flag and "休息" or "出战";
	fightBtn:SetText( ToUtf8(str) );
	
	local pic = GetImage( view, ui_beast_main_list.ID_CTRL_PICTURE_BEAST );
	local picData = GetPictureByAni( SelectCell( T_PET_RES, SelectRowInner( T_PET, "pet_type", tostring( pet_type ), "id" ), "card_pic" ), 0 );
	if picData then
		pic:SetPicture( picData );
	end
end

--召唤兽列表中子按钮回调
function p.OnListBtnClick( uiNode, uiEventType, param )
	local node = uiNode:GetParent();
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
		if ui_beast_main_list.ID_CTRL_BUTTON_INCUBATE == tag then
			WriteCon("**===============显示培养===============**");
			--显示培养界面，可以通过node:GetId()来获取需要显示哪一个召唤兽的培养界面
			dlg_beast_train.ShowUI( node:GetId() );
			
		elseif ui_beast_main_list.ID_CTRL_BUTTON_FIGHT == tag then
			WriteCon("**===============选择出战===============**");
			
			beast_mgr.SetFight( node );
		end
	end
end

--刷新出战按钮
function p.SetFightBtnCheck( node, flag )
	if node == nil then
		return;
	end	
	
	--出战按钮
	local fightBtn = GetButton( node, ui_beast_main_list.ID_CTRL_BUTTON_FIGHT );
	if fightBtn then
		fightBtn:SetChecked( flag );
		
		local str = flag and "休息" or "出战";
		fightBtn:SetText( ToUtf8( str ) );
	end
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
	end
end

