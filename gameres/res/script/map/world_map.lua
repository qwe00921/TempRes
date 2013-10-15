--------------------------------------------------------------
-- FileName: 	world_map.lua
-- author:		zhangwq, 2013/07/16
-- purpose:		�����ͼ
--------------------------------------------------------------

world_map = {}
local p = world_map;

p.userStatus =  nil;        --�û�״̬��Ϣ
p.userCoin = nil;           --�û���Ǯ��Ϣ
p.userFinishMissions = nil; --�û�����������
p.stopActionObj = nil;      --�����½���Ч

local useMoveEffect = false; --�Ƿ�ʹ���ƶ���Ч��������������Ч

--�򿪵�ͼ
function p.OpenMap()
	p.RegEvent();
	GetTileMapMgr():OpenMapWorld( "world_map.tmx", true ); --true to fade in.
	world_map_mainui.ShowUI();
end	

--�رյ�ͼ
function p.CloseMap()
	--˳��:�ȹر�UI���ٹرյ�ͼ��
	dlg_stage_map.CloseUI();
	world_map_mainui.CloseUI();
	GetTileMapMgr():CloseMap();
	
	p.userStatus =  nil;
    p.userCoin = nil;
    p.userFinishMissions = nil;
    p.stopActionObj = nil;
end

--ע���ͼ�¼�
function p.RegEvent()
	RegTileMapCallBack( "click_empty", 	    p.OnClickEmpty );
	RegTileMapCallBack( "click_obj", 	    p.OnClickObj );
	RegTileMapCallBack( "loadmap_begin",    p.OnLoadMapBegin );
	RegTileMapCallBack( "loadmap_end", 	    p.OnLoadMapEnd );
	RegTileMapCallBack( "player_jump_done", nil );
end

--��յ�
function p.OnClickEmpty()
    WriteCon("OnClickEmpty");
	dlg_stage_map.CloseUI();
	p.AddEffect( p.stopActionObj );
	p.stopActionObj = nil;
	
	maininterface.CloseAllPanel();
	dlg_menu.CloseUI();
end

--�����
function p.OnClickObj( tileObj, isTouchDown, objType, tileX, tileY )
	--ֻ����down�¼���������up�¼�
	if isTouchDown then
		WriteCon("OnClickObj: objType="..objType..", tileX="..tileX..", tileY="..tileY..",tag="..tileObj:GetTag())
		--local posobj = GetTileMap():FindPathLayer():GetObjAtTilePos(tileX,tileY);	
		dlg_stage_map.CloseUI();
		p.AddEffect( p.stopActionObj );
		
		--������ֻ��һ����ͼʱ��ֱ�ӽ���
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

--��ʼ���ص�ͼ
function p.OnLoadMapBegin(idMap, bWorldMap)
    WriteCon("OnLoadMapBegin: idMap="..idMap..",bWorldMap="..tostring(bWorldMap));
end

--�������ص�ͼ
function p.OnLoadMapEnd(idMap, bWorldMap)
    WriteCon("OnLoadMapEnd: idMap="..idMap..",bWorldMap="..tostring(bWorldMap));
	
	--ע���ͼ�¼�
	--GetTileMap():SetLuaDelegate( p.OnMapEvent );
	
	--���������϶��ķ���
	GetTileMap():SetMoveDir( true, false ); --horz,vert
	
	-- ��ȡ�����ͼ����
	p.getWordMapData();

end

-- ��ȡ�����ͼ����
function p.getWordMapData()
    ShowLoading( true );
	local user_id = GetUID();
	SendReq( "Mission","GetUserMissionProgress",user_id,"" );
end


function p.RefreshUI(msg)
    p.userStatus =  msg.user_status;
    p.userCoin = msg.user_coin;
    p.userFinishMissions = msg.user_finish_missions;
    
    --��������½�
    p.AddAllChapters();
    ShowLoading( false );
end

--��������½�
function p.AddAllChapters()

	--��ȡǰ����
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

--����½����
function p.AddChapterObj( fgLayer, tileX, tileY, offsetX, offsetY, 
							pic, titleText, chapterId, chapterName )

	--������
	local obj = fgLayer:AddTileObj( E_TILE_OBJ_CHAPTER, tileX, tileY );
	
	if obj ~= nil then
		--����ͼƬ�ͻ���ƫ��
		obj:SetPicture( pic );
		obj:SetDrawingOffset( offsetX, offsetY );
		obj:SetId( chapterId );
		obj:SetName( chapterName );
		
		--���������������
		local objPos = obj:GetFramePos();
        local picSize = UISize( pic:GetSize());
		picSize.w = picSize.w * 1.1f;
		picSize.h = picSize.h * 1.1f;
        local rect = CCRectMake( 
            objPos.x - 0.5f * picSize.w, 
            objPos.y - 0.5f * picSize.h,
            picSize.w, picSize.h );
        obj:SetFrameRect( rect );
		
		--�ж��Ƿ����
		local isUnlock = true;
		local needTravelId = SelectCellMatch( T_CHAPTER_OPEN_CHECK, "chapter_id", chapterId, "need_travel_id" );
		if needTravelId ~= nil then
			isUnlock = p.isTravelFinish( needTravelId );
		end
		obj:SetEnabled( isUnlock );
		
		if not isUnlock then
			--���δ�����򣬲��ű���Ч��������Ч����ɫ�ɰ�
            obj:SetMaskColor( ccc4(80,80,80,255) );
            
            local imageNode = createNDUIImage();
            imageNode:Init();
            obj:AddChild(imageNode);
            local pos = imageNode:GetFramePos();
            imageNode:SetFramePosXY(pos.x + picSize.w * 0.5f, pos.y + picSize.h * 0.5f);
            imageNode:AddFgEffect("ui.map_lock");
        else
			--����Ѿ����������ű���Ч��
            p.AddEffect( obj );
		end
		
		--�����½ڱ���
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

--�½���Ч����
function p.AddEffect( obj )
	if obj ~= nil then
		obj:AddActionEffect( p.GetChapterActionTitle() ); 
	end
end

--�½���Чɾ��
function p.DelEffect( obj )
    if obj ~= nil then
		obj:DelActionEffect( p.GetChapterActionTitle() ); 
	end
end

--ȡaction��Ч����
function p.GetChapterActionTitle()
	if useMoveEffect then
		--�����ƶ�
		return "ui_cmb.common_move"; 
	else
		--����
		return "lancer_cmb.world_map_chapter_fx"; 
	end
end


--�ж��û��Ƿ����ĳ���е�ͼ
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

--�϶���ͼʱ�����½�UI
function p.OnMapEvent( mapEvent, delta, distance )
	if mapEvent == 1 and distance > 5 then
		--WriteConErr( "OnMapEvent()" );
		--dlg_stage_map.CloseUI();
	end
end