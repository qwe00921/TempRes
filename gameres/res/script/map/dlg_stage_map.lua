--------------------------------------------------------------
-- FileName: 	dlg_stage_map.lua
-- author:		xyd, 2013/07/16
-- purpose:		�����ͼ
--------------------------------------------------------------

dlg_stage_map = {}
local p = dlg_stage_map;
local ui = ui_dlg_stage_map;

p.layer = nil;
p.chapterId = nil;

--��ť��ǩ
p.chapterTag = {};

--��ʾUI
function p.ShowUI( tileObj, rowlist_stageMap )
	if tileObj == nil then return false end;
	
	--��ʾ�򴴽�layer
    if p.layer ~= nil then
		p.layer:SetVisible( true );
	else
		local layer = createNDUIDialog();
		if layer == nil then
			return false;
		end
		
		layer:NoMask();
		layer:Init(layer);
		layer:SetSwallowTouch(false);
		layer:SetFrameRectFull();

		tileObj:AddChild(layer);		
		LoadDlg("dlg_stage_map.xui", layer, nil);
		p.chapterId = tileObj:GetId();
		p.SetDelegate( layer, tileObj, rowlist_stageMap );
		
		p.layer = layer;
	end
	
	--����λ�úͳߴ�
	local objSize = tileObj:GetFrameSize();
	local bgSize = p.GetBgSize();
	local x = 0.5f * objSize.w - 0.5f * bgSize.w;
	local y = 0.5f * objSize.h - 0.5f * bgSize.h;
	local rect = CCRectMake( x, y, bgSize.w, bgSize.h );
	p.layer:SetFrameRect( rect );
end

--��ʼ����ť
function p.SetDelegate( layer, tileObj, rowlist_stageMap )
	--��ť��ǩ
	p.chapterTag = {
					   ui.ID_CTRL_BUTTON_1,
					   ui.ID_CTRL_BUTTON_2,
					   ui.ID_CTRL_BUTTON_3,
					   ui.ID_CTRL_BUTTON_4,
					   ui.ID_CTRL_BUTTON_5,
					   ui.ID_CTRL_BUTTON_6,
					   ui.ID_CTRL_BUTTON_7,
					   ui.ID_CTRL_BUTTON_8
				  };

    local mapAni = "map."..tileObj:GetName();
	for i=1,#rowlist_stageMap do
	   local btn = GetButton(layer,p.chapterTag[i] );
	   
	   --�ж��Ƿ����
       local isUnlock = true;
	   local needTravelId = SelectCellMatch( T_STAGE_OPEN_CHECK, "stage_id", rowlist_stageMap[i].id, "need_travel_id" );
	   if needTravelId ~= nil then
	       isUnlock = world_map.isTravelFinish( tonumber( needTravelId ) );
	   end
	   btn:SetEnabled( isUnlock );
		
	   btn:SetId( tonumber( rowlist_stageMap[i].id ) );
	   btn:SetName( rowlist_stageMap[i].stage_type );
	   if btn ~= nil then
		  btn:SetImage( GetPictureByAni(mapAni, i-1) );
		  btn:SetLuaDelegate(p.OnBtnClick);
	   else
		  WriteConErr( string.format( "GetButton() failed, tag=%d\r\n", p.chapterTag[i] ));
	   end
    end	   
end


--�¼�����
function p.OnBtnClick(uiNode, uiEventType, param)	
	local tag = uiNode:GetTag();
	local stageId = uiNode:GetId();
	local stageType = tonumber( uiNode:GetName() );
	local travelId = GetTravelId( p.chapterId, stageId );
	local mapName = GetMapName( travelId );
	if IsClickEvent( uiEventType ) then
		local tag = uiNode:GetTag();
		
		if ( ui.ID_CTRL_BUTTON_1 == tag ) then	
				WriteCon( "1");
				p.EnterMapByType( stageType, mapName, stageId );
				
		elseif ( ui.ID_CTRL_BUTTON_2 == tag ) then
				WriteCon( "2");
				p.EnterMapByType( stageType, mapName, stageId );
				
		elseif ( ui.ID_CTRL_BUTTON_3 == tag ) then
				WriteCon( "3");
				p.EnterMapByType( stageType, mapName, stageId );
				
		elseif ( ui.ID_CTRL_BUTTON_4 == tag ) then
				WriteCon( "4");
				p.EnterMapByType( stageType, mapName, stageId );
				
		elseif ( ui.ID_CTRL_BUTTON_5 == tag ) then
				WriteCon( "5");
				p.EnterMapByType( stageType, mapName, stageId );
				
		elseif ( ui.ID_CTRL_BUTTON_6 == tag ) then
				WriteCon( "6");
				p.EnterMapByType( stageType, mapName, stageId );
				
		elseif ( ui.ID_CTRL_BUTTON_7 == tag ) then
				WriteCon( "7");
				p.EnterMapByType( stageType, mapName, stageId );
				
		elseif ( ui.ID_CTRL_BUTTON_8 == tag ) then
				WriteCon( "8");
				p.EnterMapByType( stageType, mapName, stageId );
		end
        
	end
end

--���������ͼ�򸱱���ͼ
function p.EnterMapByType( stageType, mapName, stageId )
    --ע�⣺�ȹر����UI��رյ�ͼ��˳��Ҫ�ģ�
    p.CloseUI();
    if stageType == ENTER_MAP_TASK then
        game_main.EnterTaskMap( mapName, p.chapterId, stageId, stageType );
    elseif stageType == ENTER_MAP_DUNGEON then
        dlg_dungeon_enter.ShowUI( mapName, p.chapterId, stageId, stageType ); 
    end
end

function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end

function p.CloseUI()	
    if p.layer ~= nil then
	    p.layer:LazyClose();
        p.layer = nil;
    end
end

--��ȡ�װ�ߴ�
function p.GetBgSize()
	if p.layer ~= nil then
		local bg = GetImage( p.layer, ui.ID_CTRL_PICTURE_BG );
		if bg ~= nil then
			return bg:GetFrameSize();
		end
	end
	return SizeZero;
end