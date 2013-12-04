
card_intensify_succeed  = {}
local p = card_intensify_succeed;

local ui = ui_card_intensify_succeed;

p.layer = nil;
p.beforCardInfo = nil;
p.cardInfo = nil;
function p.ShowUI(beforCardInfo)
	WriteCon("ShowUI.....1"..beforCardInfo.UniqueId);
	if beforCardInfo == nil then 
		return;
	end
	WriteCon("ShowUI.....2"..beforCardInfo.UniqueId);
	p.beforCardInfo = beforCardInfo;
	
	if p.layer ~= nil then 
		p.layer:SetVisible(true);
		return;
	end
	WriteCon("ShowUI.....3"..beforCardInfo.UniqueId);
    local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end
	WriteCon("ShowUI.....4"..beforCardInfo.UniqueId);
	
	layer:NoMask();
    layer:Init();   
	layer:SetSwallowTouch(false);
	
    GetUIRoot():AddDlg(layer);
    LoadDlg("card_intensify_succeed.xui", layer, nil);

    p.layer = layer;
    p.SetDelegate(layer);
	WriteCon("ShowUI-------------");
end




--主界面事件处理
function p.SetDelegate(layer)
	local intensifyBtn = GetButton(layer, ui.ID_CTRL_BUTTON_INTENSIFY);
	intensifyBtn:SetLuaDelegate(p.OnUIClickEvent);

	local backBtn = GetButton(layer, ui.ID_CTRL_BUTTON_BACK);
	backBtn:SetLuaDelegate(p.OnUIClickEvent);
	
end

--事件处理
function p.OnUIClickEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent(uiEventType) then
		if(ui.ID_CTRL_BUTTON_BACK == tag) then --返回
			p.CloseUI();
			card_intensify.CloseUI();
		elseif(ui.ID_CTRL_BUTTON_INTENSIFY == tag) then --强化
			
			--card_intensify.ShowUI(p.cardInfo);
			card_intensify.OnSendReq();
			p.CloseUI();
		end
	end
end


--显示卡牌列表
function p.ShowCardLevel(msg)
	WriteCon("ShowCardLevel.....");
	if p.layer == nil then
		return;
	end
	if msg == nil then
		return;
	end
	p.cardInfo = msg.cardinfo;
	
	local cardPic = GetImage(p.layer,ui.ID_CTRL_PICTURE_CARD);
	local aniIndex = "card.card_"..p.cardInfo.CardID;
	
	cardPic:SetPicture( GetPictureByAni(aniIndex, 0) );
	
	local pCardLeveInfo= SelectRowInner( T_CARD_LEVEL, "card_level", p.cardInfo.Level);
	
	--经验
	local cardExp = GetLabel(p.layer,ui.ID_CTRL_TEXT_EXP);
	cardExp:SetText(tostring(p.cardInfo.Exp).."/"..tostring(pCardLeveInfo.feed_exp)); 	
	
	--未强化前的等级
	local cardbeforLevel = GetLabel(p.layer,ui.ID_CTRL_TEXT_21);
	cardbeforLevel:SetText(tostring(p.beforCardInfo.Level)); 
	--强化后的等级
	local cardLevel = GetLabel(p.layer,ui.ID_CTRL_TEXT_22);
	cardLevel:SetText(tostring(p.cardInfo.Level)); 
	
	
	--未强化前的HP
	local cardbeforHP = GetLabel(p.layer,ui.ID_CTRL_TEXT_HP_1);
	cardbeforHP:SetText(tostring(p.beforCardInfo.Hp)); 
	--强化后的HP
	local cardHP = GetLabel(p.layer,ui.ID_CTRL_TEXT_HP_2);
	cardHP:SetText("+"..tostring(p.cardInfo.add_Hp)); 
	
	--未强化前的攻击
	local cardbeforAttack = GetLabel(p.layer,ui.ID_CTRL_TEXT_ATTACK_1);
	cardbeforAttack:SetText(tostring(p.beforCardInfo.Attack)); 
	--强化后的攻击
	local cardAttack = GetLabel(p.layer,ui.ID_CTRL_TEXT_ATTACK_2);
	cardAttack:SetText("+"..tostring(p.cardInfo.add_Attack)); 
	
	--未强化前的防御
	local cardbeforDefence = GetLabel(p.layer,ui.ID_CTRL_TEXT_DEFENCE_1);
	cardbeforDefence:SetText(tostring(p.beforCardInfo.Defence)); 
	--强化后的防御
	local cardDefence = GetLabel(p.layer,ui.ID_CTRL_TEXT_DEFENCE_2);
	cardDefence:SetText("+"..tostring(p.cardInfo.add_Defence)); 

	--未强化前的速度
	local cardbeforSpeed = GetLabel(p.layer,ui.ID_CTRL_TEXT_SPEED_1);
	cardbeforSpeed:SetText(tostring(p.beforCardInfo.Speed)); 
	--强化后的速度
	local cardSpeed = GetLabel(p.layer,ui.ID_CTRL_TEXT_SPEED_2);
	cardSpeed:SetText("+"..tostring(p.cardInfo.add_Speed)); 
	
	--未强化前的暴击
	local cardbeforCrit = GetLabel(p.layer,ui.ID_CTRL_TEXT_CRIT_1);
	cardbeforCrit:SetText(tostring(p.beforCardInfo.Crit)); 
	--强化后的暴击
	local cardCrit = GetLabel(p.layer,ui.ID_CTRL_TEXT_CRIT_2);
	cardCrit:SetText("+"..tostring(p.cardInfo.add_Speed)); 
	
end


function p.HideUI()
    if p.layer ~= nil then
        p.layer:SetVisible( false );
    end
end

function p.CloseUI()
    if p.layer ~= nil then
        p.layer:LazyClose();
        p.layer = nil;
		p.beforCardInfo = nil;
		p.cardInfo = nil;
		
    end
end

