
card_intensify_succeed  = {}
local p = card_intensify_succeed;

local ui = ui_card_intensify_succeed;

p.layer = nil;
p.beforCardInfo = nil;
p.cardInfo = nil;
function p.ShowUI(beforCardInfo)
	if beforCardInfo == nil then 
		return;
	end
	p.beforCardInfo = beforCardInfo;
	
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
    LoadDlg("card_intensify_succeed.xui", layer, nil);

    p.layer = layer;
    p.SetDelegate(layer);
end




--�������¼�����
function p.SetDelegate(layer)
	local intensifyBtn = GetButton(layer, ui.ID_CTRL_BUTTON_INTENSIFY);
	intensifyBtn:SetLuaDelegate(p.OnUIClickEvent);

	local backBtn = GetButton(layer, ui.ID_CTRL_BUTTON_BACK);
	backBtn:SetLuaDelegate(p.OnUIClickEvent);
	
end

--�¼�����
function p.OnUIClickEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent(uiEventType) then
		if(ui.ID_CTRL_BUTTON_BACK == tag) then --����
			
			card_intensify.CloseUI();
			card_intensify2.OnSendReq();
			card_rein.GetRefreshCardUI();
			p.CloseUI();
		elseif(ui.ID_CTRL_BUTTON_INTENSIFY == tag) then --ǿ��
			
			--card_intensify.ShowUI(p.cardInfo);
			card_intensify2.OnSendReq();
			card_rein.GetRefreshCardUI();
			p.CloseUI();
		end
	end
end


