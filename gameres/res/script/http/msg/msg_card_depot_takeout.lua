--------------------------------------------------------------
-- FileName:    msg_card_depot_takeout.lua
-- author:      hst, 2013/08/01
-- purpose:     卡牌仓库取出
--------------------------------------------------------------

msg_card_depot_takeout = msg_base:new();
local p = msg_card_depot_takeout;
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
    self.idMsg = MSG_DEPOT_TAKEOUT; --消息号
    
    self.takeout_num = nil;
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
    WriteConWarning( "** msg_card_depot_takeout:Process() called" );
    --dump_obj(self);
    dlg_card_depot.RefreshTakeout(self);
end
