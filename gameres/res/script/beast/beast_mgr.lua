


beast_mgr = {};
local p = beast_mgr;

p.source = nil;--��������ٻ��޿ռ������������id�Լ������ٻ����б�
p.fightId = {};
p.objs = {};	--�Է�������ݽ��д�������id���д洢���������
p.layer = nil;

p.curNode = nil;

p.idList = {};--�ٻ���������ѡ���ز��б�

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
	
	p.fightId = {};
	p.objs = {};
	
	if p.source then
		if p.source.pet_call and type(p.source.pet_call) == "table" then
			for _, pet_id in pairs(p.source.pet_call) do
				if pet_id.id ~= 0 then
					table.insert( p.fightId, pet_id.id )
				end
			end
		end
		
		if p.source.pet ~= nil and type(p.source.pet) == "table" then
			for _, v in pairs( p.source.pet ) do
				if v.id ~= nil then
					p.objs[v.id] = v;
				end
			end
		end
	end

	dlg_beast_main.RefreshUI( source );
end

--�������
function p.ClearData()
	p.source = nil;

	p.fightId = {};
	p.objs = {};
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

--�ٻ�������
function p.GetSource()
	return p.source;
end

--�ز��б�
function p.GetIDList()
	return p.idList;
end

--�����ѡ���زĿ���֧����������
function p.CheckUpLevel( nLev, nExp)
	if nLev == nil or nExp == nil then
		return 0, 0;
	end

	local upLev = 0;--�仯�ĵȼ�����
	
	local needExp = tonumber( SelectRowInner( T_PET_LEVEL, "level", tostring(nLev + upLev), "exp" ) );
	if needExp == 0 then
		return upLev, nExp;--�Ѿ�Ϊ��ߵȼ�
	end
	
	local totalExp = p.GetTotalExp() + nExp;
	while (totalExp >= needExp) do
		upLev = upLev + 1;
		totalExp = totalExp - needExp;
		needExp = tonumber(SelectRowInner( T_PET_LEVEL, "level", tostring(nLev + upLev), "exp" ));
	end
	return upLev, totalExp;
end

--��ȡ���ӵľ���
function p.GetTotalExp()
	if #p.idList == 0 then
		return 0;
	end
	
	local addExp = 0;
	for _, id in pairs(p.idList) do
		local t = p.objs[id];
		if t ~= nil then
			local nExp = tonumber(SelectRowInner( T_PET_LEVEL, "level", t.Level , "sacrifice_exp" ));
			addExp = addExp + nExp;
		end
	end
	return addExp;
end

--��ȡ���ĵĽ��
function p.GetTotalCostMoney()
	if #p.idList == 0 then
		return 0;
	end
	
	local costMoney = 0;
	for _, id in pairs(p.idList) do
		local t = p.objs[id];
		if t ~= nil then
			local nMoney = tonumber(SelectRowInner( T_PET_LEVEL, "level", t.Level , "sacrifice_money" ));
			costMoney = costMoney + nMoney;
		end
	end
	return costMoney;
end

--ѡ���ȡ���ز�
--������ѡ���ȡ�������������0
function p.SelectPetID( id, layer )
	if p.CheckIsFightPet( id ) then
		dlg_msgbox.ShowOK( ToUtf8("��ʾ"), ToUtf8("����ѡ���ս�ٻ���"), nil, layer );
		return 0;
	end
	
	local flag = true;
	for i, v in pairs(p.idList) do
		if v == id then
			table.remove( p.idList, i );
			flag = false;
			break;
		end
	end
	
	if flag then
		if #p.idList >= 5 then
			dlg_msgbox.ShowOK( ToUtf8("��ʾ"), ToUtf8("һ�����ֻ��ѡ��5���ٻ���"), nil, layer );
			return 0;
		else
			table.insert( p.idList, id);
		end
	end
	
	return flag;
end

function p.RequestTrain( id )
	if id == nil then
		return;
	end
	
	if #p.idList == 0 then
		dlg_msgbox.ShowOK( ToUtf8("��ʾ"), ToUtf8("δѡ���ز�"), nil, layer );
		return;
	end
	
	if p.GetTotalCostMoney() > tonumber(msg_cache.msg_player.Money) then
		dlg_msgbox.ShowOK( ToUtf8("��ʾ"), ToUtf8("��������Ľ�Ҳ���"), nil, layer );
		return;
	end
	
	local uid = GetUID();
	if uid == 0 or uid == nil then
		return ;
	end
	
	local param = string.format( "&id=%d&idm=%s", id, table.concat( p.idList, "," ) );
	--�ٻ��޳�ս
	SendReq("Pet", "TrainPet", uid, param);
end

function p.TrainBeast(source)
	p.RefreshUI( source );
	p.idList = {};

	dlg_beast_train.TrainCallBack();
end