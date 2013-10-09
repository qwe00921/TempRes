--------------------------------------------------------------
-- FileName: 	dlg_card_fuse.lua
-- author:		zjj, 2013/07/22
-- purpose:		卡片融合界面
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

--已选卡牌id
p.selectcard = nil;
--使用道具id
p.useItem = 0;

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
    LoadDlg("dlg_card_fuse.xui", layer, nil);
	
	p.SetDelegate(layer);
	p.layer = layer;
	p.LoadFuseItemData();
end


--设置事件处理
function p.SetDelegate(layer)
	--首页按钮
	local topBtn = GetButton(layer,ui_dlg_card_fuse.ID_CTRL_BUTTON_1);
    topBtn:SetLuaDelegate(p.OnCardFuseUIEvent);
	
	--选择卡片1按钮
	p.cardBtn1 = GetButton(layer,ui_dlg_card_fuse.ID_CTRL_BUTTON_CARD1);
    p.cardBtn1:SetLuaDelegate(p.OnCardFuseUIEvent);
	--选择卡片2按钮
	p.cardBtn2 = GetButton(layer,ui_dlg_card_fuse.ID_CTRL_BUTTON_CARD2);
    p.cardBtn2:SetLuaDelegate(p.OnCardFuseUIEvent);

	--确定融合按钮
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
		--选择卡牌1
		elseif ( ui_dlg_card_fuse.ID_CTRL_BUTTON_CARD1 == tag ) then
			WriteCon("select card1");
			p.selectCardindex = 1;
			card_box_mgr.SetEquiped(true); -- 设置过滤有装备卡牌		
			if p.selectcard ~= nil then
				card_box_mgr.SetDelCardById(p.selectcard.id); --过滤已选卡牌
				card_box_mgr.SetFuseCardRare(p.selectcard.rare); --过滤卡牌星级条件			
			end	
			card_box_mgr.SetSelectMaxLevel( true );
			dlg_card_box_mainui.ShowUI(CARD_INTENT_GETONE,dlg_card_fuse);
		--选择卡牌2
		elseif ( ui_dlg_card_fuse.ID_CTRL_BUTTON_CARD2 == tag ) then
			WriteCon("select card2");
			p.selectCardindex = 2;
			card_box_mgr.SetEquiped(true);	-- 设置过滤有装备卡牌			
			if p.selectcard ~= nil then
				card_box_mgr.SetDelCardById(p.selectcard.id);	--过滤已选卡牌
				card_box_mgr.SetFuseCardRare(p.selectcard.rare);	--过滤卡牌星级条件					
			end		
			card_box_mgr.SetSelectMaxLevel( true );	
			dlg_card_box_mainui.ShowUI(CARD_INTENT_GETONE,dlg_card_fuse);	
		--开始融合
		elseif ( ui_dlg_card_fuse.ID_CTRL_BUTTON_9 == tag ) then
			WriteCon("show card fuse result");
			--金币不足提示
			if msg_cache.msg_player.gold < p.GetUseMoney() then
				p.NoEnoughMsgBox();
				return;
			end
			p.CardFuseQeq();
		end				
	end
end

--金币不足提示框
function p.NoEnoughMsgBox()
	dlg_msgbox.ShowOK(ToUtf8("提示"), ToUtf8("融合所需金币不够！！"), p.OnMsgBoxCallback , p.layer );
end

--消息框回调
function p.OnMsgBoxCallback( result )
	
end
--发送融合请求
function p.CardFuseQeq()
	WriteCon("卡片融合请求");
	local uid = GetUID();
	if uid == 0 then uid = 100 end; 
	local param = string.format("&user_card_ids=%d,%d",p.card1.id,p.card2.id);	
	WriteCon(param);
	SendReq("Mix","MixCards",uid,param);
end

function p.LoadFuseItemData()
	WriteCon("加载融合道具数据");
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

--初始化UI
function p.RefreshUI()
	if p.layer == nil then
		return;
	end
	--清除选择卡牌数据
	p.card1 = nil;
	p.card2 = nil;
	p.selectcard = nil;
	
	--初始化合成按钮
	local cardFuseBtn = GetButton(p.layer,ui_dlg_card_fuse.ID_CTRL_BUTTON_9);
	cardFuseBtn:SetEnabled( false );
	
	--道具数刷新
	local itemNumLab = GetLabel(p.layer,ui_dlg_card_fuse.ID_CTRL_TEXT_ITEM_NUM);
	itemNumLab:SetText(" 0 / 99 ");
end

 
--判断并加载融合道具
function p.LoadItem()
	if p.card1 ~= nil and p.card2 ~= nil then  --已选择两张卡牌
		local cardFuseBtn = GetButton(p.layer,ui_dlg_card_fuse.ID_CTRL_BUTTON_9);
		cardFuseBtn:SetEnabled( true );
		WriteCon("rare" .. p.card1.rare .. p.card2.rare );
		if p.compareRare(p.card1.rare, p.card2.rare) >= 4 then --最低四星
			if p.compareRare(p.card1.rare, p.card2.rare) >= 5 then --最低五星
				WriteCon("加载1801");
				local itemNumLab = GetLabel(p.layer,ui_dlg_card_fuse.ID_CTRL_TEXT_ITEM_NUM);
				itemNumLab:SetText(tostring(p.item2.num) .. " / 99 ");
				return;
			end
			WriteCon("加载1800");
			local itemNumLab = GetLabel(p.layer,ui_dlg_card_fuse.ID_CTRL_TEXT_ITEM_NUM);
			itemNumLab:SetText(tostring(p.item1.num) .. " / 99 ");
			return;
		end	
		WriteCon("不加载融合道具");
	end
end

function p.compareRare(a,b)
	if tonumber(a) >= tonumber(b) then
		return tonumber(a);
	end
	return tonumber(b);
end

--加载融合道具回调，保存融合道具数据
function p.SaveItemData(mix_items)
	p.item1 = mix_items[1];
	p.item2 = mix_items[2];
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
    end

end

