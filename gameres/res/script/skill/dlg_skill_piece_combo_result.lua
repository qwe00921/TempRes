--------------------------------------------------------------
-- FileName: 	dlg_skill_piece_combo_result.lua
-- author:		zjj, 2013/07/22
-- purpose:		��Ƭ�ںϽ������
--------------------------------------------------------------

dlg_skill_piece_combo_result = {}
local p = dlg_skill_piece_combo_result;
p.layer = nil;
p.skillcard = nil;


--��ʾUI
function p.ShowUI(skillcard)
	local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end
    
	layer:Init();	
	GetUIRoot():AddDlg(layer);
    LoadDlg("dlg_skill_piece_combo_result.xui", layer, nil);
	
	p.layer = layer;
	p.skillcard = skillcard;
	p.SetDelegate(layer);
	--��ʾ����
	p.ShowSkillCard(skillcard);
	--ˢ�¼��ܺϳɽ���
	dlg_skill_piece_combo.ReloadData();
end

--�����¼�����
function p.SetDelegate(layer)
	--ȷ��
	local okBtn = GetButton(layer,ui_dlg_skill_piece_combo_result.ID_CTRL_BUTTON_OK);
    okBtn:SetLuaDelegate(p.OnUISkillResult);
end

--������������ʾ
function p.SendToPresentBox()
	dlg_msgbox.ShowOK( ToUtf8("��ʾ"), ToUtf8("�������������ܿ�Ƭ�ѱ�����������"), p.OnMsgBoxCallback , p.layer );
end

--��Ϣ��ص�
function p.OnMsgBoxCallback( result )
	dlg_skill_piece_combo.SetComboBtnEnabled( true );
end
--�¼�����
function p.OnUISkillResult(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	WriteCon( "on btn clicked" .. tag );
	if IsClickEvent( uiEventType ) then
        if ( ui_dlg_skill_piece_combo_result.ID_CTRL_BUTTON_OK == tag ) then	
			WriteCon("click team btn");
			dlg_skill_piece_combo.SetComboBtnEnabled( true );
			p.CloseUI();
		end					
	end
end

function p.ShowSkillCard(skillcard)
	if skillcard.is_present then
		p.SendToPresentBox();
	end
	--����ͼ��
	local skillPicImg = GetImage(p.layer, ui_dlg_skill_piece_combo_result.ID_CTRL_PICTURE_SKILL_PIC);
    --��������
    local skillNameLab = GetLabel( p.layer, ui_dlg_skill_piece_combo_result.ID_CTRL_TEXT_SKILL_NAME );
    local skillname = SelectCell( T_SKILL,skillcard.skill_id,"name" );
    skillNameLab:SetText(tostring(skillname));
end

function p.LoadSelectData( card )
	WriteCon("get select card");
	dump_obj(card);
	
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