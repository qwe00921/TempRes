--------------------------------------------------------------
-- FileName: 	msg_world_info.lua
-- author:		xyd, 2013/07/19
-- purpose:		世界地图消息明细
--------------------------------------------------------------

msg_world_info = msg_base:new();
local p = msg_world_info;
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
    self.idMsg = MSG_WORLD_INFO; --消息号
    
    self.user_cards_sum = nil;
    self.recover_mission_point = nil;
    
    self.user_status = {};
    self.user_status.user_id = nil;
    self.user_status.user_name = nil;
    self.user_status.character = nil;
    self.user_status.sex = nil;
    self.user_status.level = nil;
    self.user_status.exp = nil;
    self.user_status.mission_point = nil;
    self.user_status.mission_point_max = nil;
    self.user_status.arena_point = nil;
    self.user_status.arena_point_max = nil;
    self.user_status.chapter_id = nil;
    self.user_status.stage_id = nil;
    self.user_status.travel_id = nil;
    self.user_status.position_x = nil;
    self.user_status.position_y = nil;
    self.user_status.dungeon_chapter_id = nil;
    self.user_status.dungeon_stage_id = nil;
    self.user_status.dungeon_travel_id = nil;
    self.user_status.dungeon_x = nil;
    self.user_status.dungeon_y = nil;
    self.user_status.card_max_num = nil;
    self.user_status.created_time = nil;
    self.user_status.recover_last_time = nil;
    self.user_status.roll_num = nil;
    
    self.user_coin = {};
    self.user_coin.user_id = nil;
    self.user_coin.coin_type = nil;
    self.user_coin.coin_num = nil;
    self.user_coin.used_coin_count = nil;
    
    self.user_finish_missions = {};
    self.user_finish_missions.id = nil;
    self.user_finish_missions.user_id = nil;
    self.user_finish_missions.travel_id = nil;
    self.user_finish_missions.finish = nil;
    
end

--初始化
function p:Init()
	
end

--处理消息
function p:Process()
	msg_cache.msg_world_info = self;
	WriteConWarning( "** msg_world_info:Process() called" );
	world_map.RefreshUI(self);
end
