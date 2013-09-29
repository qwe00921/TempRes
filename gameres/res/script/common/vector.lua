--------------------------------------------------------------
-- FileName: 	vector.lua
-- author:		zhangwq, 2013/06/20
-- purpose:		容器--数组（多实例）
--
-- 用法：
--	push	压入
--	pop		弹出
--	insert	插入
--	remove	删除
--	clear	清空
--	size	元素个数
--	get		获取元素
--	set		设置元素值
--	find	查找
--	备注：元素数据类型不限，支持nil值！
--------------------------------------------------------------

vector = {}
local p = vector;

--创建新实例
function p:new()	
	o = {}
	setmetatable( o, self );
	self.__index = self;
    o:ctor(); return o;
end

--构造函数
function p:ctor()
	self.t = {}
	self.num = 0; --table.maxn(t)很不靠谱,需要自己维护元素个数!
end

--压入元素
function p:push( elem )
	table.insert( self.t, self.num + 1, elem );
	--table.insert( self.t, elem ); --若存在nil值,省略pos会导致错误!
	self:inc();
end

--弹出元素
function p:pop()
	self:remove( self.num );
end

--插入元素
function p:insert( pos, elem )
	table.insert( self.t, pos, elem );
	self:inc();
end

--删除元素
function p:remove( pos )
	--lua在计算元素个数时，会忽略末尾的nil数值！会删除删除错误位置的元素！
	--print(pos,table.maxn(self.t));
	if pos > table.maxn(self.t) then
		self.t[pos] = nil;
		self:dec();
	else
		table.remove( self.t, pos );
		self:dec();
	end
end

--清空
function p:clear()
	while self.num > 0 do
		self:pop();
	end
end

--返回元素个数
function p:size()
	return self.num;
	--table.maxn(t)很不靠谱,需要自己维护元素个数!
	--return table.maxn(self.t);
end

--取元素（边界安全可不检查）
function p:get( pos )
	return self.t[pos];
end

--设置值
function p:set( pos, val )
	self.t[pos] = val;
end

--查找（成功返回索引，失败返回0）
function p:find( val )
	for pos=1, self:size() do
		if self.t[pos] == val then
			return pos;
		end
	end
	return 0;
end

function p:inc() 
	self.num = self.num + 1 
end
function p:dec() 
	self.num = self.num - 1 
end
