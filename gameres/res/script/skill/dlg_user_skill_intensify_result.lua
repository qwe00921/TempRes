--------------------------------------------------------------
-- FileName: 	dlg_user_skill_intensify_result.lua
-- author:		xyd, 2013��8��13��
-- purpose:		ǿ����ɽ���
--------------------------------------------------------------

dlg_user_skill_intensify_result = {}
local p = dlg_user_skill_intensify_result;
local ui = ui_dlg_user_skill_intensify_result;

p.layer = nil;

p.masterCard = nil;
p.materCardList = nil;
p.allMoney = nil;
p.pBtnBack = nil;
p.pBtnContinue = nil;
p.masterCardLevel = nil;
p.masterCardexp = nil;

function p.ShowUI(masterCard,materCardList,allMoney)
    
    if p.layer == nil then    
        local layer = createNDUIDialog();
        if layer == nil then
            return false;
        end

        layer:Init();       
        GetUIRoot():AddDlg(layer);
        LoadDlg("dlg_user_skill_intensify_result.xui", layer, nil);
        p.layer = layer;
        p.masterCard = masterCard;
        p.materCardList = materCardList;
        p.allMoney = allMoney;
        p.init();
        p.SetDelegate();
    end

    p.StartReq();
end

function p.init()

	local cardItem = SelectRow(T_SKILL,p.masterCard.skill_id);
    if cardItem == nil then
    	return;
    end

    -- ����icon
    local masterCardIcon = GetImage( p.layer, ui.ID_CTRL_PICTURE_ICON );
    masterCardIcon:SetPicture( user_skill_mgr.GetCardPicture(p.masterCard.skill_id) );

    -- ��������
    local masterCardName = GetLabel( p.layer,ui.ID_CTRL_TEXT_NAME );
    masterCardName:SetText(tostring(cardItem.name));

    -- ϡ�ж�
    local masterCardRare = GetLabel( p.layer,ui.ID_CTRL_TEXT_RATE );
    local rare = string.format("%s:%s",GetStr("user_skill_rate"),tostring(cardItem.rare));
    masterCardRare:SetText(rare);

    -- �ȼ�
    p.masterCardLevel = GetLabel( p.layer,ui.ID_CTRL_TEXT_LV );
    local level = string.format("%s:%s/%s",GetStr("user_skill_level"),tostring(p.masterCard.level),tostring(cardItem.level_max));
    p.masterCardLevel:SetText(level);
    
    -- ����ֵ
    p.masterCardexp = GetLabel( p.layer,ui.ID_CTRL_TEXT_EXP );
    local exp_max = SelectCellMatch( T_SKILL_GROW,"level" , p.masterCard.level, "exp" );
    local exp = string.format("%s:%s/%s",GetStr("user_skill_exp"),tostring(p.masterCard.exp),tostring(exp_max));
    p.masterCardexp:SetText(exp);
    
    -- ��Ǯ
    p.pTextNeedMoney = GetLabel( p.layer, ui.ID_CTRL_TEXT_ANGSTER );
    local needmoney = string.format("%s:%s",GetStr("user_skill_needmoney"),tostring(p.allMoney));
    p.pTextNeedMoney:SetText(needmoney);
    
end


--�����¼�����
function p.SetDelegate(layer)

	p.pBtnBack = GetButton(p.layer,ui.ID_CTRL_BUTTON_BACK);
    p.pBtnBack:SetLuaDelegate(p.OnUIEvent);
    
    p.pBtnContinue = GetButton(p.layer,ui.ID_CTRL_BUTTON_CONTINUE);
    p.pBtnContinue:SetLuaDelegate(p.OnUIEvent);
end

--�¼�����
function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
        if ( ui.ID_CTRL_BUTTON_BACK == tag ) then
        	--����
            p.CloseUI();
        elseif ( ui.ID_CTRL_BUTTON_CONTINUE == tag ) then
        	--����ǿ��
            p.CloseUI();
            dlg_user_skill.ShowUI(SKILL_INTENT_PREVIEW);
		end		
	end
end


-- ǿ�����UI
function p.RefreshUI(msg)

    local level_max = SelectCell( T_SKILL, p.masterCard.skill_id, "level_max" );
    local level = string.format("%s:%s/%s",GetStr("user_skill_level"),tostring(msg.user_skill.level),tostring(level_max));
    p.masterCardLevel:SetText(level);
    
    local exp_max = SelectCellMatch( T_SKILL_GROW,"level" , msg.user_skill.level, "exp" );
    local exp = string.format("%s:%s/%s",GetStr("user_skill_exp"),tostring(msg.user_skill.exp),tostring(exp_max));
    p.masterCardexp:SetText(exp);
    
    -- ǿ��ǰicon
    local iconStart = GetImage( p.layer, ui.ID_CTRL_PICTURE_INTENSIFY_START );
    iconStart:SetPicture( user_skill_mgr.GetCardPicture(msg.user_skill.skill_id) );
    
    -- ǿ����icon
    local iconEnd = GetImage( p.layer, ui.ID_CTRL_PICTURE_INTENSIFY_END );
    iconEnd:SetPicture( user_skill_mgr.GetCardPicture(msg.user_skill.skill_id) );
    
    -- ��ͷicon
    local iconArrow = GetImage( p.layer, ui.ID_CTRL_PICTURE_ARROW );
	iconArrow:SetVisible(true);
    
    -- ǿ��ǰlevel
    local levelStart = GetLabel( p.layer,ui.ID_CTRL_TEXT_RESULT_LEVEL_START );
    levelStart:SetText("LV:"..tostring(p.masterCard.level));
    
    -- ǿ����level
    local levelEnd = GetLabel( p.layer,ui.ID_CTRL_TEXT_RESULT_LEVEL_END );
    levelEnd:SetText("LV:"..tostring(msg.user_skill.level));
    
    -- ��������ֵ
    local expAdd = GetLabel( p.layer,ui.ID_CTRL_TEXT_RESULT_EXP_ADD );
    expAdd:SetText("Exp+"..tostring(msg.upgrade_exp));
    
end

function p.StartReq()

    if p.materCardList == nil or #p.materCardList == 0 then
        WriteCon("StartIntensify():materCardList is null");
        return;
    end

    local materCardIds = "";
    for i=1,#p.materCardList do
        materCardIds = materCardIds..tostring( p.materCardList[i].id);
        if i ~= #p.materCardList then
            materCardIds = materCardIds..",";
        end
    end

    local user_id = GetUID();
    local param = string.format("base_user_skill_id=%d&material_user_skill_ids=%s", p.masterCard.id, materCardIds);
    SendReq( "Skill","Upgrade",user_id,param ); 
    WriteCon("param = "..param);
    
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
        p.masterCard = nil;
        p.materCardList = nil;
        p.allMoney = nil;
        p.pBtnBack = nil;
        p.pBtnContinue = nil;
        p.masterCardLevel = nil;
        p.masterCardexp = nil;
    end
end