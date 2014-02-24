choose_card = {}
local p = choose_card;
local ui = ui_learning_card;

p.layer = nil;

p.scrollList = nil;
p.cardNum = 5;

p.cardIdList = {}
p.cardIdList[1] = 10174 
p.cardIdList[2] = 10186 
p.cardIdList[3] = 10175 
p.cardIdList[4] = 10054 
p.cardIdList[5] = 10109

function p.ShowUI()
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
	LoadUI("learning_card.xui",layer,nil);
	
	p.layer = layer;
	p.SetDelegate(layer);
	p.InitScrollList();
	p.Init()
end

--初始化卡牌
function p.InitScrollList()
	local posCtrller = GetImage( p.layer, ui.ID_CTRL_PICTURE_CARD );
	local bList = createNDUIScrollContainerExpand();
	if nil == bList then
		WriteConErr("createNDUIScrollContainerExpand() error");
		return false;
	end
	
	p.scrollList = bList;
	local posXY = posCtrller:GetFramePos();
	local size = posCtrller:GetFrameSize();
	bList:Init();
	bList:SetLuaDelegate( p.OnTouchList );
	bList:SetFramePosXY( posXY.x, posXY.y);
	bList:SetFrameSize( size.w, size.h );
	bList:SetSizeView( CCSizeMake(520,0) );
	
	for i = 1,p.cardNum do
		local bView = createNDUIScrollViewExpand();
		if bView == nil then
			WriteConErr("createNDUIScrollViewExpand() error");
			return true;
		end
		bView:Init();
		LoadUI( "card.xui", bView, nil );

		local cardId = tonumber(p.cardIdList[i])
		local cardT = SelectRowInner(T_CHAR_RES,"card_id",cardId);
		local picIndex = cardT.card_pic;
		
		local pic = GetImage( bView, ui_card.ID_CTRL_PICTURE_144 );
		pic:SetPicture( GetPictureByAni(picIndex,0));
		bList:AddView(bView);
	end
	p.layer:AddChild( bList );
end

function p.Init()
	local cardId = p.getNowCardId()
	WriteCon("cardId ==== "..cardId);
	p.setText(cardId)
end

function p.getNowCardId()
	local indexId = tonumber(p.scrollList:GetCurrentIndex())
	--indexId = indexId + 1;
	if indexId == 0 then
		indexId = 5
	end
	WriteCon("indexId ==== "..indexId);
	local cardId = tonumber(p.cardIdList[indexId])
	return cardId
end

function p.setText(cardId)
	local cardT = SelectRowInner(T_CARD,"id",cardId);
	local descriptionText = GetLabel(p.layer, ui.ID_CTRL_TEXT_WORD);
	descriptionText:SetText(tostring(cardT.description));
end

function p.OnTouchList(uiNode,uiEventType,param)
	local cardId = p.getNowCardId()
	WriteCon("cardId ==== "..cardId);
	p.setText(cardId)
end

function p.SetDelegate(uiNode,uiEventType,param)
	local btnOK = GetButton(p.layer, ui.ID_CTRL_BUTTON_START );
	btnOK:SetLuaDelegate(p.OnBtnClick);
	-- local btnLeft = GetButton(p.layer, ui.ID_CTRL_BUTTON_LEFT );
	-- btnLeft:SetLuaDelegate(p.OnBtnClick);
	-- local btnRight = GetButton(p.layer, ui.ID_CTRL_BUTTON_RIGHT );
	-- btnRight:SetLuaDelegate(p.OnBtnClick);
end

function p.OnBtnClick(uiNode,uiEventType,param)
	if IsClickEvent(uiEventType) then
		local tag = uiNode:GetTag();
		if (ui.ID_CTRL_BUTTON_START == tag) then
			local cardId = p.getNowCardId();
			WriteCon( "cardId == "..cardId );
			
			--local uid = GetUID();
			--local param = "guide="..(rookie_main.stepId).."&param="..cardId;
			--SendReq("User","Complete",uid,param);
			local param = "param="..cardId;
			rookie_main.SendUpdateStep(rookie_main.stepId,0,param)
			
			--maininterface.ShowUI();
		-- elseif ui.ID_CTRL_BUTTON_LEFT == tag then
			-- WriteCon( "ID_CTRL_BUTTON_LEFT" );
		-- elseif ui.ID_CTRL_BUTTON_RIGHT == tag then
			-- WriteCon( "ID_CTRL_BUTTON_RIGHT" );
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
		p.ClearData()
	end
end

function p.ClearData()
	p.scrollList = nil;
	p.cardIdList = {}
end
