--------------------------------------------------------------
-- FileName: 	msg_skillpiece.lua
-- author:		Zjj, 2013/07/09
-- purpose:		��Ƭ��Ϣ
--------------------------------------------------------------

msg_skillpiece = msg_base:new();
local p = msg_skillpiece;
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
    self.idMsg = MSG_SKILLPIECE; --��Ϣ��
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
	msg_cache.msg_skillpiece = self;
	WriteConWarning( "** msg_skillpiece:Process() called" );
	dlg_skill_piece_combo.ShowPieceList(self.skill_items);
end
