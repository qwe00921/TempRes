-------------------------------------------------------------------
login_ui = {}
local p = login_ui;

p.layer = nil;
local ui = ui_login_createid;

p.loginNameEdit = nil; --用户名
p.loginPWEdit = nil; --密码

--显示UI
function p.ShowUI()
	if p.layer ~= nil then
		p.layer:SetVisible(true);
		--p.SendReqUserInfo();
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
	LoadUI("login_createID.xui",layer,nil);

	p.layer = layer;
	p.SetDelegate(layer);
end

--设置按钮
function p.SetBtn(btn)
	btn:SetLuaDelegate(p.OnBtnClick);
	--btn:AddActionEffect("ui_cmb.mainui_btn_scale");
end

--设置事件处理
function p.SetDelegate(layer)
	--登陆游戏
	local startGame = GetButton(layer, ui.ID_CTRL_LOGIN_CTRL_BUTTON_STARTGAME);
	p.SetBtn(startGame);
	
	--创建账号
	local createID = GetButton(layer, ui.ID_CTRL_LOGIN_CTRL_BUTTON_CREATEID);
	p.SetBtn(createID);
end

--按钮点击事件
function p.OnBtnClick(uiNode,uiEventType,param)
	if IsClickEvent(uiEventType) then
		--p.CloseAllPanel();
		local tag = uiNode:GetTag();
		if (ui.ID_CTRL_LOGIN_CTRL_BUTTON_STARTGAME == tag) then
			WriteCon("登入");
			
			p.loginNameEdit = GetEdit(p.layer, ui_login_createid.ID_CTRL_INPUT_TEXT_ID);
			WriteCon(p.loginNameEdit:GetText());
			
			p.loginPWEdit = GetEdit(p.layer, ui_login_createid.ID_CTRL_INPUT_TEXT_151 );
			WriteCon(p.loginPWEdit:GetText());
			
			local loginName = p.loginNameEdit:GetText();
			local loginPW = p.loginPWEdit:GetText(); --MD5再加密下
			
			local uid = GetUID();
			
			local param = "&loginName="..loginName.."&loginPW="..loginPW;
			WriteCon(param);
			--SendReq("login","loginCheck",uid,param);
			SendReq("ServerList","List",uid,"MachineType=Android");
			
			p.HideUI();
			--server_list.ShowUI();
			--game_main.EnterWorldMap();
			
		elseif (ui.ID_CTRL_LOGIN_CTRL_BUTTON_CREATEID == tag) then
			WriteCon("创建账号");
			
			WriteCon(p.loginNameEdit);
			WriteCon(p.loginPWEdit);
		end
	end
end


--隐藏UI
function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible(false);
		
	end
end

--关闭UI
function p.CloseUI()
	if p.layer ~= nil then
		p.layer:LazyClose();
		p.layer = nil;
	end
end
