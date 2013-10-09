--------------------------------------------------------------
-- FileName: 	dlg_user_skill_detail.lua
-- author:		xyd, 2013��8��12��
-- purpose:		���ܿ�Ƭ��ϸ
--------------------------------------------------------------

dlg_user_skill_detail = {}
local p = dlg_user_skill_detail;
local ui = ui_dlg_user_skill_detail;

p.layer = nil;
p.id = nil;
p.level = nil;
p.masterCard = nil;

function p.ShowUI(masterCard)

    if p.layer == nil then    
        local layer = createNDUIDialog();
        if layer == nil then
            return false;
        end

        layer:Init();       
        GetUIRoot():AddDlg(layer);
        LoadDlg("dlg_user_skill_detail.xui", layer, nil);
        p.layer = layer;
        p.masterCard = masterCard;
        p.init();
        p.SetDelegate();
    end 
end

function p.init()
    
    local cardItem = SelectRow(T_SKILL,p.masterCard.skill_id);
    if cardItem == nil then
    	return;
    end
    
    -- ����icon
    local skill_icon = GetImage( p.layer, ui.ID_CTRL_PICTURE_SKILL_ICON );
    skill_icon:SetPicture( user_skill_mgr.GetCardPicture(p.masterCard.skill_id) );

    -- ��������
    local skill_name = GetLabel( p.layer,ui.ID_CTRL_TEXT_SKILL_NAME );
    skill_name:SetText(tostring(cardItem.name));

    -- ϡ�ж�
    local skill_rare = GetLabel( p.layer,ui.ID_CTRL_TEXT_SKILL_RATE );
    local rare = string.format("%s:%s",GetStr("user_skill_rate"),tostring(cardItem.rare));
    skill_rare:SetText(rare);

    -- �ȼ�
    local skill_level = GetLabel( p.layer,ui.ID_CTRL_TEXT_SKILL_LEVEL );
    local level = string.format("%s:%s/%s",GetStr("user_skill_level"),tostring(p.masterCard.level),tostring(cardItem.level_max));
    skill_level:SetText(level);

    -- ��Ƭ˵��    
    local skill_descript = GetLabel( p.layer,ui.ID_CTRL_TEXT_DESCRIBE )
    skill_descript:SetText(tostring(cardItem.description));
    
    -- ����ֵ
    local skill_exp = GetLabel( p.layer,ui.ID_CTRL_TEXT_SKILL_EXP )
    local needexp = SelectCellMatch( T_SKILL_GROW,"level" , p.masterCard.level, "exp" );
    local exp = string.format("%s:%s/%s",GetStr("user_skill_exp"),tostring(p.masterCard.exp),tostring(needexp));
    skill_exp:SetText(exp);

end

--�����¼�����
function p.SetDelegate(layer)

	local pBtnBack = GetButton(p.layer,ui.ID_CTRL_BUTTON_BACK);
    pBtnBack:SetLuaDelegate(p.OnUIEvent);
    local pBtnEquip = GetButton(p.layer,ui.ID_CTRL_BUTTON_EQUIP);
    pBtnEquip:SetLuaDelegate(p.OnUIEvent);
    local pBtnIntensify = GetButton(p.layer,ui.ID_CTRL_BUTTON_INTENSIFY);
    pBtnIntensify:SetLuaDelegate(p.OnUIEvent);
    
end

--�¼�����
function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
        if ( ui.ID_CTRL_BUTTON_BACK == tag ) then
        	-- ����
            p.CloseUI();
        elseif ( ui.ID_CTRL_BUTTON_EQUIP == tag ) then
        	-- װ��
            WriteCon("װ��");
        elseif ( ui.ID_CTRL_BUTTON_INTENSIFY == tag ) then
        	-- ǿ��
            p.StartIntensify();
		end		
	end
end

-- ��ʼǿ��
function p.StartIntensify()
	dlg_user_skill_intensify.ShowUI(p.masterCard);
    p.CloseUI();
    dlg_user_skill.CloseUI();
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
    end
end