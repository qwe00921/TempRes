--------------------------------------------------------------
-- FileName:    dlg_collect_mainui.lua
-- author:      xyd, 2013/09/11
-- purpose:     ͼ��������
--------------------------------------------------------------

dlg_collect_mainui = {}
local p = dlg_collect_mainui;
local ui = ui_dlg_collect_mainui;
local ui_pet = ui_collect_pet_view;
local ui_equip = ui_collect_item_view;
local ui_skill = ui_collect_skill_view;

p.layer = nil;
p.cur_option = nil;								--��ǰѡ��

--����ͼ��
p.petBtnCategorys = {};
p.petCategorys = {
	ui.ID_CTRL_BUTTON_DRAGON,					--��
	ui.ID_CTRL_BUTTON_DEMON,					--��ħ
	ui.ID_CTRL_BUTTON_NATURE,					--��Ȼ
	ui.ID_CTRL_BUTTON_ANIMAL,					--����
	ui.ID_CTRL_BUTTON_FLY,						--����
	ui.ID_CTRL_BUTTON_PLANT,					--ֲ��
	ui.ID_CTRL_BUTTON_MATTER					--����
};
--װ��ͼ��
p.equipCategorys = {
	ui.ID_CTRL_BUTTON_WEAPON,					--����
	ui.ID_CTRL_BUTTON_ARMOR,					--����
	ui.ID_CTRL_BUTTON_ACC						--��Ʒ
};
p.equipBtnCategorys = {};

--��ɫ����
p.skillCategorys = {
	ui.ID_CTRL_BUTTON_ACTIVE_SKILL,				--��������
	ui.ID_CTRL_BUTTON_PASSIVE_SKILL				--��������
};
p.skillBtnCategorys = {};

p.listBox = nil;								--�����б�����
p.collectType = nil;							--ͼ����ǰ��������
p.collectNum = nil;								--��ǰͼ������
p.collectEfficiency = nil;						--�ռ���

function p.ShowUI()

	if p.layer == nil then
		local layer = createNDUIDialog();
		if layer == nil then
			return false;
		end
		layer:Init();
		GetUIRoot():AddDlg(layer);
		LoadDlg("dlg_collect_mainui.xui", layer, nil);
		p.layer = layer;
		p.Init();
		p.SetDelegate();
		--SetTimerOnce( collect_mgr.LoadCard, 0.5f );
	end
end

function p.Init()
	p.cur_option = COLLECT_OPTION_PET;
	p.listBox = GetListBoxVert(p.layer ,ui.ID_CTRL_VERTICAL_LIST_CONTENT);
	p.collectType = GetLabel( p.layer,ui.ID_CTRL_TEXT_COLLECT_TYPE );
	p.collectNum = GetLabel( p.layer,ui.ID_CTRL_TEXT_COLLECT_NUM );
	p.collectEfficiency = GetLabel( p.layer,ui.ID_CTRL_TEXT_EFFICIENCY );
end

function p.SetDelegate()

	--����ͼ��
	local btnPet = GetButton(p.layer,ui.ID_CTRL_BUTTON_PET);
	btnPet:SetLuaDelegate(p.OnUIEventCollect);
	
	--װ��ͼ��
	local btnEquip = GetButton(p.layer,ui.ID_CTRL_BUTTON_EQUIPMENT);
	btnEquip:SetLuaDelegate(p.OnUIEventCollect);
	
	--��ɫ����
	local btnSkill = GetButton(p.layer,ui.ID_CTRL_BUTTON_SKILL);
	btnSkill:SetLuaDelegate(p.OnUIEventCollect);

	--����
	local btnBack = GetButton(p.layer,ui.ID_CTRL_BUTTON_BACK);
	btnBack:SetLuaDelegate(p.OnUIEventCollect);
	
	--ȫ��
	local btnAll = GetButton(p.layer,ui.ID_CTRL_BUTTON_ALL);
	btnAll:SetLuaDelegate(p.OnUIEventCollect);
	
	--����ͼ����ť����
	for i=1,#p.petCategorys do
		local btn = GetButton(p.layer,p.petCategorys[i]);
		btn:SetLuaDelegate(p.OnUIEventCollect);
		p.petBtnCategorys[i] = btn;
	end
	
	--װ��ͼ����ť����
	for i=1,#p.equipCategorys do
		local btn = GetButton(p.layer,p.equipCategorys[i]);
		btn:SetLuaDelegate(p.OnUIEventCollect);
		p.equipBtnCategorys[i] = btn;
	end
	
	--��ɫ���ܰ�ť����
	for i=1,#p.skillCategorys do
		local btn = GetButton(p.layer,p.skillCategorys[i]);
		btn:SetLuaDelegate(p.OnUIEventCollect);
		p.skillBtnCategorys[i] = btn;
	end
	
	-- ���ð�ť��ʾ״̬
	p.SetBtnStatus();
