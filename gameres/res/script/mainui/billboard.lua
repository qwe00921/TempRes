--------------------------------------------------------------
-- FileName: 	billboard.lua
-- author:		xyd, 2013年8月12日
-- purpose:		跑马灯管理器
--------------------------------------------------------------

billboard = {}
local p = billboard;

------------------消息类型------------------
p.EVENT_MESSAGE_TYPE_PET_CARD_INFY                    = 0;        -- 宠物卡片强化
p.EVENT_MESSAGE_TYPE_PET_CARD_EVOLVE                  = 1;        -- 宠物卡片进化
p.EVENT_MESSAGE_TYPE_PET_CARD_FUSE                    = 2;        -- 宠物卡牌融合
p.EVENT_MESSAGE_TYPE_SKILL                            = 3;        -- 玩家技能强化
p.EVENT_MESSAGE_TYPE_PET_EQUIP                        = 4;        -- 卡牌装备强化
p.EVENT_MESSAGE_TYPE_GACHA                            = 5;        -- 玩家扭蛋事件
p.EVENT_MESSAGE_TYPE_TIPS                             = 6;        -- 游戏TIPS信息
p.EVENT_MESSAGE_TYPE_SYSTEM                           = 7;        -- 系统消息
p.EVENT_MESSAGE_TYPE_PET_SKILL                        = 8;        -- 宠物技能消息


p.layer = nil;
p.title = nil;
p.message = {};                         -- 消息存储器
p.message_sys = {};                     -- 系统消息
p.message_user = {};                    -- 玩家消息
p.message_tips = {};                    -- 提示消息

p.timer = nil;

p.billboardHeight = 50;
p.billboardRatio = 0.7;					-- 跑马灯宽度比例系数
p.billboard_y = nil;
p.billboard_x = nil;


function p.ShowUI()

   if p.layer == nil then
        p.layer = GetHudLayer();
    end
   
   if p.title == nil then
        p.title = createNDUIScrollText();
        p.title:Init();
        
		--设置矩形区域
		local x = p.billboard_x or 0.5f * (1.0f - p.billboardRatio) * GetScreenWidth();
		local y = p.billboard_y or UIOffsetY(0);
		local w = GetScreenWidth() * p.billboardRatio;
		local rect = dlg_menu.GetBillboardRect();
		if rect == nil then
			rect = CCRectMake( x, y, w, UIOffsetY(p.billboardHeight) );
		end
		
        p.title:SetFrameRect( rect );
		
        p.title:SetScrollSpeed(tonumber( GetStr( "message_speed" )));
        p.layer:AddChild(p.title);
		p.layer:SetEnableDragging(false);
        
   end
	p.LoadMessage();
    p.StartTimer();
end

function p.ShowUIWithInit(parentLayer,posX,posY,height)

	if p.layer == nil then
        p.layer = parentLayer;
    end
	
	if p.billboard_x == nil then
		p.billboard_x = posX;
	end
	
	if p.billboard_y == nil then
		p.billboard_y = posY;
	end
	
	p.billboardHeight = height;
	
	p.ShowUI();
end

-- 加载消息
function p.LoadMessage()

    WriteCon("**请求消息数据**");
    local uid = GetUID();
    if uid == 0 or uid == nil then
        return ;
    end;
    SendReq("Message","GetLastMessage",uid,"");
end

-- 刷新消息
function p.RefreshMessage(msg)
    p.message = msg.message;
    if p.message ~= nil and #p.message > 0 then
        p.SplitMessage();
        p.ShowMessage();
   end  
end

