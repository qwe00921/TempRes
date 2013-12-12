--------------------------------------------------------------
-- FileName: 	dlg_gacha.lua
-- author:		zjj, 2013/08/19
-- purpose:		Ť������
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
p.timezj = nil; --�м�Ť��ʱ��
p.timegj = nil; --�߼�Ť��ʱ��

p.gachadata = nil;
p.rmb = nil; --Ԫ��ֵ
p.pt  = nil; --ptֵ
p.idTimerRefresh = nil;
p.freeTimeList = {};
--p.timerIDList = {};
p.coin_config = {};
p.gachaBtnlist = {};
p.useTicketSign = 0;

--Ť������
p.gacha_id = nil;
p.charge_type = nil;
p.gacha_type = nil;

p.gachaIndex = nil;

p.gachaList = nil;
p.shopItemList = nil;
p.shopPackList = nil;
p.gachaBtn = nil;
p.shopItmeBtn = nil;
p.shopPackBtn = nil;

--�����Ʒ�б���Ϣ
p.shopData = nil;
--�������б���Ϣ
p.giftData = nil;

p.requestFlag = false;
p.clickEvent = false;

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

--��ʾUI
function p.ShowUI( intent )
	dlg_menu.SetNewUI( p );
	
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
	layer:SetSwallowTouch(false);
	
	p.layer = layer;
	p.SetDelegate();
	
	if intent == SHOP_GACHA then
	   p.ShowGachaData();
	elseif intent == SHOP_ITEM then
	   p.ShowShopData();
	elseif intent == SHOP_GIFT_PACK then 
	   p.ShowGiftPackData();
	end
end

