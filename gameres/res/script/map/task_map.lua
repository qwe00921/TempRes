--------------------------------------------------------------
-- FileName: 	task_map.lua
-- author:		zhangwq, 2013/05/10
-- purpose:		�����ͼ
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

p.cur_level = nil;	--���µȼ�
p.cur_exp = nil;	--���¾���

p.needMissionPoint = nil;		--���е�ͼÿ����һ����Ҫ���ĵ��ж���
p.missionPoint = nil;			--�û���ǰ�ж���
p.missionPointMax = nil;		--�û������ж���
p.recoverMissionPoint = nil;	--ÿ���ӻָ����ж�����
p.recoverFullTime = nil;		--�ж��ָ�����ʱ��
p.rollNumber = nil;				--ROLL��ֵ

p.chapterId = nil;		--�½�ID
p.stageId = nil;   		--�ؿ�ID
p.mapName = nil;		--��ͼ����
p.stageType = nil;		--1:��ͨ���е�ͼ��2:�������е�ͼ
p.difficulty = nil;		--�����Ѷ�
p.travelId = nil;		--���е�ͼID
p.isNextMap = false;	--�Ƿ���Ҫ������һ�ŵ�ͼ��ʶ


--�򿪵�ͼ
--------------------------------------------------------------------------------
--@param {string} mapName   :��Ҫ�򿪵ĵ�ͼ����(�磺travel_1_1_1.tmx)
--@param {number} chapterId :�½�ID          
--@param {number} stageId   :����ID 
--@param {number} stageType :��ͼ���� ��1Ϊ�����ͼ   2Ϊ������ͼ  ��
--@param {number} difficulty:�����Ѷȣ�����stageType = 2 ��������Ч
--------------------------------------------------------------------------------
function p.OpenMap( mapName, chapterId, stageId, stageType, difficulty )

	--���ݲ���ѡ����ʵĵ�ͼ
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
    
	--ע���ͼ�¼�
    p.RegEvent();
	
	--�򿪵�ͼ
	WriteCon( string.format("enter map: %s", p.mapName ));
    GetTileMapMgr():OpenMap( p.mapName, true ); --true to fade in
	
	--@rollstate
	task_map_roll_state.OnEnterMap();
end
	
--�رյ�ͼ
function p.CloseMap()
    GetTileMapMgr():CloseMap();
	maininterface.m_bgImage:SetVisible(true);
    p.ClearData();
    p.ClearTimer();
	
	--@rollstate
	task_map_roll_state.OnCloseMap();	
end

--�������
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

--ע���ͼ�¼�
function p.RegEvent()
    RegTileMapCallBack( "click_empty", 	    p.OnClickEmpty );
    RegTileMapCallBack( "click_obj", 	    p.OnClickObj );
    RegTileMapCallBack( "loadmap_begin",    p.OnLoadMapBegin );
    RegTileMapCallBack( "loadmap_end", 	    p.OnLoadMapEnd );
    RegTileMapCallBack( "player_jump_done", p.OnPlayerJumpDone );
end

--��յ�
function p.OnClickEmpty()
    WriteCon("OnClickEmpty");
end

--�����
function p.OnClickObj( tileObj, isTouchDown, objType, tileX, tileY )

    --ֻ����down�¼���������up�¼�
    if not isTouchDown then return end;
    WriteCon("OnClickObj: objType="..objType..", tileX="..tileX..", tileY="..tileY)

    --��鵱ǰ״̬�Ƿ�Ϊ�ȴ����Ѱ·״̬
    if task_map_roll_state.IsState_ClickPath() then

		--����Ƿ�·����
        if (E_TILE_OBJ_PATH == objType) then
			p.OnClickObj_Path( tileObj, tileX, tileY );
        end
    end
end