-- 拆分消息
function p.SplitMessage()
    
    for i = 1,#p.message do
        local type = tonumber(p.message[i].TypeId);
        if p.EVENT_MESSAGE_TYPE_SYSTEM == type then
            --系统消息
            p.message_sys[#p.message_sys + 1] = p.message[i];
        else
            -- 玩家信息
            p.message_user[#p.message_user + 1] = p.message[i];
        end
     end
     -- tips
     local cur_time = tonumber(os.time());
     local temp_tips = SelectRowList( T_EVENT_MESSAGE, "type", "7" );
     if temp_tips and #temp_tips > 0 then
     	for i = 1,#temp_tips do
     		local start_time = tonumber(temp_tips[i].start_time);
     		local end_time = tonumber(temp_tips[i].end_time);
     		if start_time and end_time and (cur_time > start_time and cur_time < end_time) then
     			p.message_tips[#p.message_tips + 1] = temp_tips[i];
     		end
     	end
	 end
	 
end

-- 显示消息
function p.ShowMessage()
    if #p.message_sys > 0 then
        p.ShowSysMessage();
    else
        if #p.message_user > 0 then
            p.ShowUserMessage();
        else
            p.ShowTipsMessage();
        end
    end
end

-- 显示系统消息
function p.ShowSysMessage()
	--p.title:setEnableDragging(false);
   -- p.title:RunText(string.format("%s%s","<#ff0000ff>","my my my msg"));--p.message_sys[1].Message));
	WriteCon(string.format("跑马灯消息：%s%s","<#ff0000ff>",p.message_sys[1].Message));
	p.title:RunText(string.format("%s%s","<#ff0000ff>",p.message_sys[1].Message));
    table.remove(p.message_sys,1);
end

-- 显示玩家消息
function p.ShowUserMessage()

    local type = tonumber(p.message_user[1].TypeId);
    local user_id = tostring(p.message_user[1].UserName);
    local card_id = tostring(p.message_user[1].ObjectId);
    local rare = tonumber(p.message_user[1].Rare);
    local level = tonumber(p.message_user[1].Level);
    local text = nil;
	
	
    local msg = p.SelectTabeMsg(type, rare,level);
	
	local name = nil;
	--if rare == 0 then
		name = SelectCell( T_CARD, tostring(card_id), "name" );
	--elseif rare == 4 then
		if (name == nil) then
			name = SelectCell( T_EQUIP, tostring(card_id), "name" );
		end
	--end
	
	card_id = name or card_id;
	
	if msg == nil then
		if p.EVENT_MESSAGE_TYPE_PET_CARD_INFY == type then
			-- 宠物卡片强化事件
			text = string.format(GetStr("bill_board_message_skill"),user_id,card_id,level);
		elseif p.EVENT_MESSAGE_TYPE_PET_CARD_EVOLVE == type then
			-- 宠物卡片进化
			text = string.format(GetStr("bill_board_message_evolve"),user_id,card_id,level);
		elseif p.EVENT_MESSAGE_TYPE_PET_CARD_FUSE == type then
			-- 宠物卡牌融合
			text = string.format(GetStr("bill_board_message_fuse"),user_id,rare,card_id);
		elseif p.EVENT_MESSAGE_TYPE_SKILL == type then
			-- 玩家技能强化
			text = string.format(GetStr("bill_board_message_skill"),user_id,card_id,level);
		elseif p.EVENT_MESSAGE_TYPE_PET_EQUIP == type then
			-- 卡牌装备强化
			text = string.format(GetStr("bill_board_message_equip"),user_id,card_id,level);
		elseif p.EVENT_MESSAGE_TYPE_GACHA == type then
			-- 扭蛋
			text = string.format(GetStr("bill_board_message_gacha"),user_id,rare,card_id);
		elseif p.EVENT_MESSAGE_TYPE_PET_SKILL == type then
			-- 宠物技能强化
			text = string.format(GetStr("bill_board_message_pet_skill"),user_id,card_id,level);
		end
	else
		text = string.format(msg,user_id,card_id,level);
	end

    if text ~= nil then
        p.title:RunText(text);
        table.remove(p.message_user,1);
    end
	
end

-- 显示tips
function p.ShowTipsMessage()
	if (#p.message_tips > 0) then
    	local index = math.random(1,#p.message_tips);
    	p.title:RunText(string.format("%s%s","<#yellow>",p.message_tips[index].message));
	end
	
end


-- 开启定时器
function p.StartTimer()
    p.clearTimer();
    p.timer = SetTimer( p.ShowMessage, tonumber( GetStr( "message_timer" )));
end

-- 清除定时器
function p.clearTimer()
    if p.timer ~= nil then
        KillTimer(p.timer);
        p.timer = nil;
    end
end

-- 暂停跑马灯
function p.pauseBillBoard()
	p.clearTimer();
	p.title:SetVisible(false);
	p.message = {};
    p.message_sys = {};
    p.message_user = {};
    p.message_tips = {};
end

-- 恢复跑马灯
function p.resumeBillBoard()
	p.title:SetVisible(true);
	--p.LoadMessage(); -- 不在resumeBillBoard下读数据
	p.StartTimer();
end

function p.SetFrameRect(rect)
	if p.title then
		p.title:SetFrameRect( rect );
	end
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
        p.title = nil;
        p.timer = nil;
        p.message = {};
        p.message_sys = {};
        p.message_user = {};
        p.message_tips = {};
    end
end

function p.SelectTabeMsg(mtype, rare,level)
	local itemTable = SelectRowList(T_EVENT_MESSAGE,"type",tostring(mtype));
	local text = nil;
	if #itemTable >= 1 then
		for k,v in pairs(itemTable) do
			if tonumber(v.rare) == tonumber(rare) and tonumber(v.level) == tonumber(level) then
				text = v.message;
			end
		end
		
	else
		WriteConErr("itemTable error ");
	end
	return text;
end