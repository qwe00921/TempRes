--------------------------------------------------------------
-- FileName:    msg_card_depot.lua
-- author:      hst, 2013/07/10
-- purpose:     卡箱数据
--------------------------------------------------------------

msg_card_depot = msg_base:new();
local p = msg_card_depot;
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
    self.idMsg = MSG_CARDBOX_DEPOT; --消息号
    
    self.store_max =nil;
    self.bag_max = nil;
    self.user_cards_sun = nil;
    
    --self.user_card_store={
    self.id = nil;
    self.user_id = nil;
    self.card_id = nil;
    self.race = nil;
    self.pierce = nil;
    self.evolution_step = nil;
    self.rare = nil;
    self.damage_type = nil;
    self.level = nil;
    self.exp = nil;
    self.hp = nil;
    self.attack = nil;
    self.defence = nil;
    self.leader_check = nil;
    self.team_no = nil;
    self.weapon = nil;
    self.armor = nil;
    self.jewelry = nil;
    self.skill_id = nil;
    self.delete_flag = nil;
    self.deleted_at = nil;
    self.bag_type = nil;
    --}
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
    WriteConWarning( "** msg_card_depot:Process() called" );
    --dump_obj(self.user_cards);
    card_depot_mgr.RefreshUI(self);
end