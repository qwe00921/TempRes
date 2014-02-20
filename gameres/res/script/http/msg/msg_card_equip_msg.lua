--------------------------------------------------------------
-- FileName: 	msg_mail_send_msg.lua
-- author:		wjl, 2013/11/27
-- purpose:		发送邮件
--------------------------------------------------------------

msg_card_equip_msg = msg_base:new();
local p = msg_card_equip_msg;
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
    self.idMsg = MSG_CARD_EQUIPMENT_DETAIL; --消息号
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
	WriteCon( "** msg_card_equip_msg:Process() called" );
	--dump_obj(self.user_cards);
	
	if self.idMsg == MSG_CARD_EQUIPMENT_DETAIL then --卡版装备详细
		dlg_card_equip_detail.OnLoadEquitDetail(self);
	elseif self.idMsg == MSG_CARD_EQUIPMENT_INSTALL then --卡版装备安装
		dlg_card_equip_detail.OnDress(self);
	elseif self.idMsg == MSG_CARD_EQUIPMENT_UNINSTALL then --卡版装备卸下
		dlg_card_equip_detail.OnUnDress(self);
	elseif self.idMsg == MSG_CARD_EQUIPMENT_LIST then
		--card_equip_select_list.OnLoadList(self);
		equip_dress_select.OnLoadList(self);
		equip_room.ShowInfo(self);
		equip_rein_select.ShowInfo(self);
		equip_sell.update(self);
	elseif   self.idMsg ==  MSG_CARD_EQUIPMENT_UPGRADE then
		--card_equip_select_list.OnNetUpgradeCallback(self);
		--equip_rein_list.OnNetUpgradeCallback(self);
		equip_rein_list.OnServerBack( self );
	end
end
