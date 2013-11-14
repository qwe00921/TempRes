pack_box = {}
local p = pack_box;

p.layer = nil;
p.curBtnNode = nil;

function p.ShowUI()
	if p.layer ~= nil then 
		p.layer:SetVisible(true);
		return;
	end
	
    local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end

	layer:NoMask();
    layer:Init();   
	layer:SetSwallowTouch(false);
	
    GetUIRoot():AddDlg(layer);
    LoadDlg("bag_main.xui", layer, nil);

    p.layer = layer;
    p.SetDelegate(layer);
	
	--���ر�������
    pack_box_mgr.LoadAllItem( p.layer );
end

function p.GetLayer()
	return p.layer();
end

--�����¼�����
function p.SetDelegate(layer)
	--����
	local retBtn = GetButton(layer, ui_bag_main.ID_CTRL_BUTTON_BACK);
	retBtn:SetLuaDelegate(p.OnUIEvent);
	--����
	local clearBtn = GetButton(layer, ui_bag_main.ID_CTRL_BUTTON_CLEAR);
	clearBtn:SetLuaDelegate(p.OnUIEvent);
	--ʹ��
	local useBtn = GetButton(layer, ui_bag_main.ID_CTRL_BUTTON_15);
	useBtn:SetLuaDelegate(p.OnUIEvent);
end

--�¼�����
function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
		if(ui_bag_main.ID_CTRL_BUTTON_BACK == tag) then
			p.CloseUI();
		elseif (ui_bag_main.ID_CTRL_BUTTON_CLEAR == tag) then
			p.SetBtnCheckedFX( uiNode )
			WriteCon("����");
		elseif (ui_bag_main.ID_CTRL_BUTTON_15 == tag) then
			p.SetBtnCheckedFX( uiNode )
			WriteCon("ʹ��");
		end
	end
end
--����ѡ�а�ť
function p.SetBtnCheckedFX( node )
	local btnNode = ConverToButton( node );
	if p.curBtnNode ~= nil then
		p.curBtnNode:SetChecked(false);
	end
	btnNode:SetChecked(true)
	p.curbtnNode = btnNode;
end

--��ʾ�����б�
function p.ShowItemList( itemList )
	local list = GetListBoxVert(p.layer ,ui_bag_main.ID_CTRL_VERTICAL_LIST_10);
	list:ClearView();
	
	if itemList == nil or #itemList <= 0 then
		WriteCon("ShowItemList():itemList is null");
		return
	end
	WriteCon("listLenght = "..#itemList);
	local listLenght = #itemList;
	local row = math.ceil(listLenght / 4)

	for i = 1 ,row do
		local view = createNDUIXView();
		view:Init();
		LoadUI("bag_list.xui",view,nil);
		local bg = GetUiNode( view, ui_bag_list.ID_CTRL_PICTURE_13);
        view:SetViewSize( bg:GetFrameSize());

        local row_index = i;
        local start_index = (row_index-1)*4+1;
        local end_index = start_index + 3;

		--�����б�����Ϣ��һ��4������
        for j = start_index,end_index do
            if j <= listLenght then
                local item = itemList[j];
                local itemIndex = end_index - j;
				p.ShowItemInfo( view, item, itemIndex );
            end
        end
        list:AddView( view );
	end
end

--����������ʾ
function p.ShowItemInfo( view, item, itemIndex )
    --local isUse;
    --local subTitleBg;
    local itemBtn;
    local itemNumber;
    local itemName;
	if itemIndex == 3 then
        --isUse = ui_bag_list.ID_CTRL_TEXT_29;
        itemBtn = ui_bag_list.ID_CTRL_BUTTON_ITEMBG;
        itemNumber = ui_bag_list.ID_CTRL_TEXT_ITEMNUM1;
        itemName = ui_bag_list.ID_CTRL_PICTURE_PICITEM1;
    elseif itemIndex == 2 then
       -- isUse = ui_bag_list.ID_CTRL_TEXT_30;
        itemBtn = ui_bag_list.ID_CTRL_BUTTON_6;
        itemNumber = ui_bag_list.ID_CTRL_TEXT_ITEMNUM2;
        itemName = ui_bag_list.ID_CTRL_PICTURE_PICITEM2;
    elseif itemIndex == 1 then
       -- isUse = ui_bag_list.ID_CTRL_TEXT_31;
        itemBtn = ui_bag_list.ID_CTRL_BUTTON_10;
        itemNumber = ui_bag_list.ID_CTRL_TEXT_ITEMNUM3;
        itemName = ui_bag_list.ID_CTRL_PICTURE_PICITEM3;
    elseif itemIndex == 0 then
       -- isUse = ui_bag_list.ID_CTRL_TEXT_32;
        itemBtn = ui_bag_list.ID_CTRL_BUTTON_9;
        itemNumber = ui_bag_list.ID_CTRL_TEXT_ITEMNUM4;
        itemName = ui_bag_list.ID_CTRL_PICTURE_PICITEM4;
    end
	
	local itemType = tonumber(item.Type)
				WriteCon("itemType = "..itemType);
	--�ж�  type��ͬ ��Ӧ��ͬ�Ĵ���
	if itemType == 9 then
		WriteCon("itemType = 9====��Ӧ");
	end
	
	--����ͼƬ
	local itemPicNode = GetButton(view, itemPic);
	--local pic = 9;
	
	--itemPicNode:SetImage(GetPictureByAni(""))
	--itemPicNode:SetId(tonumber(item.id))
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
        pack_box_mgr.ClearData();
    end
end


