--------------------------------------------------------------
-- FileName: 	task_map.lua
-- author:		zhangwq, 2013/05/10
-- purpose:		任务地图
--------------------------------------------------------------

task_map = {}
local p = task_map;

local is_offline = false;
local maskColor = ccc4(80,80,80,255);
local mapItemAni =  "lancer.mapitem";

p.fgLayer = nil;
p.player = nil;
p.flynum = nil;
p.exp = nil;

p.cur_level = nil;	--最新等级
p.cur_exp = nil;	--最新经验

p.needMissionPoint = nil;		--旅行地图每行走一次需要消耗的行动力
p.missionPoint = nil;			--用户当前行动力
p.missionPointMax = nil;		--用户最大的行动力
p.recoverMissionPoint = nil;	--每分钟恢复的行动力数
p.recoverFullTime = nil;		--行动恢复满的时间
p.rollNumber = nil;				--ROLL点值

p.chapterId = nil;		--章节ID
p.stageId = nil;   		--关卡ID
p.mapName = nil;		--地图名称
p.stageType = nil;		--1:普通旅行地图。2:副本旅行地图
p.difficulty = nil;		--副本难度
p.travelId = nil;		--旅行地图ID
p.isNextMap = false;	--是否需要进入下一张地图标识


--打开地图
--------------------------------------------------------------------------------
--@param {string} mapName   :需要打开的地图名称(如：travel_1_1_1.tmx)
--@param {number} chapterId :章节ID          
--@param {number} stageId   :区域ID 
--@param {number} stageType :地图类型 【1为任务地图   2为副本地图  】
--@param {number} difficulty:副本难度，仅对stageType = 2 即副本有效
--------------------------------------------------------------------------------
function p.OpenMap( mapName, chapterId, stageId, stageType, difficulty )

	--根据参数选择合适的地图
    if (mapName == nil) or (chapterId == nil) or (stageId == nil) or (stageType == nil) then
    	return false;
    elseif (tonumber( stageType ) == 2) and (difficulty == nil) then
        return false;
    else
        p.chapterId = tonumber( chapterId );
        p.stageId = tonumber( stageId );
        p.mapName = mapName;
        p.stageType = tonumber( stageType );
        p.difficulty = tonumber( difficulty );
    end
    
	--注册地图事件
    p.RegEvent();
	
	--打开地图
	WriteCon( string.format("enter map: %s", p.mapName ));
    GetTileMapMgr():OpenMap( p.mapName, true ); --true to fade in
	
	--@rollstate
	task_map_roll_state.OnEnterMap();
end
	
--关闭地图
function p.CloseMap()
    GetTileMapMgr():CloseMap();
	maininterface.m_bgImage:SetVisible(true);
    p.ClearData();
    p.ClearTimer();
	
	--@rollstate
	task_map_roll_state.OnCloseMap();	
end

--清楚数据
function p.ClearData()
    p.fgLayer = nil;
    p.player = nil;
    p.flynum = nil;
    p.exp = nil;
    p.needMissionPoint = nil;
    p.missionPoint = nil;
    p.missionPointMax = nil;
    p.recoverMissionPoint = nil;
    p.recoverFullTime = nil;
    p.rollNumber = nil;
    p.chapterId = nil;
    p.stageId = nil;   
    p.mapName = nil;
    p.difficulty = nil;
    p.travelId = nil;
	p.isNextMap = false;
end

--注册地图事件
function p.RegEvent()
    RegTileMapCallBack( "click_empty", 	    p.OnClickEmpty );
    RegTileMapCallBack( "click_obj", 	    p.OnClickObj );
    RegTileMapCallBack( "loadmap_begin",    p.OnLoadMapBegin );
    RegTileMapCallBack( "loadmap_end", 	    p.OnLoadMapEnd );
    RegTileMapCallBack( "player_jump_done", p.OnPlayerJumpDone );
end

--点空地
function p.OnClickEmpty()
    WriteCon("OnClickEmpty");
end

