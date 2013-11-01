
server_list = {}
local p = server_list;

p.layer = nil;
local ui = ui_login_severselect;

--显示UI
function p.ShowUI(list)

	local ServerList = list;
	
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
	
	p.ShowServerList(ServerList);
end

--服务器列表
function p.ShowServerList(ServerList)
	
	local ServerList = ServerList;
	local serverListTable = GetListBoxVert(p.layer, ui.ID_CTRL_LIST_3);
	
	--计算服务器列表长度
	-- local TableLength = 0;
	-- for k,v in pairs(ServerList) do
		-- TableLength = TableLength+1;
	-- end
	-- WriteCon("**TableLength = "..TableLength); 
	
	--取得服务器列表对应数据
	--local list = {};
	--local count = 0;
	for k,v in pairs(ServerList) do
		
		local view = createNDUIXView();
		view:Init();
		LoadUI("login_severselect_option.xui",view, nil);
		
		local bg = GetUiNode(view, ui_login_severselect_option.ID_CTRL_LOGIN_CTRL_BUTTON_SEVEROPTION);
		view:SetViewSize(CCSizeMake(bg:GetFrameSize().w,bg:GetFrameSize().h));
		
		local btn = GetButton(view, ui_login_severselect_option.ID_CTRL_LOGIN_CTRL_BUTTON_SEVEROPTION);
		local serverName = GetLabel(view, ui_login_severselect_option.ID_CTRL_LOGIN_CTRL_TEXT_SEVEROPTION);
		
		WriteCon(k); 
		for j,m in pairs(ServerList[k]) do
			WriteCon(m);
			if j == "url" then
				serverName:SetText(ToUtf8( ServerList[k][j] ));
			end
			-- list.[j].url = ServerList[k][j];
			-- list.[j].state = ServerList
			-- list.[j].serverid = 
		end
		
		btn:SetLuaDelegate(p.ToGameMain); 
		--btn:SetLuaDelegate(p.OnBtnClick); 

	
		serverListTable:AddView(view);
	end
	
	
	
	-- for i = 1, TableLength do
	
		-- local view = createNDUIXView();
		-- view:Init();
		-- LoadUI("login_severselect_option.xui",view, nil);
		-- local bg = GetUiNode(view, ui_login_severselect_option.ID_CTRL_LOGIN_CTRL_BUTTON_SEVEROPTION);
		-- view:SetViewSize(CCSizeMake(bg:GetFrameSize().w,bg:GetFrameSize().h));
		
		-- local btn = GetButton(view, ui_login_severselect_option.ID_CTRL_LOGIN_CTRL_BUTTON_SEVEROPTION);
		
		-- btn:SetLuaDelegate(p.ToGameMain); 
	
		-- serverListTable:AddView(view);
	-- end
end

--设置按钮
function p.SetBtn(btn)
	btn:SetLuaDelegate(p.OnBtnClick);
end

function p.SetDelegate(layer)
	WriteCon("**=======123=======**"); 
end	
	
function p.ToGameMain()
	
	WriteCon("**====ToGameMain====**");
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