end

function p.SetBtnStatus()
	if COLLECT_OPTION_PET == p.cur_option then
		--����ͼ��
		p.SetPetBtnStatus(true);
		p.SetEquipBtnStatus(false);
		p.SetSkillBtnStatus(false);
	elseif COLLECT_OPTION_EQUIP == p.cur_option then
		--װ��ͼ��
		p.SetPetBtnStatus(false);
		p.SetEquipBtnStatus(true);
		p.SetSkillBtnStatus(false);
	elseif COLLECT_OPTION_SKILL == p.cur_option then
		--��ɫ����
		p.SetPetBtnStatus(false);
		p.SetEquipBtnStatus(false);
		p.SetSkillBtnStatus(true);
	end
end

-- ���ó���ͼ����ť״̬
function p.SetPetBtnStatus(flag)
	for i=1,#p.petBtnCategorys do
		p.petBtnCategorys[i]:SetVisible(flag);
	end
end

-- ����װ��ͼ����ť״̬
function p.SetEquipBtnStatus(flag)
	for i=1,#p.equipBtnCategorys do
		p.equipBtnCategorys[i]:SetVisible(flag);
	end
end

-- ���ý�ɫ���ܰ�ť״̬
function p.SetSkillBtnStatus(flag)
	for i=1,#p.skillBtnCategorys do
		p.skillBtnCategorys[i]:SetVisible(flag);
	end
end


