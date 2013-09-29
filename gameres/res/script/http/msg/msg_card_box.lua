--------------------------------------------------------------
-- FileName: 	msg_card_box.lua
-- author:		hst, 2013/07/10
-- purpose:		卡箱数据
--------------------------------------------------------------

msg_card_box = msg_base:new();
local p = msg_card_box;
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
    self.idMsg = MSG_CARDBOX_USER_CARDS; --消息号
    
    self.bag_max = nil;
    self.user_cards = {}; --卡牌列表
    self.user_cards.id = nil;
    self.user_cards.user_id = nil;
    self.user_cards.card_id = nil;
    self.user_cards.race = nil;
    self.user_cards.pierce = nil;
    self.user_cards.evolution_step = nil;
    self.user_cards.rare = nil;
    self.user_cards.damage_type = nil;
    self.user_cards.level = nil;
    self.user_cards.exp = nil;
    self.user_cards.hp = nil;
    self.user_cards.attack = nil;
    self.user_cards.defence = nil;
    self.user_cards.leader_check = nil;
    self.user_cards.team_no = nil;
    self.user_cards.weapon = nil;
    self.user_cards.armor = nil;
    self.user_cards.jewelry = nil;
    self.user_cards.skill_id = nil;
    self.user_cards.delete_flag = nil;
    self.user_cards.deleted_at = nil;
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
	msg_cache.msg_card_box = self.user_cards;
	WriteConWarning( "** msg_card_box:Process() called" );
	--dump_obj(self.user_cards);
	card_box_mgr.RefreshUI(self);
end
