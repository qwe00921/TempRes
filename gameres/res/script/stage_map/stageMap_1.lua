stageMap_1 = {}
local p = stageMap_1;


function p.OpenStageMap()
    WriteCon("show stageMap_1");
	p.RegEvent();
	GetTileMapMgr():OpenMapWorld( "test_world_map1.tmx", true );
end

--注册地图事件
function p.RegEvent()
	RegTileMapCallBack( "click_empty", 	    p.OnClickEmpty );
	RegTileMapCallBack( "click_obj", 	    p.OnClickObj );
	RegTileMapCallBack( "loadmap_begin",    p.OnLoadMapBegin );
	RegTileMapCallBack( "loadmap_end", 	    p.OnLoadMapEnd );
	--RegTileMapCallBack( "player_jump_done", nil );
end

--点空地
function p.OnClickEmpty()
    WriteCon("OnClickEmpty");
end
--点物件
function p.OnClickObj( tileObj, isTouchDown, objType, tileX, tileY )
	--只处理down事件，不处理up事件
	if isTouchDown then
		WriteCon("OnClickObj: objType="..objType..", tileX="..tileX..", tileY="..tileY..",tag="..tileObj:GetTag());
		local Stage_id = tileObj:GetId();
		if Stage_id == nil then 
			WriteCon("show Stage_id error ");
			return 
		end
		p.CloseStageMap()
		WriteCon("show stageMap == "..Stage_id);
		quest_main.ShowUI(Stage_id);
	end
end

--开始加载地图
function p.OnLoadMapBegin(idMap, bWorldMap)
    WriteCon("OnLoadMapBegin: idMap="..idMap..",bWorldMap="..tostring(bWorldMap));
end

--结束加载地图
function p.OnLoadMapEnd(idMap, bWorldMap)
    WriteCon("OnLoadMapEnd: idMap="..idMap..",bWorldMap="..tostring(bWorldMap));
	--设置允许拖动的方向
	GetTileMap():SetMoveDir( true, true ); --horz,vert
	
	-- 获取世界地图数据
	p.getStageMapData();
	--p.addAllStage()
end

-- 获取世界地图数据
function p.getStageMapData()
	WriteCon("send stageMap request");
	local uid = GetUID();
	local param = "MachineType=Android";
	SendReq("Mission","StageList",uid,param);
end

--加载地图章节
function p.addAllStage(stageData)
	local stageListInif = stageData;
	--获取前景层
	local fgLayer = GetTileMap():FindFgLayer();
	if fgLayer == nil then return end;
	
	local stageList = SelectRowList( T_STAGE );
	local position = {
		{x=10,  y=10, offsetX=0, offsetY=0},
		{x=20,  y=10, offsetX=0, offsetY=0}, 
		{x=30,  y=10, offsetX=0, offsetY=0}, 
		{x=40,  y=10, offsetX=0, offsetY=0}, 
		{x=50,  y=10, offsetX=0, offsetY=0}, 
		{x=10,  y=20, offsetX=0, offsetY=0},
		{x=20,  y=20, offsetX=0, offsetY=0},
		{x=30,  y=20, offsetX=0, offsetY=0}, 
		{x=40,  y=20, offsetX=0, offsetY=0}, 
	};                                 
	WriteCon("show stageList===="..#stageList);

	for i = 1, #stageList do
		local pic = GetPictureByAni("map.stage_1", i-1);
		local titleText = stageList[i].stage_name;
		local stageId = tonumber( stageList[i].stage_id );
		local stageName = "stage_"..i;
		local isUnlock = false;
		if stageListInif["S"..stageId] then
			isUnlock = true;
		end
		p.AddStageObj( fgLayer, 
			position[i].x, position[i].y, 
			position[i].offsetX, position[i].offsetY, 
			pic, titleText, stageId, stageName, isUnlock );
	end
end

--添加物件
function p.AddStageObj( fgLayer, tileX, tileY, offsetX, offsetY, 
							pic, titleText, stageId, stageName, isUnlock)

	--添加物件
	local obj = fgLayer:AddTileObj( 100, tileX, tileY );
	
	if obj ~= nil then
		--设置图片和绘制偏移
		obj:SetPicture( pic );
		obj:SetDrawingOffset( offsetX, offsetY );
		obj:SetId( stageId );
		obj:SetName( stageName );
		
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
		
		--增加标题
		local title = createNDUILabel();
		if title ~= nil then
			title:Init();
			title:SetFontSize( FontSize(25));
			title:SetFrameSize(picSize.w,picSize.h);
			title:SetText(ToUtf8(titleText));
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

--特效增加
function p.AddEffect( obj )
	if obj ~= nil then
		obj:AddActionEffect( p.GetStageActionTitle() ); 
	end
end

--取action特效名称
function p.GetStageActionTitle()
	if useMoveEffect then
		--上下移动
		return "ui_cmb.common_move"; 
	else
		--缩放
		return "lancer_cmb.world_map_chapter_fx"; 
	end
end

function p.CloseStageMap()
	GetTileMapMgr():CloseMap();
end