--�����¼�����
function p.SetDelegate()
    p.GetCoinCost();
	--���ذ�ť
	local backBtn = GetButton(p.layer,ui_dlg_gacha.ID_CTRL_BUTTON_BACK);
    backBtn:SetLuaDelegate(p.OnGachaUIEvent);
	
	--Ť������
	p.gachaBtn = GetButton(p.layer,ui_dlg_gacha.ID_CTRL_BUTTON_GACHAUI);
	p.gachaBtn:SetLuaDelegate(p.OnGachaUIEvent);
	
    --�̵갴ť
    p.shopItmeBtn = GetButton(p.layer,ui_dlg_gacha.ID_CTRL_BUTTON_ITEMUI); 
    p.shopItmeBtn:SetLuaDelegate(p.OnGachaUIEvent);
    
    --�����ť
    p.shopPackBtn = GetButton(p.layer,ui_dlg_gacha.ID_CTRL_BUTTON_GIFT_PACKUI);
    p.shopPackBtn:SetLuaDelegate(p.OnGachaUIEvent);
    
    --��ֵ
    local payBtn = GetButton(p.layer,ui_dlg_gacha.ID_CTRL_BUTTON_PAY);
    payBtn:SetLuaDelegate(p.OnGachaUIEvent);
    
	--[[
    --����б�
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
     
    --��һ�����
    local nextAdBtn = GetButton( p.layer,ui_dlg_gacha.ID_CTRL_BUTTON_AD_NEXT);
    nextAdBtn:SetLuaDelegate(p.OnGachaUIEvent);
    --��һ�����
    local lastAdBtn = GetButton( p.layer,ui_dlg_gacha.ID_CTRL_BUTTON_AD_LAST);
    lastAdBtn:SetLuaDelegate(p.OnGachaUIEvent);
    --]]

    --Ť���б�
    p.gachaList = GetListBoxVert( p.layer, ui_dlg_gacha.ID_CTRL_VERTICAL_LIST_GACHA);
    
    --�̵��б�
    p.shopItemList = GetListBoxVert( p.layer, ui_dlg_gacha.ID_CTRL_VERTICAL_LIST_SHOP_ITEM);
    
    --����б�
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

	if not p.clickEvent and (IsClickEvent( uiEventType ) or IsDoubleEvent( uiEventType ))  then
		p.clickEvent = true;
		if ( ui_dlg_gacha.ID_CTRL_BUTTON_BACK == tag ) then  
			p.CloseUI();
			maininterface.BecomeFirstUI();
		--[[
	   elseif ( ui_dlg_gacha.ID_CTRL_BUTTON_AD_NEXT == tag ) then  
	       local adList = GetListBoxHorz( p.layer, ui_dlg_gacha.ID_CTRL_LIST_AD);
	       adList:MoveToNextView();
	       
	   elseif ( ui_dlg_gacha.ID_CTRL_BUTTON_AD_LAST == tag ) then  
	       local adList = GetListBoxHorz( p.layer, ui_dlg_gacha.ID_CTRL_LIST_AD);
           adList:MoveToPrevView();
           --]]
			p.clickEvent = false; 
		elseif ( ui_dlg_gacha.ID_CTRL_BUTTON_GACHAUI == tag ) then  --Ť�����水ť
			WriteCon( "Ť�����水ť" );
			--p.ReqGachaData();
			p.ShowGachaData( p.gachadata );
			p.clickEvent = false; 
		elseif ( ui_dlg_gacha.ID_CTRL_BUTTON_ITEMUI == tag ) then  --�̵���水ť
			WriteCon( "�̵���水ť" );
			p.ShowShopData( p.shopData );
			p.clickEvent = false; 
		elseif ( ui_dlg_gacha.ID_CTRL_BUTTON_GIFT_PACKUI == tag ) then  --������水ť
			WriteCon( "������水ť" );
			p.ShowGiftPackData( p.giftData );
			p.clickEvent = false; 
		elseif ( ui_dlg_gacha.ID_CTRL_BUTTON_PAY == tag) then --��ֵ��ť
			WriteCon( "��ֵ��ť" );
			p.clickEvent = false; 
       --��Ʒ����ť    
       --elseif ( ui_shop_item_view.ID_CTRL_BUTTON_BUY_L == tag or  ui_shop_item_view.ID_CTRL_BUTTON_BUY_R == tag) then 
		elseif ( ui_shop_item_view.ID_CTRL_BUTTON_BUY_L == tag ) then 
			WriteCon( "�̳ǹ���" );
			local item = p.shopData.list[uiNode:GetId()];
			dlg_buy_num.ShowUI( item );
			p.clickEvent = false; 
       --�������ť    
       --elseif ( ui_shop_gift_pack_view.ID_CTRL_BUTTON_BUY_L == tag or  ui_shop_gift_pack_view.ID_CTRL_BUTTON_BUY_R == tag) then 
		elseif ( ui_shop_gift_pack_view.ID_CTRL_BUTTON_BUY_L == tag ) then 
			WriteCon( "�������" );
			local gift = p.giftData.list[uiNode:GetId()];
			dlg_buy_num.ShowUI( gift );
			p.clickEvent = false; 
           --p.ReqGiftPackBuy( giftid );
		
		
		elseif ui_gacha_list_view.ID_CTRL_BUTTON_ONE == tag then
			--����Ť��
			local id = uiNode:GetParent():GetId();
			local curTime = os.time();
			local freeTime = p.gachadata.gachaData[id].Gacha_endtime;
			if freeTime <= curTime then
				--���
				local gacha_id = tonumber(p.gachadata.gachaData[id].Gacha_id);
				p.charge_type = 1;
				p.gacha_type = 1;
				p.gacha_id = gacha_id;
				p.ReqStartGacha( p.gacha_id, p.charge_type, p.gacha_type);
			else
				local gacha_id = tonumber(p.gachadata.gachaData[id].Gacha_id);
				local needRmb = tonumber(SelectCell( T_GACHA, tostring(gacha_id), "single_gacha_cost"));

				if p.rmb < needRmb then
					WriteCon("**Ť��������Ҳ���**");
				else
					--����
					p.charge_type = 2;
					p.gacha_type = 1;
					p.gacha_id = gacha_id;
					p.ReqStartGacha( p.gacha_id, p.charge_type, p.gacha_type);
				end
			end
		elseif ui_gacha_list_view.ID_CTRL_BUTTON_TEN == tag then
			--N��Ť��
			local id = uiNode:GetParent():GetId();
			local gacha_id = tonumber(p.gachadata.gachaData[id].Gacha_id);
			local needRmb = tonumber(SelectCell( T_GACHA, tostring(gacha_id), "complex_gacha_cost"));
			if p.rmb < needRmb then
				WriteCon("**Ť��������Ҳ���**");
			else
				--����
				p.charge_type = 2;
				p.gacha_type = 2;
				p.gacha_id = gacha_id;
				p.ReqStartGacha( p.gacha_id, p.charge_type, p.gacha_type);
			end
			
		--[[
		elseif ( ui_gacha_list_view.ID_CTRL_BUTTON_ONE == tag ) then  
			--ptŤ��
			if uiNode:GetId() == 1 then
				local coin_num = p.coin_config[1];
                p.gachaIndex = 1;
                dlg_msgbox.ShowYesNo(GetStr("msg_title_tips"), GetStr("gacha_need") ..coin_num..GetStr("gacha_pt"), p.OnCostGacha ,layer );
          --�м�Ť��
			elseif uiNode:GetId() == 2 then
                local coin_num = p.coin_config[3];
                p.gachaIndex = 3;
                --����м�Ť��
                if tonumber(p.timezj) <= 0 then
                    dlg_msgbox.ShowYesNo(GetStr( "msg_title_tips" ), GetStr( "gacha_free_one" ), p.OnFreeGacha , layer );
                    return;
                end
                --�м�Ť����Ť��
                if tonumber(p.gachadata.tickets[1].num) >= 1 then
                    p.useTicketSign = 1;
                    dlg_msgbox.ShowYesNo(GetStr( "msg_title_tips" ), GetStr( "gacha_need_zjticket" ), p.OnCostGacha , layer );
                    return;
                end
                --�м�Ԫ��Ť��
                dlg_msgbox.ShowYesNo(GetStr("msg_title_tips"),GetStr("gacha_need") ..coin_num..GetStr("gacha_rmb"), p.OnCostGacha , layer );
           --�߼�Ť��     
			elseif uiNode:GetId() == 3 then
                local coin_num = p.coin_config[5];
                p.gachaIndex = 5;
                --��Ѹ߼�Ť��
                if tonumber(p.timegj) <= 0 then
                    dlg_msgbox.ShowYesNo( GetStr( "msg_title_tips" ), GetStr( "gacha_free_one" ), p.OnFreeGacha , layer );
                    return;
                end
                --�߼�Ԫ��Ť��
                dlg_msgbox.ShowYesNo(GetStr( "msg_title_tips" ), GetStr("gacha_need") .. coin_num ..GetStr("gacha_rmb"), p.OnCostGacha , layer );
			end       
      
		elseif ( ui_gacha_list_view.ID_CTRL_BUTTON_TEN == tag ) then  
           --ptʮ��Ť
			if uiNode:GetId() == 1 then
                local coin_num = SelectCell( T_GACHA, "2",  "need_coin_num" );
                p.gachaIndex = 2;
                dlg_msgbox.ShowYesNo(GetStr( "msg_title_tips" ),GetStr("gacha_need") .. coin_num .. GetStr("gacha_pt"), p.OnCostGacha , layer );
           --�м�ʮ��Ť
			elseif uiNode:GetId() == 2 then
                local coin_num = SelectCell( T_GACHA, "4",  "need_coin_num" );
                p.gachaIndex = 4;
                dlg_msgbox.ShowYesNo(GetStr( "msg_title_tips" ),GetStr("gacha_need") .. coin_num .. GetStr("gacha_rmb"), p.OnCostGacha , layer );
           --�߼�ʮ��Ť
			elseif uiNode:GetId() == 3 then
                local coin_num = SelectCell( T_GACHA, "6",  "need_coin_num" );
                p.gachaIndex = 6;
                dlg_msgbox.ShowYesNo(GetStr( "msg_title_tips" ),GetStr("gacha_need") .. coin_num .. GetStr("gacha_rmb"), p.OnCostGacha , layer );
			end
		--]]   
		end
	end
