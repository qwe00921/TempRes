card_rein = {}
local p = card_rein;
p.layer = nil;
local ui = ui_card_rein;

function p.ShowUI(baseCardInfo)
	
	if p.layer ~= nil then 
		p.layer:SetVisible(true);
		p.InitUI(baseCardInfo);
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
    LoadDlg("card_rein.xui", layer, nil);

    p.layer = layer;
    p.SetDelegate(layer);	
	p.InitUI(baseCardInfo);
end

function p.InitUI(baseCardInfo)

	p.InitAllCardInfo(); --初始化所有卡牌
	
	if baseCardInfo == nil then
		local selBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_CARD_CHOOSE);
		selBtn:SetVisible(true);
	else
		local selBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_CARD_CHOOSE);
		selBtn:SetVisible(false);	
	end
end	

function p.InitAllCardInfo()
		
		local i;
		for i=1,10 do
			local cardLevText = GetLabel(p.layer, ui.ID_CTRL_TEXT_CARDLEVEL1+i-1);
			cardLevText:SetVisible(false);
			
			local cardPic = GetImage(p.layer, ui.ID_CTRL_PICTURE_111+i-1);
			cardPic:SetVisible(false);	
			
			local cardBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_CARD1+i-1);
			cardBtn:SetImage(GetPictureByAni("common_ui.cardBg", 0));
		end
	
end;	

function p.HideUI()
    if p.layer ~= nil then
        p.layer:SetVisible( false );
    end
end

function p.CloseUI()
    if p.layer ~= nil then
	    p.layer:LazyClose();
        p.layer = nil;	
    end
end

function p.SetDelegate(layer)
	local selBtn = GetButton(layer, ui.ID_CTRL_BUTTON_CARD_CHOOSE);
	selBtn:SetLuaDelegate(p.OnUIClickEvent);

	local starBtn = GetButton(layer, ui.ID_CTRL_BUTTON_START);
	starBtn:SetLuaDelegate(p.OnUIClickEvent);

	local closeBtn = GetButton(layer, ui.ID_CTRL_BUTTON_RETURN);
	closeBtn:SetLuaDelegate(p.OnUIClickEvent);

end
	
function p.OnUIClickEvent(uiNode, uiEventType, param)
	WriteCon("OnUIClickEvent....");	
	local tag = uiNode:GetTag();
	if IsClickEvent(uiEventType) then
		if(ui.ID_CTRL_BUTTON_RETURN == tag) then --返回
			p.CloseUI();
		elseif(ui.ID_CTRL_BUTTON_CARD_CHOOSE == tag) then --选择卡牌
			card_intensify.ShowUI();
		elseif(ui.ID_CTRL_BUTTON_START == tag) then --强化
		
		end;
	end
end		
	
