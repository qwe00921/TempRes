--------------------------------------------------------------
-- FileName: 	msg_travel_battle.lua
-- author:		hst, 2013/07/10
-- purpose:		旅行地图打BOSS
--------------------------------------------------------------

msg_travel_battle = msg_base:new();
local p = msg_travel_battle;
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
    self.idMsg = MSG_TRAVEL_BATTLE; --消息号
    
    --[[
    self.refresh_map = nil;下一张地图标识
    self.stage_clear = nil;通关标识
    --]]
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
	WriteConWarning( "** msg_travel_battle:Process() called" );
	--dump_obj(self.user_cards);
	task_map.BattleRefresh(self)
end