--���·����Ĵ���
function p.OnClickObj_Path( tileObj, tileX, tileY )
	
	--���Ŀ����Ƿ����Ѱ·����
	if CheckPosAndMoveTo(tileX,tileY) then

		--������Ч
		RemoveRingEffect();
		tileObj:AddFgEffect("effect.blinkto");
		p.ClearTimer();
		
		--�����ж�����
		p.UpdateActionPoint( p.missionPoint - p.needMissionPoint );
		
		--����mission_id,user_id,curr_x,curr_y�������
		local user_id = GetUID();
		
		--�����ͼ�ȵ�
		if p.stageType == ENTER_MAP_TASK then
			local param = string.format("&travel_id=%d&position_x=%d&position_y=%d&roll_num=%d", p.travelId, tileX, tileY, p.rollNumber );
			SendReq( "Mission","Explore",user_id,param );
		
		--������ͼ�ȵ�   
		elseif p.stageType == ENTER_MAP_DUNGEON then
			local param = string.format("&travel_id=%d&position_x=%d&position_y=%d&roll_num=%d", p.travelId, tileX, tileY, p.rollNumber );
			SendReq( "Dungeon","Explore",user_id,param );
		end
		
		--�޸�״̬Ϊ��·״̬
		task_map_roll_state.OnClickPath();
	end
end

--��ʼ���ص�ͼ
function p.OnLoadMapBegin(idMap, bWorldMap)
    WriteCon("OnLoadMapBegin: idMap="..idMap..",bWorldMap="..tostring(bWorldMap));
end

--�������ص�ͼ
function p.OnLoadMapEnd(idMap, bWorldMap)
    WriteCon("OnLoadMapEnd: idMap="..idMap..",bWorldMap="..tostring(bWorldMap));

    if not bWorldMap then
        --��Ҫ��ʾ·����
        GetTileMap():SetDrawPathEnabled( true );

        --���ԣ������һ�
        --GetTileMap():FindBgLayer():SetMaskColorGray();
        --GetTileMap():FindBgLayer():SetMaskColor( maskColor );

        -- ��ȡ���е�ͼ����
        p.getTaskMapData();

        --���߲���
        if is_offline then
            p.test_offline();
        end
    end
end

-- ��ȡ���е�ͼ����
function p.getTaskMapData()
    local user_id = GetUID();
    
    --�����ͼ����
    if p.stageType == ENTER_MAP_TASK then
    	local param = string.format("&chapter_id=%d&stage_id=%d", p.chapterId, p.stageId);
        SendReq( "Mission","GetMissionInfo",user_id,param );
    
    --������ͼ����
    elseif p.stageType == ENTER_MAP_DUNGEON then
        local param = string.format("&chapter_id=%d&stage_id=%d&difficulty=%d", p.chapterId, p.stageId, p.difficulty );
        SendReq( "Dungeon","GetDungeon",user_id,param );  

    end
end

--������Ϣˢ�µ�ͼ
function p.RefreshUI( msg )
    if (msg.idMsg == MSG_TRAVEL_INFO) then
        p.exp = tonumber(msg.mission_info.exp);
        p.travelId = msg.mission_info.id;
        p.needMissionPoint = tonumber(msg.mission_info.need_mission_point);
		
        --�����ҽ�ɫ[�����ͼ]
        p.AddPlayer(
			tonumber(msg.mission_info.start_point_x),
			tonumber(msg.mission_info.start_point_y));

    elseif msg.idMsg == MSG_TRAVEL_ITEM then
        for i=1,#msg.mission_rules do
            --���ñ��䡢��Ƭ������[��Ҫ������ṩ���䣬��Ƭ������λ����Ϣ]
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
		
        --�����ҽ�ɫ[������ͼ]
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
        
        --���ö�ʱ�������ж�������
        if p.missionPoint < p.missionPointMax then
            if p.idTimer_UpdateActionPoint ~= nil then
                KillTimer( p.idTimer_UpdateActionPoint );
            end
            p.idTimer_UpdateActionPoint = SetTimer( p.onTimer_UpdateActionPoint, 60  );
        end
		
		--֪ͨ�յ���Ϣ�ˣ��Ȱ�Roll������������
		task_map_roll_state.SetRollNumber( p.rollNumber );
		task_map_roll_state.OnRecvRollMsg();
        
		--�����ж�����
        p.UpdateActionPoint( p.missionPoint );
		
		--�رյȴ�����
        ShowLoading( false );
    end
end

