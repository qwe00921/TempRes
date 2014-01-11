--------------------------------------------------------------
-- FileName: 	msg_mainui.lua
-- author:		xyd, 2013/09/05
-- purpose:		检测玩家是否存在消息
--------------------------------------------------------------

msg_check_exist_role = msg_base:new();
local p = msg_check_exist_role;
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
    self.idMsg = MSG_PLAYER_HANDSHAKE; 						--消息号
  
  	--[[
    self.user_status.user_name =nil;					--用户名
    self.user_status.level = nil;						--等级
    self.user_status.mission_point = nil;				--体力
    self.user_status.mission_point_max = nil;			--体力上限
    self.user_status.arena_point = nil;					--精力
    self.user_status.arena_point_max = nil;				--精力上限
    self.card_num = nil;								--卡片数量
    self.card_max = nil;								--卡片上限
    self.gold_num = nil;								--金币数量
    self.rmb_num = nil;									--代币数量
    ]]
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
	msg_cache.msg_player = self.user;
	WriteConWarning( "** msg_check_exist_role:Process() called" );
	--msg_cache.msg_player = msg_cache.msg_player or {};

	if self.result == true then
		maininterface.ShowUI(self.user);
	else
		dlg_createrole.ShowUI();
	end
end


