--------------------------------------------------------------
-- FileName:    msg_back_pack.lua
-- author:      hst, 2013/07/10
-- purpose:     背包数据
--------------------------------------------------------------

msg_back_pack = msg_base:new();
local p = msg_back_pack;
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
    self.idMsg = MSG_EQUIP_BACK_PACK; --消息号
    
    self.id = nil;
    self.type = nil;
    self.name = nil;
    self.description = nil;
    self.exp = nil;
    self.numlimit = nil;
    self.rare = nil;
    self.issell = nil;
    self.sellprice = nil;
    self.need_rare = nil;
    self.need_pierce = nil;
    self.need_level = nil;
    self.level = nil;
    self.level_max = nil;
    self.add_attack_min = nil;
    self.add_attack_max = nil;
    self.add_defence_min = nil;
    self.add_defence_max = nil;
    self.add_hp_min = nil;
    self.add_hp_max = nil;
    self.skill = nil;
    self.card_id = nil;
    self.num = nil;
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
	msg_cache.msg_back_pack = self;
    WriteConWarning( "** msg_card_box:Process() called" );
    --dump_obj(self.user_cards);
    back_pack_mgr.RefreshUI(self.user_items);
end