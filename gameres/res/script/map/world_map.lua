--------------------------------------------------------------
-- FileName: 	world_map.lua
-- author:		zhangwq, 2013/07/16
-- purpose:		世界地图
--------------------------------------------------------------

world_map = {}
local p = world_map;

p.userStatus =  nil;        --用户状态信息
p.userCoin = nil;           --用户金钱信息
p.userFinishMissions = nil; --用户完成任务情况
p.stopActionObj = nil;      --用于章节特效

local useMoveEffect = false; --是否使用移动特效，否则用缩放特效

--打开地图
function p.OpenMap()
	p.RegEvent();
	GetTileMapMgr():OpenMapWorld( "world_map.tmx", true ); --true to fade in.
	world_map_mainui.ShowUI();
end	

--关闭地图
function p.CloseMap()
	--顺序:先关闭UI，再关闭地图！
	dlg_stage_map.CloseUI();
	world_map_mainui.CloseUI();
	GetTileMapMgr():CloseMap();
	
	p.userStatus =  nil;
    p.userCoin = nil;
    p.userFinishMissions = nil;
    p.stopActionObj = nil;
end

--注册地图事件
function p.RegEvent()
	RegTileMapCallBack( "click_empty", 	    p.OnClickEmpty );
	RegTileMapCallBack( "click_obj", 	    p.OnClickObj );
	RegTileMapCallBack( "loadmap_begin",    p.OnLoadMapBegin );
	RegTileMapCallBack( "loadmap_end", 	    p.OnLoadMapEnd );
	RegTileMapCallBack( "player_jump_done", nil );
end

--点空地
function p.OnClickEmpty()
    WriteCon("OnClickEmpty");
	dlg_stage_map.CloseUI();
	p.AddEffect( p.stopActionObj );
	p.stopActionObj = nil;
	
	maininterface.CloseAllPanel();
	dlg_menu.CloseUI();
end

--点物件
function p.OnClickObj( tileObj, isTouchDown, objType, tileX, tileY )
	--只处理down事件，不处理up事件
	if isTouchDown then
		WriteCon("OnClickObj: objType="..objType..", tileX="..tileX..", tileY="..tileY..",tag="..tileObj:GetTag())
		--local posobj = GetTileMap():FindPathLayer():GetObjAtTilePos(tileX,tileY);	
		dlg_stage_map.CloseUI();
		p.AddEffect( p.stopActionObj );
		
		--当副本只有一个地图时，直接进入
		local chapterId = tileObj:GetId();
		local stageMaps = SelectRowList( T_STAGE_MAP, "chapter_id", chapterId );
		local chapterType = SelectCell( T_CHAPTER_MAP, chapterId, "chapter_type" );
		if #stageMaps == 1 and tonumber( chapterType ) == ENTER_MAP_DUNGEON then
            p.stopActionObj = nil;
            local travelId = GetTravelId( chapterId, stageMaps[1].id );
            local mapName = GetMapName( travelId );
		    dlg_dungeon_enter.ShowUI( mapName, chapterId, stageMaps[1].id, chapterType );
		else
            dlg_stage_map.ShowUI( tileObj, stageMaps );
            p.DelEffect( tileObj );
            p.stopActionObj = tileObj;
		end
	end
end

--开始加载地图
function p.OnLoadMapBegin(idMap, bWorldMap)
    WriteCon("OnLoadMapBegin: idMap="..idMap..",bWorldMap="..tostring(bWorldMap));
end

--结束加载地图
function p.OnLoadMapEnd(idMap, bWorldMap)
    WriteCon("OnLoadMapEnd: idMap="..idMap..",bWorldMap="..tostring(bWorldMap));
	
	--注册地图事件
	--GetTileMap():SetLuaDelegate( p.OnMapEvent );
	
	--设置允许拖动的方向
	GetTileMap():SetMoveDir( true, false ); --horz,vert
	
	-- 获取世界地图数据
	p.getWordMapData();

end

-- 获取世界地图数据
function p.getWordMapData()
    ShowLoading( true );
	local user_id = GetUID();
	SendReq( "Mission","GetUserMissionProgress",user_id,"" );
end


function p.RefreshUI(msg)
    p.userStatus =  msg.user_status;
    p.userCoin = msg.user_coin;
    p.userFinishMissions = msg.user_finish_missions;
    
    --添加所有章节
    p.AddAllChapters();
    ShowLoading( false );
end

