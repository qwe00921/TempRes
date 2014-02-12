--------------------------------------------------------------
-- FileName: 	music_func.lua
-- author:		
-- purpose:		�������ֺ���
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

--����ս������
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

--���������ͼ����
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

--��������������
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

--���ŵ�¼��������
function PlayMusic_LoginUI()
    StopBGMusic()
	
	if MUSIC_GLOBAL_SILENT == 0 then
		return;
	end
	
	PlayBGMusicByName( "bgm_login.mp3" ); 
	MUSIC_GLOBAL_MUSICE = 4
end

--�����̵�,����,�ʼ��Ƚ�������
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

--ֹͣ��������
function StopMusic()
    StopBGMusic();
	MUSIC_GLOBAL_MUSICE = 0;
end