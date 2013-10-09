--------------------------------------------------------------
-- FileName: 	dlg_dungeon_enter.lua
-- author:		hst, 2013��8��13��
-- purpose:		���븱��
--------------------------------------------------------------

dlg_dungeon_enter = {}
local p = dlg_dungeon_enter;
p.layer = nil;

p.difficultyBtn1 = nil;
p.difficultyBtn2 = nil;
p.difficultyBtn3 = nil;

p.dungeonProgress = nil;

p.selectDifficulty = 1;
p.isOpenDifficulty_1 = true;
p.isOpenDifficulty_2 = false;
p.isOpenDifficulty_3 = false;

p.bossName = nil;
p.fightLimit = nil;
p.spendPoint = nil;
p.highScore = nil;
p.dumgeonInfoList = nil;
p.fightNum = nil;

p.map = nil;
p.stageId = nil;
p.chapterId = nil;
p.stageType = nil;

---------��ʾUI----------
function p.ShowUI( map, chapterId, stageId, stageType )
    if map == nil or chapterId == nil or stageId == nil or stageType == nil then
    	return false;
    else
        p.map = map;
        p.chapterId = chapterId;
        p.stageId = stageId;
        p.stageType = stageType;	
    end
    if p.layer ~= nil then
        p.layer:SetVisible( true );
    else
        local layer = createNDUIDialog();
        if layer == nil then
            return false;
        end

        layer:Init();
        GetUIRoot():AddDlg(layer);

        LoadDlg("dlg_dungeon_enter.xui", layer, nil);

        p.SetDelegate(layer);
        p.layer = layer;

        --p.DoEffect();
        --p.Init();
        p.SendReq( chapterId, stageId )
    end
end

-- ��ȡ������Ϣ
function p.SendReq( chapterId, stageId )
    ShowLoading( true );
    local user_id = GetUID();
    local param = string.format("&chapter_id=%d&stage_id=%d", chapterId, stageId);
    SendReq( "Dungeon","GetUserDungeonProgress",user_id,param );
end

function p.RefreshUI( msg )
    ShowLoading( false );
    p.dungeonProgress = msg.user_dungeon_progress;
    p.dumgeonInfoList = SelectRowList( T_TRAVEL_DUNGEON_INFO, "stage_id", p.stageId );
    if p.dumgeonInfoList ~= nil then
        p.bossName = p.dumgeonInfoList[1].boss_name;
    end
    p.spendPoint = p.GetSpendPoint();
    p.highScore = p.GetHighScore();
    p.fightLimit = p.GetFightLimit();
    p.fightNum = p.GetFightNum();
    p.InitDifficultyBtn();
    p.Init();
end

--��ȡ��Ӧ�Ѷ����ĵ�����
function p.GetSpendPoint()
    if p.dumgeonInfoList ~= nil then
        for k, v in ipairs(p.dumgeonInfoList) do
            if tonumber( v.difficulty )== p.selectDifficulty then
                return v.spend_point;
            end
        end
    end
    return 0;
end

--��ʹ���ѶȰ�ť
function p.InitDifficultyBtn()
    if p.dungeonProgress ~= nil then
    	for k, v in ipairs(p.dungeonProgress) do
    		if tonumber( v.difficulty ) == 1 then
                p.isOpenDifficulty_2 = true;
    		elseif tonumber( v.difficulty ) == 2 then
                p.isOpenDifficulty_3 = true;	
    		end
    	end
    end
    p.difficultyBtn1:SetEnabled( p.isOpenDifficulty_1 );
    p.difficultyBtn2:SetEnabled( p.isOpenDifficulty_2 );
    p.difficultyBtn3:SetEnabled( p.isOpenDifficulty_3 );
end

--��ȡ������ͬ�Ѷȵ���߷���
function p.GetHighScore()
    local highScore = 0;
	if p.dungeonProgress ~= nil then
        for k, v in ipairs(p.dungeonProgress) do
            if tonumber( v.difficulty ) == p.selectDifficulty then
                highScore = tonumber( v.high_score );
                break ;
            end
        end
    end
    return highScore;
end

