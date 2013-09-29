--------------------------------------------------------------
-- FileName:    msg_dungeon_explore.lua
-- author:      hst, 2013/08/19
-- purpose:     ������ͼ����
--------------------------------------------------------------

msg_dungeon_explore = msg_base:new();
local p = msg_dungeon_explore;
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
    self.idMsg = MSG_DUNGEON_EXPLORE; --��Ϣ��
    
    --[[
    self.explore_result = nil
    self.refresh_map = nil
    --]]
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
    WriteConWarning( "** msg_dungeon_explore:Process() called" );
    task_map.ExploreRefresh(self);
end
