stageMap_1 = {}
local p = stageMap_1;
local ui = ui_map1;
local uiNodeT = {};


p.layer = nil;
function p.ShowUI()
	if p.isReplace ~= true then
		dlg_menu.SetNewUI( p );
	end
	--maininterface.m_bgImage:SetVisible(false);
	dlg_userinfo.HideUI();
	--dlg_menu.HideUI();
	if p.layer ~= nil then 
		p.layer:SetVisible(true);
		return;
	end
	
	local layer = createNDUIDialog();
	if layer == nil then
		return false;
	end
	
	layer:NoMask();
	layer:Init();
	layer:SetSwallowTouch(false);
	
	GetUIRoot():AddDlg(layer);
	LoadUI("map1.xui",layer,nil);
	
	p.layer = layer;
	p.SetDelegate(layer);
	
	p.Init()
	
end

function p.Init()
	local stageName1 = GetLabel(p.layer, ui.ID_CTRL_TEXT_CHAPTER1);
	local stageName2 = GetLabel(p.layer, ui.ID_CTRL_TEXT_CHAPTER2);
	local stageName3 = GetLabel(p.layer, ui.ID_CTRL_TEXT_CHAPTER3);
	local stageName4 = GetLabel(p.layer, ui.ID_CTRL_TEXT_CHAPTER4);
	local stageName5 = GetLabel(p.layer, ui.ID_CTRL_TEXT_CHAPTER5);
	local stageName6 = GetLabel(p.layer, ui.ID_CTRL_TEXT_CHAPTER6);
	uiNodeT.stageName = {}
	uiNodeT.stageName[1] = stageName1;
	uiNodeT.stageName[2] = stageName2;
	uiNodeT.stageName[3] = stageName3;
	uiNodeT.stageName[4] = stageName4;
	uiNodeT.stageName[5] = stageName5;
	uiNodeT.stageName[6] = stageName6;

	local stageNameBg1 = GetImage(p.layer, ui.ID_CTRL_PICTURE_HEAD1);
	local stageNameBg2 = GetImage(p.layer, ui.ID_CTRL_PICTURE_HEAD2);
	local stageNameBg3 = GetImage(p.layer, ui.ID_CTRL_PICTURE_HEAD3);
	local stageNameBg4 = GetImage(p.layer, ui.ID_CTRL_PICTURE_HEAD4);
	local stageNameBg5 = GetImage(p.layer, ui.ID_CTRL_PICTURE_HEAD5);
	local stageNameBg6 = GetImage(p.layer, ui.ID_CTRL_PICTURE_HEAD6);
	uiNodeT.stageNameBg = {}
	uiNodeT.stageNameBg[1] = stageNameBg1;
	uiNodeT.stageNameBg[2] = stageNameBg2;
	uiNodeT.stageNameBg[3] = stageNameBg3;
	uiNodeT.stageNameBg[4] = stageNameBg4;
	uiNodeT.stageNameBg[5] = stageNameBg5;
	uiNodeT.stageNameBg[6] = stageNameBg6;
	
	WriteCon("send stageMap request");
	local uid = GetUID();
	local param = "";
	SendReq("Mission","StageList",uid,param);
end

function p.addAllStage(callBackData)
	if callBackData.result == false then
		dlg_msgbox.ShowOK("错误提示","玩家数据错误。",nil,p.layer);
		return
	end
	local stageListInif = callBackData.stages;
	if stageListInif == nil then
		dlg_msgbox.ShowOK("错误提示","玩家数据错误，请联系开发人员。",nil,p.layer);
		return;
	end

	for i = 1, 9 do
		if stageListInif["S10"..i] then
			uiNodeT.stageNameBg[i]:SetPicture( GetPictureByAni("common_ui.countNameBox", 0));
			local stageId = tonumber(stageListInif["S10"..i])
			local stageTable = SelectRowInner(T_STAGE,"stage_id",stageId);
			uiNodeT.stageName[i]:SetText(stageTable.stage_name);
			uiNodeT.stageBtn[i]:SetId(stageId);
			uiNodeT.stageBtn[i]:SetLuaDelegate(p.OnBtnClick);
		end
	end
end

function p.openQusetView(uiNode)
	local stageId = uiNode:GetId();
	if stageId == nil then 
		WriteCon("show stageId error ");
		return 
	end
	p.CloseUI()
	WriteCon("show stageMap == "..stageId);
	quest_main.ShowUI(stageId);
end

function p.SetDelegate(layer)
	local btnReturn = GetButton( p.layer, ui.ID_CTRL_BUTTON_RETURN );
	btnReturn:SetLuaDelegate(p.OnBtnClick);
	
	local stageBtn1 = GetButton( p.layer, ui.ID_CTRL_BUTTON_CHAPTER1 );
	--stageBtn1:SetLuaDelegate(p.OnBtnClick);
	local stageBtn2 = GetButton( p.layer, ui.ID_CTRL_BUTTON_CHAPTER2 );
	--stageBtn2:SetLuaDelegate(p.OnBtnClick);
	local stageBtn3 = GetButton( p.layer, ui.ID_CTRL_BUTTON_CHAPTER3 );
	--stageBtn3:SetLuaDelegate(p.OnBtnClick);
	local stageBtn4 = GetButton( p.layer, ui.ID_CTRL_BUTTON_CHAPTER4 );
	--stageBtn4:SetLuaDelegate(p.OnBtnClick);
	local stageBtn5 = GetButton( p.layer, ui.ID_CTRL_BUTTON_CHAPTER5 );
	--stageBtn5:SetLuaDelegate(p.OnBtnClick);
	local stageBtn6 = GetButton( p.layer, ui.ID_CTRL_BUTTON_CHAPTER6 );
	--stageBtn6:SetLuaDelegate(p.OnBtnClick);
	
	uiNodeT.stageBtn = {}
	uiNodeT.stageBtn[1] = stageBtn1;
	uiNodeT.stageBtn[2] = stageBtn2;
	uiNodeT.stageBtn[3] = stageBtn3;
	uiNodeT.stageBtn[4] = stageBtn4;
	uiNodeT.stageBtn[5] = stageBtn5;
	uiNodeT.stageBtn[6] = stageBtn6;
end

function p.OnBtnClick(uiNode,uiEventType,param)
	if IsClickEvent(uiEventType) then
		local tag = uiNode:GetTag();
		if (ui.ID_CTRL_BUTTON_RETURN == tag) then
			p.CloseUI();
			maininterface.ShowUI();
			dlg_userinfo.ShowUI();
			--dlg_menu.ShowUI();
		elseif (ui.ID_CTRL_BUTTON_CHAPTER1 == tag) then
			p.openQusetView(uiNode)
		elseif(ui.ID_CTRL_BUTTON_CHAPTER2 == tag) then
			p.openQusetView(uiNode)
		elseif(ui.ID_CTRL_BUTTON_CHAPTER3 == tag) then
			p.openQusetView(uiNode)
		elseif(ui.ID_CTRL_BUTTON_CHAPTER4 == tag) then
			p.openQusetView(uiNode)
		elseif(ui.ID_CTRL_BUTTON_CHAPTER5 == tag) then
			p.openQusetView(uiNode)
		elseif(ui.ID_CTRL_BUTTON_CHAPTER6 == tag) then
			p.openQusetView(uiNode)
		end
	end
end

function p.CloseUI()
	if p.layer ~= nil then
		p.layer:LazyClose();
		p.layer = nil;
		dlg_userinfo.ShowUI();
	end
end
function p.UIDisappear()
	p.CloseUI();
	
	maininterface.BecomeFirstUI();
end
