--------------------------------------------------------------
-- FileName: 	dlg_card_attr.lua
-- author:		hst, 2013/11/26
-- purpose:		������ϸ��Ϣ����
--------------------------------------------------------------
dlg_card_attr = {}
local p = dlg_card_attr;
p.layer = nil;
p.cardID = nil;
function p.ShowUI(cardID)
	WriteCon("**========������ϸ��Ϣ���� SHOWUI========**"..cardID);
	  if cardID == nil then
    	return;
	  end
	p.cardID = cardID;
	 if p.layer ~= nil then
		p.layer:SetVisible( true );
		return;
	end
	local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end
	
	--layer:NoMask();
	layer:Init();	
	GetUIRoot():AddDlg(layer);
    LoadDlg("dlg_card_attr.xui", layer, nil);
	p.layer = layer;
    p.SetDelegate(layer,cardID);
end

function p.SetDelegate(layer)
	
	
	
	T_CHAR_RES     = LoadTable( "char_res.ini" );
	local pCardInfo= SelectRowInner( T_CHAR_RES, "card_id", p.cardID); --�ӱ��л�ȡ������ϸ��Ϣ	
	if pCardInfo ==nil then
		WriteCon("**====pCardInfo == nil ====**"..cardID);
	end
	--����
    local pBtnBack = GetButton(layer,ui_dlg_card_attr.ID_CTRL_BUTTON_BACK);
    pBtnBack:SetLuaDelegate(p.OnUIEventEvolution);
	--�츳����1
	local pBtnDower1 = GetButton(layer,ui_dlg_card_attr.ID_CTRL_BUTTON_PICTURE_1);
	--�츳����2
	local pBtnDower2 = GetButton(layer,ui_dlg_card_attr.ID_CTRL_BUTTON_PICTURE_2);
	--�츳����3
	local pBtnDower3 = GetButton(layer,ui_dlg_card_attr.ID_CTRL_BUTTON_PICTURE_3);
	--��Ϊû�����������ȸ�Ϊ ~=nil 
	if pCardInfo.dower_intro_1 ~= nil then 
		pBtnDower1:SetVisible(false);
		pBtnDower2:SetVisible(false);
		pBtnDower3:SetVisible(false);
	else
		pBtnDower1:SetImage(GetPictureByAni(pCardInfo.dower_pic_1,0))
		pBtnDower1:SetLuaDelegate(p.OnUIEventEvolution);
		if pCardInfo.dower_intro_2 == nil then 
			pBtnDower2:SetVisible(false);
			pBtnDower3:SetVisible(false);
		else
			pBtnDower2:SetImage(GetPictureByAni(pCardInfo.dower_pic_2,0))
			pBtnDower2:SetLuaDelegate(p.OnUIEventEvolution);
			if pCardInfo.dower_intro_3 == nil then 
				pBtnDower3:SetVisible(false);
			else
				pBtnDower3:SetImage(GetPictureByAni(pCardInfo.dower_pic_3,0))
				pBtnDower3:SetLuaDelegate(p.OnUIEventEvolution);
			end
		end
	end
	
	--����ͼƬ
	local pImgCardPic = GetImage(layer, ui_dlg_card_attr.ID_CTRL_PICTURE); --����ͼƬ�ؼ�
	local pImage = GetPictureByAni(pCardInfo.card_pic,0)--����ͼƬ
	pImgCardPic:SetPicture(pImage);
	--���
	T_CHAR    = LoadTable( "card.ini" );
	local pFromCardInfo= SelectRowInner( T_CHAR, "id", p.cardID); --�ӱ��л�ȡ������ϸ��Ϣ	
	local pLabCardIntro = GetLabel(layer,ui_dlg_card_attr.ID_CTRL_INTRO);
	pLabCardIntro:SetText(ToUtf8(pFromCardInfo.description));
	--�츳����
	local pLabDowerIntro = GetLabel(layer,ui_dlg_card_attr.ID_CTRL_DOWER_INTRO);
	if pCardInfo.dower_intro_1 ~= nil then 
		pLabDowerIntro:SetText(tostring(pCardInfo.dower_intro_1));
	end
	--Ե��
	local pLabLuckIntro = GetLabel(layer,ui_dlg_card_attr.ID_CTRL_LUCK_INTRO);
	pLabLuckIntro:SetText(tostring(pCardInfo.luck_intro));
	
	
end


function p.OnUIEventEvolution(uiNode, uiEventType, param)
	
	T_CHAR_RES     = LoadTable( "char_res.ini" );
	local pCardInfo= SelectRowInner( T_CHAR_RES, "card_id", p.cardID); --�ӱ��л�ȡ������ϸ��Ϣ	
	local pLabDowerIntro = GetLabel(p.layer,ui_dlg_card_attr.ID_CTRL_DOWER_INTRO);
	
	if IsClickEvent( uiEventType ) then
	    local tag = uiNode:GetTag();
		if ui_dlg_card_attr.ID_CTRL_BUTTON_BACK == tag then
			p.CloseUI();
		elseif ui_dlg_card_attr.ID_CTRL_BUTTON_PICTURE_1 == tag then
			pLabDowerIntro:SetText(tostring(pCardInfo.dower_intro_1));
		elseif ui_dlg_card_attr.ID_CTRL_BUTTON_PICTURE_2 == tag then
			pLabDowerIntro:SetText(tostring(pCardInfo.dower_intro_2));
		elseif ui_dlg_card_attr.ID_CTRL_BUTTON_PICTURE_3 == tag then
			pLabDowerIntro:SetText(tostring(pCardInfo.dower_intro_3));
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
		p.cardID = nil;
	    p.layer:LazyClose();
        p.layer = nil;
    end
    
end