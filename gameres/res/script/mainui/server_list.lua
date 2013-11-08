
server_list = {}
local p = server_list;

local ui = ui_login_severselect;
p.layer = nil;
p.btn_Id = 101;
p.btn_Id_list = {};
p.url = nil;
p.ServerList = {};
--显示UI
function p.ShowUI(list)

	p.ServerList = list;
	
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
	
	local ServerList = p.ServerList;
	local serverListTable = GetListBoxVert(p.layer, ui.ID_CTRL_LIST_3);
	
	--计算服务器列表长度
	-- local TableLength = 0;
	-- for k,v in pairs(ServerList) do
		-- TableLength = TableLength+1;
	-- end
	-- WriteCon("**TableLength = "..TableLength); 
	
	--取得服务器列表对应数据

	for k,v in pairs(ServerList) do
		
		local view = createNDUIXView();
		view:Init();
		LoadUI("login_severselect_option.xui",view, nil);
		
		local bg = GetUiNode(view, ui_login_severselect_option.ID_CTRL_LOGIN_CTRL_BUTTON_SEVEROPTION);
		view:SetViewSize(CCSizeMake(bg:GetFrameSize().w,bg:GetFrameSize().h));

		
		local btn = GetButton(view, ui_login_severselect_option.ID_CTRL_LOGIN_CTRL_BUTTON_SEVEROPTION);
		btn:SetId(p.btn_Id);
		btn:SetLuaDelegate(p.OnListBtnClick);
		
		local serverName = GetLabel(view, ui_login_severselect_option.ID_CTRL_LOGIN_CTRL_TEXT_SEVEROPTION);
		WriteCon(k); 
		p.btn_Id_list[p.btn_Id] = ServerList[k];
		--WriteCon(tostring(p.btn_Id_list[101]));

		for j,m in pairs(ServerList[k]) do
			WriteCon(tostring(m));
			if j == "name" then
				serverName:SetText(ServerList[k][j]);
			end
		end
	
		serverListTable:AddView(view);
		p.btn_Id = p.btn_Id + 1;

	end
end

--设置按钮
function p.SetBtn(btn)
	--btn:SetLuaDelegate(p.OnBtnClick);
end

function p.SetDelegate(layer)
	--local btn = GetButton()
	WriteCon("**==**"); 
end	
	
function p.OnBtnClick()
	if IsClickEvent(uiEventType) then
		local event_list = 100;
		p.ToGameMain(event_list)
	end
end
	
function p.OnListBtnClick(uiNode, uiEventType, param)
	if IsClickEvent(uiEventType) then
		WriteCon("**====OnListBtnClick====**");
		local btnID = uiNode:GetId();
		WriteCon(tostring(btnID));
		p.url = p.btn_Id_list[btnID].url;
		WriteCon(tostring(p.url));
	end
	
	login_main.CloseUI();
	login_ui.CloseUI();
	p.CloseUI();
	
	--dlg_createrole.ShowUI();
	--maininterface.ShowUI();
	
	p.SendCheckRole();
end


--关闭UI
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

--是否已创建人物
function p.SendCheckRole()
	WriteCon("**==================检测是否有人物=================**");
	local uid = GetUID();
    if uid ~= nil and uid > 0 then
        SendReq("Login","HandShake",uid,"");
	end
end
