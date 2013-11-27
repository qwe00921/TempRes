--------------------------------------------------------------
-- FileName: 	dlg_gacha_result.lua
-- author:		zjj, 2013/07/22
-- purpose:		扭蛋结果界面
--------------------------------------------------------------

dlg_gacha_result = {}
local p = dlg_gacha_result;

p.layer = nil;
p.msg = nil;

p.cardIndex = 1;
p.cardIdList = {};
p.coin = nil;
p.gacharesult = nil;

--显示UI
function p.ShowUI(gacharesult)
    
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
    LoadDlg("dlg_gacha_result.xui", layer, nil);
	
	p.layer = layer;
	if gacharesult ~= nil then
	   p.gacharesult = gacharesult;
	end
	WriteCon("**扭蛋**1"  );
	
	p.GachaResult(gacharesult);
	p.SetDelegate();
end

--设置事件处理
function p.SetDelegate()
	--再来一次按钮
    p.againBtn = GetButton(p.layer,ui_dlg_gacha_result.ID_CTRL_BUTTON_AGAIN);
    p.againBtn:SetLuaDelegate(p.OnGachaResultUIEvent);
    p.againBtn:SetEnabled( false );
	--继续任务按钮
	local backBtn = GetButton(p.layer,ui_dlg_gacha_result.ID_CTRL_BUTTON_BACK);
    backBtn:SetLuaDelegate(p.OnGachaResultUIEvent);
	
    --下一张按钮
    local nextBtn = GetButton(p.layer,ui_dlg_gacha_result.ID_CTRL_BUTTON_NEXT);
    nextBtn:SetLuaDelegate(p.OnGachaResultUIEvent);
	
	--nextBtn:SetEnabled(#p.cardIdList > p.cardIndex);
end

function p.OnGachaResultUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
		if ( ui_dlg_gacha_result.ID_CTRL_BUTTON_BACK == tag ) then	-- 返回		
			p.CloseUI();
			dlg_gacha.ReqGachaData(); --重载扭蛋界面
		elseif ( ui_dlg_gacha_result.ID_CTRL_BUTTON_AGAIN == tag ) then -- 再扭一次
		    WriteCon("**再次扭蛋**");
            --保存扭蛋参数
            local gacha_id = p.gacharesult.gacha_id;
            local charge_type = dlg_gacha.charge_type;   
            local uid = GetUID();
            if uid == 0 then uid = 100 end; 
            local param = "&gacha_id=" .. gacha_id .."&charge_type=" .. charge_type;
            SendReq("Gacha","Start",uid, param);
			p.CloseUI();
		elseif ( ui_dlg_gacha_result.ID_CTRL_BUTTON_NEXT == tag ) then --下一张
		     p.ShowCardInfo(p.cardIdList[p.cardIndex].id);
		end
	end
end

--根据上一次扭蛋类型判断时候可以继续扭蛋
function p.CanGachaAgain()
    if dlg_gacha.charge_type == "3" then  --如果使用代币
        if tonumber(p.gacharesult.gacha_id) == 1 then --pt一扭
             if tonumber(p.gacharesult.gacha_point) >= tonumber(dlg_gacha.coin_config[1]) then
                    p.againBtn:SetEnabled( true );
             end
        elseif tonumber(p.gacharesult.gacha_id) == 2 then --pt十连扭
             if tonumber(p.gacharesult.gacha_point) >= tonumber(dlg_gacha.coin_config[2]) then
                    p.againBtn:SetEnabled( true );
             end
        elseif tonumber(p.gacharesult.gacha_id) == 3 then --中级一扭
             if tonumber(p.gacharesult.rmb) >= tonumber(dlg_gacha.coin_config[3]) then
                    p.againBtn:SetEnabled( true );
             end
        elseif tonumber(p.gacharesult.gacha_id) == 4 then --中级十连扭
             if tonumber(p.gacharesult.rmb) >= tonumber(dlg_gacha.coin_config[4])  then
                    p.againBtn:SetEnabled( true );
             end
        elseif tonumber(p.gacharesult.gacha_id) == 5 then --高级一扭
             if tonumber(p.gacharesult.rmb) >= tonumber(dlg_gacha.coin_config[5]) then
                    p.againBtn:SetEnabled( true );
             end
        elseif tonumber(p.gacharesult.gacha_id) == 6 then --高级十连扭
             if tonumber(p.gacharesult.rmb) >= tonumber(dlg_gacha.coin_config[6]) then
                    p.againBtn:SetEnabled( true );
             end
        end
    elseif dlg_gacha.charge_type == "2" then  --如果使用扭蛋卷
        if tonumber(p.gacharesult.ticket.num) >= 1 then
                 p.againBtn:SetEnabled( true );
        end
    end
	
end

--扭蛋结果回调
function p.GachaResult(gacharesult)
    p.cardIdList = gacharesult.card_ids;
    p.coin = gacharesult.coin;
    p.ShowCardInfo(p.cardIdList[1].id);
end

--显示卡牌信息
function p.ShowCardInfo(card_id)
    
    if card_id ~= "0" then
        WriteCon("扭蛋id" .. card_id );
		--[[
        --卡牌图片
        local cardPic = GetImage( p.layer,ui_dlg_gacha_result.ID_CTRL_PICTURE_CARD );
        local pic = GetCardPicById( card_id );
        if pic ~= nil then
        	cardPic:SetPicture( pic );
        end
		--]]
        
        --星级
        local rareLab = GetLabel( p.layer, ui_dlg_gacha_result.ID_CTRL_TEXT_RARE );
        rareLab:SetText(SelectCell( T_CARD, card_id, "rare" ));
        --名称
        local cardName = GetLabel( p.layer, ui_dlg_gacha_result.ID_CTRL_TEXT_NAME );
        cardName:SetText( ToUtf8( SelectCell( T_CARD, card_id, "name" )));
        --HP
        local cardHp = GetLabel( p.layer, ui_dlg_gacha_result.ID_CTRL_TEXT_HP );
        cardHp:SetText( SelectCell(T_CARD, card_id, "hp") );
        --攻击
        local cardAtk = GetLabel( p.layer, ui_dlg_gacha_result.ID_CTRL_TEXT_ATK );
        cardAtk:SetText( SelectCell(T_CARD, card_id, "attack") );
        --防御
        local cardDef = GetLabel( p.layer, ui_dlg_gacha_result.ID_CTRL_TEXT_DEF );
        cardDef:SetText( SelectCell(T_CARD, card_id, "defence") );
		--[[
        --技能
        local cardSkill = GetLabel( p.layer, ui_dlg_gacha_result.ID_CTRL_TEXT_SKILL );
        local skill_id = SelectCell( T_CARD, card_id, "skill" );
        if skill_id ~= "0" then
            cardSkill:SetText( SelectCell( T_SKILL, skill_id, "name" ));
        end
		--]]
        --描述
        local description = GetLabel( p.layer, ui_dlg_gacha_result.ID_CTRL_TEXT_DESCRIPTION);
        description:SetText( SelectCell( T_CARD, card_id, "description" ));
    end
    --判断没有后续卡牌 则开始再扭一次判断，并隐藏下一张按钮
    if p.cardIndex == #p.cardIdList then
        local nextBtn = GetButton(p.layer,ui_dlg_gacha_result.ID_CTRL_BUTTON_NEXT);
        nextBtn:SetVisible( false );
        p.CanGachaAgain();
    end
    --指向下一张卡牌位置
    p.cardIndex = p.cardIndex + 1;
end

--[[
--获取当前的生命值
function p.GetHP( id )
    local hp_max = SelectCell( T_CARD, id, "hp_max" );
    local hp_min = SelectCell( T_CARD, id, "hp_min" );
    local level_max = SelectCell( T_CARD, id, "max_level" );
    return p.GetCurrentValue( hp_max, hp_min, level_max, 1  );
end

--获取当前的攻击力
function p.GetAttack( id )
    local attack_max = SelectCell( T_CARD, id, "attack_max" );
    local attack_min = SelectCell( T_CARD, id, "attack_min" );
    local level_max = SelectCell( T_CARD, id, "max_level" );
    return p.GetCurrentValue( attack_max, attack_min, level_max, 1  );
end

--获取当前的防御力
function p.GetDef( id )
    local defence_max = SelectCell( T_CARD, id, "defence_max" );
    local defence_min = SelectCell( T_CARD, id, "defence_min" );
    local level_max = SelectCell( T_CARD, id, "max_level" );
    return p.GetCurrentValue( defence_max, defence_min, level_max, 1  );
end

--获取相关信息的公式
function p.GetCurrentValue( maxValue, minValue, maxLv, lv)
    local maxv = tonumber( maxValue );
    local minv = tonumber( minValue );
    local maxLv = tonumber( maxLv )
    local lv = tonumber( lv );
    local cur_value = minValue + (maxv - minv)/(maxLv - 1) * ( lv - 1)
    return math.floor( cur_value );
end
--]]

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
        p.cardIndex = 1;
        p.cardIdList = {};
        p.coin = nil;
        p.gacharesult = nil;
    end

end

