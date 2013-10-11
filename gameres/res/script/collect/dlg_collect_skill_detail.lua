--------------------------------------------------------------
-- FileName: 	dlg_collect_skill_detail.lua
-- author:		xyd, 2013��8��12��
-- purpose:		���ܿ���ͼ����ϸ
--------------------------------------------------------------

dlg_collect_skill_detail = {}
local p = dlg_collect_skill_detail;
local ui = ui_collect_skill_detail;

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
        LoadDlg("collect_skill_detail.xui", layer, nil);
        p.layer = layer;
        p.masterCard = masterCard;
        p.init();
        p.SetDelegate();
    end 
end

function p.init()
    
    local cardItem = SelectRow(T_SKILL,p.masterCard.collect_id);
    if cardItem == nil then
    	return;
    end
    
    -- ���ܿ�Ƭicon
    local skill_icon = GetImage( p.layer, ui.ID_CTRL_PICTURE_SKILL_ICON );
    skill_icon:SetPicture( collect_mgr.GetCardPicture(p.masterCard.collect_id) );

    -- ��������
    local skill_name = GetLabel( p.layer,ui.ID_CTRL_TEXT_SKILL_NAME );
    skill_name:SetText(tostring(cardItem.name));

    -- ϡ�ж�
    local rare = tonumber(cardItem.rare);
    for i=1,#p.rareTag do
    	p.rarePics[i] = GetImage( p.layer, p.rareTag[i] );
    end
    p.SetRareStatus(rare);
    
    -- ��������   
    local skillDescript = GetLabel( p.layer,ui.ID_CTRL_TEXT_SKILL_DESCRIPT )
    skillDescript:SetText(tostring(cardItem.description));

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