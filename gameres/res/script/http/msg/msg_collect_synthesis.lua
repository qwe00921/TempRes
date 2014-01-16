
msg_collect_synthesis = msg_base:new();
local p = msg_collect_synthesis;
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
    self.idMsg = MSG_COLLECT_SYNTHESIS; --��Ϣ��
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
	WriteConWarning( "** msg_collect_synthesis:Process() called" );
	
	if self.result then
		--msg_cache.msg_material_list = CopyTable( self.Material );
		local cache = msg_cache.msg_material_list or {};
		cache.Material = self.Material;
		
		country_mixhouse.MixCallBack( true );
	else
		dlg_msgbox.ShowOK( ToUtf8("��ʾ"), self.message, nil, country_mixhouse.layer );
		country_mixhouse.MixCallBack( false );
	end
end