end

--���Ť���Ի���ص�
function p.OnFreeGacha( result )
    if result then 
		if p.gachaIndex == 3 then  
			p.StartGacha("3", "1", "1");
		elseif p.gachaIndex == 5 then  
			p.StartGacha("5", "1", "1");
		end
    end
end

--Ť����Ϣ��ص�
function p.OnCostGacha( result )
    if result then
        if p.useTicketSign == 1 then   --ʹ���м�Ť����
            p.StartGacha("3", "1", "2");
        elseif p.useTicketSign == 2 then --ʹ�ø߼�Ť����
            p.StartGacha("5", "1", "2");
        elseif p.useTicketSign == 0 then --ʹ�ô���
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

--Ť����ʼ����
function p.StartGacha(gacha_id, gacha_num, charge_type)
	WriteCon("**��ʼŤ��**");
	--����Ť������
	p.gacha_id = gacha_id;
	p.charge_type = charge_type;
	
    local uid = GetUID();
    if uid == 0 then uid = 100 end; 
    local gachaparam = "&gacha_id=" .. gacha_id .. "&gacha_num=" .. gacha_num .."&charge_type=" .. charge_type;
    SendReq("Gacha","Start",uid, gachaparam);
end

--ÿ��ˢ��ʱ��
function p.RefreshFreeTime()
   --ɾ����ʱ
	if p.idTimerRefresh ~= nil then
		KillTimer(p.idTimerRefresh);
		p.idTimerRefresh = nil;
	end
	p.idTimerRefresh = SetTimer(p.onFreeTime,1.0);
	p.onFreeTime();