--点物件
function p.OnClickObj( tileObj, isTouchDown, objType, tileX, tileY )

    --只处理down事件，不处理up事件
    if not isTouchDown then return end;
    WriteCon("OnClickObj: objType="..objType..", tileX="..tileX..", tileY="..tileY)

    --检查当前状态是否为等待点击寻路状态
    if task_map_roll_state.IsState_ClickPath() then

		--检查是否路径点
        if (E_TILE_OBJ_PATH == objType) then
			p.OnClickObj_Path( tileObj, tileX, tileY );
        end
    end
end

--点击路径点的处理
function p.OnClickObj_Path( tileObj, tileX, tileY )
	
	--检查目标点是否可以寻路到达
	if CheckPosAndMoveTo(tileX,tileY) then

		--处理特效
		RemoveRingEffect();
		tileObj:AddFgEffect("effect.blinkto");
		p.ClearTimer();
		
		--更新行动力点
		p.UpdateActionPoint( p.missionPoint - p.needMissionPoint );
		
		--发送mission_id,user_id,curr_x,curr_y到服务端
		local user_id = GetUID();
		
		--任务地图踩点
		if p.stageType == ENTER_MAP_TASK then
			local param = string.format("&travel_id=%d&position_x=%d&position_y=%d&roll_num=%d", p.travelId, tileX, tileY, p.rollNumber );
			SendReq( "Mission","Explore",user_id,param );
		
		--副本地图踩点   
		elseif p.stageType == ENTER_MAP_DUNGEON then
			local param = string.format("&travel_id=%d&position_x=%d&position_y=%d&roll_num=%d", p.travelId, tileX, tileY, p.rollNumber );
			SendReq( "Dungeon","Explore",user_id,param );
		end
		
		--修改状态为走路状态
		task_map_roll_state.OnClickPath();
	end
end

--开始加载地图
function p.OnLoadMapBegin(idMap, bWorldMap)
    WriteCon("OnLoadMapBegin: idMap="..idMap..",bWorldMap="..tostring(bWorldMap));
end

--结束加载地图
function p.OnLoadMapEnd(idMap, bWorldMap)
    WriteCon("OnLoadMapEnd: idMap="..idMap..",bWorldMap="..tostring(bWorldMap));

    if not bWorldMap then
        --不要显示路径点
        GetTileMap():SetDrawPathEnabled( true );

        --测试：背景灰化
        --GetTileMap():FindBgLayer():SetMaskColorGray();
        --GetTileMap():FindBgLayer():SetMaskColor( maskColor );

        -- 获取旅行地图数据
        p.getTaskMapData();

        --离线测试
        if is_offline then
            p.test_offline();
        end
    end
end

-- 获取旅行地图数据
function p.getTaskMapData()
    local user_id = GetUID();
    
    --任务地图数据
    if p.stageType == ENTER_MAP_TASK then
    	local param = string.format("&chapter_id=%d&stage_id=%d", p.chapterId, p.stageId);
        SendReq( "Mission","GetMissionInfo",user_id,param );
    
    --副本地图数据
    elseif p.stageType == ENTER_MAP_DUNGEON then
        local param = string.format("&chapter_id=%d&stage_id=%d&difficulty=%d", p.chapterId, p.stageId, p.difficulty );
        SendReq( "Dungeon","GetDungeon",user_id,param );  

    end
end

