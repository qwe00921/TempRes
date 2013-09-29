--------------------------------------------------------------
-- FileName: 	msg_battle_fighters.lua
-- author:		zhangwq, 2013/08/22
-- purpose:		战斗：fighter消息
-- 				负责战斗开始时下发所有fighter数据
--------------------------------------------------------------

msg_battle_fighters = msg_base:new();
local p = msg_battle_fighters;
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
	self.idMsg = MSG_BATTLE_FIGHTERS; --消息号
	--[[
	if false then
		self.user_team = {};
		self.target_team = {};
		
		self.user_team.user_cards = {};
		self.user_team.user_skill = {};
		self.user_team.rage_num = 0;
		self.user_team.reage_user_skill = 0;
		
		self.target_team.user_cards = {};
        self.target_team.user_skill = {};
        self.target_team.rage_num = 0;
        self.target_team.reage_user_skill = 0;
        
        self.user_team.user_cards[1].id = nil;
        self.user_team.user_cards[1].hp = nil;
        self.user_team.user_cards[1].attack = nil;
        self.user_team.user_cards[1].defence = nil;
        self.user_team.user_cards[1].skill_id = nil;
        self.user_team.user_cards[1].weapon = nil;
        self.user_team.user_cards[1].armor = nil;
        self.user_team.user_cards[1].jewelry = nil;
        
        self.user_team.user_skill[1].id = nil;
        self.user_team.user_skill[1].level = nil;
        self.user_team.user_skill[1].exp = nil;
        self.user_team.user_skill[1].skill_id = nil;
        self.user_team.user_skill[1].skill_power = nil;
        self.user_team.user_skill[1].skill_owner = nil;
        self.user_team.user_skill[1].skill_type = nil;
        self.user_team.user_skill[1].rare = nil;
		
	end

	if false then
		self.fighters = {};
		self.fighters[1] = {};

		local ft1 = self.fighters[1];
		ft1.id_camp = 1; --1表示英雄阵营；2表示敌对阵营
		ft1.id_fighter = 101; --fighter id规则简单清晰点，如：100~200用于英雄；200~300用于敌人
		ft1.life = 5000;
		ft1.atk = 200;
		ft1.def = 100;

		self.fighters[2] = {};
		local ft2 = self.fighters[2];
		ft2.id_camp = 1;
		ft2.id_fighter = 102;
		ft2.life = 500;
		ft2.atk = 200;
		ft2.def = 100;

		self.fighters[3] = {};
		local ft3 = self.fighters[3];
		ft3.id_camp = 1;
		ft3.id_fighter = 103;
		ft3.life = 500;
		ft3.atk = 200;
		ft3.def = 100;

		self.fighters[4] = {};
		local ft4 = self.fighters[4];
		ft4.id_camp = 1;
		ft4.id_fighter = 104;
		ft4.life = 500;
		ft4.atk = 200;
		ft4.def = 100;

		self.fighters[5] = {};
		local ft5 = self.fighters[5];
		ft5.id_camp = 1;
		ft5.id_fighter = 105;
		ft5.life = 500;
		ft5.atk = 200;
		ft5.def = 100;

		self.fighters[6] = {};
		local ft6 = self.fighters[6];
		ft6.id_camp = 2;
		ft6.id_fighter = 201;
		ft6.life = 500;
		ft6.atk = 200;
		ft6.def = 100;

		self.fighters[7] = {};
		local ft7 = self.fighters[7];
		ft7.id_camp = 2;
		ft7.id_fighter = 202;
		ft7.life = 500;
		ft7.atk = 200;
		ft7.def = 100;

		self.fighters[8] = {};
		local ft8 = self.fighters[8];
		ft8.id_camp = 2;
		ft8.id_fighter = 203;
		ft8.life = 500;
		ft8.atk = 200;
		ft8.def = 100;

		self.fighters[9] = {};
		local ft9 = self.fighters[9];
		ft9.id_camp = 2;
		ft9.id_fighter = 204;
		ft9.life = 500;
		ft9.atk = 200;
		ft9.def = 100;

		self.fighters[10] = {};
		local ft10 = self.fighters[10];
		ft10.id_camp = 2;
		ft10.id_fighter = 205;
		ft10.life = 500;
		ft10.atk = 200;
		ft10.def = 100;

	end
	--]]
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
	WriteConWarning( "** msg_battle_fighters:Process() called" );
	card_battle_mgr.ReceiveFightersRes( self );
end
