
msg_setbattleitem = msg_base:new();
local p = msg_setbattleitem;
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
    self.idMsg = MSG_SETBATTLE_ITEM; --消息号
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
	WriteConWarning( "** msg_setbattleitem:Process() called" );
	if self.result then
		item_choose.SetBattleCallBack( self );
	else
		item_choose.SetBattleCallBack();
		dlg_msgbox.ShowOK( ToUtf8("提示"), self.message, nil, GetUIRoot() );
	end
end


