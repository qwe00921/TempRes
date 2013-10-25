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
p.npcName = nil;    --��ǰ˵����NPC����
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
function p:LoadPage( oDrama )
    self.talkText = oDrama.speak_text;
    self.npcName = oDrama.npc_name;
    
    self.picBg = oDrama.bg_pic;      
    self.picLeft = oDrama.npc_left_id;    
    self.picMid = oDrama.npc_middle_id;    
    self.picRight = oDrama.npc_right_id;
    
    self.npcIdTalk = oDrama.speak_id;
    
end

--��ʾҳ�棨����ҳ�����Լ���ͼƬ�Ƚ�����ʾ��
function p:ShowPage()
    dlg_drama.ResetUI( self );
end
