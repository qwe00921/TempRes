--------------------------------------------------------------
-- FileName: 	vector.lua
-- author:		zhangwq, 2013/06/20
-- purpose:		����--���飨��ʵ����
--
-- �÷���
--	push	ѹ��
--	pop		����
--	insert	����
--	remove	ɾ��
--	clear	���
--	size	Ԫ�ظ���
--	get		��ȡԪ��
--	set		����Ԫ��ֵ
--	find	����
--	��ע��Ԫ���������Ͳ��ޣ�֧��nilֵ��
--------------------------------------------------------------

vector = {}
local p = vector;

--������ʵ��
function p:new()	
	o = {}
	setmetatable( o, self );
	self.__index = self;
    o:ctor(); return o;
end

--���캯��
function p:ctor()
	self.t = {}
	self.num = 0; --table.maxn(t)�ܲ�����,��Ҫ�Լ�ά��Ԫ�ظ���!
end

--ѹ��Ԫ��
function p:push( elem )
	table.insert( self.t, self.num + 1, elem );
	--table.insert( self.t, elem ); --������nilֵ,ʡ��pos�ᵼ�´���!
	self:inc();
end

--����Ԫ��
function p:pop()
	self:remove( self.num );
end

--����Ԫ��
function p:insert( pos, elem )
	table.insert( self.t, pos, elem );
	self:inc();
end

--ɾ��Ԫ��
function p:remove( pos )
	--lua�ڼ���Ԫ�ظ���ʱ�������ĩβ��nil��ֵ����ɾ��ɾ������λ�õ�Ԫ�أ�
	--print(pos,table.maxn(self.t));
	if pos > table.maxn(self.t) then
		self.t[pos] = nil;
		self:dec();
	else
		table.remove( self.t, pos );
		self:dec();
	end
end

--���
function p:clear()
	while self.num > 0 do
		self:pop();
	end
end

--����Ԫ�ظ���
function p:size()
	return self.num;
	--table.maxn(t)�ܲ�����,��Ҫ�Լ�ά��Ԫ�ظ���!
	--return table.maxn(self.t);
end

--ȡԪ�أ��߽簲ȫ�ɲ���飩
function p:get( pos )
	return self.t[pos];
end

--����ֵ
function p:set( pos, val )
	self.t[pos] = val;
end

--���ң��ɹ�����������ʧ�ܷ���0��
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
