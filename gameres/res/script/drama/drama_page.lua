--------------------------------------------------------------
-- FileName: 	drama_page.lua
-- author:		
-- purpose:		剧情页面（对白）
--------------------------------------------------------------

drama_page = {}
local p = drama_page;

p.storyId = 0;		--所属stroyId
p.playIndex = 0;	--播放序号

p.ani = nil;		--动画
p.picBg = nil;		--背景图片
p.picLeft = nil;	--左图
p.picMid = nil;		--中图
p.picRight = nil;	--右图

p.npcIdLeft = nil;	--左边npcid
p.npdIdMid = nil;	--中间npcid
p.npcIdRight = nil;	--右边npcid

p.npcIdTalk = nil;	--当前说话的npcid
p.talkText = nil;	--说话内容


--创建新实例
function p:new()	
	o = {}
	setmetatable( o, self );
	self.__index = self;
	o:ctor(); return o;
end

--构造函数
function p:ctor()
end

--初始化
function p:Init()
end

--加载页面（将ini中的行记录加载到对象中）
function p:LoadPage()
end

--显示页面（根据页面属性加载图片等进行显示）
function p:ShowPage()
end