end

--��ʾˢ��ʱ��
function p.onFreeTime( )
	--[[
	local index = p.timerIDList[idTimer];
	WriteCon(tostring(index));
	local curTime = os.time();
	local freeTime = p.gachadata.gachaData[index].Gacha_endtime ;
	
	if freeTime <= curTime then
		p.freeTimeList[index]:SetText( ToUtf8( "��ǰ���Խ������Ť����" ) );
		KillTimer(idTimer);
		p.timerIDList[idTimer] = nil;
	else
		local secs = freeTime - curTime;
		p.freeTimeList[index]:SetText( ToUtf8( TimeToStr(secs) .. "�����ѳ�ȡ1��") );
		--p.freeTimeList[index]:SetText( ToUtf8("�����ѳ�ȡ1��") );
	end
	--]]
	
	local gachaData = p.gachadata.gachaData or {};
	local curTime = os.time();
	local needTime = false;
	
	for i = 1, #gachaData do
		local gacha = gachaData[i];
		local freeTime = gacha.Gacha_endtime or 0;
		if freeTime <= curTime then
			p.freeTimeList[i]:SetText( ToUtf8( "��ǰ���Խ������Ť����" ) );
		else
			needTime = true;
			local secs = freeTime - curTime;
			p.freeTimeList[i]:SetText( ToUtf8( TimeToStr(secs) .. "�����ѳ�ȡ1��") );
		end
	end
	
	if not needTime then
		KillTimer(p.idTimerRefresh);
		p.idTimerRefresh = nil;
	end
	
	--[[
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
	--]]
end

--����gacha����
function p.ReqGachaData()
	WriteCon("**����gacha����**");
    local uid = GetUID();
    if uid == 0 then uid = 100 end; 
    SendReq("Gacha","GetGachaInfo",uid,"");
end

--�����̳���Ʒ����
function p.ReqShopItem()
	WriteCon("**�����̳���Ʒ����**");
    local uid = GetUID();
    if uid == 0 then uid = 100 end; 
    SendReq("Shop","ShopList",uid,"&type_id=1");
end

--�����������
function p.ReqGitfPack()
    WriteCon("**�����������**");
    local uid = GetUID();
    if uid == 0 then uid = 100 end; 
    SendReq("Shop","ShopList",uid,"&type_id=2");
end

--�����������
function p.ReqGiftPackBuy( giftid )
	WriteCon("**�����������**");
    local uid = GetUID();
    if uid == 0 then uid = 100 end; 
    local num = GetLabel( p.layer, ui_dlg_buy_num.ID_CTRL_TEXT_NUM ):GetText();
    local param = "&type_id=2".."&item_id=" .. giftid .."&num=" .. 1;
    WriteCon( "�������" .. param );
    SendReq("Shop","AddUserItem",uid, param);
end

function p.ReqStartGacha( gacha_id, charge_type, gacha_type)
	if p.requestFlag then
		return;
	end
	
	p.requestFlag = true;
	
	WriteCon("**����ʼŤ��**");
	local uid = GetUID();
    if uid == 0 then uid = 100 end; 
	local param = string.format( "&gacha_id=%d&charge_type=%d&gacha_type=%d", gacha_id, charge_type, gacha_type);
	WriteCon( "Ť��������" .. param );
	SendReq("Gacha","Start",uid, param);
end

--
function p.RequestCallBack()
	p.requestFlag = false;
	p.clickEvent = false;
end

--��ʾ�̳ǵ����б�
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
    
    --�����̳���Ʒ��Ϣ
    p.shopData = shopdata;
    
	if p.rmb == nil then
		p.rmb = tonumber(shopdata.user_coin);
	end
	
    --ˢ�����Ԫ��
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