--��boss����ص���
function p.BattleRefresh(msg)
	if msg ~= nil then
		--����ͨ��
		if msg.stage_clear then
			p.ClearTimer();
			boss_out.CloseUI();
			PlayEffectSoundByName("mission_complete.mp3"); 
            SetTimerOnce( game_main.EnterWorldMap, 2.0f );
            
            --���»����еĵ�ͼ������
            msg_cache.msg_player.travel_num = 1;
            task_map_mainui.RefreshTravelNum( msg_cache.msg_player.travel_num );
			return ;
			
		--������һ��	
		elseif msg.refresh_map then
			boss_out.CloseUI();
			local id = AddHudEffect( "sk_test.nextmap" );
			RegAniEffectCallBack( id, p.GotoNextMap );
			GetTileMapMgr():GetMapNode():FadeOut();
		end
	end
end

--��ʱ�Զ������ж���
function p.onTimer_UpdateActionPoint()
	--�ۼ�
    p.missionPoint = p.missionPoint + p.recoverMissionPoint;
    if p.missionPoint >= p.missionPointMax then
        p.missionPoint = p.missionPointMax;
    end
	
	--�����ж�������
    p.UpdateActionPoint( p.missionPoint );
	
	--����Roll��״̬
	task_map_roll_state.UpdateRollState();
end

--�����ʱ:�����ж�����
function p.ClearTimer()
	if p.idTimer_UpdateActionPoint ~= nil then
        KillTimer( p.idTimer_UpdateActionPoint );
        p.idTimer_UpdateActionPoint = nil;
    end
end

--�ж��������Ƿ�OK
function p.IsActionPointOK()
	if p.needMissionPoint ~= nil and p.missionPoint ~= nil then
		if p.missionPoint >= p.needMissionPoint then
			return true;
		end
	end
	return false;
end

--�����ҽ�ɫ
function p.AddPlayer( tileX, tileY )
    WriteCon( string.format("task_map.AddPlayer(), tileX=%d, tileY=%d\r\n", tileX, tileY ));
    
    --�����ҽ�ɫ
    p.player = GetTileMap():AddPlayer( tileX, tileY );
    if p.player == nil then return end
    p.player:SetDir(4);

    --��ȡ��ɫͼƬ
    local picRight 	= GetPictureByAni("token_self.self", 0);
    local picLeft 	= GetPictureByAni("token_self.self", 1);
    local picDown 	= GetPictureByAni("token_self.self", 2);
    local picUp  	= GetPictureByAni("token_self.self", 3);

    --����ͼƬ
    p.player:SetPictures( picLeft, picUp, picRight, picDown );
    p.player:SetDrawingScale( 1.2 );

    --����4������Ļ���ƫ��
    p.player:SetDrawingOffsetUp( 0, -20 );
    p.player:SetDrawingOffsetLeft( 0, -20 );
    p.player:SetDrawingOffsetRight( 0, -20 );
    p.player:SetDrawingOffsetDown( 0, -20 );

    --��ɫͷ����Ч
    p.player:AddFgEffect("token_self.token_arrow");

    --���þ���ֵ
    p.flynum = fly_num_exp:new();
    p.flynum:SetOwnerNode( p.player );
    p.flynum:Init();
    p.player:AddChildZ( p.flynum:GetNode(), 2 );
end