--�¼�����
function p.OnUIEventCollect(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
		if ( ui.ID_CTRL_BUTTON_BACK == tag ) then
			-- ����
			p.CloseUI();
		elseif ( ui.ID_CTRL_BUTTON_PET == tag ) then
			-- ����ͼ��
			WriteCon("����ͼ��");
			collect_mgr.LoadCardByCategory(COLLECT_OPTION_PET);
			p.cur_option = COLLECT_OPTION_PET;
			p.SetBtnStatus();
		elseif ( ui.ID_CTRL_BUTTON_EQUIPMENT == tag ) then
			-- װ��ͼ��
			WriteCon("װ��ͼ��");
			collect_mgr.LoadCardByCategory(COLLECT_OPTION_EQUIP);
			p.cur_option = COLLECT_OPTION_EQUIP;
			p.SetBtnStatus();
		elseif ( ui.ID_CTRL_BUTTON_SKILL == tag ) then
			-- ��ɫ����
			WriteCon("��ɫ����");
			collect_mgr.LoadCardByCategory(COLLECT_OPTION_SKILL);
			p.cur_option = COLLECT_OPTION_SKILL;
			p.SetBtnStatus();
		elseif ( ui.ID_CTRL_BUTTON_ALL == tag ) then
			-- ȫ��
			WriteCon("ȫ��");
		elseif ( ui.ID_CTRL_BUTTON_DRAGON == tag ) then
			-- ��
			WriteCon("��");
			collect_mgr.LoadCardByChildCategory(COLLECT_OPTION_PET,COLLECT_PET_DRAGON);
		elseif ( ui.ID_CTRL_BUTTON_DEMON == tag ) then
			-- ��ħ
			WriteCon("��ħ");
			collect_mgr.LoadCardByChildCategory(COLLECT_OPTION_PET,COLLECT_PET_DEMON);
		elseif ( ui.ID_CTRL_BUTTON_NATURE == tag ) then
			-- ��Ȼ
			WriteCon("��Ȼ");
			collect_mgr.LoadCardByChildCategory(COLLECT_OPTION_PET,COLLECT_PET_NATURE);
		elseif ( ui.ID_CTRL_BUTTON_ANIMAL == tag ) then
			-- ����
			WriteCon("����");
			collect_mgr.LoadCardByChildCategory(COLLECT_OPTION_PET,COLLECT_PET_ANIMAL);
		elseif ( ui.ID_CTRL_BUTTON_FLY == tag ) then
			-- ����
			WriteCon("����");
			collect_mgr.LoadCardByChildCategory(COLLECT_OPTION_PET,COLLECT_PET_FLY);
		elseif ( ui.ID_CTRL_BUTTON_PLANT == tag ) then
			-- ֲ��
			WriteCon("ֲ��");
			collect_mgr.LoadCardByChildCategory(COLLECT_OPTION_PET,COLLECT_PET_PLANT);
		elseif ( ui.ID_CTRL_BUTTON_MATTER == tag ) then
			-- ����
			WriteCon("����");
			collect_mgr.LoadCardByChildCategory(COLLECT_OPTION_PET,COLLECT_PET_MATTER);
		elseif ( ui.ID_CTRL_BUTTON_WEAPON == tag ) then
			-- ����
			WriteCon("����");
			collect_mgr.LoadCardByChildCategory(COLLECT_OPTION_EQUIP,COLLECT_EQUIP_WEAPON);
		elseif ( ui.ID_CTRL_BUTTON_ARMOR == tag ) then
			-- ����
			WriteCon("����");
			collect_mgr.LoadCardByChildCategory(COLLECT_OPTION_EQUIP,COLLECT_EQUIP_ARMOR);
		elseif ( ui.ID_CTRL_BUTTON_ACC == tag ) then
			-- ��Ʒ
			WriteCon("��Ʒ");
			collect_mgr.LoadCardByChildCategory(COLLECT_OPTION_EQUIP,COLLECT_EQUIP_ACC);
		elseif ( ui.ID_CTRL_BUTTON_ACTIVE_SKILL == tag ) then
			-- ��������
			WriteCon("��������");
			collect_mgr.LoadCardByChildCategory(COLLECT_OPTION_SKILL,COLLECT_SKILL_ACTIVE);
		elseif ( ui.ID_CTRL_BUTTON_PASSIVE_SKILL == tag ) then
			-- ��������
			WriteCon("��������");
			collect_mgr.LoadCardByChildCategory(COLLECT_OPTION_SKILL,COLLECT_SKILL_PASSIVE);
		end
	end
end


--��ʾ�����б�
function p.ShowCardList( cardList, category , childCategory)
	
	--���±���
	p.SetTitleText(cardList,category,childCategory);
	p.listBox:ClearView();
	if cardList == nil or #cardList <= 0 then
		WriteCon("ShowCardList():cardList is null");
		return ;
	end

	local listLenght = #cardList;
	local row = math.ceil(listLenght / 4);
	for i = 1,row do
		local view = p.CreateScrollView();
		local start_index = (i-1)*4+1;
		local end_index = start_index + 3;
		--�����б�����Ϣ��һ�����ſ���
		for j = start_index,end_index do
			if j <= listLenght then
				if COLLECT_OPTION_PET == p.cur_option then
					p.SetItemInfo( view, cardList[j], end_index - j, ui_pet );
				elseif COLLECT_OPTION_EQUIP == p.cur_option then
					p.SetItemInfo( view, cardList[j], end_index - j, ui_equip );
				elseif COLLECT_OPTION_SKILL == p.cur_option then
					p.SetItemInfo( view, cardList[j], end_index - j, ui_skill );
				end
			end
		end
		p.listBox:AddView( view );
	end

end

-- ����������ͼ
function p.CreateScrollView()

	local view = createNDUIXView();
	view:Init();
	if COLLECT_OPTION_PET == p.cur_option then
		--����ͼ��
		LoadUI( "collect_pet_view.xui", view, nil );
		view:SetViewSize( GetUiNode( view, ui_pet.ID_CTRL_PICTURE_25 ):GetFrameSize());
	elseif COLLECT_OPTION_EQUIP == p.cur_option then
		--װ��ͼ��
		LoadUI( "collect_item_view.xui", view, nil );
		view:SetViewSize( GetUiNode( view, ui_equip.ID_CTRL_PICTURE_25 ):GetFrameSize());
	elseif COLLECT_OPTION_SKILL == p.cur_option then
		--��ɫ����
		LoadUI( "collect_skill_view.xui", view, nil );
		view:SetViewSize( GetUiNode( view, ui_skill.ID_CTRL_PICTURE_25 ):GetFrameSize());
	end
	return view;
end

function p.SetItemInfo( view, card, itemIndex, ui_flag )

	local cardPic;
	if itemIndex == 3 then
		cardPic = ui_flag.ID_CTRL_BUTTON_38;
	elseif itemIndex == 2 then
		cardPic = ui_flag.ID_CTRL_BUTTON_39;
	elseif itemIndex == 1 then
		cardPic = ui_flag.ID_CTRL_BUTTON_40;
	elseif itemIndex == 0 then
		cardPic = ui_flag.ID_CTRL_BUTTON_41;
	end

	--����ͼƬ
	local cardPicNode = GetButton( view, cardPic );
	cardPicNode:SetImage( user_skill_mgr.GetCardPicture(card.skill_id) );
	cardPicNode:SetTouchDownImage( user_skill_mgr.GetCardPicture(card.skill_id) );
	cardPicNode:SetId( tonumber(card.id));

	--�����¼�
	cardPicNode:SetLuaDelegate(p.OnBtnClicked);
end

--���Ƶ���¼�
function p.OnBtnClicked( uiNode, uiEventType, param )

	local card = user_skill_mgr.GetCardById(tonumber(uiNode:GetId()));
	if COLLECT_OPTION_PET == p.cur_option then
		dlg_collect_pet_detail.ShowUI(card);
	elseif COLLECT_OPTION_EQUIP == p.cur_option then
		dlg_collect_item_detail.ShowUI(card);
	elseif COLLECT_OPTION_SKILL == p.cur_option then
		dlg_collect_skill_detail.ShowUI(card);
	end
end

--���ñ���
function p.SetTitleText(cardList,category,childCategory)

	--���±���
	if childCategory == -1 then
		p.SetTitle(GetStr("COLLECT_ALL"));
	else
		p.SetTitle(collect_mgr.GetTitleInfo(category,childCategory));
	end
	
	--��������,�ռ���
	local maxNum = collect_mgr.GetCardMaxNum(category,childCategory);
	if cardList == nil or #cardList <= 0 then
		local num = string.format("(%d/%d)",0,tonumber(maxNum));
		p.collectNum:SetText(num);
		p.collectEfficiency:SetText("0%");
	else
		local num = string.format("(%d/%d)",#cardList,tonumber(maxNum));
		local effic = #cardList / tonumber(maxNum);
		p.collectNum:SetText(num);
		p.collectEfficiency:SetText(tostring(effic).."%");
	end

end


function p.OnMsgBoxCallback()
end

function p.SetTitle(str)
	if str ~= nil then
		p.collectType:SetText( str );
	end
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
		p.cur_option = nil;
		p.listBox = nil;
		p.collectType = nil;
		p.collectNum = nil;
		p.collectEfficiency = nil;
		collect_mgr.ClearData();
	end
end