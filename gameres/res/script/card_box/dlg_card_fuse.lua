--------------------------------------------------------------
-- FileName: 	dlg_card_fuse.lua
-- author:		zjj, 2013/07/22
-- purpose:		��Ƭ�ںϽ���
--------------------------------------------------------------

dlg_card_fuse = {}
local p = dlg_card_fuse;
p.layer = nil;

p.cardBtn1 = nil;
p.cardBtn2 = nil;
p.selectCardindex = 0;

p.card1 = nil;
p.card2 = nil;
p.item1 = nil;
p.item2 = nil;

--��ѡ����id
p.selectcard = nil;
--ʹ�õ���id
p.useItem = 0;

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
    LoadDlg("dlg_card_fuse.xui", layer, nil);
	
	p.SetDelegate(layer);
	p.layer = layer;
	p.LoadFuseItemData();
end


--�����¼�����
function p.SetDelegate(layer)
	--��ҳ��ť
	local topBtn = GetButton(layer,ui_dlg_card_fuse.ID_CTRL_BUTTON_1);
    topBtn:SetLuaDelegate(p.OnCardFuseUIEvent);
	
	--ѡ��Ƭ1��ť
	p.cardBtn1 = GetButton(layer,ui_dlg_card_fuse.ID_CTRL_BUTTON_CARD1);
    p.cardBtn1:SetLuaDelegate(p.OnCardFuseUIEvent);
	--ѡ��Ƭ2��ť
	p.cardBtn2 = GetButton(layer,ui_dlg_card_fuse.ID_CTRL_BUTTON_CARD2);
    p.cardBtn2:SetLuaDelegate(p.OnCardFuseUIEvent);

	--ȷ���ںϰ�ť
	local cardFuseBtn = GetButton(layer,ui_dlg_card_fuse.ID_CTRL_BUTTON_9);
    cardFuseBtn:SetLuaDelegate(p.OnCardFuseUIEvent);
	cardFuseBtn:SetEnabled( false );

end

function p.OnCardFuseUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
		if ( ui_dlg_card_fuse.ID_CTRL_BUTTON_1 == tag ) then	
			WriteCon("To top UI");
			--task_map_mainui.ShowUI();
			p.selectcard = nil;
			p.CloseUI();
		--ѡ����1
		elseif ( ui_dlg_card_fuse.ID_CTRL_BUTTON_CARD1 == tag ) then
			WriteCon("select card1");
			p.selectCardindex = 1;
			card_box_mgr.SetEquiped(true); -- ���ù�����װ������		
			if p.selectcard ~= nil then
				card_box_mgr.SetDelCardById(p.selectcard.id); --������ѡ����
				card_box_mgr.SetFuseCardRare(p.selectcard.rare); --���˿����Ǽ�����			
			end	
			card_box_mgr.SetSelectMaxLevel( true );
			dlg_card_box_mainui.ShowUI(CARD_INTENT_GETONE,dlg_card_fuse);
		--ѡ����2
		elseif ( ui_dlg_card_fuse.ID_CTRL_BUTTON_CARD2 == tag ) then
			WriteCon("select card2");
			p.selectCardindex = 2;
			card_box_mgr.SetEquiped(true);	-- ���ù�����װ������			
			if p.selectcard ~= nil then
				card_box_mgr.SetDelCardById(p.selectcard.id);	--������ѡ����
				card_box_mgr.SetFuseCardRare(p.selectcard.rare);	--���˿����Ǽ�����					
			end		
			card_box_mgr.SetSelectMaxLevel( true );	
			dlg_card_box_mainui.ShowUI(CARD_INTENT_GETONE,dlg_card_fuse);	
		--��ʼ�ں�
		elseif ( ui_dlg_card_fuse.ID_CTRL_BUTTON_9 == tag ) then
			WriteCon("show card fuse result");
			--��Ҳ�����ʾ
			if msg_cache.msg_player.gold < p.GetUseMoney() then
				p.NoEnoughMsgBox();
				return;
			end
			p.CardFuseQeq();
		end				
	end
