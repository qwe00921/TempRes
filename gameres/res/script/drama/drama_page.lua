--------------------------------------------------------------
-- FileName: 	drama_page.lua
-- author:		
-- purpose:		����ҳ�棨�԰ף�
--------------------------------------------------------------

drama_page = {}
local p = drama_page;

p.storyId = 0;		--����stroyId
p.playIndex = 0;	--�������

p.ani = nil;		--����
p.picBg = nil;		--����ͼƬ
p.picLeft = nil;	--��ͼ
p.picMid = nil;		--��ͼ
p.picRight = nil;	--��ͼ

p.npcIdLeft = nil;	--���npcid
p.npdIdMid = nil;	--�м�npcid
p.npcIdRight = nil;	--�ұ�npcid

p.npcIdTalk = nil;	--��ǰ˵����npcid
p.talkText = nil;	--˵������


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

--��ʼ��
function p:Init()
end

--����ҳ�棨��ini�е��м�¼���ص������У�
function p:LoadPage()
end

--��ʾҳ�棨����ҳ�����Լ���ͼƬ�Ƚ�����ʾ��
function p:ShowPage()
end
