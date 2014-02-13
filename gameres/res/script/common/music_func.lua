--------------------------------------------------------------
-- FileName: 	music_func.lua
-- author:		
-- purpose:		背景音乐函数
--------------------------------------------------------------


MUSIC_GLOBAL_MUSICE  = 1;
MUSIC_GLOBAL_SILENT = 1;

--[[
	1	 battle
	2	 task
	3	 mainui
	4    loginui
	5	 shopui;
]]--

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
	if MUSIC_GLOBAL_SILENT == 0 then
		return;
	end
	
	PlayBGMusicByName( "bgm_battle.mp3" );
	MUSIC_GLOBAL_MUSICE = 1
end

--播放任务地图音乐
function PlayMusic_Task(chapter)
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
	
	if MUSIC_GLOBAL_SILENT == 0 then
		return;
	end
	
	if chapter == 1 then
		PlayBGMusicByName( "bgm_task_chapter_1.mp3" );
	else
		PlayBGMusicByName( "bgm_task.mp3" );
	end
	
	MUSIC_GLOBAL_MUSICE = 2
	
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
	
	if MUSIC_GLOBAL_SILENT == 0 then
		return;
	end
	
	PlayBGMusicByName( "bgm_main.mp3" ); 
	MUSIC_GLOBAL_MUSICE = 3
end

--播放登录界面音乐
function PlayMusic_LoginUI()
    StopBGMusic()
	
	if MUSIC_GLOBAL_SILENT == 0 then
		return;
	end
	
	PlayBGMusicByName( "bgm_login.mp3" ); 
	MUSIC_GLOBAL_MUSICE = 4
end

--播放商店,卡组,邮件等界面音乐
function PlayMusic_ShopUI()

	if MUSIC_GLOBAL_MUSICE ~= 5 then
		StopBGMusic()
		
		if MUSIC_GLOBAL_SILENT == 0 then
			return;
		end
	
		PlayBGMusicByName( "bgm_shop.mp3" ); 
		MUSIC_GLOBAL_MUSICE = 5;
	end
end

function PlayMusic_Country()
	if MUSIC_GLOBAL_SILENT == 0 then
		return;
	end
	
	PlayBGMusicByName( "bgm_country.mp3" ); 
	MUSIC_GLOBAL_MUSICE = 6
	
end

--停止背景音乐
function StopMusic()
    StopBGMusic();
	MUSIC_GLOBAL_MUSICE = 0;
end