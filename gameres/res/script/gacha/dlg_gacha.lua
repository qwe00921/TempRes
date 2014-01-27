--------------------------------------------------------------
-- FileName: 	dlg_gacha.lua
-- author:		zjj, 2013/08/19
-- purpose:		扭蛋界面
--------------------------------------------------------------

dlg_gacha = {}
local p = dlg_gacha;

SHOP_GACHA      = 1;
SHOP_ITEM       = 2;
SHOP_GIFT_PACK  = 3;
SHOP_BAG		= 4;

local curPage = SHOP_ITEM;

local LEFT      = 1;
local RIGHT     = 2;
local GIFT_LEFT   = 3;
local GIFT_RIGHT  = 4;

p.intent = nil;

p.layer = nil;
p.timezj = nil; --中级扭蛋时间
p.timegj = nil; --高级扭蛋时间

p.gachadata = nil;
p.rmb = nil; --元宝值
p.pt  = nil; --pt值
p.idTimerRefresh = nil;
p.freeTimeList = {};
--p.timerIDList = {};
p.coin_config = {};
p.gachaBtnlist = {};
p.useTicketSign = 0;

--扭蛋参数
p.gacha_id = nil;
p.charge_type = nil;
p.gacha_type = nil;

p.gachaIndex = nil;

p.gachaList = nil;
p.shopItemList = nil;
p.shopPackList = nil;
p.bagList = nil;
p.gachaBtn = nil;
p.shopItmeBtn = nil;
p.shopPackBtn = nil;
p.bagBtn = nil;

--存放商品列表信息
p.shopData = nil;
--存放礼包列表信息
p.giftData = nil;
--存放背包列表信息
p.bagData = nil;

p.requestFlag = false;


function DateStrToTime( dateStr )
	local indexName ={"year", "month","day","hour","min","sec"};
	local timeTab ={};
	local i = 1;
	for num in string.gmatch(dateStr, "%d+") do
		timeTab[indexName[i]] = tonumber(num);
		i = i + 1;
	end
	return os.time( timeTab );
end

function TimeToStr( timeNum )
	local hours = math.floor(timeNum/3600);
	local mins = math.floor((timeNum%3600)/60);
	local secs = timeNum%60;
	return string.format( "%02d:%02d:%02d" , hours, mins, secs);
end

--显示UI
function p.ShowUI( intent ,reload)
	dlg_menu.SetNewUI( p );
	
    if p.layer ~= nil then
		p.layer:SetVisible( true );
		p.SetBagUseVisible(false);
		
		maininterface.HideUI();
		return;
	end
	
	local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end
	
	if intent ~= nil then
	   p.intent = intent;
	end
	
	--[[
	layer:Init();	
	GetUIRoot():AddDlg(layer);
    LoadDlg("dlg_gacha.xui", layer, nil);
	layer:SetSwallowTouch(false);
	]]--
	
	layer:NoMask();
	layer:Init();
	layer:SetSwallowTouch(false);
	layer:SetFrameRectFull();
    
	GetUIRoot():AddChild(layer);
	LoadUI("dlg_gacha.xui", layer, nil);
	
	p.layer = layer;
	p.SetDelegate();
	
	if intent == SHOP_GACHA then
	   p.ShowGachaData();
	elseif intent == SHOP_ITEM then
	   p.ShowShopData();
	elseif intent == SHOP_GIFT_PACK then 
	   p.ShowGiftPackData();
	elseif intent == SHOP_BAG then
	   p.ShowBagData();
	end
	
	p.SetBagUseVisible(false);
	
	maininterface.HideUI();
	
	gNotify:RegisterEvent( "msg_player", "Emoney", p, p.UpdateRmb );
	gNotify:RegisterEvent( "msg_player", "MailNum", p, p.UpdateMailNum );
end

--设置事件处理
function p.SetDelegate()
    p.GetCoinCost();
	--返回按钮
	local backBtn = GetButton(p.layer,ui_dlg_gacha.ID_CTRL_BUTTON_BACK);
    backBtn:SetLuaDelegate(p.OnGachaUIEvent);
	
	--扭蛋界面
	p.gachaBtn = GetButton(p.layer,ui_dlg_gacha.ID_CTRL_BUTTON_GACHAUI);
	p.gachaBtn:SetLuaDelegate(p.OnGachaUIEvent);
	
    --商店按钮
    p.shopItmeBtn = GetButton(p.layer,ui_dlg_gacha.ID_CTRL_BUTTON_ITEMUI); 
    p.shopItmeBtn:SetLuaDelegate(p.OnGachaUIEvent);
    
    --礼包按钮
    p.shopPackBtn = GetButton(p.layer,ui_dlg_gacha.ID_CTRL_BUTTON_GIFT_PACKUI);
    p.shopPackBtn:SetLuaDelegate(p.OnGachaUIEvent);
	
    
    --充值
    local payBtn = GetButton(p.layer,ui_dlg_gacha.ID_CTRL_BUTTON_PAY);
    payBtn:SetLuaDelegate(p.OnGachaUIEvent);
	
	--持有
	p.bagBtn = GetButton(p.layer,ui_dlg_gacha.ID_CTRL_BUTTON_73);
    p.bagBtn:SetLuaDelegate(p.OnGachaUIEvent);
	
    
	--[[
    --广告列表
    local adList = GetListBoxHorz( p.layer, ui_dlg_gacha.ID_CTRL_LIST_AD);
    adList:ClearView();
    adList:SetSingleMode(true);
    for i = 1,5 do
       local view = createNDUIXView();
       view:Init();
       LoadUI("gacha_ad_view.xui", view, nil);
       local bg = GetImage(view,ui_gacha_ad_view.ID_CTRL_PICTURE_AD);
       view:SetViewSize( bg:GetFrameSize());
       
       bg:SetPicture( GetPictureByAni("ui.gacha_ad", i-1));
       adList:AddView(view);
    end
     
    --下一个广告
    local nextAdBtn = GetButton( p.layer,ui_dlg_gacha.ID_CTRL_BUTTON_AD_NEXT);
    nextAdBtn:SetLuaDelegate(p.OnGachaUIEvent);
    --上一个广告
    local lastAdBtn = GetButton( p.layer,ui_dlg_gacha.ID_CTRL_BUTTON_AD_LAST);
    lastAdBtn:SetLuaDelegate(p.OnGachaUIEvent);
    --]]

    --扭蛋列表
    p.gachaList = GetListBoxVert( p.layer, ui_dlg_gacha.ID_CTRL_VERTICAL_LIST_GACHA);
    
    --商店列表
    p.shopItemList = GetListBoxVert( p.layer, ui_dlg_gacha.ID_CTRL_VERTICAL_LIST_SHOP_ITEM);
    
    --礼包列表
    p.shopPackList = GetListBoxVert( p.layer, ui_dlg_gacha.ID_CTRL_VERTICAL_LIST_GIFT_PACK);
	
	--商城列表
	p.bagList	= GetListBoxVert( p.layer, ui_dlg_gacha.ID_CTRL_VERTICAL_LIST_BAG);
