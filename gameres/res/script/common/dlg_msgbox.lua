--------------------------------------------------------------
-- FileName: 	dlg_msgbox.lua
-- author:		zjj, 2013/07/22
-- purpose:		ͨ����ʾ�Ի���
--------------------------------------------------------------

dlg_msgbox = {}
local p = dlg_msgbox;

p.layer = nil;
p.OKBtn = nil;
p.YesBtn = nil;
p.NoBtn = nil;

p.OKPic = nil;
p.YesPic = nil;
p.NoPic = nil;

p.caption = nil;
p.text = nil;
p.delegate = nil;
p.parent = nil;

local TYPE_YESNO = 1;
local TYPE_OK = 2;

--��ʾUI
function p.ShowYesNo(caption, text, delegate, parent)
	p.ShowInner( TYPE_YESNO, caption, text, delegate, parent);
end

function p.ShowOK(caption, text, delegate,parent)
	p.ShowInner( TYPE_OK, caption, text, delegate, parent );    
end

function p.ShowInner( showType, caption, text, delegate, parent )
    
	p.parent = parent;
	p.CreateDlg();
	p.caption = caption;
	p.text = text;
	p.delegate = delegate;
	p.Init();
	
	--1����YesNo�ͺ�, 2����OK�ͺ�
	p.YesBtn:SetVisible	( showType == TYPE_YESNO );
	p.NoBtn:SetVisible	( showType == TYPE_YESNO );	
	p.OKBtn:SetVisible	( showType == TYPE_OK );	
	
	p.YesPic:SetVisible	( showType == TYPE_YESNO );
	p.NoPic:SetVisible	( showType == TYPE_YESNO );	
	p.OKPic:SetVisible	( showType == TYPE_OK );	
end

--�����Ի���
function p.CreateDlg()
    if p.layer == nil then
		local layer = createNDUIDialog();
		if layer == nil then
			return false;
		end
		
		layer:NoMask()
		layer:Init();
		GetUIRoot():AddDlg(layer);
		LoadDlg("dlg_msgbox.xui", layer, nil);
		
		p.layer = layer;
		p.SetDelegate(p.layer);
	end
	return p.layer;
end

function p.SetDelegate(layer)
	--OK��ť
	p.OKBtn = GetButton(layer, ui_dlg_msgbox.ID_CTRL_BUTTON_OK);
    p.OKBtn:SetLuaDelegate(p.OnClick);
	
	--Yes��ť
	p.YesBtn = GetButton(layer, ui_dlg_msgbox.ID_CTRL_BUTTON_YES);
    p.YesBtn:SetLuaDelegate(p.OnClick);
	
	--No��ť
	p.NoBtn = GetButton(layer, ui_dlg_msgbox.ID_CTRL_BUTTON_NO);
    p.NoBtn:SetLuaDelegate(p.OnClick);
	
	p.OKPic = GetImage(layer, ui_dlg_msgbox.ID_CTRL_PICTURE_OK);
	p.YesPic = GetImage(layer, ui_dlg_msgbox.ID_CTRL_PICTURE_YES);
	p.NoPic = GetImage(layer, ui_dlg_msgbox.ID_CTRL_PICTURE_NO);
end

--�����ı�
function p.Init()
	local titleLbl = GetLabel(p.layer, ui_dlg_msgbox.ID_CTRL_TEXT_2);
	titleLbl:SetText(tostring(p.caption));
	
	local msgLbl = GetLabel(p.layer, ui_dlg_msgbox.ID_CTRL_TEXT_3);
	msgLbl:SetText(tostring(p.text));
end

--�������
function p.OnClick(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
		if ( ui_dlg_msgbox.ID_CTRL_BUTTON_OK == tag ) then	
			p.CloseUI();
			if p.delegate ~= nil then
			    p.delegate( true );
            end
			
		elseif ( ui_dlg_msgbox.ID_CTRL_BUTTON_YES == tag ) then
			p.CloseUI();
			if p.delegate ~= nil then
			    p.delegate( true );
			end
			
		elseif ( ui_dlg_msgbox.ID_CTRL_BUTTON_NO == tag ) then
			p.CloseUI();
			if p.delegate ~= nil then
			    p.delegate( false );
			end
		end
	end
end

--����UI
function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end

--�ر�UI
function p.CloseUI()
	if p.layer ~= nil then
	    p.layer:LazyClose();
        p.layer = nil;
    end
end

