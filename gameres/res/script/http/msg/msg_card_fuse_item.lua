--------------------------------------------------------------
-- FileName: 	msg_card_fuse_item.lua
-- author:		Zjj, 2013/08/05
-- purpose:		卡牌融合道具消息类
--------------------------------------------------------------

msg_card_fuse_item = msg_base:new();
local p = msg_card_fuse_item;
local super = msg_base;

--创建新实例
function p:new()	
	o = {}
	setmetatable( o, self );
	self.__index = self;
	
	o:ctor();
	return o;
end

--构造函数
function p:ctor()
	super.ctor(self);
    self.idMsg = MSG_CARD_FUSE_ITEM; --消息号
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
	msg_cache.msg_card_fuse_item = self;
	WriteConWarning( "** msg_card_fuse_item:Process() called" );
	dlg_card_fuse.SaveItemData(self.mix_items);
end
