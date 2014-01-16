

country_collect = {};
local p = country_collect;

p.layer = nil;

--拾取列表
p.collectList = {};
p.tickId = nil;
p.isBusy = false;
p.SendToServer = false;
p.collectResult = {};

E_COLLECT_MOUNTAIN = 1;
E_COLLECT_TREE = 2;
E_COLLECT_RIVER = 3;
E_COLLECT_FIELD = 4;
E_COLLECT_HOME = 5;

local DROP_TYPE_MATERIAL = 1;	--材料
local DROP_TYPE_MONEY = 4;	--金币
local DROP_TYPE_SOUL = 5;	--蓝魂

--==================================================================--
--取table长度，包含哈希部分以及数组部分
function TableLength( tTable)
	local num = 0;
	for _, _ in pairs(tTable) do
		num = num + 1;
	end
	return num;
end

--将table转换成json字符串的格式
function FormatTableToJson( tTemp )
	if type( tTemp ) ~= "table" then
		return tostring( tTemp );
	end

	local bFlag = table.getn( tTemp ) == TableLength( tTemp );
	local str = bFlag and "[" or "{";
	for key, value in pairs( tTemp ) do
		local connectStr = bFlag and "" or "\"" .. tostring( key ).. "\"" ..":";
		if type( value ) == "table" then
			str = str ..  connectStr .. FormatTableToJson( value ) .. ",";
		else
			str = str ..  connectStr .. tostring( value ) .. ",";
		end
	end

	if string.sub( str, -1, -1 ) == "," then
		str = string.sub( str, 1, -2 ) .. ""
	end
	str = str ..  (bFlag and "]" or "}");

	return str;
end
--==================================================================--

--==================================================================--
--用于材料表数量增加
function p.AddToTable( sourceTable, addTable )
	addTable.id = addTable.id or 0;
	addTable.num = addTable.num or 0;
	
	if #sourceTable == 0 then
		table.insert( sourceTable, addTable );
	else
		for i = 1, #sourceTable do
			local t = sourceTable[i];
			t.id = tonumber(t.id) or 0;
			t.num = tonumber(t.num) or 0;

			if t.id == addTable.id then
				t.num = t.num + addTable.num;
				break;
			end
		end
	end
end

--采集结果计算
function p.RandomCollectItem( collectType )
	local collectTable = {};
	local buildType = 0;
	local resultTable = nil;
	if E_COLLECT_MOUNTAIN == collectType then
		p.collectResult.Hill = p.collectResult.Hill or {};
		p.collectResult.Hill.times = p.collectResult.Hill.times or 0;
		p.collectResult.Hill.Gold = p.collectResult.Hill.Gold or 0;
		p.collectResult.Hill.Soul = p.collectResult.Hill.Soul or 0;
		p.collectResult.Hill.Material = p.collectResult.Hill.Material or {};
		
		resultTable = p.collectResult.Hill;
		buildType = 8;
	elseif E_COLLECT_TREE == collectType then
		p.collectResult.Forest = p.collectResult.Forest or {};
		p.collectResult.Forest.times = p.collectResult.Forest.times or 0;
		p.collectResult.Forest.Gold = p.collectResult.Forest.Gold or 0;
		p.collectResult.Forest.Soul = p.collectResult.Forest.Soul or 0;
		p.collectResult.Forest.Material = p.collectResult.Forest.Material or {};
		
		resultTable = p.collectResult.Forest;
		buildType = 9;
	elseif E_COLLECT_RIVER == collectType then
		p.collectResult.River = p.collectResult.River or {};
		p.collectResult.River.times = p.collectResult.River.times or 0;
		p.collectResult.River.Gold = p.collectResult.River.Gold or 0;
		p.collectResult.River.Soul = p.collectResult.River.Soul or 0;
		p.collectResult.River.Material = p.collectResult.River.Material or {};
		
		resultTable = p.collectResult.River;
		buildType = 6;
	elseif E_COLLECT_FIELD == collectType then
		p.collectResult.Farm = p.collectResult.Farm or {};
		p.collectResult.Farm.times = p.collectResult.Farm.times or 0;
		p.collectResult.Farm.Gold = p.collectResult.Farm.Gold or 0;
		p.collectResult.Farm.Soul = p.collectResult.Farm.Soul or 0;
		p.collectResult.Farm.Material = p.collectResult.Farm.Material or {};
		
		resultTable = p.collectResult.Farm;
		buildType = 7;
	elseif E_COLLECT_HOME == collectType then
		p.collectResult.Home = p.collectResult.Home or {};
		p.collectResult.Home.times = p.collectResult.Home.times or 0;
		p.collectResult.Home.Gold = p.collectResult.Home.Gold or 0;
		p.collectResult.Home.Soul = p.collectResult.Home.Soul or 0;
		p.collectResult.Home.Material = p.collectResult.Home.Material or {};
		
		resultTable = p.collectResult.Home;
		buildType = 4;
	end
	
	if resultTable ~= nil and buildType ~= 0 then
		local cache = msg_cache.msg_count_data or {};
		local builds = cache.builds or {};
		local build = builds["B".. buildType];
		local buildLevel = tonumber(build.build_level) or -1;
		
		local droplist = SelectRowList( T_MATERIAL_DROP, "build_type", buildType );
		if droplist ~= nil and #droplist > 0 then
			local temp = {};
			local total = 0;
			local dropprobability = {};
			for i = 1, #droplist do
				local level = tonumber(droplist[i].level) or 0;
				if level == buildLevel then
					total = total + tonumber( droplist[i].probability );
					table.insert( temp, droplist[i] );
					table.insert( dropprobability, total );
				end
			end
			
			if total ~= 0 then
				resultTable.times = resultTable.times + 1;
				--每次固定随机3次掉落
				for i = 1, 3 do
					local rand = math.random( 1, total );
					local index = 0;
					for j = 1, #dropprobability do
						if rand <= dropprobability[j] then
							index = j;
							break;
						end
					end
					
					if index ~= 0 then
						local drop_type = tonumber(temp[index].drop_type) or 0;
						if drop_type ~= 0 then
							if drop_type == DROP_TYPE_MATERIAL then
								p.AddToTable( resultTable.Material, { id = tonumber(temp[index].material_id) or 0, num = 1 } );
								table.insert( collectTable, { type = "material", id = tonumber(temp[index].material_id), num = tonumber(temp[index].drop_num) } );
							elseif drop_type == DROP_TYPE_MONEY then
								resultTable.Gold = resultTable.Gold + 1;
								table.insert( collectTable, { type = "gold", id = 0 } );
							elseif drop_type == DROP_TYPE_SOUL then
								resultTable.Soul = resultTable.Soul + 1;
								table.insert( collectTable, { type = "soul", id = 0 } );
							end
						end
					end
				end
			end
		end
	end
	
	return collectTable;
