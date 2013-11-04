
maininterface = {}
local p = maininterface;

p.layer = nil;
p.adList = {}

local ui = ui_main_interface

function p.ShowUI()
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		dlg_userinfo2.ShowUI();
		local achievementList = GetListBoxVert( p.layer, ui.ID_CTRL_VERTICAL_LIST_8);
		achievementList:SetVisible(true);
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
	p.SetDelegate(layer);
	
	dlg_userinfo2.ShowUI();
	p.ShowAchievementList();
end

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

--���ð�ť
function p.SetBtn(btn)
	btn:SetLuaDelegate(p.OnBtnClick);
	btn:AddActionEffect( "ui_cmb.mainui_btn_scale" );
end

function p.SetDelegate(layer)
	--���
	local gift = GetButton(layer, ui.ID_CTRL_MAIN_BUTTON_GIFT);
	gift:SetLuaDelegate(p.OnBtnClick);
	
	--���������
	local map1 = GetButton(layer, ui.ID_CTRL_TEMP_BUTTON_QUEST);
	p.SetBtn(map1);
	
	--���������
--[[	local map2 = GetButton(layer, ui.ID_CTRL_BUTTON_9);
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
			WriteCon("**���**");

			p.CloseAllPanel();
			
			dlg_drama.ShowUI(1);
		elseif ui.ID_CTRL_TEMP_BUTTON_QUEST == tag then
			p.HideUI();	
			p.CloseAllPanel();

			game_main.EnterWorldMap();
		elseif ui.ID_CTRL_MIAN_BUTTON_DOWN == tag then
			p.CloseAllPanel();
			dlg_menu.CloseUI();
		end
	end
end

--�ر������
function p.CloseAllPanel()
	dlg_userinfo.CloseUI();
	--dlg_menu.CloseUI();
end

--����UI
function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
		local achievementList = GetListBoxVert( p.layer, ui.ID_CTRL_VERTICAL_LIST_8);
		achievementList:SetVisible( false ); 
	end
end

--�ر�UI
function p.CloseUI()
	if p.layer ~= nil then
	    p.layer:LazyClose();
        p.layer = nil;
		--p.adList = nil;
    end
end

--������ʾ�˵���ť
function p.ShowMenuBtn()
	local menu = GetButton(p.layer, ui.ID_CTRL_MAIN_BUTTON_MEMU);
	if menu then
		menu:SetVisible(true);
	end
end

function p.OnClickAD()
	WriteCon("**=======AD=======**");
end
