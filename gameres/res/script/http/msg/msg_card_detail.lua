--------------------------------------------------------------
-- FileName: 	msg_mail_send_msg.lua
-- author:		wjl, 2013/11/27
-- purpose:		发送邮件
--------------------------------------------------------------

msg_card_detail = msg_base:new();
local p = msg_card_detail;
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
    self.idMsg = MSG_CARD_ROLE_DETAIL; --消息号
end

--初始化
function p:Init()
end

function p:SetIdMsg(id)
	self.idMsg = id;
end

--处理消息
function p:Process()
	--msg_cache.msg_card_box = self.user_cards;
	WriteCon( "** msg_card_detail:Process() called" );
	--dump_obj(self.user_cards);
	if self.idMsg == MSG_CARD_ROLE_DETAIL then
		dlg_card_attr_base.OnLoadCardDetail(self);
	end
end
