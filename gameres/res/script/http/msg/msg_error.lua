
msg_error = msg_base:new();
local p = msg_error;
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
	super.ctor( self );
    self.idMsg = MSG_GENERAL_ERROR; --��Ϣ��
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
	local level = tonumber(self.msglevel);
	if level ~= nil and level == 1 then
		dlg_msgbox.ShowOK( ToUtf8( "��ʾ" ), self.message, p.Process_Err1, GetUIRoot() );
	else
		dlg_msgbox.ShowOK( ToUtf8( "����" ), self.message, p.Process_Err2, GetUIRoot() );
	end
end

--������ʾ��һ����ֱ�ӹر�
function p:Process_Err1()
	--p:Process_Err2();
end

--��������˳���������
function p:Process_Err2()
	--�رյ�ͼ
	local mapNode = GetTileMapMgr():GetMapNode();
	if mapNode ~= nil then
		mapNode:FadeOut();
		world_map.CloseMap();
	end
	
	--��ʾ��½����
	game_main.main();
end




