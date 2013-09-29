--------------------------------------------------------------
-- FileName:    msg_dungeon_progress.lua
-- author:      hst, 2013/08/19
-- purpose:     副本进度信息
--------------------------------------------------------------

msg_dungeon_progress = msg_base:new();
local p = msg_dungeon_progress;
local super = msg_base;

--创建新实例
function p:new()    
    o = {}
    setmetatable( o, self );
    self.__index = self;
    o:ctor(); return o;
end

--构造函数
function p:ctor()
    super.ctor(self);
    self.idMsg = MSG_DUNGEON_PROGRESS; --消息号
    
    --self.recover_mission_point = nil;
    
    --************{user_status info
    --[[
    self.user_status = {};
    self.user_id = nil;
    self.user_name = nil;
    self.character = nil;
    self.sex = nil;
    self.level = nil;
    self.exp = nil;
    self.mission_point = nil;
    self.mission_point_max = nil;
    self.arena_point = nil;
    self.arena_point_max = nil;
    self.chapter_id = nil;
    self.stage_id = nil;
    self.travel_id = nil;
    self.position_x = nil;
    self.position_y = nil;
    self.dungeon_chapter_id = nil;
    self.dungeon_stage_id = nil;
    self.dungeon_travel_id = nil;
    self.dungeon_x = nil;
    self.dungeon_y = nil;
    self.card_max_num = nil;
    self.created_time = nil;
    self.recover_last_time = nil;
    self.last_login_time = nil;
    self.roll_num = nil;
    --]]
    --***************}
    
    --****************{user_dungeon_progress info
    --[[
    self.user_dungeon_progress = {};
    self.id = nil;
    self.user_id = nil;
    self.chapter_id = nil;
    self.stage_id = nil;
    self.num = nil;
    self.difficulty = nil;
    self.high_score = nil;
    self.now_score = nil;
    --]]
    --***********************}
    
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
    WriteConWarning( "** msg_card_box:Process() called" );
    --dump_obj(self.user_cards);
    dlg_dungeon_enter.RefreshUI(self);
end
