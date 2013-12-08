--------------------------------------------------------------
-- FileName: 	billboard.lua
-- author:		xyd, 2013��8��12��
-- purpose:		����ƹ�����
--------------------------------------------------------------

billboard = {}
local p = billboard;

------------------��Ϣ����------------------
p.EVENT_MESSAGE_TYPE_PET_CARD_INFY                    = 0;        -- ���￨Ƭǿ��
p.EVENT_MESSAGE_TYPE_PET_CARD_EVOLVE                  = 1;        -- ���￨Ƭ����
p.EVENT_MESSAGE_TYPE_PET_CARD_FUSE                    = 2;        -- ���￨���ں�
p.EVENT_MESSAGE_TYPE_SKILL                            = 3;        -- ��Ҽ���ǿ��
p.EVENT_MESSAGE_TYPE_PET_EQUIP                        = 4;        -- ����װ��ǿ��
p.EVENT_MESSAGE_TYPE_GACHA                            = 5;        -- ���Ť���¼�
p.EVENT_MESSAGE_TYPE_TIPS                             = 6;        -- ��ϷTIPS��Ϣ
p.EVENT_MESSAGE_TYPE_SYSTEM                           = 7;        -- ϵͳ��Ϣ
p.EVENT_MESSAGE_TYPE_PET_SKILL                        = 8;        -- ���＼����Ϣ


p.layer = nil;
p.title = nil;
p.message = {};                         -- ��Ϣ�洢��
p.message_sys = {};                     -- ϵͳ��Ϣ
p.message_user = {};                    -- �����Ϣ
p.message_tips = {};                    -- ��ʾ��Ϣ

p.timer = nil;

p.billboardHeight = 300;
p.billboardRatio = 0.7;					-- ����ƿ�ȱ���ϵ��
p.billboard_y = nil;
p.billboard_x = nil;


function p.ShowUI()

   if p.layer == nil then
        p.layer = GetHudLayer();
    end
   
   if p.title == nil then
        p.title = createNDUIScrollText();
        p.title:Init();
        
		--���þ�������
		local x = p.billboard_x or 0.5f * (1.0f - p.billboardRatio) * GetScreenWidth();
		local y = p.billboard_y or UIOffsetY(56);
		local w = GetScreenWidth() * p.billboardRatio;
		local rect = CCRectMake( x, y, w, UIOffsetY(p.billboardHeight) );
        p.title:SetFrameRect( rect );
		
        p.title:SetScrollSpeed(tonumber( GetStr( "message_speed" )));
        p.layer:AddChild(p.title);
        
   end
   p.LoadMessage();
    p.StartTimer();
end

function p.ShowUIWithInit(parentLayer,posX,posY)

	if p.layer == nil then
        p.layer = parentLayer;
    end
	
	if p.billboard_x == nil then
		p.billboard_x = posX;
	end
	
	if p.billboard_y == nil then
		p.billboard_y = posY;
	end
	
	p.ShowUI();
end

-- ������Ϣ
function p.LoadMessage()

    WriteCon("**������Ϣ����**");
    local uid = GetUID();
    if uid == 0 or uid == nil then
        return ;
    end;
    SendReq("Message","GetLastMessage",uid,"");
end

-- ˢ����Ϣ
function p.RefreshMessage(msg)
    p.message = msg.message;
    if p.message ~= nil and #p.message > 0 then
        p.SplitMessage();
        p.ShowMessage();
   end  
end

