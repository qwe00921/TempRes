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
p.coin_config = {};
p.gachaBtnlist = {};
p.useTicketSign = 0;

--扭蛋参数
p.gacha_id = gacha_id;
p.charge_type = charge_type;

p.gachaIndex = nil;

p.gachaList = nil;
p.shopItemList = nil;
p.shopPackList = nil;
p.gachaBtn = nil;
p.shopItmeBtn = nil;
p.shopPackBtn = nil;

--存放商品列表信息
p.shopData = nil;
--存放礼包列表信息
p.giftData = nil;

--显示UI
function p.ShowUI( intent )
    
    if p.layer ~= nil then
		p.layer:SetVisible( true );
		return;
	end
	
	local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end
	
	if intent ~= nil then
	   p.intent = intent;
	end
	
	layer:Init();	
	GetUIRoot():AddDlg(layer);
    LoadDlg("dlg_gacha.xui", layer, nil);
	
	p.layer = layer;
	p.SetDelegate();
	
	if intent == SHOP_GACHA then
	   p.ReqGachaData();
	elseif intent == SHOP_ITEM then
	   p.ShowShopData();
	elseif intent == SHOP_GIFT_PACK then 
	   p.ShowGiftPackData();
	end
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
end

function p.OnGiftUIEvent( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
		--if ( ui_shop_gift_pack_view.ID_CTRL_BUTTON_LOOK_L == tag or  ui_shop_gift_pack_view.ID_CTRL_BUTTON_LOOK_R == tag ) then  
		if ( ui_shop_gift_pack_view.ID_CTRL_BUTTON_LOOK_L == tag ) then  
			local gift = p.giftData.list[uiNode:GetId()];
			dlg_gift_pack_preview.ShowUI( gift );
		end
	end
end

function p.OnGachaUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
		if ( ui_dlg_gacha.ID_CTRL_BUTTON_BACK == tag ) then  
			p.CloseUI();
		--[[
	   elseif ( ui_dlg_gacha.ID_CTRL_BUTTON_AD_NEXT == tag ) then  
	       local adList = GetListBoxHorz( p.layer, ui_dlg_gacha.ID_CTRL_LIST_AD);
	       adList:MoveToNextView();
	       
	   elseif ( ui_dlg_gacha.ID_CTRL_BUTTON_AD_LAST == tag ) then  
	       local adList = GetListBoxHorz( p.layer, ui_dlg_gacha.ID_CTRL_LIST_AD);
           adList:MoveToPrevView();
           --]]
		elseif ( ui_dlg_gacha.ID_CTRL_BUTTON_GACHAUI == tag ) then  --扭蛋界面按钮
			WriteCon( "扭蛋界面按钮" );
			--p.ReqGachaData();
		elseif ( ui_dlg_gacha.ID_CTRL_BUTTON_ITEMUI == tag ) then  --商店界面按钮
			WriteCon( "商店界面按钮" );
			p.ShowShopData( p.shopData );

		elseif ( ui_dlg_gacha.ID_CTRL_BUTTON_GIFT_PACKUI == tag ) then  --礼包界面按钮
			WriteCon( "礼包界面按钮" );
			p.ShowGiftPackData( p.giftData );
	
		elseif ( ui_dlg_gacha.ID_CTRL_BUTTON_PAY == tag) then --充值按钮
			WriteCon( "充值按钮" );
       
       --商品购买按钮    
       --elseif ( ui_shop_item_view.ID_CTRL_BUTTON_BUY_L == tag or  ui_shop_item_view.ID_CTRL_BUTTON_BUY_R == tag) then 
		elseif ( ui_shop_item_view.ID_CTRL_BUTTON_BUY_L == tag ) then 
			WriteCon( "商城购买" );
			local item = p.shopData.list[uiNode:GetId()];
			dlg_buy_num.ShowUI( item );
           
       --礼包购买按钮    
       --elseif ( ui_shop_gift_pack_view.ID_CTRL_BUTTON_BUY_L == tag or  ui_shop_gift_pack_view.ID_CTRL_BUTTON_BUY_R == tag) then 
		elseif ( ui_shop_gift_pack_view.ID_CTRL_BUTTON_BUY_L == tag ) then 
			WriteCon( "礼包购买" );
			local gift = p.giftData.list[uiNode:GetId()];
			dlg_buy_num.ShowUI( gift );
			
           --p.ReqGiftPackBuy( giftid );
		elseif ( ui_gacha_list_view.ID_CTRL_BUTTON_ONE == tag ) then  
			--pt扭蛋
			if uiNode:GetId() == 1 then
				local coin_num = p.coin_config[1];
                p.gachaIndex = 1;
                dlg_msgbox.ShowYesNo(GetStr("msg_title_tips"), GetStr("gacha_need") ..coin_num..GetStr("gacha_pt"), p.OnCostGacha ,layer );
          --中级扭蛋
			elseif uiNode:GetId() == 2 then
                local coin_num = p.coin_config[3];
                p.gachaIndex = 3;
                --免费中级扭蛋
                if tonumber(p.timezj) <= 0 then
                    dlg_msgbox.ShowYesNo(GetStr( "msg_title_tips" ), GetStr( "gacha_free_one" ), p.OnFreeGacha , layer );
                    return;
                end
                --中级扭蛋卷扭蛋
                if tonumber(p.gachadata.tickets[1].num) >= 1 then
                    p.useTicketSign = 1;
                    dlg_msgbox.ShowYesNo(GetStr( "msg_title_tips" ), GetStr( "gacha_need_zjticket" ), p.OnCostGacha , layer );
                    return;
                end
                --中级元宝扭蛋
                dlg_msgbox.ShowYesNo(GetStr("msg_title_tips"),GetStr("gacha_need") ..coin_num..GetStr("gacha_rmb"), p.OnCostGacha , layer );
           --高级扭蛋     
			elseif uiNode:GetId() == 3 then
                local coin_num = p.coin_config[5];
                p.gachaIndex = 5;
                --免费高级扭蛋
                if tonumber(p.timegj) <= 0 then
                    dlg_msgbox.ShowYesNo( GetStr( "msg_title_tips" ), GetStr( "gacha_free_one" ), p.OnFreeGacha , layer );
                    return;
                end
                --高级元宝扭蛋
                dlg_msgbox.ShowYesNo(GetStr( "msg_title_tips" ), GetStr("gacha_need") .. coin_num ..GetStr("gacha_rmb"), p.OnCostGacha , layer );
			end       
      
		elseif ( ui_gacha_list_view.ID_CTRL_BUTTON_TEN == tag ) then  
           --pt十连扭
			if uiNode:GetId() == 1 then
                local coin_num = SelectCell( T_GACHA, "2",  "need_coin_num" );
                p.gachaIndex = 2;
                dlg_msgbox.ShowYesNo(GetStr( "msg_title_tips" ),GetStr("gacha_need") .. coin_num .. GetStr("gacha_pt"), p.OnCostGacha , layer );
           --中级十连扭
			elseif uiNode:GetId() == 2 then
                local coin_num = SelectCell( T_GACHA, "4",  "need_coin_num" );
                p.gachaIndex = 4;
                dlg_msgbox.ShowYesNo(GetStr( "msg_title_tips" ),GetStr("gacha_need") .. coin_num .. GetStr("gacha_rmb"), p.OnCostGacha , layer );
           --高级十连扭
			elseif uiNode:GetId() == 3 then
                local coin_num = SelectCell( T_GACHA, "6",  "need_coin_num" );
                p.gachaIndex = 6;
                dlg_msgbox.ShowYesNo(GetStr( "msg_title_tips" ),GetStr("gacha_need") .. coin_num .. GetStr("gacha_rmb"), p.OnCostGacha , layer );
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
end

--显示刷新时间
function p.onFreeTime()
    local timetextzj = nil;
    local timetextgj = nil;
    timetextzj = os.date("%H:%M:%S",p.timezj) .. GetStr( "gacha_time" ) ;
    timetextgj = os.date("%H:%M:%S",p.timegj) .. GetStr( "gacha_time" ) ;
    p.freeTimeList[2]:SetText(timetextzj);
    p.freeTimeList[3]:SetText(timetextgj);
    p.timezj = p.timezj - 1;
    p.timegj = p.timegj - 1;
    if tonumber(p.timezj) <= 0 then
         timetextzj = GetStr( "gacha_can_free" );
         p.freeTimeList[2]:SetText(timetextzj);
         p.gachaBtnlist[3]:SetEnabled( true);
         p.timezj = 0;
    end
    if tonumber(p.timegj) <= 0 then  
         timetextgj = GetStr( "gacha_can_free" );
         p.freeTimeList[3]:SetText(timetextgj);
         p.gachaBtnlist[5]:SetEnabled( true);
         p.timegj = 0;
    end
    if tonumber(p.timegj) <= 0 and  tonumber(p.timezj) <= 0 then
          KillTimer(p.idTimerRefresh);
          p.idTimerRefresh = nil;
    end 
end

--请求gacha数据
function p.ReqGachaData()
	WriteCon("**请求gacha数据**");
    local uid = GetUID();
    if uid == 0 then uid = 100 end; 
    SendReq("Gacha","GetGachaInfo",uid,"");
end

--请求商城物品数据
function p.ReqShopItem()
	WriteCon("**请求商城物品数据**");
    local uid = GetUID();
    if uid == 0 then uid = 100 end; 
    SendReq("Shop","ShopList",uid,"&type_id=1");
end

--请求礼包数据
function p.ReqGitfPack()
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

--显示商城道具列表
function p.ShowShopData( shopdata )
	
	if shopdata == nil then
		p.ReqShopItem();
		return;
	end
    
    p.shopItemList:SetVisible( true );
    p.gachaList:SetVisible( false ); 
    p.shopPackList:SetVisible( false );
    
    p.gachaBtn:SetEnabled( true );
    p.shopPackBtn:SetEnabled( true );
    p.shopItmeBtn:SetEnabled( false );
    
    p.shopItemList:ClearView();
    
    --保存商城物品信息
    p.shopData = shopdata;
    
    --刷新玩家元宝
    local rmbLab = GetLabel( p.layer, ui_dlg_gacha.ID_CTRL_TEXT_RMB );
    rmbLab:SetText( tostring(shopdata.user_coin));
    
    local itemList = shopdata.list;
    local listLength = #itemList;
    --local row = math.ceil( listLength / 2 ); --物品行数（一行两个）
    WriteCon( "--" .. listLength .. "**");
    
    for i=1 ,listLength do
		local view = createNDUIXView();
		view:Init();
		LoadUI("shop_item_view.xui", view, nil);
		local bg = GetUiNode(view,ui_shop_item_view.ID_CTRL_PICTURE_BG);
		view:SetViewSize( bg:GetFrameSize());
       
		local itemData = itemList[i];
		p.SetItemInfo( view, itemData, LEFT, i );
		--[[
       local itemLeft = itemList[ 2 * i -1];
       p.SetItemInfo( view , itemLeft , LEFT , 2*i-1);
       if i*2 < listLength then
            local itemRight = itemList[ 2 * i];
            p.SetItemInfo( view, itemRight , RIGHT, 2*i);
       else
            p.HideItemView( view );
       end
	--]]
		p.shopItemList:AddView( view );
    end
    
end

--显示商城礼包列表
function p.ShowGiftPackData( giftdata )
    
	if giftdata == nil then
		p.ReqGitfPack();
		return;
	end
	
	p.shopPackList:SetVisible( true );
	p.gachaList:SetVisible( false ); 
	p.shopItemList:SetVisible( false );
    
	p.gachaBtn:SetEnabled( true );
    p.shopPackBtn:SetEnabled( false );
	p.shopItmeBtn:SetEnabled( true );
	
	p.shopPackList:ClearView();
    
    --保存商城礼包信息
	p.giftData = giftdata;
    --刷新玩家元宝
	local rmbLab = GetLabel( p.layer, ui_dlg_gacha.ID_CTRL_TEXT_RMB );
    rmbLab:SetText( tostring( giftdata.user_coin ));
    
    local giftList = giftdata.list;
    local listLength = #giftList;
    --local row = math.ceil( listLength / 2 ); --物品行数（一行两个）
    
    for i=1 ,listLength do
		local view = createNDUIXView();
		view:Init();
		LoadUI("shop_gift_pack_view.xui", view, nil);
		local bg = GetUiNode(view,ui_shop_gift_pack_view.ID_CTRL_PICTURE_BG);
		view:SetViewSize( bg:GetFrameSize());
       
		local giftData = giftList[i];
		p.SetItemInfo( view , giftData , GIFT_LEFT , i);
	--[[
       if i*2 < listLength then
            local giftRight = giftList[ 2 * i];
            p.SetItemInfo( view, giftRight , GIFT_RIGHT , 2*i );
       else
            p.HideGiftView( view );
       end
       --]]
		p.shopPackList:AddView( view );
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
    
    if position == LEFT then
        name = ui_shop_item_view.ID_CTRL_TEXT_NAME_L;
        limit = ui_shop_item_view.ID_CTRL_TEXT_LIMIT_L;
        price = ui_shop_item_view.ID_CTRL_TEXT_PRICE_L;
        rebateprice = ui_shop_item_view.ID_CTRL_TEXT_REBATE_PRICE_L;
        buy = ui_shop_item_view.ID_CTRL_BUTTON_BUY_L;
    --[[    
    elseif position == RIGHT then
        name = ui_shop_item_view.ID_CTRL_TEXT_NAME_R;
        limit = ui_shop_item_view.ID_CTRL_TEXT_LIMIT_R;
        price = ui_shop_item_view.ID_CTRL_TEXT_PRICE_R;
        rebateprice = ui_shop_item_view.ID_CTRL_TEXT_REBATE_PRICE_R;
        buy = ui_shop_item_view.ID_CTRL_BUTTON_BUY_R;
    --]]
    elseif position == GIFT_LEFT then
        name = ui_shop_gift_pack_view.ID_CTRL_TEXT_NAME_L;
        limit = ui_shop_gift_pack_view.ID_CTRL_TEXT_LIMIT_L;
        price = ui_shop_gift_pack_view.ID_CTRL_TEXT_PRICE_L;
        rebateprice = ui_shop_gift_pack_view.ID_CTRL_TEXT_REBATE_PRICE_L;
        buy = ui_shop_gift_pack_view.ID_CTRL_BUTTON_BUY_L;
    --[[
    elseif position == GIFT_RIGHT then
        name = ui_shop_gift_pack_view.ID_CTRL_TEXT_NAME_R;
        limit = ui_shop_gift_pack_view.ID_CTRL_TEXT_LIMIT_R;
        price = ui_shop_gift_pack_view.ID_CTRL_TEXT_PRICE_R;
        rebateprice = ui_shop_gift_pack_view.ID_CTRL_TEXT_REBATE_PRICE_R;
        buy = ui_shop_gift_pack_view.ID_CTRL_BUTTON_BUY_R;
		--]]
    end

    --名称
    local nameLab = GetLabel( view , name );
    local row_name = SelectRowInner( T_SHOP, "item_id", item.item_id , "name"  );
    nameLab:SetText( tostring( row_name ));
    
    --限制
    local limitLab = GetLabel( view, limit );
    local lv = msg_cache.msg_player.Level;
    local row_limitLv = SelectRowInner( T_SHOP, "item_id", item.item_id , "level_limit"  );
    local num = item.num;
    local row_limitNum = SelectRowInner( T_SHOP, "item_id", item.item_id , "num_limit"  );
    limitLab:SetText( row_limitLv .. ToUtf8( "级以上可以购买" ));
    
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
                limitLab:SetText( ToUtf8( "仅限购买")..row_limitNum..ToUtf8("次").."("..num.."/"..row_limitNum..")");
                buyBtn:SetEnabled( true );
            else
                limitLab:SetText( ToUtf8("已购买")..num.."/"..row_limitNum..ToUtf8("次"));
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
        priceLab:SetText( ToUtf8( "原价:" .. row_price ));
        priceLab:SetCenterline( true );
        priceLab:SetCenterlineColor( priceLab:GetFontColor() );
        
        rebatePriceLab:SetText( ToUtf8( "现价:" .. row_rebatePrice ));
    --无折扣
    else 
        --原价处显示现价，修改颜色，现价处清零
        priceLab:SetText( ToUtf8( "现价:" .. row_price ));
        priceLab:SetFontColor( ccc4(255,255,255,255));
        rebatePriceLab:SetText("");
    end
	--道具说明（暂无）
	
	--如果是礼包项
	if position == GIFT_LEFT  then
	   local lookBtn = GetButton( view, ui_shop_gift_pack_view.ID_CTRL_BUTTON_LOOK_L);
	   lookBtn:SetLuaDelegate( p.OnGiftUIEvent );
	   lookBtn:SetId( index );
	--[[
	elseif position == GIFT_RIGHT then
	   local lookBtn = GetButton( view, ui_shop_gift_pack_view.ID_CTRL_BUTTON_LOOK_R);
       lookBtn:SetLuaDelegate( p.OnGiftUIEvent );
       lookBtn:SetId( index );
	--]]
	end
end

--请求gacha数据回调函数
function p.ShowGachaData(gachadata)

    p.gachaList:SetVisible( true );
    p.shopItemList:SetVisible( false ); 
    p.shopPackList:SetVisible( false );
    
    p.gachaBtn:SetEnabled( false );
    p.shopPackBtn:SetEnabled( true );
    p.shopItmeBtn:SetEnabled( true );
    
    p.gachaList:ClearView();
    p.gachadata = gachadata;
    --设置现实免费扭蛋剩余时间
    p.timezj = gachadata.free_gacha[2].next_free_time;
    p.timegj = gachadata.free_gacha[3].next_free_time;
    p.RefreshFreeTime();
    
    p.pt = gachadata.gacha_point;
    p.rmb = gachadata.rmb;
    --元宝值
    local rmbLab = GetLabel( p.layer, ui_dlg_gacha.ID_CTRL_TEXT_RMB );
    rmbLab:SetText( tostring( p.rmb ));
    
    --pt值
    local ptLab = GetLabel( p.layer, ui_dlg_gacha.ID_CTRL_TEXT_PT );
    ptLab:SetText( tostring(p.pt));
    
	for i=1,3 do
       local view = createNDUIXView();
       view:Init();
       LoadUI("gacha_list_view.xui", view, nil);
       local bg = GetUiNode(view,ui_gacha_list_view.ID_CTRL_PICTURE_BG);
       view:SetViewSize( bg:GetFrameSize());
       
       local gachaName = GetLabel( view , ui_gacha_list_view.ID_CTRL_TEXT_GACHANAME ); -- 扭蛋名称
       local gachaPic = GetImage( view , ui_gacha_list_view.ID_CTRL_PICTURE_PIC ); --扭蛋图片
       local ticketTitle = GetLabel( view, ui_gacha_list_view.ID_CTRL_TEXT_TICKET_TITLE ); 
       local ticketNum = GetLabel( view, ui_gacha_list_view.ID_CTRL_TEXT_TICKET_NUM ); --扭蛋卷数
       local gachaText = GetLabel( view, ui_gacha_list_view.ID_CTRL_TEXT_EXPLAIN );  --扭蛋说明
       local gachaOneBtn = GetButton( view ,ui_gacha_list_view.ID_CTRL_BUTTON_ONE); --免费扭蛋、一次扭蛋按钮
       local gachaTenBtn = GetButton( view ,ui_gacha_list_view.ID_CTRL_BUTTON_TEN); --十年扭按钮
       local gachaFreeTime = GetLabel( view, ui_gacha_list_view.ID_CTRL_TEXT_FREE_TIME ); --免费剩余时间
       p.freeTimeList[i] = gachaFreeTime;
       if i == 1 then
            ticketTitle:SetVisible(false);
            gachaFreeTime:SetVisible(false);
            ticketNum:SetVisible(false);
            gachaName:SetText( GetStr( "gacha_pt" ));
            gachaText:SetText(tostring( SelectCell( T_GACHA, "1",  "description" )));
            gachaPic:SetPicture( GetPictureByAni("ui.gacha_icon", 0));
            gachaOneBtn:SetImage( GetPictureByAni("ui.gacha_btn", 1));
            gachaTenBtn:SetImage( GetPictureByAni("ui.gacha_btn", 2));
            
       elseif i == 2 then
            gachaName:SetText( GetStr( "gacha_zj" ));
            ticketNum:SetText( tostring(gachadata.tickets[1].num) );
            gachaText:SetText(tostring( SelectCell( T_GACHA, "3",  "description" )));
            gachaPic:SetPicture( GetPictureByAni("ui.gacha_icon", 1));
            gachaOneBtn:SetImage( GetPictureByAni("ui.gacha_btn", 3));
            gachaTenBtn:SetImage( GetPictureByAni("ui.gacha_btn", 4));
            
       elseif i == 3 then
            gachaName:SetText( GetStr( "gacha_gj" ));
            ticketNum:SetText( tostring(gachadata.tickets[2].num) );
            gachaText:SetText(tostring( SelectCell( T_GACHA, "5",  "description" )));
            gachaPic:SetPicture( GetPictureByAni("ui.gacha_icon", 2));
            gachaOneBtn:SetImage( GetPictureByAni("ui.gacha_btn", 3));
            gachaTenBtn:SetImage( GetPictureByAni("ui.gacha_btn", 4)); 
       end
       
       gachaOneBtn:SetLuaDelegate(p.OnGachaUIEvent);
       gachaOneBtn:SetId(i);
       gachaOneBtn:SetEnabled( false );
       
       gachaTenBtn:SetLuaDelegate(p.OnGachaUIEvent);
       gachaTenBtn:SetId(i);
       gachaTenBtn:SetEnabled( false );
       
       p.gachaBtnlist[i*2-1] = gachaOneBtn;
       p.gachaBtnlist[i*2] = gachaTenBtn;
       --设置按钮状态
       p.SetGachaBtnByCoin(i);
       
       p.gachaList:AddView(view);      
	end
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
        
        --删除定时
        if p.idTimerRefresh ~= nil then
            KillTimer(p.idTimerRefresh);
            p.idTimerRefresh = nil;
        end
    end
end