--更新消息刷新地图
function p.RefreshUI( msg )
    if (msg.idMsg == MSG_TRAVEL_INFO) then
        p.exp = tonumber(msg.mission_info.exp);
        p.travelId = msg.mission_info.id;
        p.needMissionPoint = tonumber(msg.mission_info.need_mission_point);
		
        --添加玩家角色[任务地图]
        p.AddPlayer(
			tonumber(msg.mission_info.start_point_x),
			tonumber(msg.mission_info.start_point_y));

    elseif msg.idMsg == MSG_TRAVEL_ITEM then
        for i=1,#msg.mission_rules do
            --放置宝箱、卡片、怪物[需要服务端提供宝箱，卡片，怪物位置信息]
            local rule = msg.mission_rules[i];
            p.AddItems(
				tonumber(rule.treasure_type),
				tonumber(rule.position_x),
				tonumber(rule.position_y));
        end
        
    elseif msg.idMsg == MSG_DUNGEON then
        p.exp = tonumber(msg.dungeon_info.exp);
        p.travelId = msg.dungeon_info.id;
        p.needMissionPoint = tonumber(msg.dungeon_info.need_mission_point);
		
        --添加玩家角色[副本地图]
        p.AddPlayer(
			tonumber(msg.dungeon_info.start_point_x),
			tonumber(msg.dungeon_info.start_point_y));
        
    elseif (msg.idMsg == MSG_MISSION_ROLL) then
		WriteCon("------------MSG_MISSION_ROLL");
		
        p.rollNumber = tonumber( msg.roll_num );
        p.missionPoint = tonumber(msg.mission_point);
        p.missionPointMax = tonumber(msg.mission_point_max);
        p.recoverMissionPoint = tonumber(msg.recover_mission_point);
        p.recoverFullTime = msg.recover_full_time;
        
        --设置定时器更新行动力点数
        if p.missionPoint < p.missionPointMax then
            if p.idTimer_UpdateActionPoint ~= nil then
                KillTimer( p.idTimer_UpdateActionPoint );
            end
            p.idTimer_UpdateActionPoint = SetTimer( p.onTimer_UpdateActionPoint, 60  );
        end
		
		--通知收到消息了，先把Roll存起来后面用
		task_map_roll_state.SetRollNumber( p.rollNumber );
		task_map_roll_state.OnRecvRollMsg();
        
		--更新行动力点
        p.UpdateActionPoint( p.missionPoint );
		
		--关闭等待界面
        ShowLoading( false );
    end
end

--打boss请求回调整
function p.BattleRefresh(msg)
	if msg ~= nil then
		--任务通关
		if msg.stage_clear then
			p.ClearTimer();
			boss_out.CloseUI();
			PlayEffectSoundByName("mission_complete.mp3"); 
            SetTimerOnce( game_main.EnterWorldMap, 2.0f );
            
            --更新缓存中的地图旅行数
            msg_cache.msg_player.travel_num = 1;
            task_map_mainui.RefreshTravelNum( msg_cache.msg_player.travel_num );
			return ;
			
		--进入下一关	
		elseif msg.refresh_map then
			boss_out.CloseUI();
			local id = AddHudEffect( "sk_test.nextmap" );
			RegAniEffectCallBack( id, p.GotoNextMap );
			GetTileMapMgr():GetMapNode():FadeOut();
		end
	end
end

--定时自动更新行动力
function p.onTimer_UpdateActionPoint()
	--累计
    p.missionPoint = p.missionPoint + p.recoverMissionPoint;
    if p.missionPoint >= p.missionPointMax then
        p.missionPoint = p.missionPointMax;
    end
	
	--更新行动力点数
    p.UpdateActionPoint( p.missionPoint );
	
	--更新Roll点状态
	task_map_roll_state.UpdateRollState();
end

--清除定时:更新行动力点
function p.ClearTimer()
	if p.idTimer_UpdateActionPoint ~= nil then
        KillTimer( p.idTimer_UpdateActionPoint );
        p.idTimer_UpdateActionPoint = nil;
    end
end

--行动力点数是否OK
function p.IsActionPointOK()
	if p.needMissionPoint ~= nil and p.missionPoint ~= nil then
		if p.missionPoint >= p.needMissionPoint then
			return true;
		end
	end
	return false;
end

