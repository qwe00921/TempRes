


beast_mgr = {};
local p = beast_mgr;

p.source = nil;--��������ٻ��޿ռ������������id�Լ������ٻ����б�
p.layer = nil;

p.fight = nil;


--��������
function p.LoadData( layer )
	if layer ~= nil then
		p.layer = layer;
	end
	
	WriteCon("�����ٻ�������");
	
	local uid = GetUID();
    if uid == 0 or uid == nil then
        return ;
    end;
	--�ٻ�����������
    SendReq("Pet", "GetUserPet", uid, "");
end

--ˢ��UI
function p.RefreshUI( source )
	p.source = source;
	
	dlg_beast_main.RefreshUI( source );
end

--�������
function p.ClearData()
	p.source = nil;
    p.layer = nil;
    p.fight = nil;
end

--�ж��Ƿ�Ϊ��ս�ٻ���
function p.CheckIsFightPet( id )
	return p.source.pei_id == id;
end

--���ó�ս
function p.SetFight( uiNode )
	if p.fight ~= nil then
		dlg_beast_main.SetFightBtnCheck( p.fight, false);
	end
	
	p.fight = uiNode;
	dlg_beast_main.SetFightBtnCheck( p.fight, true );
end