--���ñ��䡢��Ƭ������
function p.AddItems( rules_type, tileX, tileY )
    --��ȡǰ����
    local fgLayer = GetTileMap():FindFgLayer();
    p.fgLayer = fgLayer;
    if fgLayer == nil then return end;

    if (rules_type == E_RULES_TYPE_CARD) then	--��Ƭ
        local picCard = GetPictureByAni( mapItemAni, MAP_ELEM_CARD );
        p.AddCard( fgLayer, tileX, tileY, picCard );

    elseif (rules_type == E_RULES_TYPE_BOX) then	--�ƽ���
        local picBox  = GetPictureByAni( mapItemAni, MAP_ELEM_BOX );
        p.AddBox( fgLayer, tileX, tileY, picBox );

    elseif (rules_type == E_RULES_TYPE_MONSTER) then	--С��
        local picMonster = GetPictureByAni( mapItemAni, MAP_ELEM_MONSTER );
        p.AddMonster( fgLayer, tileX, tileY, picMonster, E_TILE_OBJ_MONSTER );
		
    elseif (rules_type == E_RULES_TYPE_BOSS) then	--Boss
        local picBoss = GetPictureByAni( mapItemAni, MAP_ELEM_BOSS );
        p.AddBoss( fgLayer, tileX, tileY, picBoss, E_TILE_OBJ_BOSS );
    
    elseif (rules_type == E_RULES_TYPE_FINAL_BOSS) then   --����Boss
        local picBoss = GetPictureByAni( mapItemAni, MAP_ELEM_FINAL_BOSS );
        p.AddBoss( fgLayer, tileX, tileY, picBoss, E_TILE_OBJ_FINAL_BOSS );
           
    elseif (rules_type == E_RULES_TYPE_NEXTMAP) then  --������
        local pic = GetPictureByAni( mapItemAni, MAP_ELEM_NEXT_MAP );
        p.AddNextMap( fgLayer, tileX, tileY, pic );
    
    elseif (rules_type == E_RULES_TYPE_BEGIN_POINT) then --��ʼ�� 
        local pic = GetPictureByAni( mapItemAni, MAP_ELEM_BEGIN_POINT );
        p.AddBeginPoint( fgLayer, tileX, tileY, pic );    
        
    end
end

--��ͼ���ͼƬ
function p.AddBeginPoint( fgLayer, tileX, tileY, pic )
	local obj = fgLayer:AddTileObj( E_TILE_OBJ_BEGINPOINT, tileX, tileY );
    if obj ~= nil then
        obj:SetPicture( pic );
        obj:SetDrawingOffset( 0, -13 );
    end
end

--�¸���ͼ
function p.AddNextMap( fgLayer, tileX, tileY, pic )
	local obj = fgLayer:AddTileObj( E_TILE_OBJ_NEXTMAP, tileX, tileY );
	if obj ~= nil then
        obj:SetPicture( pic );
        obj:SetDrawingOffset( 0, -13 );
        obj:SetExit();
    end
end

--��ӿ�Ƭ
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

--�������
function p.AddBox( fgLayer, tileX, tileY, pic )
    local obj = fgLayer:AddTileObj( E_TILE_OBJ_BOX, tileX, tileY );
    if obj ~= nil then
        obj:SetPicture( pic );
        obj:SetDrawingScale( 0.9 );
        obj:SetDrawingOffset( 1, -18 );
        obj:AddActionEffect("test_cmb.mission_box_fx");
    end
end

--���С��
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

--���Boss
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

--�����������ﵽĿ��㣩
function p.OnPlayerJumpDone( tileX, tileY )
	
	WriteCon("-------------OnPlayerJumpDone");
	
	--ɾ��Ѱ·��ʾ��Ч
    RemoveRingEffect();
	
	--����Ѿ����յ�Roll���ˣ�������Ϊ����״̬
	task_map_roll_state.OnPlayerJumpDone();
	
	--Ʈ������ֵ
    p.flynum:AdjustOffset(p.exp);
    p.flynum:PlayNum(p.exp);

	--������ҵȼ�
    p.UpdateLevel();
    --p.UpdatePointFullTime();

	--����Ŀ�����¼�
    local nType = GetTileObjType(tileX,tileY);
    if (nType ~= 0) then
		WriteCon( string.format("jump done, objType=%d", nType ));
		
		--������
		if (E_TILE_OBJ_BOX == nType) then
			open_box.ShowUI();
			
		--��ȡ��Ƭ
		elseif (E_TILE_OBJ_CARD == nType) then
			get_card.ShowUI();
			
		--������BOSS
		elseif (E_TILE_OBJ_FINAL_BOSS == nType) then
		   boss_out.ShowUI(p.travelId,tileX,tileY);
		   
		--��BOSS
		elseif (E_TILE_OBJ_BOSS == nType) then
		   boss_out.ShowUI(p.travelId,tileX,tileY);
		   
		--��С��
		elseif (E_TILE_OBJ_MONSTER == nType) then
		   boss_out.ShowUI(p.travelId,tileX,tileY);
		   
		--������
		elseif (E_TILE_OBJ_NEXTMAP == nType) then
			local id = AddHudEffect( "sk_test.nextmap" );
			RegAniEffectCallBack( id, p.GotoNextMap );
			GetTileMapMgr():GetMapNode():FadeOut();
		end

		--ɾ�����
		local obj = p.fgLayer:GetObjAtTilePos(tileX,tileY);
		p.fgLayer:RemoveTileObj( obj );
	end
