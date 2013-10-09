--------------------------------------------------------------
-- FileName: 	dlg_item_select.lua
-- author:		zjj, 2013/08/05
-- purpose:		װ��ǿ������ѡ�����
--------------------------------------------------------------

dlg_item_select = {}
local p = dlg_item_select;

p.layer = nil;
p.useNumList = {}; 

--����ѡ������
p.limitNum = nil;

--������
p.caller = nil;

--ҩˮ����
p.itemNum = nil;

--��ѡ��װ����
p.selectNum = 0;

--�ѽ�ѡ��װ������б�
p.selectIndexList = {0,0,0};

p.viewList = {};

--��ʾUI
function p.ShowUI( limitNum , itemNum ,caller )   
    if p.layer ~= nil then
		p.layer:SetVisible( true );
		return;
	end
	
	local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end
	
	if limitNum ~= nil then
		p.limitNum = limitNum;
	end
	if caller ~= nil then
		p.caller = caller;
	end
	if itemNum ~= nil then
		p.itemNum = itemNum;
	end
	
	layer:Init();
	--layer:SetSwallowTouch(true);
	--layer:SetFrameRectFull();
	
	GetUIRoot():AddDlg(layer);
    LoadDlg("dlg_item_select.xui", layer, nil);
	p.layer = layer;
	p.SetDelegate();
	p.ShowMedicineInfo();
end

function p.ShowMedicineInfo()	
	local list = GetListBoxVert(p.layer,ui_dlg_item_select.ID_CTRL_VERTICAL_LIST_ITEMS);
	list:ClearView();

	for i=1,3 do
		local view = createNDUIXView();
		view:Init();
		LoadUI("equip_item_view.xui", view, nil);
		
		local bg = GetUiNode(view,ui_equip_item_view.ID_CTRL_PICTURE_BG);
		view:SetViewSize( bg:GetFrameSize());
		view:EnableSelImage(true);
		view:SetId(i);
		list:AddView(view);	
		view:SetEnabled(false);
		
		--���ӵ��߰�ť
		local addBtn =  GetButton(view , ui_equip_item_view.ID_CTRL_BUTTON_ADD);
		addBtn:SetLuaDelegate(p.OnItemSelectUIEvent);
		addBtn:SetId(i);
		
		--���ٵ��߰�ť
		local minusBtn = GetButton(view , ui_equip_item_view.ID_CTRL_BUTTON_MINUS);
		minusBtn:SetLuaDelegate(p.OnItemSelectUIEvent);
		minusBtn:SetId(i);
		
		--������
		local itemNumLab = GetLabel(view, ui_equip_item_view.ID_CTRL_TEXT_ITEM_NUM);
		itemNumLab:SetText("0");
		if p.itemNum[i] ~= nil and p.itemNum ~= nil then
			itemNumLab:SetText(tostring( p.itemNum[i]));
		end
		
		--ʹ�õ�����
		local useNumLab = GetLabel(view, ui_equip_item_view.ID_CTRL_TEXT_USE_NUM);
		useNumLab:SetText("0");
		p.useNumList[i] = useNumLab;
		
		--����ͼ��
		local itemIconImg = GetImage(view, ui_equip_item_view.ID_CTRL_PICTURE_ITEM);
		itemIconImg:SetPicture( GetPictureByAni("item.item_icon", i - 1));
		p.viewList[i] = view;
	end
end