--��ʾ�̳�����б�
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
    
    --�����̳������Ϣ
	p.giftData = giftdata;
	
	if p.rmb == nil then
		p.rmb = tonumber(giftdata.user_coin);
	end
	
    --ˢ�����Ԫ��
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

--������Ʒ��
function p.HideItemView( view )
	--[[
	local temp = Get9SlicesImage(view , ui_shop_item_view.ID_CTRL_9SLICES_BG_R);
	temp:SetVisible( false );
	temp = GetButton( view ,ui_shop_item_view.ID_CTRL_BUTTON_BUY_R);
	temp:SetVisible( false );
	--]]
end

--���������
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

--��ʾ��Ʒ��Ϣ
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

    --����
    local nameLab = GetLabel( view , name );
    --local row_name = SelectRowInner( T_SHOP, "item_id", item.item_id , "name"  );
	local row_name = SelectCell( T_ITEM, item.item_id, "name" );
    nameLab:SetText(  row_name );
    
    --����
    local limitLab = GetLabel( view, limit );
    local lv = msg_cache.msg_player.Level;
    local row_limitLv = SelectRowInner( T_SHOP, "item_id", item.item_id , "level_limit"  );
    local num = item.num;
    local row_limitNum = SelectRowInner( T_SHOP, "item_id", item.item_id , "num_limit"  );
    limitLab:SetText( row_limitLv .. ToUtf8( "�����Ͽ��Թ���" ));
    
    --����ť
    local buyBtn = GetButton( view , buy );
    buyBtn:SetEnabled( false );
    buyBtn:SetLuaDelegate( p.OnGachaUIEvent );
    buyBtn:SetId( index );
    
    --�Ѵﵽ���ƹ���ȼ�
    if tonumber( lv ) >= tonumber( row_limitLv ) then
        --������Ʒ�й����������
        if tonumber( row_limitNum ) ~= 0 then
            --δ�򵽹�������
            if tonumber( num ) ~= tonumber( row_limitNum ) then
                limitLab:SetText( ToUtf8( "���޹���")..row_limitNum..ToUtf8("��").."("..num.."/"..row_limitNum..")");
                buyBtn:SetEnabled( true );
            else
                limitLab:SetText( ToUtf8("�ѹ���")..num.."/"..row_limitNum..ToUtf8("��"));
            end
        --û�й�������
        else
            limitLab:SetText(""); --����ʾ����     
            buyBtn:SetEnabled( true );
        end
    end
    
    
    local row_price = SelectRowInner( T_SHOP, "item_id", item.item_id , "price");
    local row_rebatePrice = SelectRowInner( T_SHOP, "item_id", item.item_id , "rebate_price");
    local priceLab = GetLabel( view, price );
    local rebatePriceLab = GetLabel( view, rebateprice );
    --���ۿۼ�
    if tonumber( row_rebatePrice ) ~= 0 then
        priceLab:SetText( ToUtf8(  row_price ));
        priceLab:SetCenterline( true );
        priceLab:SetCenterlineColor( priceLab:GetFontColor() );
        
        rebatePriceLab:SetText( ToUtf8( row_rebatePrice ));
    --���ۿ�
    else
		rebatePriceLab:SetText( ToUtf8( row_price ) );
		
		priceLab:SetVisible( false );
		local label = GetLabel( view, priceLabel );
		label:SetVisible( false );

		local pic = GetImage( view, emoneyPic );
		pic:SetVisible( false );
		
		pic = GetImage( view, linePic);
		pic:SetVisible( false );
		--[[ 
        --ԭ�۴���ʾ�ּۣ��޸���ɫ���ּ۴�����
        priceLab:SetText( ToUtf8( row_price ));
        priceLab:SetFontColor( ccc4(255,255,255,255));
        rebatePriceLab:SetText("");
		--]]
    end
	--����˵�������ޣ�
	local descLabel = GetLabel( view, desc );
	descLabel:SetText( SelectCell( T_ITEM, item.item_id, "description" ) );
	
	--����ͼƬ
	local image = GetImage( view, picture );
	local imageData = GetPictureByAni( SelectCell( T_ITEM, item.item_id , "item_pic" ) ,0 );
	if image and imageData then
		image:SetPicture( imageData );
	end
	
	--����������
	if position == GIFT_LEFT  then
	   local lookBtn = GetButton( view, ui_shop_gift_pack_view.ID_CTRL_BUTTON_LOOK_L);
	   lookBtn:SetLuaDelegate( p.OnGiftUIEvent );
	   lookBtn:SetId( index );
	end