--添加玩家角色
function p.AddPlayer( tileX, tileY )
    WriteCon( string.format("task_map.AddPlayer(), tileX=%d, tileY=%d\r\n", tileX, tileY ));
    
    --添加玩家角色
    p.player = GetTileMap():AddPlayer( tileX, tileY );
    if p.player == nil then return end
    p.player:SetDir(4);

    --获取角色图片
    local picRight 	= GetPictureByAni("token_self.self", 0);
    local picLeft 	= GetPictureByAni("token_self.self", 1);
    local picDown 	= GetPictureByAni("token_self.self", 2);
    local picUp  	= GetPictureByAni("token_self.self", 3);

    --设置图片
    p.player:SetPictures( picLeft, picUp, picRight, picDown );
    p.player:SetDrawingScale( 1.2 );

    --设置4个方向的绘制偏移
    p.player:SetDrawingOffsetUp( 0, -20 );
    p.player:SetDrawingOffsetLeft( 0, -20 );
    p.player:SetDrawingOffsetRight( 0, -20 );
    p.player:SetDrawingOffsetDown( 0, -20 );

    --角色头顶光效
    p.player:AddFgEffect("token_self.token_arrow");

    --设置经验值
    p.flynum = fly_num_exp:new();
    p.flynum:SetOwnerNode( p.player );
    p.flynum:Init();
    p.player:AddChildZ( p.flynum:GetNode(), 2 );
end

--放置宝箱、卡片、怪物
function p.AddItems( rules_type, tileX, tileY )
    --获取前景层
    local fgLayer = GetTileMap():FindFgLayer();
    p.fgLayer = fgLayer;
    if fgLayer == nil then return end;

    if (rules_type == E_RULES_TYPE_CARD) then	--卡片
        local picCard = GetPictureByAni( mapItemAni, MAP_ELEM_CARD );
        p.AddCard( fgLayer, tileX, tileY, picCard );

    elseif (rules_type == E_RULES_TYPE_BOX) then	--黄金宝箱
        local picBox  = GetPictureByAni( mapItemAni, MAP_ELEM_BOX );
        p.AddBox( fgLayer, tileX, tileY, picBox );

    elseif (rules_type == E_RULES_TYPE_MONSTER) then	--小怪
        local picMonster = GetPictureByAni( mapItemAni, MAP_ELEM_MONSTER );
        p.AddMonster( fgLayer, tileX, tileY, picMonster, E_TILE_OBJ_MONSTER );
		
    elseif (rules_type == E_RULES_TYPE_BOSS) then	--Boss
        local picBoss = GetPictureByAni( mapItemAni, MAP_ELEM_BOSS );
        p.AddBoss( fgLayer, tileX, tileY, picBoss, E_TILE_OBJ_BOSS );
    
    elseif (rules_type == E_RULES_TYPE_FINAL_BOSS) then   --最终Boss
        local picBoss = GetPictureByAni( mapItemAni, MAP_ELEM_FINAL_BOSS );
        p.AddBoss( fgLayer, tileX, tileY, picBoss, E_TILE_OBJ_FINAL_BOSS );
           
    elseif (rules_type == E_RULES_TYPE_NEXTMAP) then  --切屏点
        local pic = GetPictureByAni( mapItemAni, MAP_ELEM_NEXT_MAP );
        p.AddNextMap( fgLayer, tileX, tileY, pic );
    
    elseif (rules_type == E_RULES_TYPE_BEGIN_POINT) then --初始点 
        local pic = GetPictureByAni( mapItemAni, MAP_ELEM_BEGIN_POINT );
        p.AddBeginPoint( fgLayer, tileX, tileY, pic );    
        
    end
end

--地图起点图片
function p.AddBeginPoint( fgLayer, tileX, tileY, pic )
	local obj = fgLayer:AddTileObj( E_TILE_OBJ_BEGINPOINT, tileX, tileY );
    if obj ~= nil then
        obj:SetPicture( pic );
        obj:SetDrawingOffset( 0, -13 );
    end
end

--下个地图
function p.AddNextMap( fgLayer, tileX, tileY, pic )
	local obj = fgLayer:AddTileObj( E_TILE_OBJ_NEXTMAP, tileX, tileY );
	if obj ~= nil then
        obj:SetPicture( pic );
        obj:SetDrawingOffset( 0, -13 );
        obj:SetExit();
    end
end

--添加卡片
function p.AddCard( fgLayer, tileX, tileY, pic )
    local obj = fgLayer:AddTileObj( E_TILE_OBJ_CARD, tileX, tileY );
    if obj ~= nil then
        obj:SetPicture( pic );
        obj:SetDrawingScale( 0.9 );
        obj:SetDrawingOffset( 2, -22 );
        obj:AddActionEffect("test_cmb.mission_card_fx");
        --obj:AddBgEffect("lancer.mission_card_bg_fx");
        --obj:AddFgEffect("lancer.mission_card_fg_fx");
    --obj:SetMaskColor( maskColor );
    end
