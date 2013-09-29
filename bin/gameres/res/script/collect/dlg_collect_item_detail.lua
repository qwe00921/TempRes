--------------------------------------------------------------
-- FileName: 	dlg_collect_item_detail.lua
-- author:		xyd, 2013��8��12��
-- purpose:		װ��ͼ����ϸ
--------------------------------------------------------------

dlg_collect_item_detail = {}
local p = dlg_collect_item_detail;
local ui = ui_collect_item_detail;

p.layer = nil;
p.masterCard = nil;

p.rareTag = {
	ui.ID_CTRL_PICTURE_RARE1,
	ui.ID_CTRL_PICTURE_RARE2,
	ui.ID_CTRL_PICTURE_RARE3,
	ui.ID_CTRL_PICTURE_RARE4,
	ui.ID_CTRL_PICTURE_RARE5,
	ui.ID_CTRL_PICTURE_RARE6,
	ui.ID_CTRL_PICTURE_RARE7,
};
p.rarePics = {};

function p.ShowUI(masterCard)

    if p.layer == nil then    
        local layer = createNDUIDialog();
        if layer == nil then
            return false;
        end

        layer:Init();       
        GetUIRoot():AddDlg(layer);
        LoadDlg("collect_item_detail.xui", layer, nil);
        p.layer = layer;
        p.masterCard = masterCard;
        p.init();
        p.SetDelegate();
    end 
end

function p.init()
    
    local cardItem = SelectRow(T_ITEM,p.masterCard);
    if cardItem == nil then
    	return;
    end
    
    -- װ��icon
    local equip_icon = GetImage( p.layer, ui.ID_CTRL_PICTURE_EQUIP_NAME );
    equip_icon:SetPicture( collect_mgr.GetCardPicture(p.masterCard,COLLECT_OPTION_EQUIP) );

    -- װ������
    local equip_name = GetLabel( p.layer,ui.ID_CTRL_TEXT_EQUIP_NAME );
    equip_name:SetText(tostring(cardItem.name));

    -- ϡ�ж�
    local rare = tonumber(cardItem.rare);
    for i=1,#p.rareTag do
    	p.rarePics[i] = GetImage( p.layer, p.rareTag[i] );
    end
    p.SetRareStatus(rare);
    

    -- ����
    local hp = GetLabel( p.layer,ui.ID_CTRL_TEXT_HP );
    hp:SetText(tostring(cardItem.add_hp_min));

    -- ����
    local atk = GetLabel( p.layer,ui.ID_CTRL_TEXT_ATK );
    atk:SetText(tostring(cardItem.add_attack_min));
    
    -- ����
    local def = GetLabel( p.layer,ui.ID_CTRL_TEXT_DEF );
    def:SetText(tostring(cardItem.add_defence_min));

    -- ��������   
    local skillName = GetLabel( p.layer,ui.ID_CTRL_TEXT_SKILL_NAME )
    skillName:SetText(tostring(""));
   
   	-- ����˵��
    local skillDescript = GetLabel( p.layer,ui.ID_CTRL_TEXT_SKILL_DESCRIPTION )
    skillDescript:SetText(tostring(""));
    
    -- ��������   
    local equipDescript = GetLabel( p.layer,ui.ID_CTRL_TEXT_EQUIP_DESCRIPT )
    equipDescript:SetText(tostring(cardItem.description));

end

function p.SetRareStatus(rare)

	for i=1,#p.rarePics do
    	if i <= rare then
    		p.rarePics[i]:SetVisible(true);
    	else
    		p.rarePics[i]:SetVisible(false);
    	end
    end
    
end

--�����¼�����
function p.SetDelegate(layer)
	local pBtnBack = GetButton(p.layer,ui.ID_CTRL_BUTTON_BACK);
    pBtnBack:SetLuaDelegate(p.OnUIEvent); 
end

--�¼�����
function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
        if ( ui.ID_CTRL_BUTTON_BACK == tag ) then
        	-- ����
            p.CloseUI();
		end		
	end
end

function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end

function p.CloseUI()	
    if p.layer ~= nil then
    	p.masterCard = nil;
    	p.rarePics = {};
	    p.layer:LazyClose();
        p.layer = nil;
    end
end