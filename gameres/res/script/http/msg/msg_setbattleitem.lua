
msg_setbattleitem = msg_base:new();
local p = msg_setbattleitem;
local super = msg_base;

--������ʵ��
function p:new()	
	o = {}
	setmetatable( o, self );
	self.__index = self;
	
	o:ctor();
	return o;
end

--���캯��
function p:ctor()
	super.ctor(self);
    self.idMsg = MSG_SETBATTLE_ITEM; --��Ϣ��
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
	WriteConWarning( "** msg_setbattleitem:Process() called" );
	if self.result then
		item_choose.SetBattleCallBack( self );
	else
		item_choose.SetBattleCallBack();
		dlg_msgbox.ShowOK( ToUtf8("��ʾ"), self.message, nil, GetUIRoot() );
	end
end