end

--添加箱子
function p.AddBox( fgLayer, tileX, tileY, pic )
    local obj = fgLayer:AddTileObj( E_TILE_OBJ_BOX, tileX, tileY );
    if obj ~= nil then
        obj:SetPicture( pic );
        obj:SetDrawingScale( 0.9 );
        obj:SetDrawingOffset( 1, -18 );
        obj:AddActionEffect("test_cmb.mission_box_fx");
    end
end

--添加小怪
function p.AddMonster( fgLayer, tileX, tileY, pic ,tileObj )
    local obj = fgLayer:AddTileObj( tileObj, tileX, tileY );
    if obj ~= nil then
        obj:SetPicture( pic );
        --obj:SetDrawingScale( 1 );
        obj:SetDrawingOffset( 0, -5 );
        --obj:AddFgEffect("lancer.mission_boss_fx");
		obj:AddActionEffect( "lancer_cmb.task_map_monster_fx" );
    end
end

--添加Boss
function p.AddBoss( fgLayer, tileX, tileY, pic ,tileObj )
    local obj = fgLayer:AddTileObj( tileObj, tileX, tileY );
    if obj ~= nil then
        obj:SetPicture( pic );
        --obj:SetDrawingScale( 1 );
        obj:SetDrawingOffset( 0, -5 );
        --obj:AddFgEffect("lancer.mission_boss_fx");
		obj:AddActionEffect( "lancer_cmb.task_map_monster_fx" );
        obj:SetExit();
    end
end

--跳跳结束（达到目标点）
function p.OnPlayerJumpDone( tileX, tileY )
	
	WriteCon("-------------OnPlayerJumpDone");
	
	--删除寻路提示光效
    RemoveRingEffect();
	
	--如果已经接收到Roll点了，则设置为就绪状态
	task_map_roll_state.OnPlayerJumpDone();
	
	--飘个经验值
    p.flynum:AdjustOffset(p.exp);
    p.flynum:PlayNum(p.exp);

	--更新玩家等级
    p.UpdateLevel();
    --p.UpdatePointFullTime();

	--处理目标点的事件
    local nType = GetTileObjType(tileX,tileY);
    if (nType ~= 0) then
		WriteCon( string.format("jump done, objType=%d", nType ));
		
		--开箱子
		if (E_TILE_OBJ_BOX == nType) then
			open_box.ShowUI();
			
		--获取卡片
		elseif (E_TILE_OBJ_CARD == nType) then
			get_card.ShowUI();
			
		--遇最终BOSS
		elseif (E_TILE_OBJ_FINAL_BOSS == nType) then
		   boss_out.ShowUI(p.travelId,tileX,tileY);
		   
		--遇BOSS
		elseif (E_TILE_OBJ_BOSS == nType) then
		   boss_out.ShowUI(p.travelId,tileX,tileY);
		   
		--遇小怪
		elseif (E_TILE_OBJ_MONSTER == nType) then
		   boss_out.ShowUI(p.travelId,tileX,tileY);
		   
		--切屏点
		elseif (E_TILE_OBJ_NEXTMAP == nType) then
			local id = AddHudEffect( "sk_test.nextmap" );
			RegAniEffectCallBack( id, p.GotoNextMap );
			GetTileMapMgr():GetMapNode():FadeOut();
		end

		--删除物件
		local obj = p.fgLayer:GetObjAtTilePos(tileX,tileY);
		p.fgLayer:RemoveTileObj( obj );
	end
end

