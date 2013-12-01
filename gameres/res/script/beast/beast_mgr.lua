


beast_mgr = {};
local p = beast_mgr;

p.source = nil;--包含玩家召唤兽空间数量、上阵的id以及所有召唤兽列表
p.fightId = {};
p.objs = {};	--对服务端数据进行处理，根据id进行存储具体的数据
p.layer = nil;

p.curNode = nil;

p.idList = {};--召唤兽培养已选择素材列表

--加载数据
function p.LoadData( layer )
	WriteCon("请求召唤兽数据");
	
	if layer then
		p.layer = layer;
	end
	
	local uid = GetUID();
    if uid == 0 or uid == nil then
        return ;
    end
	--召唤兽数据请求
    SendReq("Pet", "GetPetData", uid, "");
end

--刷新UI
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

--清除数据
function p.ClearData()
	p.source = nil;

	p.fightId = {};
	p.objs = {};
	p.layer = nil;
	
	p.curNode = nil;
end

--判断是否为出战召唤兽
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

--设置出战
function p.SetFight( uiNode )
	for i, id in pairs(p.fightId) do
		if id == uiNode:GetId() then
			p.curNode = uiNode;
			
			local uid = GetUID();
			if uid == 0 or uid == nil then
				return ;
			end
			
			local param = string.format( "&id=%d&type=2", uiNode:GetId() );
			--召回召唤兽请求
			SendReq("Pet", "CallPet", uid, param);
			return;
		end
	end

	if p.fightId and #p.fightId >= 2 then
		dlg_msgbox.ShowOK( ToUtf8("提示"), ToUtf8("最多只能出战两个召唤兽"), nil, p.layer );
		return;
	end

	p.curNode = uiNode;
	
	local uid = GetUID();
	if uid == 0 or uid == nil then
		return ;
	end
	
	local param = string.format( "&id=%d&type=1", uiNode:GetId() );
	--召唤兽出战
	SendReq("Pet", "CallPet", uid, param);
end

--召唤兽出战、召回消息回调
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

--召唤兽数据
function p.GetSource()
	return p.source;
end

--素材列表
function p.GetIDList()
	return p.idList;
end

--检查已选的素材可以支持升级数量
function p.CheckUpLevel( nLev, nExp)
	if nLev == nil or nExp == nil then
		return 0, 0;
	end

	local upLev = 0;--变化的等级数量
	
	local needExp = tonumber( SelectRowInner( T_PET_LEVEL, "level", tostring(nLev + upLev), "exp" ) );
	if needExp == 0 then
		return upLev, nExp;--已经为最高等级
	end
	
	local totalExp = p.GetTotalExp() + nExp;
	while (totalExp >= needExp) do
		upLev = upLev + 1;
		totalExp = totalExp - needExp;
		needExp = tonumber(SelectRowInner( T_PET_LEVEL, "level", tostring(nLev + upLev), "exp" ));
	end
	return upLev, totalExp;
end

--获取增加的经验
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

--获取消耗的金币
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

--选择或取消素材
--非正常选择和取消的情况，返回0
function p.SelectPetID( id, layer )
	if p.CheckIsFightPet( id ) then
		dlg_msgbox.ShowOK( ToUtf8("提示"), ToUtf8("不能选择出战召唤兽"), nil, layer );
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
			dlg_msgbox.ShowOK( ToUtf8("提示"), ToUtf8("一次最多只能选择5个召唤兽"), nil, layer );
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
		dlg_msgbox.ShowOK( ToUtf8("提示"), ToUtf8("未选择素材"), nil, layer );
		return;
	end
	
	if p.GetTotalCostMoney() > tonumber(msg_cache.msg_player.Money) then
		dlg_msgbox.ShowOK( ToUtf8("提示"), ToUtf8("培养所需的金币不足"), nil, layer );
		return;
	end
	
	local uid = GetUID();
	if uid == 0 or uid == nil then
		return ;
	end
	
	local param = string.format( "&id=%d&idm=%s", id, table.concat( p.idList, "," ) );
	--召唤兽出战
	SendReq("Pet", "TrainPet", uid, param);
end

function p.TrainBeast(source)
	p.RefreshUI( source );
	p.idList = {};

	dlg_beast_train.TrainCallBack();
end