end

function p.OnGiftUIEvent( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
		if ( ui_shop_gift_pack_view.ID_CTRL_BUTTON_LOOK_L == tag ) then  
			local gift = p.giftData.list[uiNode:GetId()];
			dlg_gift_pack_preview.ShowUI( gift );
		end
	end
end

function p.OnGachaUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();

	if IsClickEvent( uiEventType ) or IsDoubleEvent( uiEventType ) then
		if ( ui_dlg_gacha.ID_CTRL_BUTTON_BACK == tag ) then  
			p.CloseUI();
			maininterface.ShowUI();
			maininterface.BecomeFirstUI();
			
			dlg_menu.SetSelectButton( -1 );
		elseif ( ui_dlg_gacha.ID_CTRL_BUTTON_GACHAUI == tag ) then  --扭蛋界面按钮
			WriteCon( "扭蛋界面按钮" );
			if curPage ~= SHOP_GACHA then
				p.ShowGachaData( p.gachadata );
			end
		elseif ( ui_dlg_gacha.ID_CTRL_BUTTON_ITEMUI == tag ) then  --商店界面按钮
			WriteCon( "商店界面按钮" );
			if curPage ~= SHOP_ITEM then
				p.ShowShopData( p.shopData );
			end
		elseif ( ui_dlg_gacha.ID_CTRL_BUTTON_GIFT_PACKUI == tag ) then  --礼包界面按钮
			WriteCon( "礼包界面按钮" );
			if curPage ~= SHOP_GIFT_PACK then
				p.ShowGiftPackData( p.giftData );
			end
		elseif ( ui_dlg_gacha.ID_CTRL_BUTTON_PAY == tag) then --充值按钮
			WriteCon( "充值按钮" );
			
		elseif (ui_dlg_gacha.ID_CTRL_BUTTON_73 == tag) then
			if curPage ~= SHOP_BAG then
				p.ShowBagData( p.bagData );
			end
			
		elseif ( ui_shop_item_view.ID_CTRL_BUTTON_BUY_L == tag ) then 
			WriteCon( "商城购买" );
			local item = p.shopData.list[uiNode:GetId()];
			dlg_buy_num.ShowUI( item );
		elseif ( ui_shop_gift_pack_view.ID_CTRL_BUTTON_BUY_L == tag ) then 
			WriteCon( "礼包购买" );
			local gift = p.giftData.list[uiNode:GetId()];
			dlg_buy_num.ShowUI( gift );
		
		elseif ui_gacha_list_view.ID_CTRL_BUTTON_ONE == tag then
			--单次扭蛋
			local id = uiNode:GetParent():GetId();
			local curTime = os.time();
			local freeTime = p.gachadata.gachaData[id].Gacha_endtime;
			if freeTime <= curTime then
				--免费
				local gacha_id = tonumber(p.gachadata.gachaData[id].Gacha_id);
				p.charge_type = 1;
				p.gacha_type = 1;
				p.gacha_id = gacha_id;
				p.ReqStartGacha( p.gacha_id, p.charge_type, p.gacha_type);
			else
				local gacha_id = tonumber(p.gachadata.gachaData[id].Gacha_id);
				local needRmb = tonumber(SelectCell( T_GACHA, tostring(gacha_id), "single_gacha_cost"));

				if p.rmb < needRmb then
					WriteCon("**扭蛋需求代币不足**");
					dlg_msgbox.ShowYesNo( "提示", "您身上的宝石不足，是否进行充值？", p.DidAddEmoney, p.layer );
				else
					--付费
					p.charge_type = 2;
					p.gacha_type = 1;
					p.gacha_id = gacha_id;
					p.ReqStartGacha( p.gacha_id, p.charge_type, p.gacha_type);
				end
			end
		elseif ui_gacha_list_view.ID_CTRL_BUTTON_TEN == tag then
			--N次扭蛋
			local id = uiNode:GetParent():GetId();
			local gacha_id = tonumber(p.gachadata.gachaData[id].Gacha_id);
			local needRmb = tonumber(SelectCell( T_GACHA, tostring(gacha_id), "complex_gacha_cost"));
			if p.rmb < needRmb then
				WriteCon("**扭蛋需求代币不足**");
				dlg_msgbox.ShowYesNo( "提示", "您身上的宝石不足，是否进行充值？", p.DidAddEmoney, p.layer );
			else
				--付费
				p.charge_type = 2;
				p.gacha_type = 2;
				p.gacha_id = gacha_id;
				p.ReqStartGacha( p.gacha_id, p.charge_type, p.gacha_type);
			end
		end
	end
end

--免费扭蛋对话框回调
function p.OnFreeGacha( result )
    if result then 
		if p.gachaIndex == 3 then  
			p.StartGacha("3", "1", "1");
		elseif p.gachaIndex == 5 then  
			p.StartGacha("5", "1", "1");
		end
    end
end

--扭蛋消息框回调
function p.OnCostGacha( result )
    if result then
        if p.useTicketSign == 1 then   --使用中级扭蛋卷
            p.StartGacha("3", "1", "2");
        elseif p.useTicketSign == 2 then --使用高级扭蛋卷
            p.StartGacha("5", "1", "2");
        elseif p.useTicketSign == 0 then --使用代币
             if p.gachaIndex == 1 then  
                p.StartGacha("1", "1", "3");
             elseif p.gachaIndex ==2 then
                 p.StartGacha("2", "1", "3");
             elseif p.gachaIndex ==3 then
               p.StartGacha("3", "1", "3");
             elseif p.gachaIndex ==4 then
                  p.StartGacha("4", "1", "3");
             elseif p.gachaIndex ==5 then
                  p.StartGacha("5", "1", "3");
             elseif p.gachaIndex ==6 then
                  p.StartGacha("6", "1", "3");
             end
        end
    end
end

--扭蛋开始请求
function p.StartGacha(gacha_id, gacha_num, charge_type)
	WriteCon("**开始扭蛋**");
	--保存扭蛋参数
	p.gacha_id = gacha_id;
	p.charge_type = charge_type;
	
    local uid = GetUID();
    if uid == 0 then uid = 100 end; 
    local gachaparam = "&gacha_id=" .. gacha_id .. "&gacha_num=" .. gacha_num .."&charge_type=" .. charge_type;
    SendReq("Gacha","Start",uid, gachaparam);
end

--每秒刷新时间
function p.RefreshFreeTime()
   --删除定时
	if p.idTimerRefresh ~= nil then
		KillTimer(p.idTimerRefresh);
		p.idTimerRefresh = nil;
	end
	p.idTimerRefresh = SetTimer(p.onFreeTime,1.0);
	p.onFreeTime();
end

--显示刷新时间
function p.onFreeTime( )
	local gachaData = p.gachadata.gachaData or {};
	local curTime = os.time();
	local needTime = false;
	
	for i = 1, #gachaData do
		local gacha = gachaData[i];
		local freeTime = gacha.Gacha_endtime or 0;
		if freeTime <= curTime then
			p.freeTimeList[i]:SetText( "当前可以进行免费扭蛋！" );
		else
			needTime = true;
			local secs = freeTime - curTime;
			p.freeTimeList[i]:SetText( TimeToStr(secs) .. "后可免费抽取1次" );
		end
	end
	
	if not needTime then
		KillTimer(p.idTimerRefresh);
		p.idTimerRefresh = nil;
	end
end

--请求gacha数据
function p.ReqGachaData()
	p.rmb = nil;
	WriteCon("**请求gacha数据**");
    local uid = GetUID();
    if uid == 0 then uid = 100 end; 
    SendReq("Gacha","GetGachaInfo",uid,"");
end

--请求商城物品数据
function p.ReqShopItem()
	p.rmb = nil;
	WriteCon("**请求商城物品数据**");
    local uid = GetUID();
    if uid == 0 then uid = 100 end; 
    SendReq("Shop","ShopList",uid,"&type_id=1");
end

--请求礼包数据
function p.ReqGitfPack()
	p.rmb = nil;
    WriteCon("**请求礼包数据**");
    local uid = GetUID();
    if uid == 0 then uid = 100 end; 
    SendReq("Shop","ShopList",uid,"&type_id=2");
end

--请求礼包购买
function p.ReqGiftPackBuy( giftid )
	WriteCon("**请求礼包购买**");
    local uid = GetUID();
    if uid == 0 then uid = 100 end; 
    local num = GetLabel( p.layer, ui_dlg_buy_num.ID_CTRL_TEXT_NUM ):GetText();
    local param = "&type_id=2".."&item_id=" .. giftid .."&num=" .. 1;
    WriteCon( "购买参数" .. param );
    SendReq("Shop","AddUserItem",uid, param);
end

--请求持有(背包)数据
function p.ReqBag()
    WriteCon("**请求礼包数据**");
    local uid = GetUID();
    if uid == 0 then uid = 100 end; 
    SendReq("Item","ListItem",uid,"");
end

function p.ReqStartGacha( gacha_id, charge_type, gacha_type)
	if p.requestFlag then
		return;
	end
	
	p.requestFlag = true;
	
	WriteCon("**请求开始扭蛋**");
	local uid = GetUID();
    if uid == 0 then uid = 100 end; 
	local param = string.format( "&gacha_id=%d&charge_type=%d&gacha_type=%d", gacha_id, charge_type, gacha_type);
	WriteCon( "扭蛋参数：" .. param );
	SendReq("Gacha","Start",uid, param);
end

--
function p.RequestCallBack()
	p.requestFlag = false;
end

--显示商城道具列表
function p.ShowShopData( shopdata )
	curPage = SHOP_ITEM;
	
	if shopdata == nil then
		p.rmb = nil;
		p.ReqShopItem();
		return;
	end

    p.shopItemList:SetVisible( true );
    p.gachaList:SetVisible( false ); 
    p.shopPackList:SetVisible( false );
	p.bagList:SetVisible( false );
	p.SetBagUseVisible(false);
    
    p.gachaBtn:SetChecked( false );
    p.shopPackBtn:SetChecked( false );
	p.bagBtn:SetChecked( false );
    p.shopItmeBtn:SetChecked( true );
    
    p.shopItemList:ClearView();
    
    --保存商城物品信息
    p.shopData = shopdata;
    
	if p.rmb == nil then
		p.rmb = tonumber(shopdata.user_coin);
	end
	
    --刷新玩家元宝
    local rmbLab = GetLabel( p.layer, ui_dlg_gacha.ID_CTRL_TEXT_RMB );
    rmbLab:SetText( tostring(p.rmb));
    
    local itemList = shopdata.list;
    local listLength = #itemList;

    WriteCon( "--" .. listLength .. "**");
    
    for i=1 ,listLength do
		local view = createNDUIXView();
		view:Init();
		LoadUI("shop_item_view.xui", view, nil);
		local bg = GetUiNode(view,ui_shop_item_view.ID_CTRL_PICTURE_BG);
		view:SetViewSize( bg:GetFrameSize());
       
		local itemData = itemList[i];
		p.SetItemInfo( view, itemData, LEFT, i );
		p.shopItemList:AddView( view );
    end
    
end

--显示商城礼包列表
function p.ShowGiftPackData( giftdata )
    curPage = SHOP_GIFT_PACK;
	
	if giftdata == nil then
		p.rmb = nil;
		p.ReqGitfPack();
		return;
	end

	p.shopPackList:SetVisible( true );
	p.gachaList:SetVisible( false ); 
	p.shopItemList:SetVisible( false );
	p.bagList:SetVisible( false );
	p.SetBagUseVisible(false);
    
	p.gachaBtn:SetChecked( false );
    p.shopPackBtn:SetChecked( true );
	p.bagBtn:SetChecked( false );
	p.shopItmeBtn:SetChecked( false );
	
	p.shopPackList:ClearView();
    
    --保存商城礼包信息
	p.giftData = giftdata;
	
	if p.rmb == nil then
		p.rmb = tonumber(giftdata.user_coin);
	end
	
    --刷新玩家元宝
	local rmbLab = GetLabel( p.layer, ui_dlg_gacha.ID_CTRL_TEXT_RMB );
    rmbLab:SetText( tostring( p.rmb ));
    
    local giftList = giftdata.list;
    local listLength = #giftList;
    
    for i=1 ,listLength do
		local view = createNDUIXView();
		view:Init();
		LoadUI("shop_gift_pack_view.xui", view, nil);
		local bg = GetUiNode(view,ui_shop_gift_pack_view.ID_CTRL_PICTURE_BG);
		view:SetViewSize( bg:GetFrameSize());
       
		local giftData = giftList[i];
		p.SetItemInfo( view , giftData , GIFT_LEFT , i);
		p.shopPackList:AddView( view );
    end
end

--显示持有
function p.ShowBagData( bagdata )
	    curPage = SHOP_BAG;
	
	if bagdata == nil then
		p.ReqBag();
		return;
	end

	p.shopPackList:SetVisible( false );
	p.gachaList:SetVisible( false ); 
	p.shopItemList:SetVisible( false );
	p.bagList:SetVisible( true );
	p.SetBagUseVisible(false);
    
	p.gachaBtn:SetChecked( false );
    p.shopPackBtn:SetChecked( false );
	p.shopItmeBtn:SetChecked( false );
	p.bagBtn:SetChecked( true );
	
	p.bagList:ClearView();
    
    --保存信息
	p.bagdata = bagdata;
    
    local itemList = bagdata.user_items or {};
    local itemNum = #itemList;
    
    local row = math.ceil(itemNum / 5);
	
	for i = 1, row do
		local view = createNDUIXView();
		view:Init();
		LoadUI("bag_list.xui",view,nil);
		local bg = GetUiNode( view, ui_bag_list.ID_CTRL_PICTURE_13);
        view:SetViewSize( bg:GetFrameSize());
		
		local row_index = i;
		local start_index = (row_index-1)*5+1
        local end_index = start_index + 4;

		--设置列表项信息，一行5个道具
		for j = start_index,end_index do
			if j <= itemNum then
				local item = itemList[j];
				local itemIndex = j - start_index + 1;
				p.ShowBagItemInfo( view, item, itemIndex );
			end
		end
		p.bagList:AddView( view );
	end
    
end


--隐藏物品项
function p.HideItemView( view )
	--[[
	local temp = Get9SlicesImage(view , ui_shop_item_view.ID_CTRL_9SLICES_BG_R);
	temp:SetVisible( false );
	temp = GetButton( view ,ui_shop_item_view.ID_CTRL_BUTTON_BUY_R);
	temp:SetVisible( false );
	--]]
end

--隐藏礼包项
function p.HideGiftView( view )
	--[[
    local temp = Get9SlicesImage(view , ui_shop_gift_pack_view.ID_CTRL_9SLICES_BG_R);
    temp:SetVisible( false );
    temp = GetButton( view ,ui_shop_gift_pack_view.ID_CTRL_BUTTON_LOOK_R);
    temp:SetVisible( false );
    temp = GetButton(view,ui_shop_gift_pack_view.ID_CTRL_BUTTON_BUY_R);
    temp:SetVisible( false );
	--]]
end

--显示物品信息
function p.SetItemInfo( view , item , position, index)

    local name;
    local limit;
    local price;
    local rebateprice;
    local description;
    local buy;
	local picture;
	local desc;
	local priceLabel;
	local emoneyPic;
	local linePic;
	
    
    if position == LEFT then
        name = ui_shop_item_view.ID_CTRL_TEXT_NAME_L;
        limit = ui_shop_item_view.ID_CTRL_TEXT_LIMIT_L;
        price = ui_shop_item_view.ID_CTRL_TEXT_PRICE_L;
        rebateprice = ui_shop_item_view.ID_CTRL_TEXT_REBATE_PRICE_L;
		
		priceLabel = ui_shop_item_view.ID_CTRL_TEXT_30;
		emoneyPic = ui_shop_item_view.ID_CTRL_PICTURE_31;
		linePic = ui_shop_item_view.ID_CTRL_PICTURE_27;
		
        buy = ui_shop_item_view.ID_CTRL_BUTTON_BUY_L;
		picture = ui_shop_item_view.ID_CTRL_PICTURE_11;
		desc = ui_shop_item_view.ID_CTRL_TEXT_DESCRIPTION_L;
    elseif position == GIFT_LEFT then
        name = ui_shop_gift_pack_view.ID_CTRL_TEXT_NAME_L;
        limit = ui_shop_gift_pack_view.ID_CTRL_TEXT_LIMIT_L;
        price = ui_shop_gift_pack_view.ID_CTRL_TEXT_PRICE_L;
        rebateprice = ui_shop_gift_pack_view.ID_CTRL_TEXT_REBATE_PRICE_L;
		
		priceLabel = ui_shop_gift_pack_view.ID_CTRL_TEXT_14;
		emoneyPic = ui_shop_gift_pack_view.ID_CTRL_PICTURE_16;
		linePic = ui_shop_gift_pack_view.ID_CTRL_PICTURE_18;
		
        buy = ui_shop_gift_pack_view.ID_CTRL_BUTTON_BUY_L;
		picture = ui_shop_gift_pack_view.ID_CTRL_PICTURE_ICON_L;
		desc = ui_shop_gift_pack_view.ID_CTRL_TEXT_DESCRIPTION_L;
    end

    --名称
    local nameLab = GetLabel( view , name );
    --local row_name = SelectRowInner( T_SHOP, "item_id", item.item_id , "name"  );
	--local row_name = SelectCell( T_ITEM, item.item_id, "name" );
	local row_name = GetItemName( item.item_id, G_ITEMTYPE_SHOP );
    nameLab:SetText(  row_name );
    
    --限制
    local limitLab = GetLabel( view, limit );
    local lv = msg_cache.msg_player.Level;
    local row_limitLv = SelectRowInner( T_SHOP, "item_id", item.item_id , "level_limit"  );
    local num = item.num;
    local row_limitNum = SelectRowInner( T_SHOP, "item_id", item.item_id , "num_limit"  );
    limitLab:SetText( row_limitLv ..  "级以上可以购买" );
    
    --购买按钮
    local buyBtn = GetButton( view , buy );
    buyBtn:SetEnabled( false );
    buyBtn:SetLuaDelegate( p.OnGachaUIEvent );
    buyBtn:SetId( index );
    
    --已达到限制购买等级
    if tonumber( lv ) >= tonumber( row_limitLv ) then
        --如有物品有购买次数限制
        if tonumber( row_limitNum ) ~= 0 then
            --未打到购买上线
            if tonumber( num ) ~= tonumber( row_limitNum ) then
                limitLab:SetText(  "仅限购买"..row_limitNum.."次".."("..num.."/"..row_limitNum..")");
                buyBtn:SetEnabled( true );
            else
                limitLab:SetText( "已购买"..num.."/"..row_limitNum.."次");
            end
        --没有购买限制
        else
            limitLab:SetText(""); --不显示内容     
            buyBtn:SetEnabled( true );
        end
    end
    
    
    local row_price = SelectRowInner( T_SHOP, "item_id", item.item_id , "price");
    local row_rebatePrice = SelectRowInner( T_SHOP, "item_id", item.item_id , "rebate_price");
    local priceLab = GetLabel( view, price );
    local rebatePriceLab = GetLabel( view, rebateprice );
    --有折扣价
    if tonumber( row_rebatePrice ) ~= 0 then
        priceLab:SetText(  row_price );
        priceLab:SetCenterline( true );
        priceLab:SetCenterlineColor( priceLab:GetFontColor() );
        
        rebatePriceLab:SetText(  row_rebatePrice );
    --无折扣
    else
		rebatePriceLab:SetText( row_price );
		
		priceLab:SetVisible( false );
		local label = GetLabel( view, priceLabel );
		label:SetVisible( false );

		local pic = GetImage( view, emoneyPic );
		pic:SetVisible( false );
		
		pic = GetImage( view, linePic);
		pic:SetVisible( false );
    end
	--道具说明（暂无）
	local descLabel = GetLabel( view, desc );
	descLabel:SetText( SelectCell( T_ITEM, item.item_id, "description" ) );
	
	--道具图片
	local image = GetImage( view, picture );
	--local imageData = GetPictureByAni( SelectCell( T_ITEM, item.item_id , "item_pic" ) ,0 );
	local imageData = GetItemPic( item.item_id, G_ITEMTYPE_SHOP );
	if image and imageData then
		image:SetPicture( imageData );
	end
	
	--如果是礼包项
	if position == GIFT_LEFT  then
	   local lookBtn = GetButton( view, ui_shop_gift_pack_view.ID_CTRL_BUTTON_LOOK_L);
	   lookBtn:SetLuaDelegate( p.OnGiftUIEvent );
	   lookBtn:SetId( index );
	end
end

function p.ShowBagItemInfo( view, item, itemIndex )
    local itemBtn = nil;
    local itemNum = nil;
    local itemName = nil;
	local equipStarPic = nil;
	local subTitleBg = nil;
    local isUse = nil;
	local ui_list = ui_bag_list;
	
	if itemIndex == 1 then
        itemBtn = ui_list.ID_CTRL_BUTTON_ITEM1;
        itemNum = ui_list.ID_CTRL_TEXT_ITEMNUM1;
		equipLevel = ui_list.ID_CTRL_TEXT_EQUIP_LEV1
        isUse = ui_list.ID_CTRL_PICTURE_EQUIP1;
		boxFrame = ui_list.ID_CTRL_PICTURE_91;
		numBg = ui_list.ID_CTRL_PICTURE_NUM_BG1;
		--subTitleBg = ui_list.ID_CTRL_PICTURE_22;
        --itemName = ui_list.ID_CTRL_TEXT_ITEMNAME1;
		--equipStarPic = ui_list.ID_CTRL_PICTURE_STAR1;
	elseif itemIndex == 2 then
        itemBtn = ui_list.ID_CTRL_BUTTON_ITEM2;
        itemNum = ui_list.ID_CTRL_TEXT_ITEMNUM2;
		equipLevel = ui_list.ID_CTRL_TEXT_EQUIP_LEV2
        isUse = ui_list.ID_CTRL_PICTURE_EQUIP2;
		boxFrame = ui_list.ID_CTRL_PICTURE_92;
		numBg = ui_list.ID_CTRL_PICTURE_NUM_BG2;
		--subTitleBg = ui_list.ID_CTRL_PICTURE_23;
        --itemName = ui_list.ID_CTRL_TEXT_ITEMNAME2;
		--equipStarPic = ui_list.ID_CTRL_PICTURE_STAR2;
	elseif itemIndex == 3 then
        itemBtn = ui_list.ID_CTRL_BUTTON_ITEM3;
        itemNum = ui_list.ID_CTRL_TEXT_ITEMNUM3;
		equipLevel = ui_list.ID_CTRL_TEXT_EQUIP_LEV3
        isUse = ui_list.ID_CTRL_PICTURE_EQUIP3;
		boxFrame = ui_list.ID_CTRL_PICTURE_93;
		numBg = ui_list.ID_CTRL_PICTURE_NUM_BG3;
		--subTitleBg = ui_list.ID_CTRL_PICTURE_24;
        --itemName = ui_list.ID_CTRL_TEXT_ITEMNAME3;
		--equipStarPic = ui_list.ID_CTRL_PICTURE_STAR3;
	elseif itemIndex == 4 then
        itemBtn = ui_list.ID_CTRL_BUTTON_ITEM4;
        itemNum = ui_list.ID_CTRL_TEXT_ITEMNUM4;

		equipLevel = ui_list.ID_CTRL_TEXT_EQUIP_LEV4
        isUse = ui_list.ID_CTRL_PICTURE_EQUIP4;
		boxFrame = ui_list.ID_CTRL_PICTURE_94;
		numBg = ui_list.ID_CTRL_PICTURE_NUM_BG4;
		--subTitleBg = ui_list.ID_CTRL_PICTURE_25;
        --itemName = ui_list.ID_CTRL_TEXT_ITEMNAME4;
		--equipStarPic = ui_list.ID_CTRL_PICTURE_STAR4;
	elseif itemIndex == 5 then
        itemBtn = ui_list.ID_CTRL_BUTTON_ITEM5;
		boxFrame = ui_list.ID_CTRL_PICTURE_95;
		numBg = ui_list.ID_CTRL_PICTURE_NUM_BG5;
        itemNum = ui_list.ID_CTRL_TEXT_ITEMNUM5;
        isUse = ui_list.ID_CTRL_PICTURE_EQUIP5;
		equipLevel = ui_list.ID_CTRL_TEXT_EQUIP_LEV5
	end
	--显示边框
	local boxFramePic = GetImage(view,boxFrame);
	boxFramePic:SetPicture( GetPictureByAni("common_ui.frame", 0) );
	--显示名字背景图片
	--local subTitleBgPic = GetImage(view,subTitleBg);
	--subTitleBgPic:SetPicture( GetPictureByAni("common_ui.levelBg", 0) );

	local item_id = tonumber(item.Item_id);
	local itemType = tonumber(item.Item_type);
	local itemUniqueId = tonumber(item.id);
	local itemTable = nil;
	if itemType == 2 then
		itemTable = SelectRowInner(T_EQUIP,"id",item_id);
	--elseif itemType == 0 or itemType == 4 or itemType == 5 or itemType == 6 then
	else
		itemTable = SelectRowInner(T_ITEM,"id",item_id);
	end
	if itemTable == nil then
		WriteConErr("itemTable error ");
	end
	
	local aniIndex = "item."..item_id;
	if rtype == 2 then
			aniIndex = "card_icon."..item_id;
	elseif rtype == 4 then
			aniIndex = "ui.emoney"
	elseif rtype == 6 then
			aniIndex = "ui.money"
	elseif rtype == 5 then
			aniIndex = "ui.soul"
	end

	--显示物品图片
	local itemButton = GetButton(view, itemBtn);
    itemButton:SetImage( GetPictureByAni(aniIndex,0) );
	itemButton:SetId(item_id);
    itemButton:SetUID(itemUniqueId);
	itemButton:SetXID(itemType);
	
	--物品名字
	--local itemNameText = GetLabel(view,itemName );
	--itemNameText:SetText(itemTable.name);
	
	local itemNumText = GetLabel(view,itemNum );	--物品数量
	--local equipStarPic = GetImage(view,equipStarPic);	--装备星级
	local equipLevelText = GetLabel(view,equipLevel);	--装备等级
	local isUsePic = GetImage(view,isUse);			--是否装备
	itemNumText:SetVisible( false );
	--equipStarPic:SetVisible( false );
	equipLevelText:SetVisible( false );
	isUsePic:SetVisible( false );

	if itemType == 0 or itemType == 4 or itemType == 5 or itemType == 6 then
	--普通可叠加物品，显示数量
		itemNumText:SetVisible(true);
		itemNumText:SetText("X "..item.Num);
	--显示数量背景
		local numBgPic = GetImage(view,numBg);
		numBgPic:SetPicture( GetPictureByAni("common_ui.levelBg", 0) );
	elseif itemType == 3 then 
		--装备，显示星级
		-- equipStarPic:SetVisible(true);
		-- local starNum = tonumber(item.Rare);
		-- if starNum == 0 then
			-- equipStarPic:SetVisible(false);
		-- else
			-- equipStarPic:SetPicture( GetPictureByAni("common_ui.equipStar", starNum) );
		-- end
		--显示装备等级
		equipLevelText:SetVisible(true);
		equipLevelText:SetText("LV"..item.Equip_level);
		--是否装备
		if item.Is_dress == 1 or item.Is_dress == "1" then
			isUsePic:SetVisible(true);
			isUsePic:SetPicture( GetPictureByAni("common_ui.equipUse", 0) );
		end
	end
	
	--设置物品按钮事件
	itemButton:SetLuaDelegate(p.OnBagItemClickEvent);
	
end

--请求gacha数据回调函数
function p.ShowGachaData( gachadata )
	curPage = SHOP_GACHA;
	
	if gachadata == nil then
		p.rmb = nil;
		p.ReqGachaData();
		return;
	end
	
    p.gachaList:SetVisible( true );
    p.shopItemList:SetVisible( false ); 
    p.shopPackList:SetVisible( false );
	p.bagList:SetVisible( false );
	p.SetBagUseVisible(false);
    
    p.gachaBtn:SetChecked( true );
    p.shopPackBtn:SetChecked( false );
	p.bagBtn:SetChecked( false );
    p.shopItmeBtn:SetChecked( false );
    
    p.gachaList:ClearView();
	
    p.gachadata = gachadata;
	
	if p.rmb == nil then
		p.rmb = tonumber(gachadata.emoney);
	end
	
    --元宝值
    local rmbLab = GetLabel( p.layer, ui_dlg_gacha.ID_CTRL_TEXT_RMB );
    rmbLab:SetText( tostring( p.rmb ));

	local gacha = gachadata.gachaData or {};
	local curTime = os.time();
	
	for i=1,#gacha do
		local view = createNDUIXView();
		view:Init();
		LoadUI("gacha_list_view.xui", view, nil);
		local bg = GetUiNode(view,ui_gacha_list_view.ID_CTRL_PICTURE_BG);
		view:SetViewSize( bg:GetFrameSize());

		local gachaName = GetLabel( view, ui_gacha_list_view.ID_CTRL_TEXT_GACHANAME );
		local gachaPic = GetImage( view, ui_gacha_list_view.ID_CTRL_PICTURE_PIC );
		local gachaOneBtn = GetButton( view, ui_gacha_list_view.ID_CTRL_BUTTON_ONE );
		local gachaFewBtn = GetButton( view, ui_gacha_list_view.ID_CTRL_BUTTON_TEN );
		local gachaFreeTime = GetLabel( view, ui_gacha_list_view.ID_CTRL_TEXT_FREE_TIME );
		
		local gachaOneNum = GetLabel( view, ui_gacha_list_view.ID_CTRL_TEXT_EMONEY_ONCE );
		local gachaOnePic = GetImage( view, ui_gacha_list_view.ID_CTRL_PICTURE_12 );
		local gachaFewNum = GetLabel( view, ui_gacha_list_view.ID_CTRL_TEXT_EMONEY_SOMETIMES );
		
		local gachaFreeMsg = GetLabel( view, ui_gacha_list_view.ID_CTRL_TEXT_FREE_MSG );
		
		local gachaid = gacha[i].Gacha_id;
		view:SetId( tonumber(gachaid) );
		
		p.freeTimeList[i] = gachaFreeTime;
		
		--免费时间大于当前时间，则进行倒计时
		if gacha[i]. Gacha_endtime > curTime then
			gachaOneNum:SetVisible(true);
			gachaOnePic:SetVisible(true);
			gachaFreeMsg:SetVisible(false);
		else
			gachaOneNum:SetVisible(false);
			gachaOnePic:SetVisible(false);
			gachaFreeMsg:SetVisible(true);
			gachaFreeTime:SetText( "当前可以进行免费扭蛋！" );
		end
		
		gachaName:SetText( gacha[i].Name );
		gachaPic:SetPicture( GetPictureByAni( "gacha_pic." .. gachaid, 0 ) );
		
		gachaOneBtn:SetLuaDelegate(p.OnGachaUIEvent);
		gachaFewBtn:SetLuaDelegate(p.OnGachaUIEvent);
		
		gachaOneNum:SetText( SelectCell( T_GACHA, gachaid, "single_gacha_cost") );
		gachaFewNum:SetText( SelectCell( T_GACHA, gachaid, "complex_gacha_cost") );

		p.gachaList:AddView( view );
	end
	
	p.RefreshFreeTime();
end

--获取扭蛋代币数量配置
function p.GetCoinCost()
	local t = {};
	local k = {};
    for i=1, 6 do
        t[i] = SelectCell( T_GACHA, tostring(i), "need_coin_num" );
        k[i] = SelectCell( T_GACHA, tostring(i), "need_rebate_num" );
    end
    for j=1, 6 do
        if k[j] ~= "0" then 
            t[j] = k[j];        
        end
    end
    p.coin_config = t;
end

--根据所有代币数量设置扭蛋按钮
function p.SetGachaBtnByCoin(index)
    if index == 1 then
        if tonumber(p.pt) >= tonumber(p.coin_config[1]) then
             p.gachaBtnlist[1]:SetEnabled( true );
        end
        if tonumber(p.pt) >= tonumber(p.coin_config[2]) then
            p.gachaBtnlist[2]:SetEnabled( true );
        end     
    elseif index == 2 then
        if tonumber(p.rmb) >= tonumber(p.coin_config[3]) then
            p.gachaBtnlist[3]:SetEnabled( true );
        end
        if tonumber(p.rmb) >= tonumber(p.coin_config[4]) then
            p.gachaBtnlist[4]:SetEnabled( true );
        end
    elseif index == 3 then
        if tonumber(p.rmb) >= tonumber(p.coin_config[5]) then
            p.gachaBtnlist[5]:SetEnabled( true );
        end
        if tonumber(p.rmb) >= tonumber(p.coin_config[6]) then
            p.gachaBtnlist[6]:SetEnabled( true );
        end
    end 	
end

--设置"使用"栏不可见
function p.SetBagUseVisible(visible)
	local useBtn = GetButton(p.layer, ui_dlg_gacha.ID_CTRL_BUTTON_USE);
	useBtn:SetVisible(visible);
	local useTextPic = GetImage(p.layer,ui_dlg_gacha.ID_CTRL_PICTURE_LABEL_USE);
	useTextPic:SetVisible(visible);
	local itemDescribeText = GetLabel(p.layer,ui_dlg_gacha.ID_CTRL_TEXT_ITEM_INFO );
	itemDescribeText:SetVisible(visible);
	
	local bg = GetImage(p.layer,ui_dlg_gacha.ID_CTRL_PICTURE_USE);
	bg:SetVisible(visible);
	
end

--点击物品事件
function p.OnBagItemClickEvent(uiNode, uiEventType, param)
	local itemId = uiNode:GetId();
	local itemUniqueId = uiNode:GetUID();
	local itemType = uiNode:GetXID();

	if itemType == 3 then
		pack_box_equip.ShowEquip(itemId,itemUniqueId,itemType);
		local useBtn = GetButton(p.layer, ui_dlg_gacha.ID_CTRL_BUTTON_USE);
		useBtn:SetVisible(false);
		local useTextPic = GetImage(p.layer,ui_dlg_gacha.ID_CTRL_PICTURE_LABEL_USE);
		useTextPic:SetVisible(false);
		local itemDescribeText = GetLabel(p.layer,ui_dlg_gacha.ID_CTRL_TEXT_ITEM_INFO );
		itemDescribeText:SetText(" ");
		local bg = GetImage(p.layer,ui_dlg_gacha.ID_CTRL_PICTURE_USE);
		bg:SetVisible(false);
	else
		local itemDescribeText = GetLabel(p.layer,ui_dlg_gacha.ID_CTRL_TEXT_ITEM_INFO );
		local itemData = SelectRowInner(T_ITEM,"id",itemId);
		if itemData == nil then
			WriteConErr("itemTable error ");
		end
		itemDescribeText:SetText(itemData.description);
	
		local useBtn = GetButton(p.layer, ui_dlg_gacha.ID_CTRL_BUTTON_USE);
		useBtn:SetLuaDelegate(p.OnUseItemClickEvent);
		useBtn:SetVisible(true);
		useBtn:SetId(itemId);
		useBtn:SetUID(itemUniqueId);
		useBtn:SetXID(itemType);
		useBtn:SetZOrder(9999);
		
		local useTextPic = GetImage(p.layer,ui_dlg_gacha.ID_CTRL_PICTURE_LABEL_USE);
		useTextPic:SetVisible(true);
		itemDescribeText:SetVisible(true);
		local bg = GetImage(p.layer,ui_dlg_gacha.ID_CTRL_PICTURE_USE);
		bg:SetVisible(true);
	end
	p.SetItemChechedFX(uiNode);
end

--设置选中物品
function p.SetItemChechedFX(uiNode)
	local itemNode = ConverToButton( uiNode );
	if p.itemBtnNode ~= nil then
		p.itemBtnNode:RemoveAllChildren(true);
	end
	p.ShowSelectEffect(itemNode)
	p.itemBtnNode = itemNode;
end

function p.ShowSelectEffect(uiNode)
	local view = createNDUIXView();
	view:Init();
	LoadUI("bag_item_select.xui",view,nil);
	local bg = GetUiNode( view, ui_bag_item_select.ID_CTRL_PICTURE_1);
	view:SetViewSize( bg:GetFrameSize());
	view:SetTag(ui_bag_item_select.ID_CTRL_PICTURE_1);
	uiNode:AddChild( view );
end

--点击使用物品事件
function p.OnUseItemClickEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent(uiEventType) then
		if(ui_dlg_gacha.ID_CTRL_BUTTON_USE == tag) then --使用
			local itemId = uiNode:GetId();
			local itemUniqueId = uiNode:GetUID();
			local itemType = uiNode:GetXID();
			WriteCon("Use itemId = "..itemId);
			WriteCon("Use itemUniqueId = "..itemUniqueId);
			WriteCon("Use itemType = "..itemType);
			if itemId == 0 or itemId == nil then
				WriteConErr("used Button id error ");
				return
			end
			pack_box_mgr.UseItemEvent(itemId,itemUniqueId,itemType);
			p.SetBagUseVisible(false)
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
	gNotify:UnregisterAllEvent( "msg_player", p );
	
	if p.layer ~= nil then
		if p.idTimerRefresh then
			KillTimer( p.idTimerRefresh );
			p.idTimerRefresh = nil;
		end
		
	    p.layer:LazyClose();
        p.layer = nil;
		
		--扭蛋参数
		p.gacha_id = nil;
		p.charge_type = nil;
		p.gacha_type = nil;

		p.gachaIndex = nil;

		p.gachaList = nil;
		p.shopItemList = nil;
		p.shopPackList = nil;
		p.bagList	= nil;
		p.gachaBtn = nil;
		p.shopItmeBtn = nil;
		p.shopPackBtn = nil;
		p.bagBtn = nil;

		--存放商品列表信息
		p.shopData = nil;
		--存放礼包列表信息
		p.giftData = nil;
		
		p.intent = nil;
		p.timezj = nil; --中级扭蛋时间
		p.timegj = nil; --高级扭蛋时间

		p.gachadata = nil;
		p.rmb = nil; --元宝值
		p.pt  = nil; --pt值
		p.idTimerRefresh = nil;
		p.freeTimeList = {};
		--p.timerIDList = {};
		p.coin_config = {};
		p.gachaBtnlist = {};
		p.useTicketSign = 0;

		p.requestFlag = false;
		
		--maininterface.ShowUI();
    end
end

function p.UIDisappear()
	p.CloseUI();
	
	maininterface.BecomeFirstUI();
end

function p.UpdateRmb( emoney )
	if p.layer == nil then
		return;
	end
	
	p.rmb = tonumber(emoney);
	
	--元宝值
    local rmbLab = GetLabel( p.layer, ui_dlg_gacha.ID_CTRL_TEXT_RMB );
    rmbLab:SetText( tostring( p.rmb ));
end

function p.UpdateMailNum()
	if p.layer == nil then
		return;
	end
	
	dlg_msgbox.ShowOK( "提示", "背包已满，请查看系统邮件", nil, p.layer );
end

function p.DidAddEmoney( flag )
	--充值流程
	if flag then
		
	end
end
