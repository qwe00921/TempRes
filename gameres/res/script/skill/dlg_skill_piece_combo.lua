--------------------------------------------------------------
-- FileName: 	dlg_skill_piece_combo.lua
-- author:		zjj, 2013/07/22
-- purpose:		队伍列表界面
--------------------------------------------------------------

dlg_skill_piece_combo = {}
local p = dlg_skill_piece_combo;

p.layer = nil;

p.msg = nil;
p.topbtnlist = {};
p.piecelist = {};
p.skillpieceid = nil;
p.selectpiece = nil;

--显示UI
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

--设置事件处理
function p.SetDelegate(layer)
	--首页按钮
	local topBtn = GetButton(layer,ui_dlg_skill_piece_combo.ID_CTRL_BUTTON_10);
    topBtn:SetLuaDelegate(p.OnSkillPieceComboUIEvent);
	
	--技能碎片合成按钮
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
			--保存选择碎片id
			if piece ~= nil then
				p.skillpieceid = piece.item_id;
				--清除蒙版
				p.clearTopBtn();
				--修改放入图片
				local pieceImg = GetImage(p.layer, ui_dlg_skill_piece_combo.ID_CTRL_PICTURE_5);
				pieceImg:SetPicture( GetPictureByAni("item.skill_piece_icon", btnID-1));
				--修改放入碎片数量
				local pieceNumLab = GetLabel(p.layer,ui_dlg_skill_piece_combo.ID_CTRL_TEXT_NUM);
				pieceNumLab:SetText(tostring(piece.num));
				--修改放入提示
				local tipLab = GetLabel(p.layer,ui_dlg_skill_piece_combo.ID_CTRL_TEXT_TIP);
				tipLab:SetText(tostring(piece.num) .. "/ 5 ");
			end	
			
			--显示蒙版
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

--清除蒙版
function p.clearTopBtn()
	for i=1,#p.topbtnlist do 
		if p.piecelist[i] ~= nil and p.piecelist[i].num ~= 0 then
			p.topbtnlist[i]:SetVisible(false);
		end		
	end	
end

--显示所有蒙版
function p.showTopBtn()
	for i=1,#p.topbtnlist do 
		p.topbtnlist[i]:SetVisible( true );
	end	
end

function p.ReloadData()
	--扣除合成碎片数
	p.piecelist[p.selectpiece].num = p.piecelist[p.selectpiece].num -5;
	--重载碎片列表
	p.ShowPieceList(p.piecelist);
	
	--添加已放入碎片蒙版	
	p.topbtnlist[p.selectpiece]:SetVisible( true );
	--修改放入图片
	local pieceImg = GetImage(p.layer, ui_dlg_skill_piece_combo.ID_CTRL_PICTURE_5);
	pieceImg:SetPicture( GetPictureByAni("item.skill_piece_icon", p.selectpiece-1));
	--修改放入碎片数量
	local pieceNumLab = GetLabel(p.layer,ui_dlg_skill_piece_combo.ID_CTRL_TEXT_NUM);
	pieceNumLab:SetText(tostring(p.piecelist[p.selectpiece].num));
	--修改放入提示
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
	WriteCon("**载入碎片列表**");
	local uid = GetUID();
	if uid == 0 then uid = 100 end; 
	SendReq("Skill","GetSkillItems",uid,"");
end

function p.ReqForCombo()
	WriteCon("**发送合成碎片请求**");
	local uid = GetUID();
	if uid == 0 or uid == nil then
        return ;
    end;
	local param = string.format("&skill_item_id=%d",p.skillpieceid)
	SendReq("Skill","PieceCombine",uid,param);
end

function p.ShowPieceList(piecelist)	
	WriteCon("**显示碎片列表**");
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
		
		--放入碎片按钮
		local btn = GetButton(view, ui_skill_piece_list_view.ID_CTRL_BUTTON_5)
		btn:SetLuaDelegate(p.OnSkillPieceComboUIEvent);
		btn:SetId(i);
		
		--碎片名称
		local lab = GetLabel(view,ui_skill_piece_list_view.ID_CTRL_TEXT_4);
		lab:SetText(string.format("%d "..GetStr("combo_skill_piece_name"), i));
		
		--碎片图标
		local icon = GetImage(view,ui_skill_piece_list_view.ID_CTRL_PICTURE_2);
		icon:SetPicture( GetPictureByAni("item.skill_piece_icon", i-1));
		
		--碎片数量
		local numLab = GetLabel(view,ui_skill_piece_list_view.ID_CTRL_TEXT_NUM);
		numLab:SetText("0");
		
		--点击蒙版
		local top = GetButton(view, ui_skill_piece_list_view.ID_CTRL_BUTTON_6);
		topbtnlist = {};
		p.topbtnlist[i] = top;
		
		--有碎片设置
		if piecelist[i] ~=  nil and piecelist[i].num ~= 0  then
			numLab:SetText( tostring(piecelist[i].num));
			btn:SetDataStr( tostring(piecelist[i].item_id));
			top:SetVisible(false);
		end
	end
end

--设置可见
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

