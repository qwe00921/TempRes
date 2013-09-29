--------------------------------------------------------------
-- FileName: 	music_func.lua
-- author:		
-- purpose:		±≥æ∞“Ù¿÷∫Ø ˝
--------------------------------------------------------------


--≤•∑≈’Ω∂∑“Ù¿÷
function PlayMusic_Battle()
	StopBGMusic()
	
	if E_DEMO_VER == 1 then
        PlayBGMusicByName( "bgm_battle.mp3" );
    elseif E_DEMO_VER == 2 then
        PlayBGMusicByName( "bgm_battle_v2.mp3" );
    elseif E_DEMO_VER == 3 then
        PlayBGMusicByName( "bgm_battle_v2.mp3" );--@todo        
    end        
end

--≤•∑≈»ŒŒÒµÿÕº“Ù¿÷
function PlayMusic_Task()
    StopBGMusic()
    
    if E_DEMO_VER == 1 then
        PlayBGMusicByName( "bgm_task.mp3" );
    elseif E_DEMO_VER == 2 then        
        PlayBGMusicByName( "bgm_task.mp3" );
    elseif E_DEMO_VER == 3 then    
        PlayBGMusicByName( "bgm_task.mp3" );
    end        
end

--≤•∑≈÷˜ΩÁ√Ê“Ù¿÷
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
end

--Õ£÷π±≥æ∞“Ù¿÷
function StopMusic()
    StopBGMusic();
end