--�����¼�����
function p.SetDelegate()
	--��ҳ��ť
	local backBtn = GetButton(p.layer,ui_dlg_item_select.ID_CTRL_BUTTON_BACK);
    backBtn:SetLuaDelegate(p.OnItemSelectUIEvent);
	
	--ȷ�ϰ�ť
	local okBtn = GetButton(p.layer,ui_dlg_item_select.ID_CTRL_BUTTON_OK);
    okBtn:SetLuaDelegate(p.OnItemSelectUIEvent);
	
	--��ѡ��ť1
	local checkBtn1 = GetButton(p.layer,ui_dlg_item_select.ID_CTRL_BUTTON_CHECK1);
	checkBtn1:SetId(1);
	checkBtn1:SetLuaDelegate(p.OnCheckEvent);
	checkBtn1:SetImage(GetPictureByAni("ui.item_check_btn", 1));
	checkBtn1:SetTouchDownImage(GetPictureByAni("ui.item_check_btn", 0));
	
	--��ѡ��ť2
	local checkBtn2 = GetButton(p.layer,ui_dlg_item_select.ID_CTRL_BUTTON_CHECK2);
	checkBtn2:SetId(2);
	checkBtn2:SetLuaDelegate(p.OnCheckEvent);
	checkBtn2:SetImage(GetPictureByAni("ui.item_check_btn", 1));
	checkBtn2:SetTouchDownImage(GetPictureByAni("ui.item_check_btn", 0));
	
	--��ѡ��ť3
	local checkBtn3 = GetButton(p.layer,ui_dlg_item_select.ID_CTRL_BUTTON_CHECK3);
	checkBtn3:SetId(3);
	checkBtn3:SetLuaDelegate(p.OnCheckEvent);
	checkBtn3:SetImage(GetPictureByAni("ui.item_check_btn", 1));
	checkBtn3:SetTouchDownImage(GetPictureByAni("ui.item_check_btn", 0));
	
end

function p.OnCheckEvent(uiNode, uiEventType, param)
	local btn = ConverToButton(uiNode);
	if  IsClickEvent(uiEventType) then	
		p.CheckSelectItem(uiNode);
		p.viewList[uiNode:GetId()]:SetEnabled(false);
		btn:SetChecked( false);
		if p.selectIndexList[uiNode:GetId()] ==1  then
			p.viewList[uiNode:GetId()]:SetEnabled(true);
			btn:SetChecked( true);
		end	
	end								 
end

function p.CheckSelectItem(uiNode)
	if p.selectIndexList[uiNode:GetId()] == 0 then
		if p.CanSelectEquip() then
			p.selectIndexList[uiNode:GetId()] = 1;
			p.selectNum = p.selectNum + 1;	
		else 
		end	
	elseif p.selectIndexList[uiNode:GetId()] == 1 then
		p.selectIndexList[uiNode:GetId()] = 0;
		p.selectNum = p.selectNum - 1;
	end		
end
		
	
	
function p.OnItemSelectUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
		if ( ui_dlg_item_select.ID_CTRL_BUTTON_BACK == tag ) then	
			p.HideUI();
		elseif ( ui_equip_item_view.ID_CTRL_BUTTON_ADD == tag ) then
			local num = tonumber(p.useNumList[uiNode:GetId()]:GetText()) + 1;
			p.useNumList[uiNode:GetId()]:SetText(tostring(num));
		elseif ( ui_equip_item_view.ID_CTRL_BUTTON_MINUS == tag ) then
			local num = tonumber(p.useNumList[uiNode:GetId()]:GetText());
			if num ~= 0 then
				num = num - 1;
			end	
			p.useNumList[uiNode:GetId()]:SetText(tostring(num));
		elseif ( ui_dlg_item_select.ID_CTRL_BUTTON_OK == tag ) then
			dlg_equip_upgrade.LoadSelectItemData(p.GetSelectItemlist() , ITEM_TYPE_8);
			p.HideUI();
		end				
	end
end

--��ȡ����ѡ��ҩƷ�б�
function p.GetSelectItemlist()
	local selectItemNum = {};
	for i=1,3 do
		if p.selectIndexList[i] == 1 then
			local num = tonumber(p.useNumList[i]:GetText());
			if num ~= 0 then
				selectItemNum[i] = num;
			end
		end
	end
	
	local selectItemlist = {{type=ITEM_TYPE_8,item_id=1300,itemNum=0},{type=ITEM_TYPE_8,item_id=1301,itemNum=0},{type=ITEM_TYPE_8,item_id=1302,itemNum=0}};
	for i=1,3 do
		selectItemlist[i].itemNum = selectItemNum[i];
	end
	
	local t ={};
	for i=1,3 do
		if selectItemlist[i].itemNum ~= nil then
			t[#t + 1] = selectItemlist[i];
		end
	end
	return t;	
end

function p.CanSelectEquip()
	if p.selectNum + 1  <=  p.limitNum then
		return true;
	end
	return false;
end

function p.SendHttpRequest()

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
		p.limitNum = nil;
		p.caller = nil;
		p.itemNum = nil;
		p.selectNum = nil;
		p.selectIndexList = nil;
    end
end