end

--根据随机的物品，播放采集物品动画
function p.CollectAnimation( node, result )
	if node == nil or result == nil then
		return;
	end
	local size = node:GetFrameSize();
	
	local image = createNDUIImage();
	image:Init();
	image:SetFramePosXY(size.w/2, size.h/2);
	image:SetFrameSize(24 , 24);
	image:SetVisible( false );

	local picData = nil;
	
	if result.type == "material" then
		picData = GetPictureByAni( "w_drop.hpball", 0 );
	elseif result.type == "gold" then
		picData = GetPictureByAni( "w_drop.money", 0 );
	elseif result.type == "soul" then
		picData = GetPictureByAni( "w_drop.bluesoul", 0 );
	end
	if picData ~= nil then
		image:SetPicture( picData );
	end
	
	node:AddChild( image );
	local effectName = "lancer_cmb.country_collect_" .. math.random( 1, 4 );
	image:AddActionEffect(effectName);
end
--==================================================================--

--==================================================================--
--采集山地
function p.CollectMountain( beginEvent, endEvent )
	if p.layer == nil then
		return;
	end
	
	local cache = msg_cache.msg_count_data or {};
	local times = cache.times or {};
	local collectTimes = tonumber(times.Hill) or 0;
	
	p.collectResult.Hill = p.collectResult.Hill or {};
	p.collectResult.Hill.times = p.collectResult.Hill.times or 0;
	if p.collectResult.Hill.times + 1 > collectTimes then
		return;
	end
	
	local collectTable = p.RandomCollectItem( E_COLLECT_MOUNTAIN );
	
	local node = GetButton( p.layer, ui_country.ID_CTRL_BUTTON_MOUNTAIN );
	p.CollectDone( node, collectTable, beginEvent, endEvent );
end

--采集森林
function p.CollectTree( beginEvent, endEvent )
	if p.layer == nil then
		return;
	end
	
	local cache = msg_cache.msg_count_data or {};
	local times = cache.times or {};
	local collectTimes = tonumber(times.Forest) or 0;
	
	p.collectResult.Forest = p.collectResult.Forest or {};
	p.collectResult.Forest.times = p.collectResult.Forest.times or 0;
	if p.collectResult.Forest.times + 1 > collectTimes then
		return;
	end

	local collectTable = p.RandomCollectItem( E_COLLECT_TREE );
	
	local node = GetButton( p.layer, ui_country.ID_CTRL_BUTTON_TREE );
	p.CollectDone( node, collectTable, beginEvent, endEvent );
end

--采集河流
function p.CollectRiver( beginEvent, endEvent )
	if p.layer == nil then
		return;
	end
	
	local cache = msg_cache.msg_count_data or {};
	local times = cache.times or {};
	local collectTimes = tonumber(times.River) or 0;
	
	p.collectResult.River = p.collectResult.River or {};
	p.collectResult.River.times = p.collectResult.River.times or 0;
	if p.collectResult.River.times + 1 > collectTimes then
		return;
	end

	local collectTable = p.RandomCollectItem( E_COLLECT_RIVER );
	
	local node = GetButton( p.layer, ui_country.ID_CTRL_BUTTON_RIVER );
	p.CollectDone( node, collectTable, beginEvent, endEvent );