--��ȡ�����븱���Ĵ���
function p.GetFightNum()
    local fightNum = 0;
    if p.dungeonProgress ~= nil then
        for k, v in ipairs(p.dungeonProgress) do
            fightNum = fightNum + tonumber( v.num );
        end
    end
    return fightNum;
end

--��ȡ���������������
function p.GetFightLimit()
    local fightLimit = 0;
    if p.stageId ~= nil then
    	local num = SelectCell( T_STAGE_MAP, p.stageId, "fight_limit" ); 
    	if num ~= nil then
    		fightLimit = tonumber( num );
    	end
    end
	return fightLimit;
end


--�����¼�����
function p.SetDelegate(layer)
    local pBtn01 = GetButton(layer,ui_dlg_dungeon_enter.ID_CTRL_BUTTON_ENTER);
    pBtn01:SetLuaDelegate(p.OnUIEvent);
    
    local pBtn02 = GetButton(layer,ui_dlg_dungeon_enter.ID_CTRL_BUTTON_BACK);
    pBtn02:SetLuaDelegate(p.OnUIEvent);

    p.difficultyBtn1 = GetButton(layer,ui_dlg_dungeon_enter.ID_CTRL_BUTTON_VAL_DIFFICULTY1);
    p.difficultyBtn1:SetLuaDelegate(p.OnUIEvent);
    
    p.difficultyBtn2 = GetButton(layer,ui_dlg_dungeon_enter.ID_CTRL_BUTTON_VAL_DIFFICULTY2);
    p.difficultyBtn2:SetLuaDelegate(p.OnUIEvent);
    
    p.difficultyBtn3 = GetButton(layer,ui_dlg_dungeon_enter.ID_CTRL_BUTTON_VAL_DIFFICULTY3);
    p.difficultyBtn3:SetLuaDelegate(p.OnUIEvent);

end

