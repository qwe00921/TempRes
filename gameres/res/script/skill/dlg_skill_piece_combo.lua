--------------------------------------------------------------
-- FileName: 	dlg_skill_piece_combo.lua
-- author:		zjj, 2013/07/22
-- purpose:		�����б����
--------------------------------------------------------------

dlg_skill_piece_combo = {}
local p = dlg_skill_piece_combo;

p.layer = nil;

p.msg = nil;
p.topbtnlist = {};
p.piecelist = {};
p.skillpieceid = nil;
p.selectpiece = nil;

--��ʾUI
function p.ShowUI()
    
    if p.layer ~= nil then
		p.layer:SetVisible( true );
		return;
	end
	
	local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end
	
	layer:Init();	
	GetUIRoot():AddDlg(layer);
    LoadDlg("dlg_skill_piece_combo.xui", layer, nil);
	
	p.SetDelegate(layer);
	p.layer = layer;
	p.LoadSkillPieceData();
end

--�����¼�����
function p.SetDelegate(layer)
	--��ҳ��ť
	local topBtn = GetButton(layer,ui_dlg_skill_piece_combo.ID_CTRL_BUTTON_10);
    topBtn:SetLuaDelegate(p.OnSkillPieceComboUIEvent);
	
	--������Ƭ�ϳɰ�ť
	local comboBtn = GetButton(layer,ui_dlg_skill_piece_combo.ID_CTRL_BUTTON_7);
    comboBtn:SetLuaDelegate(p.OnSkillPieceComboUIEvent);
	comboBtn:SetEnabled( false );

end

function p.OnSkillPieceComboUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
		if ( ui_skill_piece_list_view.ID_CTRL_BUTTON_5 == tag ) then	
			local btnID = uiNode:GetId();
			local piece = p.piecelist[btnID];
			p.selectpiece = btnID;
			--����ѡ����Ƭid
			if piece ~= nil then
				p.skillpieceid = piece.item_id;
				--����ɰ�
				p.clearTopBtn();
				--�޸ķ���ͼƬ
				local pieceImg = GetImage(p.layer, ui_dlg_skill_piece_combo.ID_CTRL_PICTURE_5);
				pieceImg:SetPicture( GetPictureByAni("item.skill_piece_icon", btnID-1));
				--�޸ķ�����Ƭ����
				local pieceNumLab = GetLabel(p.layer,ui_dlg_skill_piece_combo.ID_CTRL_TEXT_NUM);
				pieceNumLab:SetText(tostring(piece.num));
				--�޸ķ�����ʾ
				local tipLab = GetLabel(p.layer,ui_dlg_skill_piece_combo.ID_CTRL_TEXT_TIP);
				tipLab:SetText(tostring(piece.num) .. "/ 5 ");
			end	
			
			--��ʾ�ɰ�
			local topbtn = GetButton(uiNode:GetParent(), ui_skill_piece_list_view.ID_CTRL_BUTTON_6);
			topbtn:SetVisible(true);
			WriteCon("put pieces in" .. btnID );
			
			p.SetComboBtnEnabled( true );
						
		elseif ( ui_dlg_skill_piece_combo.ID_CTRL_BUTTON_7 == tag ) then
			WriteCon("start combo ");
			p.SetComboBtnEnabled( false );
			p.showTopBtn();
			p.ReqForCombo();
			
		elseif ( ui_dlg_skill_piece_combo.ID_CTRL_BUTTON_11 == tag ) then
			WriteCon("To top UI");
			--task_map_mainui.ShowUI();
			p.CloseUI();
			
		elseif ( ui_dlg_skill_piece_combo.ID_CTRL_BUTTON_10 == tag ) then
			WriteCon("back to questUI");
			--task_map_mainui.ShowUI();
			p.CloseUI();
		end				
	end
end

--����ɰ�
function p.clearTopBtn()
	for i=1,#p.topbtnlist do 
		if p.piecelist[i] ~= nil and p.piecelist[i].num ~= 0 then
			p.topbtnlist[i]:SetVisible(false);
		end		
	end	
end

--��ʾ�����ɰ�
function p.showTopBtn()
	for i=1,#p.topbtnlist do 
		p.topbtnlist[i]:SetVisible( true );
	end	
end

