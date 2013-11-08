
maininterface = {}
local p = maininterface;

p.layer = nil;

local ui = ui_main_interface

function p.ShowUI(userinfo)
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		--[[dlg_userinfo2.ShowUI();
		local achievementList = GetListBoxVert( p.layer, ui.ID_CTRL_VERTICAL_LIST_8);
		achievementList:SetVisible(true);--]]
		return;
	end
	
	local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	
	layer:Init();
	layer:SetSwallowTouch(true);
	layer:SetFrameRectFull();
    
	GetUIRoot():AddChild(layer);
	LoadUI("main_interface.xui", layer, nil);
    
	p.layer = layer;
	p.SetDelegate();
	
	dlg_userinfo.ShowUI(userinfo);
	--p.SendReqUserInfo();
end

--���ð�ť
function p.SetBtn(btn)
	btn:SetLuaDelegate(p.OnBtnClick);
	btn:AddActionEffect( "ui_cmb.mainui_btn_scale" );
end

function p.SetDelegate()
	--����
	local gift = GetButton( p.layer, ui.ID_CTRL_MAIN_BUTTON_GIFT );
	gift:SetLuaDelegate(p.OnBtnClick);
	
	--������
	local pvp = GetButton( p.layer, ui.ID_CTRL_BUTTON_PVP);
	pvp:SetLuaDelegate(p.OnBtnClick);
	
	--���ᰴť
	local union = GetButton( p.layer, ui.ID_CTRL_BUTTON_UNION );
	union:SetLuaDelegate(p.OnBtnClick);
	
	--�̳�
	local shop = GetButton( p.layer, ui.ID_CTRL_MAIN_BUTTON_SHOP);
	shop:SetLuaDelegate(p.OnBtnClick);
	
--[[	--���������
	local map2 = GetButton(layer, ui.ID_CTRL_BUTTON_9);
	p.SetBtn(map2);
	
	--���������
	local map3 = GetButton(layer, ui.ID_CTRL_BUTTON_8);
	p.SetBtn(map3);--]]
	
--[[	local bgBtn = GetButton(layer, ui.ID_CTRL_MIAN_BUTTON_DOWN);
	bgBtn:SetLuaDelegate(p.OnBtnClick);--]]
end

function p.OnBtnClick(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
	    local tag = uiNode:GetTag();
		if ui.ID_CTRL_MAIN_BUTTON_GIFT == tag then
			WriteCon("**======================����======================**");
			p.CloseAllPanel();

			game_main.EnterWorldMap();
			
			--������UI	
			p.HideUI();
		elseif ui.ID_CTRL_BUTTON_PVP == tag then
			WriteCon("**=====================������=====================**");
		elseif ui.ID_CTRL_BUTTON_UNION == tag then
			WriteCon("**======================����======================**");
		elseif ui.ID_CTRL_MAIN_BUTTON_SHOP == tag then
			WriteCon("**======================�̳�======================**");
		end
	end
end

--�ر������
function p.CloseAllPanel()
	--dlg_userinfo.CloseUI();
	
end

--����UI
function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
		--local achievementList = GetListBoxVert( p.layer, ui.ID_CTRL_VERTICAL_LIST_8);
		--achievementList:SetVisible( false ); 
	end
end

--�ر�UI
function p.CloseUI()
	if p.layer ~= nil then
	    p.layer:LazyClose();
        p.layer = nil;
    end
end

--������ʾ�˵���ť
function p.ShowMenuBtn()
	local menu = GetButton(p.layer, ui.ID_CTRL_MAIN_BUTTON_MEMU);
	if menu then
		menu:SetVisible(true);
	end
end

--[[
--���ù������
function p.ShowAchievementList()
	local achievementList = GetListBoxVert( p.layer, ui.ID_CTRL_VERTICAL_LIST_8);	
	for i=1, 4 do
		local view = createNDUIXView();
		view:Init();
		LoadUI("main_actANDad.xui", view, nil);
		local bg = GetUiNode(view, ui_main_actandad.ID_CTRL_CTRL_BUTTON_24);
		view:SetViewSize( CCSizeMake(bg:GetFrameSize().w, bg:GetFrameSize().h+5.0));
		
		--���
		local btn = GetButton(view, ui_main_actandad.ID_CTRL_CTRL_BUTTON_24);
		btn:SetLuaDelegate(p.OnClickAD);

		achievementList:AddView( view );
	end
end
--]]

--[[
function p.OnClickAD()
	WriteCon("**=======AD=======**");
end
--]]