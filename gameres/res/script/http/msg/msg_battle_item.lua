
msg_battle_item = msg_base:new();
local p = msg_battle_item;
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
    self.idMsg = MSG_BATTLE_ITEM; --消息号
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
	WriteConWarning( "** msg_battle_item:Process() called" );
	
	if self.result then
		item_choose.RefreshUI( self.battle_items );
	end
end


