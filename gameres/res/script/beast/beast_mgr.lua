


beast_mgr = {};
local p = beast_mgr;

p.source = nil;--包含玩家召唤兽空间数量、上阵的id以及所有召唤兽列表
p.fightId = {};
p.layer = nil;

p.curNode = nil;

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
	
	if p.source and p.source.pet_call and type(p.source.pet_call) == "table" then
		for _, pet_id in pairs(p.source.pet_call) do
			if pet_id.id ~= 0 then
				table.insert( p.fightId, pet_id.id )
			end
		end
	end
	
	dlg_beast_main.RefreshUI( source );
end

--清除数据
function p.ClearData()
	p.source = nil;

	p.fightId = {};
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

