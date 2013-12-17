--------------------------------------------------------------
-- FileName: 	dlg_buy_num.lua
-- author:		zjj, 2013/09/11
-- purpose:		购买数量界面
--------------------------------------------------------------

dlg_buy_num = {}
local p = dlg_buy_num;

p.layer = nil;
p.item = nil;
p.maxNum = nil;

p.addNum = nil;

--显示UI
function p.ShowUI( item )
    
    if p.layer ~= nil then
		p.layer:SetVisible( true );
		return;
	end
	
	local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end
	
	layer:NoMask();
	layer:Init();	
	GetUIRoot():AddDlg(layer);
    LoadDlg("dlg_buy_num.xui", layer, nil);
	
	if item ~= nil then
	   p.item = item;
	end
	
	p.layer = layer;
	p.Init( item );
	p.GetMaxNum();
	p.SetDelegate();
end

--初始化界面内容
function p.Init( item )
	--名称
	local nameLab = GetLabel( p.layer, ui_dlg_buy_num.ID_CTRL_TEXT_NAME );
	local row_name = SelectRowInner( T_SHOP, "item_id", item.item_id , "name"  );
	nameLab:SetText( row_name );
	--单价
	local priceLab = GetLabel( p.layer, ui_dlg_buy_num.ID_CTRL_TEXT_PRICE );
	local row_price = SelectRowInner( T_SHOP, "item_id", item.item_id  , "price");
    local row_rebatePrice = SelectRowInner( T_SHOP, "item_id", item.item_id  , "rebate_price");
    if tonumber( row_rebatePrice ) == 0 then
        priceLab:SetText( tostring(row_price));
    else
         priceLab:SetText( tostring(row_rebatePrice));
    end
		
	local pic = GetImage( p.layer, ui_dlg_buy_num.ID_CTRL_PICTURE_ICON );
	local picData = GetPictureByAni( SelectCell( T_ITEM, item.item_id , "item_pic" ) ,0 );
	if pic and picData then
		pic:SetPicture( picData );
	end
	
    p.RefreshTotalPrice();
end

--刷新总价
function p.RefreshTotalPrice()
	local price = tonumber(GetLabel( p.layer, ui_dlg_buy_num.ID_CTRL_TEXT_PRICE ):GetText());
	local num = tonumber(GetLabel( p.layer, ui_dlg_buy_num.ID_CTRL_TEXT_NUM ):GetText());
	local totalPrice = price * num;
	local totalLab = GetLabel( p.layer, ui_dlg_buy_num.ID_CTRL_TEXT_TOTAL );
	totalLab:SetText( tostring( totalPrice));
end

--设置事件处理
function p.SetDelegate()
    --取消
    local cancelBtn = GetButton(p.layer,ui_dlg_buy_num.ID_CTRL_BUTTON_CANCEL);
    cancelBtn:SetLuaDelegate(p.OnBuyNumUIEvent);
    
    --确定
    local okBtn = GetButton(p.layer,ui_dlg_buy_num.ID_CTRL_BUTTON_OK);
    okBtn:SetLuaDelegate(p.OnBuyNumUIEvent);
    
    --减1
    local sub1 = GetButton(p.layer,ui_dlg_buy_num.ID_CTRL_BUTTON_SUB);
    sub1:SetLuaDelegate(p.OnBuyNumUIEvent);
    
    --加1
    local add1 = GetButton(p.layer,ui_dlg_buy_num.ID_CTRL_BUTTON_ADD);
    add1:SetLuaDelegate(p.OnBuyNumUIEvent);
    
    --加2
    local add2 = GetButton(p.layer,ui_dlg_buy_num.ID_CTRL_BUTTON_ADD_2);
    add2:SetLuaDelegate(p.OnBuyNumUIEvent);
    
    --加5
    local add5 = GetButton(p.layer,ui_dlg_buy_num.ID_CTRL_BUTTON_ADD_5);
    add5:SetLuaDelegate(p.OnBuyNumUIEvent);
    
    --加10
    local add10 = GetButton(p.layer,ui_dlg_buy_num.ID_CTRL_BUTTON_ADD_10);
    add10:SetLuaDelegate(p.OnBuyNumUIEvent);
    
    --最大
    local addMax = GetButton(p.layer,ui_dlg_buy_num.ID_CTRL_BUTTON_MAX);    
    addMax:SetLuaDelegate(p.OnBuyNumUIEvent);
    
end

--获取该物品最大购买数量
function p.GetMaxNum()
    --配置购买上限
	local row_limitNum = tonumber(SelectRowInner( T_SHOP,"item_id", p.item.item_id,"num_limit"));
	--已购买数量
	local num = tonumber( p.item.num );
	--可购买数量
	local numByLimit = row_limitNum - num;
	--根据剩余元宝计算可购买数量
	local rmb = tonumber( dlg_gacha.rmb );
	local price = tonumber(GetLabel( p.layer, ui_dlg_buy_num.ID_CTRL_TEXT_PRICE ):GetText());
	local numByRmb = math.floor( rmb / price ); 
	 
	if row_limitNum == 0 then
		p.maxNum = numByRmb;
	else
		p.maxNum = math.min( numByLimit, numByRmb );
	end