--�¼�����
function p.OnUIEvent(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    if IsClickEvent( uiEventType ) then
        if ( ui_dlg_dungeon_enter.ID_CTRL_BUTTON_ENTER == tag ) then
            WriteCon("���븱��");
            if p.fightNum >= p.fightLimit then
            	dlg_msgbox.ShowOK( ToUtf8( "��ʾ" ), ToUtf8( "������ս����������ƣ�������������" ), p.OnMsgBoxCallback );
            	return ;
            end
            if tonumber( world_map.userStatus.mission_point ) < tonumber( p.spendPoint ) then
                dlg_msgbox.ShowOK( ToUtf8( "��ʾ" ), ToUtf8( "�ж������㣬�޷����븱����" ), p.OnMsgBoxCallback );
                return ;
            end
            game_main.EnterTaskMap( p.map, p.chapterId, p.stageId, p.stageType, p.selectDifficulty );
            p.CloseUI();
            
        elseif ( ui_dlg_dungeon_enter.ID_CTRL_BUTTON_BACK == tag ) then
            p.CloseUI();

        elseif ( ui_dlg_dungeon_enter.ID_CTRL_BUTTON_VAL_DIFFICULTY1 == tag ) then
            p.selectDifficulty = 1;
            p.RefreshSpendPoint();
            p.RefreshHighScore();
            
        elseif ( ui_dlg_dungeon_enter.ID_CTRL_BUTTON_VAL_DIFFICULTY2 == tag ) then
            p.selectDifficulty = 2;
            p.RefreshSpendPoint();
            p.RefreshHighScore();
            
        elseif ( ui_dlg_dungeon_enter.ID_CTRL_BUTTON_VAL_DIFFICULTY3 == tag ) then
            p.selectDifficulty = 3;
            p.RefreshSpendPoint();
            p.RefreshHighScore();
            
        end
    end
end

function p.OnMsgBoxCallback()
	
end

--���ĵ���
function p.RefreshSpendPoint()
    p.spendPoint = p.GetSpendPoint();
    local point_lab = GetLabel( p.layer, ui_dlg_dungeon_enter.ID_CTRL_TEXT_LAB_POINT );
    local point_val = GetLabel( p.layer, ui_dlg_dungeon_enter.ID_CTRL_TEXT_VAL_POINT );
    point_val:SetText( p.spendPoint ); 
end

--�÷�
function p.RefreshHighScore()
    p.highScore = p.GetHighScore();
	local score_lab = GetLabel( p.layer, ui_dlg_dungeon_enter.ID_CTRL_TEXT_LAB_SCORE );
    local star1 = GetImage( p.layer,ui_dlg_dungeon_enter.ID_CTRL_PICTURE_STAR1 );
    local star2 = GetImage( p.layer,ui_dlg_dungeon_enter.ID_CTRL_PICTURE_STAR2 );
    local star3 = GetImage( p.layer,ui_dlg_dungeon_enter.ID_CTRL_PICTURE_STAR3 );
    
    if p.highScore == 0 then
        star1:SetPicture( GetPictureByAni( "ui.star_fx_1", -1 ) );
        star2:SetPicture( GetPictureByAni( "ui.star_fx_1", -1 ) );
        star3:SetPicture( GetPictureByAni( "ui.star_fx_1", -1 ) );
    elseif p.highScore == 1 then
        star1:SetPicture( GetPictureByAni( "ui.star_fx_1", 0 ) );
        star2:SetPicture( GetPictureByAni( "ui.star_fx_1", -1 ) );
        star3:SetPicture( GetPictureByAni( "ui.star_fx_1", -1 ) );
    elseif p.highScore == 2 then
        star1:SetPicture( GetPictureByAni( "ui.star_fx_1", 0 ) );
        star2:SetPicture( GetPictureByAni( "ui.star_fx_1", 0 ) );
        star3:SetPicture( GetPictureByAni( "ui.star_fx_1", -1 ) );
    elseif p.highScore == 3 then
        star1:SetPicture( GetPictureByAni( "ui.star_fx_1", 0 ) );
        star2:SetPicture( GetPictureByAni( "ui.star_fx_1", 0 ) );
        star3:SetPicture( GetPictureByAni( "ui.star_fx_1", 0 ) );
    end
    
end

function p.Init()
    --��������
    local stageMap = SelectRow( T_STAGE_MAP, p.stageId );
    
    local title = GetLabel( p.layer, ui_dlg_dungeon_enter.ID_CTRL_TEXT_TITLE );
    title:SetText( stageMap.stage_name );
    --����ͼƬ
    local logo = GetImage( p.layer,ui_dlg_dungeon_enter.ID_CTRL_PICTURE_LOGO );
    logo:SetPicture( GetPictureByAni("dungeon.1-1", 0) );

    --��������
    local descreption = GetLabel( p.layer, ui_dlg_dungeon_enter.ID_CTRL_TEXT_DESCREPTION );
    descreption:SetText( stageMap.stage_description );

    --BOSS����
    local boss_lab = GetLabel( p.layer, ui_dlg_dungeon_enter.ID_CTRL_TEXT_LAB_BOSS );
    local boss_val = GetLabel( p.layer, ui_dlg_dungeon_enter.ID_CTRL_TEXT_VAL_BOSS );
    boss_val:SetText( p.bossName );

    --�Ѷ�
    local difficulty = GetLabel( p.layer, ui_dlg_dungeon_enter.ID_CTRL_TEXT_LAB_DIFFICULTY );

    --�÷�
    p.RefreshHighScore();

    --��ս����
    local challenge_lab = GetLabel( p.layer, ui_dlg_dungeon_enter.ID_CTRL_TEXT_LAB_CHALLENGE );
    local challenge_val = GetLabel( p.layer, ui_dlg_dungeon_enter.ID_CTRL_TEXT_VAL_CHALLENGE );
    challenge_val:SetText( p.fightNum.."/"..p.fightLimit );

    --���ĵ���
    p.RefreshSpendPoint();
    
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
        p.difficultyBtn1 = nil;
        p.difficultyBtn2 = nil;
        p.difficultyBtn3 = nil;
        
        p.dungeonProgress = nil;
        
        p.selectDifficulty = 1;
        p.isOpenDifficulty_1 = true;
        p.isOpenDifficulty_2 = false;
        p.isOpenDifficulty_3 = false;
        
        p.bossName = nil;
        p.fightLimit = nil;
        p.spendPoint = nil;
        p.highScore = nil;
        p.dumgeonInfoList = nil;
        p.fightNum = nil;
        p.stageId = nil;
    end
end