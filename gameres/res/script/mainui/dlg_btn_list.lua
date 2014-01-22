

dlg_btn_list = {};
local p = dlg_btn_list;

local ui = ui_main_btn_list;

p.layer = nil;

local ID_NOTICE = 1;
local ID_SETTING = 2;
local ID_RANK = 3;
local ID_GEN = 4;
local ID_STRENGTHEN = 5;
local ID_PET = 6;
local ID_UNION = 7;
local ID_FRIEND = 8;
local ID_PICTORIAL = 9;
local ID_CARD = 10;

local tShowIndex = { ID_NOTICE, ID_SETTING, ID_RANK, ID_STRENGTHEN, ID_FRIEND, ID_PICTORIAL };
local tValidIndex = { ID_STRENGTHEN };

function p.ShowUI()
	if p.layer ~= nil then
		p.CloseUI();
		return;
	end
	
	local layer = createNDUIDialog();
	if layer == nil then
		return false;
	end
	
	layer:NoMask();
	layer:Init();
	layer:SetSwallowTouch(false);
    
	GetUIRoot():AddChild(layer);
	LoadUI("main_btn_list.xui", layer, nil);
    
	p.layer = layer;
	
	p.layer:SetVisible(true);
	p.layer:SetZOrder(10000);
	--p.layer:SetIsTop(true);
	
	p.SetDelegate();
	p.ShowBtnList();
end

function p.SetDelegate()
	local closeBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_3 );
	closeBtn:SetLuaDelegate( p.OnCloseClick );
end

function p.ShowBtnList()
	card_bag_mian.SetEnableAll(false);

	local list = GetListBoxVert( p.layer, ui.ID_CTRL_VERTICAL_LIST_2 );
	if list ~= nil then
		local btn_num = #tShowIndex;
		local row = math.ceil(btn_num / 4);
		for i = 1, row do
			local view = createNDUIXView();
			view:Init();
			LoadUI("main_btn_node.xui", view, nil);
			--view:SetZOrder(40000);
			
			local bg = GetUiNode( view, ui_main_btn_node.ID_CTRL_PICTURE_BG );
			view:SetViewSize( bg:GetFrameSize());
			for j = 1, 4 do
				if (i - 1) * 4 + j > btn_num then
					local btn = GetButton( view, ui_main_btn_node["ID_CTRL_BUTTON_BTN_" .. j] );
					if btn then
						btn:SetVisible( false );
					end
				else
					local pic = GetPictureByAni( "ui.more_action_list", tShowIndex[(i - 1) * 4 + j] - 1 );
					if pic then
						local btn = GetButton( view, ui_main_btn_node["ID_CTRL_BUTTON_BTN_" .. j] );
						if btn ~= nil then
							btn:SetVisible( true );
							btn:SetId( tShowIndex[(i-1)*4+j] );
							btn:SetImage(
									GetPictureByAni("ui.more_action_list",
											tShowIndex[(i - 1) * 4 + j] - 1));
							btn:SetTouchDownImage(
									GetPictureByAni("ui.more_action_list",
											tShowIndex[(i - 1) * 4 + j] - 1));
							btn:SetDisabledImage(
									GetPictureByAni("ui.more_action_list",
											tShowIndex[(i - 1) * 4 + j] - 1));
							btn:SetLuaDelegate( p.OnBtnClick );
							btn:SetZOrder(10010);
							
							btn:SetEnabled( p.CheckEnabledIndex( tShowIndex[(i - 1) * 4 + j] ) );
						end
					end
				end
			end
			list:AddView( view );
		end
	end
end

function p.CheckEnabledIndex( index )
	local flag = false;
	for _, v in pairs(tValidIndex) do
		if index == v then
			flag = true;
			break;
		end
	end
	return flag;
end

function p.OnCloseClick(uiNode, uiEventType, param)
	
	if IsClickEvent( uiEventType ) then
		local tag = uiNode:GetTag();
		if ui.ID_CTRL_BUTTON_3 == tag then
			p.CloseUI();
		end
	end
end

function p.OnBtnClick(uiNode, uiEventType, param)
	
	if IsClickEvent(uiEventType) then
		local id = uiNode:GetId();
		WriteCon( tostring(id) );		
		p.CloseUI();
--[[		if id == ID_PET then
			dlg_beast_main.ShowUI();
		end
		
		if id == ID_CARD then
			card_bag_mian.ShowUI();
		end
		--]]
		if id == ID_STRENGTHEN then
			card_rein.ShowUI();
		end
	end
end

function p.CloseUI()
	p.HideUI();
	card_bag_mian.SetEnableAll(true);
    if p.layer ~= nil then
		p.layer:SetVisible(false);
        p.layer:LazyClose();
        p.layer = nil;
    end
end

function p.HideUI()
	if p.layer ~= nil then
        p.layer:SetVisible(false);
	end
end