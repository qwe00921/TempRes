--------------------------------------------------------------
-- FileName: 	dlg_skill_piece_combo_result.lua
-- author:		zjj, 2013/07/22
-- purpose:		卡片融合结果界面
--------------------------------------------------------------

dlg_skill_piece_combo_result = {}
local p = dlg_skill_piece_combo_result;
p.layer = nil;
p.skillcard = nil;


--显示UI
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
	--显示卡牌
	p.ShowSkillCard(skillcard);
	--刷新技能合成界面
	dlg_skill_piece_combo.ReloadData();
end

--设置事件处理
function p.SetDelegate(layer)
	--确定
	local okBtn = GetButton(layer,ui_dlg_skill_piece_combo_result.ID_CTRL_BUTTON_OK);
    okBtn:SetLuaDelegate(p.OnUISkillResult);
end

--送入礼物箱提示
function p.SendToPresentBox()
	dlg_msgbox.ShowOK( ToUtf8("提示"), ToUtf8("卡箱已满，技能卡片已被送入礼物箱"), p.OnMsgBoxCallback , p.layer );
end

--消息框回调
function p.OnMsgBoxCallback( result )
	dlg_skill_piece_combo.SetComboBtnEnabled( true );
end
--事件处理
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
	--技能图标
	local skillPicImg = GetImage(p.layer, ui_dlg_skill_piece_combo_result.ID_CTRL_PICTURE_SKILL_PIC);
    --技能名称
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