end

--����gacha���ݻص�����
function p.ShowGachaData( gachadata )
	if gachadata == nil then
		p.ReqGachaData();
		return;
	end
	
    p.gachaList:SetVisible( true );
    p.shopItemList:SetVisible( false ); 
    p.shopPackList:SetVisible( false );
    
    p.gachaBtn:SetEnabled( false );
    p.shopPackBtn:SetEnabled( true );
    p.shopItmeBtn:SetEnabled( true );
    
    p.gachaList:ClearView();
	
	--[[
	--ɾ����ʱ
	for timer, _ in pairs(p.timerIDList) do
		WriteCon(tostring(timer));
		KillTimer(timer);
	end
	p.timerIDList = {};
	--]]
	
    p.gachadata = gachadata;
	
    p.rmb = tonumber(gachadata.emoney);
    --Ԫ��ֵ
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
		
		--���ʱ����ڵ�ǰʱ�䣬����е���ʱ
		if gacha[i]. Gacha_endtime > curTime then
			--[[
			local timerid = SetTimer( p.onFreeTime, 1.0f );
			p.timerIDList[timerid] = i;
			
			p.onFreeTime(timerid);
			--]]
			
			gachaOneNum:SetVisible(true);
			gachaOnePic:SetVisible(true);
			gachaFreeMsg:SetVisible(false);
		else
			gachaOneNum:SetVisible(false);
			gachaOnePic:SetVisible(false);
			gachaFreeMsg:SetVisible(true);
			gachaFreeTime:SetText( ToUtf8( "��ǰ���Խ������Ť����" ) );
		end
		
		gachaName:SetText( gacha[i].Name );
		gachaPic:SetPicture( GetPictureByAni( "gacha_pic." .. gachaid, 0 ) );
		
		--[[
		gachaOneBtn:SetImage( GetPictureByAni("ui.gacha_btn", 1));
		gachaFewBtn:SetImage( GetPictureByAni("ui.gacha_btn", 2));
		--]]
		
		gachaOneBtn:SetLuaDelegate(p.OnGachaUIEvent);
		gachaFewBtn:SetLuaDelegate(p.OnGachaUIEvent);
		
		gachaOneNum:SetText( SelectCell( T_GACHA, gachaid, "single_gacha_cost") );
		gachaFewNum:SetText( SelectCell( T_GACHA, gachaid, "complex_gacha_cost") );

		p.gachaList:AddView( view );
	end
	
	p.RefreshFreeTime();
end

--��ȡŤ��������������
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

--�������д�����������Ť����ť
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

--���ÿɼ�
function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end

function p.CloseUI()
	if p.layer ~= nil then
		--[[
		--ɾ����ʱ
        for timer, _ in pairs(p.timerIDList) do
			WriteCon(tostring(timer));
			KillTimer(timer);
		end
		p.timerIDList = {};
		--]]
		if p.idTimerRefresh then
			KillTimer( p.idTimerRefresh );
			p.idTimerRefresh = nil;
		end
		
	    p.layer:LazyClose();
        p.layer = nil;
		
		--Ť������
		p.gacha_id = nil;
		p.charge_type = nil;
		p.gacha_type = nil;

		p.gachaIndex = nil;

		p.gachaList = nil;
		p.shopItemList = nil;
		p.shopPackList = nil;
		p.gachaBtn = nil;
		p.shopItmeBtn = nil;
		p.shopPackBtn = nil;

		--�����Ʒ�б���Ϣ
		p.shopData = nil;
		--�������б���Ϣ
		p.giftData = nil;
		
		p.intent = nil;
		p.timezj = nil; --�м�Ť��ʱ��
		p.timegj = nil; --�߼�Ť��ʱ��

		p.gachadata = nil;
		p.rmb = nil; --Ԫ��ֵ
		p.pt  = nil; --ptֵ
		p.idTimerRefresh = nil;
		p.freeTimeList = {};
		--p.timerIDList = {};
		p.coin_config = {};
		p.gachaBtnlist = {};
		p.useTicketSign = 0;

		p.requestFlag = false;
		p.clickEvent = false;
    end
end

function p.UIDisappear()
	p.CloseUI();
end
