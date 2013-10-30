
server_list = {}
local p = server_list;

p.layer = nil;
local ui = ui_login_severselect;

--显示UI
function p.ShowUI()
	if p.layer ~= nil then
		p.layer:SetVisible(true);
		
		return;
	end
	
	local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	
	layer:Init();
	layer:SetSwallowTouch(true);
	--layer:SetFrameRectFull();
	
	GetUIRoot():AddChild(layer);
	LoadUI("login_severselect",layer,nil);
	
	p.layer = layer;
	p.SetDelegate(layer);
	
	p.ShowServerList();
end

--服务器列表
function p.ShowServerList()
	local serverList = GetListBoxVert(p.layer, ui.ID_CTRL_LIST_3);

	for i = 1, 4 do
		local view = createNDUIXView();
		view:Init();
		LoadUI("login_severselect_option.xui",view, nil);
		local bg = GetUiNode(view, ui_login_severselect_option.ID_CTRL_LOGIN_CTRL_BUTTON_SEVEROPTION);
		view:SetViewSize(CCSizeMake(bg:GetFrameSize().w,bg:GetFrameSize().h));
		
		local btn = GetButton(view, ui_login_severselect_option.ID_CTRL_LOGIN_CTRL_BUTTON_SEVEROPTION);
		
		btn:SetLuaDelegate(p.ToGameMain); 
	
		serverList:AddView(view);
	end
end

--设置按钮
function p.SetBtn(btn)
	btn:SetLuaDelegate(p.OnBtnClick);
end

function p.SetDelegate(layer)
	WriteCon("**=======123=======**"); 
end	
	
function p.ToGameMain()
	
	WriteCon("**=======AD=======**");
	login_main.CloseUI();
	login_ui.CloseUI();
	p.CloseUI();
	maininterface.ShowUI();
end


--隐藏UI
function p.HideUI()
	if p.layer ~= nil then
		p.layer:LazyClose();
		p.layer = nil;
	end
end

--关闭UI
function p.CloseUI()
	if p.layer ~= nil then
		p.layer:LazyClose();
		p.layer = nil;
	end
end