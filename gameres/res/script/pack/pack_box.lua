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
    local itemBtn;
    local itemNumber;
    local itemName;
	local subTitleBg;
    local isUse;
	if itemIndex == 3 then
        itemBtn = ui_bag_list.ID_CTRL_BUTTON_ITEM1;
        itemNumber = ui_bag_list.ID_CTRL_TEXT_ITEMNUM1;
        itemName = ui_bag_list.ID_CTRL_TEXT_ITEMNAME1;
		subTitleBg = ui_bag_list.ID_CTRL_PICTURE_22;
        isUse = ui_bag_list.ID_CTRL_PICTURE_EQUIP1;
    elseif itemIndex == 2 then
        itemBtn = ui_bag_list.ID_CTRL_BUTTON_ITEM2;
        itemNumber = ui_bag_list.ID_CTRL_TEXT_ITEMNUM2;
        itemName = ui_bag_list.ID_CTRL_TEXT_ITEMNAME2;
		subTitleBg = ui_bag_list.ID_CTRL_PICTURE_23;
        isUse = ui_bag_list.ID_CTRL_PICTURE_EQUIP2;
    elseif itemIndex == 1 then
        itemBtn = ui_bag_list.ID_CTRL_BUTTON_ITEM3;
        itemNumber = ui_bag_list.ID_CTRL_TEXT_ITEMNUM3;
        itemName = ui_bag_list.ID_CTRL_TEXT_ITEMNAME3;
		subTitleBg = ui_bag_list.ID_CTRL_PICTURE_24;
        isUse = ui_bag_list.ID_CTRL_PICTURE_EQUIP3;
    elseif itemIndex == 0 then
        itemBtn = ui_bag_list.ID_CTRL_BUTTON_ITEM4;
        itemNumber = ui_bag_list.ID_CTRL_TEXT_ITEMNUM4;
        itemName = ui_bag_list.ID_CTRL_TEXT_ITEMNAME4;
		subTitleBg = ui_bag_list.ID_CTRL_PICTURE_25;
        isUse = ui_bag_list.ID_CTRL_PICTURE_EQUIP4;
    end
	
	local itemType = tonumber(item.Type)
	--�ж�  type��ͬ ��Ӧ��ͬ�Ĵ���
	if itemType == 9 then
		WriteCon("itemType = 9====��Ӧ");
	end
	
	--����ͼƬ
	local itemPicNode = GetButton(view, itemBtn);
	local pic = 9;
    itemPicNode:SetImage( GetPictureByAni("item.item_db", pic) );
    itemPicNode:SetId( tonumber(item.id));
	--��������
    local itemNumberNode = GetLabel( view, itemNumber );
    itemNumberNode:SetText( string.format("%d", item.Num) );

	--��������
    local itemNameNode = GetLabel( view, itemName );
    itemNameNode:SetText( item.Name );
	
	--�����¼�
	itemPicNode:SetLuaDelegate(p.OnBtnClicked);
end

--��ѡ�����¼�
function p.OnBtnClicked(uiNode, uiEventType, param)
	local itemId = uiNode:GetId();
	WriteCon("itemId = "..itemId);
	WriteCon(tostring(T_ITEM));

	local itemTable = SelectRowList(T_ITEM,"id",itemId);
	WriteCon("text = "..itemTable);
	local text = itemTable.name;
	WriteCon("text = "..text);
	--local itemNamePic = GetImage(p.layer,ui_bag_main.ID_CTRL_PICTURE_ITEMNAME);
	--local itemNameText = GetLabel(p.layer, ui_bag_main.ID_CTRL_TEXT_ITEMNAME);
	--itemNameText:SetText( "131232" );

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