end

--��Ҳ�����ʾ��
function p.NoEnoughMsgBox()
	dlg_msgbox.ShowOK(ToUtf8("��ʾ"), ToUtf8("�ں������Ҳ�������"), p.OnMsgBoxCallback , p.layer );
end

--��Ϣ��ص�
function p.OnMsgBoxCallback( result )
	
end
--�����ں�����
function p.CardFuseQeq()
	WriteCon("��Ƭ�ں�����");
	local uid = GetUID();
	if uid == 0 then uid = 100 end; 
	local param = string.format("&user_card_ids=%d,%d",p.card1.id,p.card2.id);	
	WriteCon(param);
	SendReq("Mix","MixCards",uid,param);
end

function p.LoadFuseItemData()
	WriteCon("�����ںϵ�������");
	local uid = GetUID();
	if uid == 0 then uid = 100 end; 
	SendReq("Mix","GetMixItems",uid,"");
end

function p.LoadSelectData( card )
	WriteCon("get select card");
	p.selectcard = card;
	dump_obj(card);
	if (p.selectCardindex == 1) then
		p.card1 = card;
		p.cardBtn1:SetImage( GetCardPicById( card.card_id ) );
		
	elseif (p.selectCardindex == 2) then
    	p.card2 = card;
    	p.cardBtn2:SetImage( GetCardPicById( card.card_id ) );
	end
	p.LoadItem();
end

function p.GetUseMoney()
	local n = p.compareRare(p.card1.rare,p.card2.rare);
	if n == 1 then return SelectRowMatch( T_CONFIG, "mix_rare_1_cost", "config" ) end;
	if n == 2 then return SelectRowMatch( T_CONFIG, "mix_rare_2_cost", "config" ) end;
	return 5000;
end

--��ʼ��UI
function p.RefreshUI()
	if p.layer == nil then
		return;
	end
	--���ѡ��������
	p.card1 = nil;
	p.card2 = nil;
	p.selectcard = nil;
	
	--��ʼ���ϳɰ�ť
	local cardFuseBtn = GetButton(p.layer,ui_dlg_card_fuse.ID_CTRL_BUTTON_9);
	cardFuseBtn:SetEnabled( false );
	
	--������ˢ��
	local itemNumLab = GetLabel(p.layer,ui_dlg_card_fuse.ID_CTRL_TEXT_ITEM_NUM);
	itemNumLab:SetText(" 0 / 99 ");
end

 
--�жϲ������ںϵ���
function p.LoadItem()
	if p.card1 ~= nil and p.card2 ~= nil then  --��ѡ�����ſ���
		local cardFuseBtn = GetButton(p.layer,ui_dlg_card_fuse.ID_CTRL_BUTTON_9);
		cardFuseBtn:SetEnabled( true );
		WriteCon("rare" .. p.card1.rare .. p.card2.rare );
		if p.compareRare(p.card1.rare, p.card2.rare) >= 4 then --�������
			if p.compareRare(p.card1.rare, p.card2.rare) >= 5 then --�������
				WriteCon("����1801");
				local itemNumLab = GetLabel(p.layer,ui_dlg_card_fuse.ID_CTRL_TEXT_ITEM_NUM);
				itemNumLab:SetText(tostring(p.item2.num) .. " / 99 ");
				return;
			end
			WriteCon("����1800");
			local itemNumLab = GetLabel(p.layer,ui_dlg_card_fuse.ID_CTRL_TEXT_ITEM_NUM);
			itemNumLab:SetText(tostring(p.item1.num) .. " / 99 ");
			return;
		end	
		WriteCon("�������ںϵ���");
	end
end

function p.compareRare(a,b)
	if tonumber(a) >= tonumber(b) then
		return tonumber(a);
	end
	return tonumber(b);
end

--�����ںϵ��߻ص��������ںϵ�������
function p.SaveItemData(mix_items)
	p.item1 = mix_items[1];
	p.item2 = mix_items[2];
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
    end

end