--添加所有章节
function p.AddAllChapters()

	--获取前景层
	local fgLayer = GetTileMap():FindFgLayer();
	if fgLayer == nil then return end;
	
	local chapters = SelectRowList( T_CHAPTER_MAP );
	local position = 
	{
	   {x=4,  y=4, offsetX=-14, offsetY=-6},
	   {x=8,  y=2, offsetX=-5,  offsetY=-25}, 
	   {x=2,  y=6, offsetX=-3,  offsetY=-18}, 
	   {x=13, y=1, offsetX=-5,  offsetY=25}, 
	   {x=6,  y=5, offsetX=5,   offsetY=-27}, 
	   {x=12, y=4, offsetX=1,   offsetY=-12},
	   
	   {x=14,  y=9, offsetX=-30, offsetY=-50},
	   {x=17, y=7, offsetX=15,  offsetY=-10}, 
	};
	
	for i=1, #chapters do
		local is_hide = false;
		if not is_hide then
			local titleText = chapters[i].chapter_name;
			local pic = GetPictureByAni("map.chapter", i-1);
			local chapterId = tonumber( chapters[i].id )
			local chapterName = "chapter_"..i
			
			p.AddChapterObj( fgLayer, 
				position[i].x, position[i].y, 
				position[i].offsetX, position[i].offsetY, 
				pic, titleText, chapterId, chapterName );
		end
	end
end

--添加章节物件
function p.AddChapterObj( fgLayer, tileX, tileY, offsetX, offsetY, 
							pic, titleText, chapterId, chapterName )

	--添加物件
	local obj = fgLayer:AddTileObj( E_TILE_OBJ_CHAPTER, tileX, tileY );
	
	if obj ~= nil then
		--设置图片和绘制偏移
		obj:SetPicture( pic );
		obj:SetDrawingOffset( offsetX, offsetY );
		obj:SetId( chapterId );
		obj:SetName( chapterName );
		
		--设置物件所在区域
		local objPos = obj:GetFramePos();
        local picSize = UISize( pic:GetSize());
		picSize.w = picSize.w * 1.1f;
		picSize.h = picSize.h * 1.1f;
        local rect = CCRectMake( 
            objPos.x - 0.5f * picSize.w, 
            objPos.y - 0.5f * picSize.h,
            picSize.w, picSize.h );
        obj:SetFrameRect( rect );
		
		--判断是否解锁
		local isUnlock = true;
		local needTravelId = SelectCellMatch( T_CHAPTER_OPEN_CHECK, "chapter_id", chapterId, "need_travel_id" );
		if needTravelId ~= nil then
			isUnlock = p.isTravelFinish( needTravelId );
		end
		obj:SetEnabled( isUnlock );
		
		if not isUnlock then
			--如果未解锁则，播放表现效果：锁特效、灰色蒙版
            obj:SetMaskColor( ccc4(80,80,80,255) );
            
            local imageNode = createNDUIImage();
            imageNode:Init();
            obj:AddChild(imageNode);
            local pos = imageNode:GetFramePos();
            imageNode:SetFramePosXY(pos.x + picSize.w * 0.5f, pos.y + picSize.h * 0.5f);
            imageNode:AddFgEffect("ui.map_lock");
        else
			--如果已经解锁，播放表现效果
            p.AddEffect( obj );
		end
		
		--增加章节标题
		local title = createNDUILabel();
		if title ~= nil then
		  title:Init();
		  title:SetFontSize( FontSize(25));
		  title:SetFrameSize(picSize.w,picSize.h);
		  title:SetText( titleText );
		  title:SetFramePosXY( 0, -obj:GetFrameSize().h * 0.6f );
		  obj:AddChild(title);
		  
		  if isUnlock then
			title:SetFontColor( ccc4(0,0,255,255));
		  else
			title:SetFontColor( ccc4(125,125,125,255));
		  end
		  
		 else
		  WriteConErr( "create label err");
		end
	end
end

--章节特效增加
function p.AddEffect( obj )
	if obj ~= nil then
		obj:AddActionEffect( p.GetChapterActionTitle() ); 
	end
end

--章节特效删除
function p.DelEffect( obj )
    if obj ~= nil then
		obj:DelActionEffect( p.GetChapterActionTitle() ); 
	end
end

--取action特效名称
function p.GetChapterActionTitle()
	if useMoveEffect then
		--上下移动
		return "ui_cmb.common_move"; 
	else
		--缩放
		return "lancer_cmb.world_map_chapter_fx"; 
	end
end


--判断用户是否完成某旅行地图
function p.isTravelFinish( travelId )
	if p.userFinishMissions ~= nil then
	   for k, v in ipairs(p.userFinishMissions) do
	       if tonumber( v.travel_id ) == travelId and tonumber( v.finish ) == 1 then
	           return true;
	       end
	   end
	end
	return false;
end

--拖动地图时隐藏章节UI
function p.OnMapEvent( mapEvent, delta, distance )
	if mapEvent == 1 and distance > 5 then
		--WriteConErr( "OnMapEvent()" );
		--dlg_stage_map.CloseUI();
	end
end