end

--采集农田
function p.CollectField( beginEvent, endEvent )
	if p.layer == nil then
		return;
	end
	
	local cache = msg_cache.msg_count_data or {};
	local times = cache.times or {};
	local collectTimes = tonumber(times.Farm) or 0;
	
	p.collectResult.Farm = p.collectResult.Farm or {};
	p.collectResult.Farm.times = p.collectResult.Farm.times or 0;
	if p.collectResult.Farm.times + 1 > collectTimes then
		return;
	end
	
	local collectTable = p.RandomCollectItem( E_COLLECT_FIELD );
	
	local node = GetButton( p.layer, ui_country.ID_CTRL_BUTTON_FIELD );
	p.CollectDone( node, collectTable, beginEvent, endEvent );
end

--采集房屋
function p.CollectHome( beginEvent, endEvent )
	if p.layer == nil then
		return;
	end
	
	local cache = msg_cache.msg_count_data or {};
	local times = cache.times or {};
	local collectTimes = tonumber(times.Home) or 0;
	
	p.collectResult.Home = p.collectResult.Home or {};
	p.collectResult.Home.times = p.collectResult.Home.times or 0;
	if p.collectResult.Home.times + 1 > collectTimes then
		return;
	end
	
	local collectTable = p.RandomCollectItem( E_COLLECT_HOME );
	
	local node = GetButton( p.layer, ui_country.ID_CTRL_BUTTON_HOME );
	p.CollectDone( node, collectTable, beginEvent, endEvent );
end

--通用采集流程
function p.CollectDone( node, collectTable, beginEvent, endEvent )
	if node == nil then
		return;
	end
	
	if not (collectTable ~= nil and #collectTable > 0) then
		return;
	end
	
	--开始事件
	if beginEvent then
		beginEvent();
	end
	
	for i = 1, #collectTable do
		local result = collectTable[i];
		if result.type == "material" then
			for j = 1,tonumber(result.num) do
				local temp = { type = result.type, id = result.id };
				p.CollectAnimation( node, temp );
			end
		else
			p.CollectAnimation( node, result );
		end
	end

	--结束事件
	if endEvent then
		endEvent();
	end
end
--==================================================================--

--==================================================================--
--主循环
function p.Main_Tick()
	if p.isBusy then
		return;
	end
	
	local event = p.collectList[1] or "";
	local pEvent = p[event];
	if pEvent then
		table.remove( p.collectList, 1 );
		pEvent( p.SetBusy, p.SetFree );
	end
end

function p.SetBusy()
	p.isBusy = true;
end

function p.SetFree()
	p.isBusy = false;
end
--==================================================================--

--==================================================================--
--抛出接口
--设置层
function p.SetLayer( layer )
	p.layer = layer;
end

--开启主循环
function p.StartTick()
	if p.tickId ~= nil then
		KillTimer( p.tickId );
	end
	p.tickId = SetTimer( p.Main_Tick, 0.05 );
end

--结束主循环
function p.EndTick()
	if p.tickId ~= nil then
		KillTimer( p.tickId );
		p.tickId = nil;
	end
	
	p.collectList = {};
	p.isBusy = false;
	p.collectResult = {};
	p.layer = nil;
	p.SendToServer = false;
end

--增加拾取操作队列
function p.Collect( collectType )
	WriteCon( tostring(collectType) );
	if E_COLLECT_MOUNTAIN == collectType then
		table.insert( p.collectList, 1, "CollectMountain" );
	elseif E_COLLECT_TREE == collectType then
		table.insert( p.collectList, 1, "CollectTree" );
	elseif E_COLLECT_RIVER == collectType then
		table.insert( p.collectList, 1, "CollectRiver" );
	elseif E_COLLECT_FIELD == collectType then
		table.insert( p.collectList, 1, "CollectField" );
	elseif E_COLLECT_HOME == collectType then
		table.insert( p.collectList, 1, "CollectHome" );
	end
end

--发送采集结果请求
function p.SendCollectMsg()
	--已经发送采集结果
	if p.SendToServer then
		WriteCon( "已发送过" );
		return false;
	end
	
	if TableLength( p.collectResult ) == 0 then
		WriteCon( "没采集数据" );
		return false;
	end
	
	p.SendToServer = true;
	
	local uid = GetUID();
	if uid == nil or uid == 0 then
		return;
	end
	
	local str = FormatTableToJson( p.collectResult );
	WriteCon( str );
	
	SendPost("Collect", "Pick", uid, "", str);	
	return true;
end
--==================================================================--

--==================================================================--
--发送采集结果消息回调
function p.SendResultCallBack()
	p.SendToServer = false;
	p.collectResult = {};
	
	--材料仓库请求数据
	country_storage.RequestData();
end
--==================================================================--
