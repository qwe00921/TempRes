-------------------------------------------------------------------
login_ui = {}
local p = login_ui;

p.layer = nil;
local ui = ui_login_createid;

p.loginNameEdit = nil; --�û���
p.loginPWEdit = nil; --����

--��ʾUI
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

--���ð�ť
function p.SetBtn(btn)
	btn:SetLuaDelegate(p.OnBtnClick);
	--btn:AddActionEffect("ui_cmb.mainui_btn_scale");
end

--�����¼�����
function p.SetDelegate(layer)
	--��½��Ϸ
	local startGame = GetButton(layer, ui.ID_CTRL_LOGIN_CTRL_BUTTON_STARTGAME);
	p.SetBtn(startGame);
	
	--�����˺�
	local createID = GetButton(layer, ui.ID_CTRL_LOGIN_CTRL_BUTTON_CREATEID);
	p.SetBtn(createID);
end

--��ť����¼�
function p.OnBtnClick(uiNode,uiEventType,param)
	if IsClickEvent(uiEventType) then
		--p.CloseAllPanel();
		local tag = uiNode:GetTag();
		if (ui.ID_CTRL_LOGIN_CTRL_BUTTON_STARTGAME == tag) then
			WriteCon("����");
			
			p.loginNameEdit = GetEdit(p.layer, ui_login_createid.ID_CTRL_INPUT_TEXT_ID);
			WriteCon(p.loginNameEdit:GetText());
			
			p.loginPWEdit = GetEdit(p.layer, ui_login_createid.ID_CTRL_INPUT_TEXT_151 );
			WriteCon(p.loginPWEdit:GetText());
			
			local loginName = p.loginNameEdit:GetText();
			local loginPW = p.loginPWEdit:GetText(); --MD5�ټ�����
			
			local uid = GetUID();
			
			local param = "&loginName="..loginName.."&loginPW="..loginPW;
			WriteCon(param);
			--SendReq("login","loginCheck",uid,param);
			SendReq("ServerList","List",uid,"MachineType=Android");
			
			p.HideUI();
			--server_list.ShowUI();
			--game_main.EnterWorldMap();
			
		elseif (ui.ID_CTRL_LOGIN_CTRL_BUTTON_CREATEID == tag) then
			WriteCon("�����˺�");
			
			WriteCon(p.loginNameEdit);
			WriteCon(p.loginPWEdit);
		end
	end
end


--����UI
function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible(false);
		
	end
end

--�ر�UI
function p.CloseUI()
	if p.layer ~= nil then
		p.layer:LazyClose();
		p.layer = nil;
	end
end