--��ʾ�����б�
function p.ShowCardLevel(msg)
	WriteCon("ShowCardLevel.....");
	if p.layer == nil then
		return;
	end
	if msg == nil then
		return;
	end
	p.cardInfo = msg.cardinfo;
	
	local pCardUpLevelInfo= SelectRowInner( T_CARD_LEVEL, "level", tonumber(p.cardInfo.Level)+1);--�����������뾭��
	local pCardInfo= SelectRowInner( T_CHAR_RES, "card_id", p.cardInfo.CardID); --�ӱ��л�ȡ������ϸ��Ϣ	
	--����ͼƬ
	--local cardPic = GetImage(p.layer,ui.ID_CTRL_PICTURE_CARD);
	--cardPic:SetPicture(GetPictureByAni(pCardInfo.card_pic, 0) );
	
	local pCardInfo2= SelectRowInner( T_CARD, "id", p.cardInfo.CardID);
	local pCardLeveInfo= SelectRowInner( T_CARD_LEVEL, "level", p.cardInfo.Level);
	
	--�������� ID_CTRL_TEXT_NAME
	local pCardName = GetLabel(p.layer,ui.ID_CTRL_TEXT_NAME);
	pCardName:SetText(tostring(pCardInfo2.name)); 
	
	--�������� ID_CTRL_PICTURE_CARDNATURE element card_nature
	local pPicCardNature = GetImage(p.layer, ui.ID_CTRL_PICTURE_26 );
	if tonumber(pCardInfo2.element) == 1 then
		pPicCardNature:SetPicture(GetPictureByAni("ui.card_nature",0));
	elseif tonumber(pCardInfo2.element) == 2 then
		pPicCardNature:SetPicture(GetPictureByAni("ui.card_nature",1));
	elseif tonumber(pCardInfo2.element) == 3 then
		pPicCardNature:SetPicture(GetPictureByAni("ui.card_nature",2));
	elseif tonumber(pCardInfo2.element) == 4 then
		pPicCardNature:SetPicture(GetPictureByAni("ui.card_nature",3));
	elseif tonumber(pCardInfo2.element) == 5 then
		pPicCardNature:SetPicture(GetPictureByAni("ui.card_nature",4));
	elseif tonumber(pCardInfo2.element) == 6 then
		pPicCardNature:SetPicture(GetPictureByAni("ui.card_nature",5));
	end
	
	--����
	--local cardExp = GetLabel(p.layer,ui.ID_CTRL_TEXT_EXP);
	--cardExp:SetText(tostring(p.cardInfo.Exp).."/"..tostring(pCardLeveInfo.exp)); 	
	--������
	local expBar = GetExp( p.layer, ui.ID_CTRL_EXP_EXPNEED);
	local expSstartNum = tonumber(p.cardInfo.Exp);
	local expLeast = 0;
	
	expbar_move_effect.showEffect(expBar,expLeast,tonumber(pCardUpLevelInfo.exp),expSstartNum,0);
	
	--������������
	local upExp = tonumber(pCardUpLevelInfo.exp) - tonumber(p.cardInfo.Exp);
	local labUpLevel =  GetLabel(p.layer,ui.ID_CTRL_TEXT_LEVELUPNEED);
	labUpLevel:SetText(tostring(upExp)); 
	

	--δǿ��ǰ�ĵȼ�
	local cardbeforLevel = GetLabel(p.layer,ui.ID_CTRL_TEXT_21);
	cardbeforLevel:SetText(tostring(p.beforCardInfo.Level)); 
	--ǿ����ĵȼ�
	local cardLevel = GetLabel(p.layer,ui.ID_CTRL_TEXT_22);
	cardLevel:SetText(tostring(p.cardInfo.Level)); 
	
	
	--δǿ��ǰ��HP
	local cardbeforHP = GetLabel(p.layer,ui.ID_CTRL_TEXT_HP_1);
	cardbeforHP:SetText(tostring(p.beforCardInfo.Hp)); 
	--ǿ�����HP
	local cardHP = GetLabel(p.layer,ui.ID_CTRL_TEXT_HP_2);
	cardHP:SetText("+"..tostring(p.cardInfo.add_Hp)); 
	
	--δǿ��ǰ�Ĺ���
	local cardbeforAttack = GetLabel(p.layer,ui.ID_CTRL_TEXT_ATTACK_1);
	cardbeforAttack:SetText(tostring(p.beforCardInfo.Attack)); 
	--ǿ����Ĺ���
	local cardAttack = GetLabel(p.layer,ui.ID_CTRL_TEXT_ATTACK_2);
	cardAttack:SetText("+"..tostring(p.cardInfo.add_Attack)); 
	
	--δǿ��ǰ�ķ���
	local cardbeforDefence = GetLabel(p.layer,ui.ID_CTRL_TEXT_DEFENCE_1);
	cardbeforDefence:SetText(tostring(p.beforCardInfo.Defence)); 
	--ǿ����ķ���
	local cardDefence = GetLabel(p.layer,ui.ID_CTRL_TEXT_DEFENCE_2);
	cardDefence:SetText("+"..tostring(p.cardInfo.add_Defence)); 

	--δǿ��ǰ���ٶ�
	local cardbeforSpeed = GetLabel(p.layer,ui.ID_CTRL_TEXT_SPEED_1);
	cardbeforSpeed:SetText(tostring(p.beforCardInfo.Speed)); 
	--ǿ������ٶ�
	local cardSpeed = GetLabel(p.layer,ui.ID_CTRL_TEXT_SPEED_2);
	cardSpeed:SetText("+"..tostring(p.cardInfo.add_Speed)); 
	--[[
	--δǿ��ǰ�ı���
	local cardbeforCrit = GetLabel(p.layer,ui.ID_CTRL_TEXT_CRIT_1);
	cardbeforCrit:SetText(tostring(p.beforCardInfo.Crit)); 
	--ǿ����ı���
	local cardCrit = GetLabel(p.layer,ui.ID_CTRL_TEXT_CRIT_2);
	cardCrit:SetText("+"..tostring(p.cardInfo.add_Speed)); 
	]]--
	
	-- get default serial sequence
	--local sequence = p.GetDefaultSerialSequence();

	-- add hud effect
	--local cmd = createCommandEffect():AddHudEffect( 2, "sk_test.cardflash" );
	--if cmd ~= nil then
	--	sequence:AddCommand( cmd );
	--end
	
	--�Ƿ񱬻��ɹ�msg.is_crit;
	local pPicIsCrit = GetImage(p.layer, ui.ID_CTRL_PICTURE_SUCCEED);
	WriteCon("is_crit = " .. tostring(msg.is_crit));
	if msg.is_crit == true then
		WriteCon("is_crit = true" );
		pPicIsCrit:SetPicture(GetPictureByAni("ui.intensify_succeed",0));
	else
		WriteCon("is_crit = false" );
		pPicIsCrit:SetPicture(GetPictureByAni("ui.intensify_succeed",1));
	end
	
	
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

