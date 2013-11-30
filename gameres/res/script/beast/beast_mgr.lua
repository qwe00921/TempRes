


beast_mgr = {};
local p = beast_mgr;

p.source = nil;--��������ٻ��޿ռ������������id�Լ������ٻ����б�
p.fightId = {};
p.layer = nil;

p.curNode = nil;

--��������
function p.LoadData( layer )
	WriteCon("�����ٻ�������");
	
	if layer then
		p.layer = layer;
	end
	
	local uid = GetUID();
    if uid == 0 or uid == nil then
        return ;
    end
	--�ٻ�����������
    SendReq("Pet", "GetPetData", uid, "");
end

--ˢ��UI
function p.RefreshUI( source )
	p.source = source;
	
	if p.source and p.source.pet_call and type(p.source.pet_call) == "table" then
		for _, pet_id in pairs(p.source.pet_call) do
			if pet_id.id ~= 0 then
				table.insert( p.fightId, pet_id.id )
			end
		end
	end
	
	dlg_beast_main.RefreshUI( source );
end

--�������
function p.ClearData()
	p.source = nil;

	p.fightId = {};
	p.layer = nil;
	
	p.curNode = nil;
end

--�ж��Ƿ�Ϊ��ս�ٻ���
function p.CheckIsFightPet( id )
	local flag = false;
	for _, petid in pairs( p.fightId ) do
		if petid == id then
			flag = true;
			break;
		end
	end
	return flag;
end

--���ó�ս
function p.SetFight( uiNode )
	for i, id in pairs(p.fightId) do
		if id == uiNode:GetId() then
			p.curNode = uiNode;
			
			local uid = GetUID();
			if uid == 0 or uid == nil then
				return ;
			end
			
			local param = string.format( "&id=%d&type=2", uiNode:GetId() );
			--�ٻ��ٻ�������
			SendReq("Pet", "CallPet", uid, param);
			return;
		end
	end

	if p.fightId and #p.fightId >= 2 then
		dlg_msgbox.ShowOK( ToUtf8("��ʾ"), ToUtf8("���ֻ�ܳ�ս�����ٻ���"), nil, p.layer );
		return;
	end

	p.curNode = uiNode;
	
	local uid = GetUID();
	if uid == 0 or uid == nil then
		return ;
	end
	
	local param = string.format( "&id=%d&type=1", uiNode:GetId() );
	--�ٻ��޳�ս
	SendReq("Pet", "CallPet", uid, param);
end

--�ٻ��޳�ս���ٻ���Ϣ�ص�
function p.CallBeast( nType )
	if p.curNode then
		if nType == 1 then
			dlg_beast_main.SetFightBtnCheck( p.curNode, true );
			table.insert( p.fightId, p.curNode:GetId() );
		else
			dlg_beast_main.SetFightBtnCheck( p.curNode, false );
			for i, id in pairs(p.fightId) do
				if id == p.curNode:GetId() then
					table.remove(p.fightId, i);
					break;
				end
			end
		end
	end
	p.curNode = nil;
end