-- �����Ϣ
function p.SplitMessage()
    
    for i=1,#p.message do
        local type = tonumber(p.message[i].TypeId);
        if p.EVENT_MESSAGE_TYPE_SYSTEM == type then
            --ϵͳ��Ϣ
            p.message_sys[#p.message_sys + 1] = p.message[i];
        else
            -- �����Ϣ
            p.message_user[#p.message_user + 1] = p.message[i];
        end
     end
     -- tips
     local cur_time = tonumber(os.time());
     local temp_tips = SelectRowList( T_EVENT_MESSAGE, "type", "7" );
     if temp_tips and #temp_tips > 0 then
     	for i=1,#temp_tips do
     		local start_time = tonumber(temp_tips[i].start_time);
     		local end_time = tonumber(temp_tips[i].end_time);
     		if (cur_time > start_time and cur_time < end_time) then
     			p.message_tips[#p.message_tips + 1] = temp_tips[i];
     		end
     	end
	 end
	 
end

-- ��ʾ��Ϣ
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

-- ��ʾϵͳ��Ϣ
function p.ShowSysMessage()
	
   -- p.title:RunText(string.format("%s%s","<#ff0000ff>","my my my msg"));--p.message_sys[1].Message));
	p.title:RunText(string.format("%s%s","<#ff0000ff>",p.message_sys[1].Message));
    table.remove(p.message_sys,1);
end

-- ��ʾ�����Ϣ
function p.ShowUserMessage()

    local type = tonumber(p.message_user[1].TypeId);
    local user_id = tostring(p.message_user[1].UserName);
    local card_id = tostring(p.message_user[1].ObjectId);
    local rare = tonumber(p.message_user[1].Rare);
    local level = tonumber(p.message_user[1].Level);
    local text = nil;
    
    if p.EVENT_MESSAGE_TYPE_PET_CARD_INFY == type then
    	-- ���￨Ƭǿ���¼�
    	text = string.format(GetStr("bill_board_message_skill"),user_id,card_id,level);
    elseif p.EVENT_MESSAGE_TYPE_PET_CARD_EVOLVE == type then
    	-- ���￨Ƭ����
        text = string.format(GetStr("bill_board_message_evolve"),user_id,card_id,level);
    elseif p.EVENT_MESSAGE_TYPE_PET_CARD_FUSE == type then
    	-- ���￨���ں�
        text = string.format(GetStr("bill_board_message_fuse"),user_id,rare,card_id);
    elseif p.EVENT_MESSAGE_TYPE_SKILL == type then
    	-- ��Ҽ���ǿ��
        text = string.format(GetStr("bill_board_message_skill"),user_id,card_id,level);
    elseif p.EVENT_MESSAGE_TYPE_PET_EQUIP == type then
    	-- ����װ��ǿ��
        text = string.format(GetStr("bill_board_message_equip"),user_id,card_id,level);
    elseif p.EVENT_MESSAGE_TYPE_GACHA == type then
    	-- Ť��
        text = string.format(GetStr("bill_board_message_gacha"),user_id,rare,card_id);
	elseif p.EVENT_MESSAGE_TYPE_PET_SKILL == type then
		-- ���＼��ǿ��
		 text = string.format(GetStr("bill_board_message_pet_skill"),user_id,card_id,level);
    end

    if text ~= nil then
        p.title:RunText(text);
        table.remove(p.message_user,1);
    end
end

-- ��ʾtips
function p.ShowTipsMessage()
	
	if (#p.message_tips > 0) then
    	local index = math.random(1,#p.message_tips);
    	p.title:RunText(string.format("%s%s","<#yellow>",p.message_tips[index].message));
	end
	
end


-- ������ʱ��
function p.StartTimer()
    p.clearTimer();
    p.timer = SetTimer( p.ShowMessage, tonumber( GetStr( "message_timer" )));
end

-- �����ʱ��
function p.clearTimer()
    if p.timer ~= nil then
        KillTimer(p.timer);
        p.timer = nil;
    end
end

-- ��ͣ�����
function p.pauseBillBoard()
	p.clearTimer();
	p.title:SetVisible(false);
	p.message = {};
    p.message_sys = {};
    p.message_user = {};
    p.message_tips = {};
end

-- �ָ������
function p.resumeBillBoard()
	p.title:SetVisible(true);
	--p.LoadMessage(); -- ����resumeBillBoard�¶�����
	p.StartTimer();
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