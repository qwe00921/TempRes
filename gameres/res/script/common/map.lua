--------------------------------------------------------------
-- FileName: 	map.lua
-- author:		zhangwq, 2013/06/20
-- purpose:		����--��ϣ����ʵ����
--------------------------------------------------------------

map = {}
local p = map;

--������ʵ��
function p:new()	
	o = {}
	setmetatable( o, self );
	self.__index = self;
	o:ctor(); return o;
end

--���캯��
function p:ctor()
end
