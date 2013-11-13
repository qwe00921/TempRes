


beast_mgr = {};
local p = beast_mgr;

p.source = nil;--包含玩家召唤兽空间数量、上阵的id以及所有召唤兽列表
p.layer = nil;

p.fight = nil;


--加载数据
function p.LoadData( layer )
	if layer ~= nil then
		p.layer = layer;
	end
	
	WriteCon("请求召唤兽数据");
	
	local uid = GetUID();
    if uid == 0 or uid == nil then
        return ;
    end;
	--召唤兽数据请求
    SendReq("Pet", "GetUserPet", uid, "");
end

--刷新UI
function p.RefreshUI( source )
	p.source = source;
	
	dlg_beast_main.RefreshUI( source );
end

--清除数据
function p.ClearData()
	p.source = nil;
    p.layer = nil;
    p.fight = nil;
end

--判断是否为出战召唤兽
function p.CheckIsFightPet( id )
	return p.source.pei_id == id;
end

--设置出战
function p.SetFight( uiNode )
	if p.fight ~= nil then
		dlg_beast_main.SetFightBtnCheck( p.fight, false);
	end
	
	p.fight = uiNode;
	dlg_beast_main.SetFightBtnCheck( p.fight, true );
end
