--------------------------------------------------------------
-- FileName: 	msg_mail_send_msg.lua
-- author:		wjl, 2013/11/27
-- purpose:		�����ʼ�
--------------------------------------------------------------

msg_mail_msg = msg_base:new();
local p = msg_mail_msg;
local super = msg_base;

--������ʵ��
function p:new()	
	o = {}
	setmetatable( o, self );
	self.__index = self;
	o:ctor(); return o;
end

--���캯��
function p:ctor()
	super.ctor(self);
    self.idMsg = MSG_MAIL_SEND_MSG; --��Ϣ��
end

--��ʼ��
function p:Init()
end

function p:SetIdMsg(id)
	self.idMsg = id;
end

--������Ϣ
function p:Process()
	--msg_cache.msg_card_box = self.user_cards;
	WriteCon( "** msg_mail_msg:Process() called" );
	--dump_obj(self.user_cards);
	if self.idMsg == MSG_MAIL_SEND_MSG then
		mail_write_mail.NetCallback(self);
		mail_gm_mail.NetCallback(self);
	elseif self.idMsg == MSG_MAIL_GET_MSGS then
		mail_main.OnNetCallback(self);
		mail_gm_mail.OnNetGetListCallback(self);
	elseif self.idMsg == MSG_MAIL_DEL_MSG then
		mail_main.OnNetDelCallback(self);
		mail_detail_sys.OnNetDelCallback(self);
		mail_detail_user.OnNetDelCallback(self);
	elseif self.idMsg == MSG_MAIL_GET_MSG_DETAIL then
		mail_detail_sys.OnNetGetDetail(self);
		mail_detail_user.OnNetGetDetail(self);
		mail_gm_mail.OnNetGetDetail(self);
	elseif self.idMsg == MSG_MAIL_GET_REWARD then
		mail_detail_sys.OnNetGainReward(self);
	end
end
