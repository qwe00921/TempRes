

dlg_btn_list = {};
local p = dlg_btn_list;

local ui = ui_main_btn_list;

p.layer = nil;

local btn_num = 10;

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
	layer:SetSwallowTouch(false);
    
	GetUIRoot():AddChild(layer);
	LoadUI("main_btn_list.xui", layer, nil);
    
	p.layer = layer;
	
	p.ShowBtnList();
end

function p.ShowBtnList()
	local list = GetListBoxVert( p.layer, ui.ID_CTRL_VERTICAL_LIST_2 );
	if list ~= nil then
		local row = math.ceil(btn_num/4);
		for i = 1, row do
			local view = createNDUIXView();
			view:Init();
			LoadUI("main_btn_node.xui", view, nil);
			
			local bg = GetUiNode( view, ui_main_btn_node.ID_CTRL_PICTURE_BG );
			view:SetViewSize( bg:GetFrameSize());
			for j = 1, 4 do
				if (i-1)*4+j > btn_num then
					local btn = GetButton( view, ui_main_btn_node["ID_CTRL_BUTTON_BTN_" .. j] );
					if btn then
						btn:SetVisible( false );
					end
				else
					local pic = GetPictureByAni( "ui.more_action_list", (i-1)*4+j-1);
					if pic then
						local btn = GetButton( view, ui_main_btn_node["ID_CTRL_BUTTON_BTN_" .. j] );
						if btn ~= nil then
							btn:SetVisible( true );
							btn:SetId( (i-1)*4+j );
							btn:SetImage( GetPictureByAni( "ui.more_action_list", (i-1)*4+j-1) );
							btn:SetTouchDownImage( GetPictureByAni( "ui.more_action_list", (i-1)*4+j-1) );
							btn:SetDisabledImage( GetPictureByAni( "ui.more_action_list", (i-1)*4+j-1) );
							
							btn:SetLuaDelegate( p.OnBtnClick );
						end
					end
				end
			end
			list:AddView( view );
		end
	end
end

function p.OnBtnClick(uiNode, uiEventType, param)
	if IsClickEvent(uiEventType) then
		local id = uiNode:GetId();
		
	end
end

function p.CloseUI()
    if p.layer ~= nil then
        p.layer:LazyClose();
        p.layer = nil;
    end
end

function p.HideUI()
	if p.layer ~= nil then
        p.layer:SetVisible(false);
	end
end