function p.ReloadData()
	--�۳��ϳ���Ƭ��
	p.piecelist[p.selectpiece].num = p.piecelist[p.selectpiece].num -5;
	--������Ƭ�б�
	p.ShowPieceList(p.piecelist);
	
	--����ѷ�����Ƭ�ɰ�	
	p.topbtnlist[p.selectpiece]:SetVisible( true );
	--�޸ķ���ͼƬ
	local pieceImg = GetImage(p.layer, ui_dlg_skill_piece_combo.ID_CTRL_PICTURE_5);
	pieceImg:SetPicture( GetPictureByAni("item.skill_piece_icon", p.selectpiece-1));
	--�޸ķ�����Ƭ����
	local pieceNumLab = GetLabel(p.layer,ui_dlg_skill_piece_combo.ID_CTRL_TEXT_NUM);
	pieceNumLab:SetText(tostring(p.piecelist[p.selectpiece].num));
	--�޸ķ�����ʾ
	local tipLab = GetLabel(p.layer,ui_dlg_skill_piece_combo.ID_CTRL_TEXT_TIP);
	tipLab:SetText(tostring(p.piecelist[p.selectpiece].num) .. "/ 5 ");
	
end

function p.SetComboBtnEnabled( bEnabled )
	local comboBtn = GetButton(p.layer,ui_dlg_skill_piece_combo.ID_CTRL_BUTTON_7);
	if comboBtn ~= nil then
		    comboBtn:SetEnabled( bEnabled );
	end

end
function p.LoadSkillPieceData()
	WriteCon("**������Ƭ�б�**");
	local uid = GetUID();
	if uid == 0 then uid = 100 end; 
	SendReq("Skill","GetSkillItems",uid,"");
end

function p.ReqForCombo()
	WriteCon("**���ͺϳ���Ƭ����**");
	local uid = GetUID();
	if uid == 0 or uid == nil then
        return ;
    end;
	local param = string.format("&skill_item_id=%d",p.skillpieceid)
	SendReq("Skill","PieceCombine",uid,param);
end

function p.ShowPieceList(piecelist)	
	WriteCon("**��ʾ��Ƭ�б�**");
	p.piecelist = piecelist;
	local list = GetListBoxVert(p.layer,ui_dlg_skill_piece_combo.ID_CTRL_VERTICAL_LIST_2);
	list:ClearView();

	for i = 1,7 do
		local view = createNDUIXView();
		view:Init();
		LoadUI("skill_piece_list_view.xui", view, nil);

		local bg = GetUiNode(view,ui_skill_piece_list_view.ID_CTRL_9SLICES_BG);
		view:SetViewSize( bg:GetFrameSize());
		list:AddView(view);
		
		--������Ƭ��ť
		local btn = GetButton(view, ui_skill_piece_list_view.ID_CTRL_BUTTON_5)
		btn:SetLuaDelegate(p.OnSkillPieceComboUIEvent);
		btn:SetId(i);
		
		--��Ƭ����
		local lab = GetLabel(view,ui_skill_piece_list_view.ID_CTRL_TEXT_4);
		lab:SetText(string.format("%d "..GetStr("combo_skill_piece_name"), i));
		
		--��Ƭͼ��
		local icon = GetImage(view,ui_skill_piece_list_view.ID_CTRL_PICTURE_2);
		icon:SetPicture( GetPictureByAni("item.skill_piece_icon", i-1));
		
		--��Ƭ����
		local numLab = GetLabel(view,ui_skill_piece_list_view.ID_CTRL_TEXT_NUM);
		numLab:SetText("0");
		
		--����ɰ�
		local top = GetButton(view, ui_skill_piece_list_view.ID_CTRL_BUTTON_6);
		topbtnlist = {};
		p.topbtnlist[i] = top;
		
		--����Ƭ����
		if piecelist[i] ~=  nil and piecelist[i].num ~= 0  then
			numLab:SetText( tostring(piecelist[i].num));
			btn:SetDataStr( tostring(piecelist[i].item_id));
			top:SetVisible(false);
		end
	end
end

--���ÿɼ�
function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end


function p.CloseUI()
	if p.layer ~= nil then
	    p.layer:LazyClose();
        p.layer = nil;
        p.topbtnlist = {};
    end

end