end

function p.OnBuyNumUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
	    --取消
		if( ui_dlg_buy_num.ID_CTRL_BUTTON_CANCEL == tag ) then
		      p.CloseUI();
		--确定
		elseif( ui_dlg_buy_num.ID_CTRL_BUTTON_OK == tag ) then
		      p.ReqBuyItem();
		--减1
		elseif( ui_dlg_buy_num.ID_CTRL_BUTTON_SUB == tag ) then
		    local num = tonumber(GetLabel( p.layer, ui_dlg_buy_num.ID_CTRL_TEXT_NUM ):GetText());
		    num = num - 1;
		    if num < 1 then
		       GetLabel( p.layer, ui_dlg_buy_num.ID_CTRL_TEXT_NUM ):SetText( tostring( 1 ));
		    else 
		       GetLabel( p.layer, ui_dlg_buy_num.ID_CTRL_TEXT_NUM ):SetText( tostring( num ));
		    end
		    p.RefreshTotalPrice();
        --加1
        elseif( ui_dlg_buy_num.ID_CTRL_BUTTON_ADD == tag ) then
            p.AddNum( 1 );
        --加2
        elseif( ui_dlg_buy_num.ID_CTRL_BUTTON_ADD_2 == tag ) then
            p.AddNum( 2 );
        --加5
        elseif( ui_dlg_buy_num.ID_CTRL_BUTTON_ADD_5 == tag ) then
            p.AddNum( 5 );
        --加10
        elseif( ui_dlg_buy_num.ID_CTRL_BUTTON_ADD_10 == tag ) then
            p.AddNum( 10 );
        --最大
        elseif( ui_dlg_buy_num.ID_CTRL_BUTTON_MAX == tag ) then
			p.AddNum( p.maxNum - tonumber(GetLabel( p.layer, ui_dlg_buy_num.ID_CTRL_TEXT_NUM ):GetText()) );
            --GetLabel( p.layer, ui_dlg_buy_num.ID_CTRL_TEXT_NUM ):SetText( tostring(p.maxNum) );
		end
	end
end

function p.AddNum( num )
    local addNum = tonumber(GetLabel( p.layer, ui_dlg_buy_num.ID_CTRL_TEXT_NUM ):GetText()) + num;
    --如果大于最大数量则设为最大数量
    if addNum >= p.maxNum then
        GetLabel( p.layer, ui_dlg_buy_num.ID_CTRL_TEXT_NUM ):SetText( tostring(p.maxNum) );
    --后者设为增加后的数量
    else
        GetLabel( p.layer, ui_dlg_buy_num.ID_CTRL_TEXT_NUM ):SetText( tostring(addNum) );
    end 
	p.RefreshTotalPrice();
end

--发送商品购买请求
function p.ReqBuyItem()
	WriteCon("**请求购买**");
    local uid = GetUID();
    if uid == 0 then uid = 100 end; 
    local num = GetLabel( p.layer, ui_dlg_buy_num.ID_CTRL_TEXT_NUM ):GetText();

	if tonumber(num) == 0 then
		dlg_msgbox.ShowOK( ToUtf8( "提示" ), ToUtf8( "购买数量为0" ), nil , p.layer );
		return;
	end
	
	local type_id = tostring( SelectRowInner( T_SHOP, "item_id", p.item.item_id  , "type"));
    local param = "&type_id=" .. type_id .. "&item_id=" .. p.item.item_id .."&num=" .. num;
    WriteCon( "购买参数" .. param );
	p.addNum = num;
    SendReq("Shop","AddUserItem",uid, param);
end

--购买成功回调
function p.BuySuccessResult( msg )
    p.CloseUI();
	if msg~= nil and msg.list ~= nil then
		local item_id = msg.list.item_id or 0 ;
		local num = p.addNum or 0;
		if item_id ~= 0 and num ~= 0 then
			local item_name = SelectCell( T_ITEM, item_id, "name" ) or "";
			dlg_msgbox.ShowOK( ToUtf8( "提示" ), ToUtf8( "你成功购买了" ) .. ToUtf8(tostring(num)) .. ToUtf8("个") .. item_name, p.OnMsgOKClick, p.layer );
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
    end

end

function p.OnMsgOKClick()
	local item_id = p.item.item_id;
	local num_limit = tonumber( SelectRowInner( T_SHOP, "item_id", p.item.item_id  , "num_limit"));
	local type_id = tonumber( SelectRowInner( T_SHOP, "item_id", p.item.item_id  , "type"));
	if num_limit ~= 0 then
		if type_id == 1 then
			dlg_gacha.ReqShopItem();
		elseif type_id == 2 then
			dlg_gacha.ReqGitfPack();
		end
	end
end

