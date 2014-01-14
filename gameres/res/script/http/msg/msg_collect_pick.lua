
msg_collect_pick = msg_base:new();
local p = msg_collect_pick;
local super = msg_base;

function p:new()
	o = {}
	setmetatable(o, self);
	self.__index = self;
	o:ctor();
	return o;
end

function p:ctor()
	super.ctor(self);
	self.idMsg = MSG_COLLECT_PICK;
end

function p:Init()
end

--处理消息
function p:Process()
	WriteConWarning( "** msg_collect_pick:Process() called" );
	
	if self.result then
		country_collect.SendResultCallBack();
	else
		dlg_msgbox.ShowOK( ToUtf8("提示") , self.message , nil, country_main.layer );
	end
end



