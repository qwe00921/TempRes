--------------------------------------------------------------
-- FileName: 	dlg_user_skill_intensify_result.lua
-- author:		xyd, 2013年8月13日
-- purpose:		强化完成界面
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

    -- 技能icon
    local masterCardIcon = GetImage( p.layer, ui.ID_CTRL_PICTURE_ICON );
    masterCardIcon:SetPicture( user_skill_mgr.GetCardPicture(p.masterCard.skill_id) );

    -- 技能名称
    local masterCardName = GetLabel( p.layer,ui.ID_CTRL_TEXT_NAME );
    masterCardName:SetText(tostring(cardItem.name));

    -- 稀有度
    local masterCardRare = GetLabel( p.layer,ui.ID_CTRL_TEXT_RATE );
    local rare = string.format("%s:%s",GetStr("user_skill_rate"),tostring(cardItem.rare));
    masterCardRare:SetText(rare);

    -- 等级
    p.masterCardLevel = GetLabel( p.layer,ui.ID_CTRL_TEXT_LV );
    local level = string.format("%s:%s/%s",GetStr("user_skill_level"),tostring(p.masterCard.level),tostring(cardItem.level_max));
    p.masterCardLevel:SetText(level);
    
    -- 经验值
    p.masterCardexp = GetLabel( p.layer,ui.ID_CTRL_TEXT_EXP );
    local exp_max = SelectCellMatch( T_SKILL_GROW,"level" , p.masterCard.level, "exp" );
    local exp = string.format("%s:%s/%s",GetStr("user_skill_exp"),tostring(p.masterCard.exp),tostring(exp_max));
    p.masterCardexp:SetText(exp);
    
    -- 金钱
    p.pTextNeedMoney = GetLabel( p.layer, ui.ID_CTRL_TEXT_ANGSTER );
    local needmoney = string.format("%s:%s",GetStr("user_skill_needmoney"),tostring(p.allMoney));
    p.pTextNeedMoney:SetText(needmoney);
    
end


--设置事件处理
function p.SetDelegate(layer)

	p.pBtnBack = GetButton(p.layer,ui.ID_CTRL_BUTTON_BACK);
    p.pBtnBack:SetLuaDelegate(p.OnUIEvent);
    
    p.pBtnContinue = GetButton(p.layer,ui.ID_CTRL_BUTTON_CONTINUE);
    p.pBtnContinue:SetLuaDelegate(p.OnUIEvent);
end

--事件处理
function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
        if ( ui.ID_CTRL_BUTTON_BACK == tag ) then
        	--返回
            p.CloseUI();
        elseif ( ui.ID_CTRL_BUTTON_CONTINUE == tag ) then
        	--继续强化
            p.CloseUI();
            dlg_user_skill.ShowUI(SKILL_INTENT_PREVIEW);
		end		
	end
end


-- 强化结果UI
function p.RefreshUI(msg)

    local level_max = SelectCell( T_SKILL, p.masterCard.skill_id, "level_max" );
    local level = string.format("%s:%s/%s",GetStr("user_skill_level"),tostring(msg.user_skill.level),tostring(level_max));
    p.masterCardLevel:SetText(level);
    
    local exp_max = SelectCellMatch( T_SKILL_GROW,"level" , msg.user_skill.level, "exp" );
    local exp = string.format("%s:%s/%s",GetStr("user_skill_exp"),tostring(msg.user_skill.exp),tostring(exp_max));
    p.masterCardexp:SetText(exp);
    
    -- 强化前icon
    local iconStart = GetImage( p.layer, ui.ID_CTRL_PICTURE_INTENSIFY_START );
    iconStart:SetPicture( user_skill_mgr.GetCardPicture(msg.user_skill.skill_id) );
    
    -- 强化后icon
    local iconEnd = GetImage( p.layer, ui.ID_CTRL_PICTURE_INTENSIFY_END );
    iconEnd:SetPicture( user_skill_mgr.GetCardPicture(msg.user_skill.skill_id) );
    
    -- 箭头icon
    local iconArrow = GetImage( p.layer, ui.ID_CTRL_PICTURE_ARROW );
	iconArrow:SetVisible(true);
    
    -- 强化前level
    local levelStart = GetLabel( p.layer,ui.ID_CTRL_TEXT_RESULT_LEVEL_START );
    levelStart:SetText("LV:"..tostring(p.masterCard.level));
    
    -- 强化后level
    local levelEnd = GetLabel( p.layer,ui.ID_CTRL_TEXT_RESULT_LEVEL_END );
    levelEnd:SetText("LV:"..tostring(msg.user_skill.level));
    
    -- 经验增长值
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