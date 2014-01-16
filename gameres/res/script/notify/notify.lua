--ȫ��ע��֪ͨ

notify = {};
local p = notify;

function p:new()
	o = {}
    setmetatable( o, self );
    self.__index = self;
    o:ctor(); return o;
end

function p:ctor()
	self.pEvent = {};
end

--ע���¼�֪ͨ
--[[
	strSourceΪ����Դ������Ҫע��msg_cache.msg_player��֪ͨ�¼���strSource����Ϊ"msg_player"
	strEventΪ�¼�����Ϊ���㣬�Է����Э���·��������Ϣ�ֶ���Ϊ�¼���
	pObjectΪUI������ֱ�Ӵ������ַ�������ַ���
	pCallbackΪ�ص�������ֱ�Ӵ���ַ
	...Ϊ�ɱ��������ʾ�ص�ʱ��Ҫ�Ķ��������Ĭ�ϻص�ʱ��һ���������¼�����Ӧ���ֶ�ֵ
--]]
function p:RegisterEvent( strSource, strEvent, pObject, pCallback, ... )
	if strSource == nil or strSource == "" or strEvent == nil or strEvent == "" or pObject == nil or pCallback == nil then
		WriteConErr("param error");
		return;
	end
	self.pEvent[strSource] = self.pEvent[strSource] or {};
	local temp = self.pEvent[strSource];
	
	temp[strEvent] = temp[strEvent] or {};
	
	local flag = false;
	for i, v in pairs(temp[strEvent]) do
		if v.object == pObject and v.callback == pCallback then
			flag = true;
			break;
		end
	end
	
	if not flag then
		local count = select( "#", ... );
		local arguments = {};
		for i = 1, count do
			arguments[i] = select( i, ... );
		end
		if #arguments > 0 then
			table.insert( temp[strEvent], { object = pObject, callback = pCallback, param = arguments } );
		else
			table.insert( temp[strEvent], { object = pObject, callback = pCallback } );
		end
	end
end

--��ע��ȫ���¼�֪ͨ
function p:UnregisterAllEvent( strSource, pObject )
	if strSource == nil or strSource == "" or pObject == nil then
		WriteConErr("param error");
		return;
	end
	
	self.pEvent[strSource] = self.pEvent[strSource] or {};
	local temp = self.pEvent[strSource];
	
	for strEvent, events in pairs( temp ) do
		for i = #temp[strEvent], 1, -1 do
			local event = temp[strEvent][i];
			if event ~= nil then
				if event.object == pObject then
					table.remove( temp[strEvent], i );
				end
			end
		end
	end
end

--��ע��ָ���¼�
function p:UnregisterEvent( strSource, strEvent, pObject, pCallback )
	if strSource == nil or strSource == "" or strEvent == nil or strEvent == "" or pObject == nil then
		WriteConErr("param error");
		return;
	end
	
	self.pEvent[strSource] = self.pEvent[strSource] or {};
	local temp = self.pEvent[strSource][strEvent];
	if temp == nil then
		return;
	end
	
	for i = #temp, 1, -1 do
		local event = temp[i];
		if event ~= nil then
			if event.object == pObject and (pCallback == nil or event.callback == pCallback) then
				table.remove( temp, i );
			end
		end
	end
end

local function getArguments( obj, index, count, arguments, ... )
	if index < count then
		return obj[(arguments[index])], getArguments(obj, index+1, count, arguments, ...);
	elseif index == count then
		return obj[(arguments[index])], ...;
	elseif index > count then
		return ...;
	end
end

--��������ص�
function p:RequestEvent( strSource, strEvent, pObject )
	if strSource == nil or strSource == "" or strEvent == nil or strEvent == "" or pObject == nil then
		WriteConErr("param error");
		return;
	end
	
	self.pEvent[strSource] = self.pEvent[strSource] or {};
	local temp = self.pEvent[strSource][strEvent];
	if temp == nil then
		return;
	end
	
	for i = #temp, 1, -1 do
		local event = temp[i];
		if event ~= nil then
			if event.object == pObject and event.callback ~= nil then				
				local cache = msg_cache[strSource] or {};
				if event.param ~= nil then
					local count = #event.param;
					event.callback( cache[strEvent], getArguments( cache, 1, count, event.param) );
				else
					event.callback( cache[strEvent] );
				end
			end
		end
	end
end

--�����ص�����
function p:TriggerEvent( strSource, strEvent )
	if strSource == nil or strSource == "" or strEvent == nil or strEvent == "" then
		WriteConErr("param error");
		return;
	end
	
	self.pEvent[strSource] = self.pEvent[strSource] or {};
	local temp = self.pEvent[strSource][strEvent];
	if temp == nil then
		return;
	end
	
	for i = #temp, 1, -1 do
		local event = temp[i];
		if event ~= nil then
			if event.callback ~= nil then
				local cache = msg_cache[strSource] or {};
				if event.param ~= nil then
					local count = #event.param;
					event.callback( cache[strEvent], getArguments( cache, 1, count, event.param) );
				else
					event.callback( cache[strEvent] );
				end
			end
		end
	end
end

--ȫ��
gNotify = notify:new();

