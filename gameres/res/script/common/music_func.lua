--------------------------------------------------------------
-- FileName: 	music_func.lua
-- author:		
-- purpose:		背景音乐函数
--------------------------------------------------------------


--播放战斗音乐
function PlayMusic_Battle()
	StopBGMusic()
	--[[
	if E_DEMO_VER == 1 then
        PlayBGMusicByName( "bgm_battle.mp3" );
    elseif E_DEMO_VER == 2 then
        PlayBGMusicByName( "bgm_battle_v2.mp3" );
    elseif E_DEMO_VER == 3 then
        PlayBGMusicByName( "bgm_battle_v2.mp3" );--@todo        
    end        
	]]--
	PlayBGMusicByName( "bgm_battle.mp3" );
end

--播放任务地图音乐
function PlayMusic_Task()
    StopBGMusic()
    
	--[[
    if E_DEMO_VER == 1 then
        PlayBGMusicByName( "bgm_task.mp3" );
    elseif E_DEMO_VER == 2 then        
        PlayBGMusicByName( "bgm_task.mp3" );
    elseif E_DEMO_VER == 3 then    
        PlayBGMusicByName( "bgm_task.mp3" );
    end        
	]]--
	PlayBGMusicByName( "bgm_task.mp3" );
end

--播放主界面音乐
function PlayMusic_MainUI()
    StopBGMusic()
    
    --[[
    if E_DEMO_VER == 1 then
        --PlayBGMusicByName( "bgm_task.mp3" );        
    elseif E_DEMO_VER == 2 then        
        --PlayBGMusicByName( "bgm_task.mp3" );        
    elseif E_DEMO_VER == 3 then
        --PlayBGMusicByName( "bgm_task.mp3" );        
    end        
    --]]
	PlayBGMusicByName( "bgm_main.mp3" ); 
end

--播放登录界面音乐
function PlayMusic_LoginUI()
    StopBGMusic()
	PlayBGMusicByName( "bgm_login.mp3" ); 
end

--播放商店界面音乐
function PlayMusic_ShopUI()
    StopBGMusic()
	PlayBGMusicByName( "bgm_shop.mp3" ); 
end

--停止背景音乐
function StopMusic()
    StopBGMusic();
end