end

--������һ��
function p.GotoNextMap()
	p.ClearTimer();
	
	--���ݵ�ǰ���е�ͼIDȥȡ��һ�ŵ�ID
    local nextTravelId;
    if p.stageType == ENTER_MAP_DUNGEON then
    	--�������������λΪ�Ѷ�ֵ��������Ҫ��100���ɵõ���һ�����е�ͼID
    	nextTravelId = p.travelId + 100;
    	msg_cache.msg_world_info.user_status.dungeon_travel_id = nextTravelId;
    else
    	--��ͨ���е�ͼ��1���ɵõ���һ�����е�ͼID
    	nextTravelId = p.travelId + 1;
    	msg_cache.msg_world_info.user_status.travel_id = nextTravelId;
    end
	
	--������һ��ͼ
    local nextMapName = GetMapName( nextTravelId );
    p.OpenMap( nextMapName, p.chapterId, p.stageId, p.stageType, p.difficulty );
	
	--����UI:���е�ͼ���
    msg_cache.msg_player.travel_num = tonumber( msg_cache.msg_player.travel_num ) + 1;
    task_map_mainui.RefreshTravelNum( msg_cache.msg_player.travel_num );
end

--���������߲���
function p.test_offline()

    --�����ҽ�ɫ
    p.AddPlayer( 3, 8 );

    --���ñ��䡢��Ƭ������
    p.test_add_items();
end

--���ñ��䡢��Ƭ������
function p.test_add_items()

    --��ȡǰ����
    local fgLayer = GetTileMap():FindFgLayer();
    if fgLayer == nil then return end;

    --��ȡ��ͼԪ�ص�ͼƬ
    local picCard = GetPictureByAni( mapItemAni, MAP_ELEM_CARD );
    local picBox  = GetPictureByAni( mapItemAni, MAP_ELEM_BOX );
    local picBoss = GetPictureByAni( mapItemAni, MAP_ELEM_BOSS );

    --��ӿ�Ƭ
    p.AddCard( fgLayer, 3, 5, picCard );
    p.AddCard( fgLayer, 2, 3, picCard );
    p.AddCard( fgLayer, 3, 3, picCard );
    p.AddCard( fgLayer, 4, 4, picCard );
    p.AddCard( fgLayer, 5, 5, picCard );
    p.AddCard( fgLayer, 7, 5, picCard );

    --�������
    p.AddBox( fgLayer, 4, 8, picBox );
    p.AddBox( fgLayer, 6, 8, picBox );
    p.AddBox( fgLayer, 7, 7, picBox );
    p.AddBox( fgLayer, 9, 4, picBox );
    p.AddBox( fgLayer, 11, 2, picBox );
    p.AddBox( fgLayer, 11, 4, picBox );
    p.AddBox( fgLayer, 13, 2, picBox );

    --��ӹ�
    p.AddBoss( fgLayer, 4, 3, picBoss );
    p.AddBoss( fgLayer, 6, 5, picBoss );
    p.AddBoss( fgLayer, 7, 4, picBoss );
    p.AddBoss( fgLayer, 12, 5, picBoss );
    p.AddBoss( fgLayer, 9, 7, picBoss );
    p.AddBoss( fgLayer, 10, 4, picBoss );
    p.AddBoss( fgLayer, 10, 2, picBoss );
end

--���״̬����
function p.ExploreRefresh(msg)
	p.cur_level = tonumber(msg.user_status.level);
	p.cur_exp =  tonumber(msg.user_status.exp);
end

-- ���µȼ�
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

--�����ж�������
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

--���»ָ�ʱ��
--function p.UpdatePointFullTime()
--    if p.recoverFullTime ~= nil then
--    	task_map_mainui.RefreshPointFullTime( p.recoverFullTime );
--    end
--end