--进入下一关
function p.GotoNextMap()
	p.ClearTimer();
	
	--根据当前旅行地图ID去取下一张的ID
    local nextTravelId;
    if p.stageType == ENTER_MAP_DUNGEON then
    	--副本：因最后两位为难度值，所以需要加100即可得到下一张旅行地图ID
    	nextTravelId = p.travelId + 100;
    	msg_cache.msg_world_info.user_status.dungeon_travel_id = nextTravelId;
    else
    	--普通旅行地图加1即可得到下一张旅行地图ID
    	nextTravelId = p.travelId + 1;
    	msg_cache.msg_world_info.user_status.travel_id = nextTravelId;
    end
	
	--进入下一张图
    local nextMapName = GetMapName( nextTravelId );
    p.OpenMap( nextMapName, p.chapterId, p.stageId, p.stageType, p.difficulty );
	
	--更新UI:旅行地图序号
    msg_cache.msg_player.travel_num = tonumber( msg_cache.msg_player.travel_num ) + 1;
    task_map_mainui.RefreshTravelNum( msg_cache.msg_player.travel_num );
end

--仅用于离线测试
function p.test_offline()

    --添加玩家角色
    p.AddPlayer( 3, 8 );

    --放置宝箱、卡片、怪物
    p.test_add_items();
end

--放置宝箱、卡片、怪物
function p.test_add_items()

    --获取前景层
    local fgLayer = GetTileMap():FindFgLayer();
    if fgLayer == nil then return end;

    --获取地图元素的图片
    local picCard = GetPictureByAni( mapItemAni, MAP_ELEM_CARD );
    local picBox  = GetPictureByAni( mapItemAni, MAP_ELEM_BOX );
    local picBoss = GetPictureByAni( mapItemAni, MAP_ELEM_BOSS );

    --添加卡片
    p.AddCard( fgLayer, 3, 5, picCard );
    p.AddCard( fgLayer, 2, 3, picCard );
    p.AddCard( fgLayer, 3, 3, picCard );
    p.AddCard( fgLayer, 4, 4, picCard );
    p.AddCard( fgLayer, 5, 5, picCard );
    p.AddCard( fgLayer, 7, 5, picCard );

    --添加箱子
    p.AddBox( fgLayer, 4, 8, picBox );
    p.AddBox( fgLayer, 6, 8, picBox );
    p.AddBox( fgLayer, 7, 7, picBox );
    p.AddBox( fgLayer, 9, 4, picBox );
    p.AddBox( fgLayer, 11, 2, picBox );
    p.AddBox( fgLayer, 11, 4, picBox );
    p.AddBox( fgLayer, 13, 2, picBox );

    --添加怪
    p.AddBoss( fgLayer, 4, 3, picBoss );
    p.AddBoss( fgLayer, 6, 5, picBoss );
    p.AddBoss( fgLayer, 7, 4, picBoss );
    p.AddBoss( fgLayer, 12, 5, picBoss );
    p.AddBoss( fgLayer, 9, 7, picBoss );
    p.AddBoss( fgLayer, 10, 4, picBoss );
    p.AddBoss( fgLayer, 10, 2, picBoss );
end

--玩家状态更新
function p.ExploreRefresh(msg)
	p.cur_level = tonumber(msg.user_status.level);
	p.cur_exp =  tonumber(msg.user_status.exp);
end

-- 更新等级
function p.UpdateLevel()
	local oldLevel = tonumber(msg_cache.msg_player.level);
	if p.cur_level > oldLevel then
		msg_cache.msg_player.level = p.cur_level;
		p.player:AddFgEffect("sk_test.levelup");
		task_map_mainui.RefreshLevel( p.cur_level );
	end
	msg_cache.msg_player.exp = p.cur_exp;
	task_map_mainui.RefreshExp( p.cur_exp );
end

--更新行动力点数
function p.UpdateActionPoint( point )
    --local point = p.mission_point - p.needMissionPoint;
    if point == nil or point < 0 then
        point = 0;
    end
    if msg_cache.msg_player ~= nil then
    	msg_cache.msg_player.mission_point = point;
    	task_map_mainui.RefreshActionPoint( point );
    end
end

--更新恢复时间
--function p.UpdatePointFullTime()
--    if p.recoverFullTime ~= nil then
--    	task_map_mainui.RefreshPointFullTime( p.recoverFullTime );
--    end
--end
