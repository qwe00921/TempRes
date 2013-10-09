--------------------------------------------------------------
-- FileName: 	global_event_define.lua
-- author:		
-- purpose:		ȫ���¼�����
--------------------------------------------------------------

local GLOBALEVENT_BEGIN = 100;

GLOBALEVENT = 
{
    GE_GENERATE_GAMESCENE		= GLOBALEVENT_BEGIN;
	GE_ITEM_UPDATE				= GLOBALEVENT_BEGIN + 1;
	GE_KILL_MONSTER				= GLOBALEVENT_BEGIN + 2;
    GE_LOGIN_GAME               = GLOBALEVENT_BEGIN + 3;
	GE_SWITCH					= GLOBALEVENT_BEGIN + 4,
    
	GE_ONMOVE							= GLOBALEVENT_BEGIN + 5,
	GE_ONMOVE_END						= GLOBALEVENT_BEGIN + 6,
	GE_QUITGAME							= GLOBALEVENT_BEGIN + 7,
	GE_BATTLE_BEGIN						= GLOBALEVENT_BEGIN + 8,
	GE_BATTLE_END						= GLOBALEVENT_BEGIN + 9,
	GE_CLICK_OTHERPLAYER                = GLOBALEVENT_BEGIN + 10,
	GE_LOGINOK_GUEST                    = GLOBALEVENT_BEGIN + 11,
	GE_LOGINOK_NORMAL                   = GLOBALEVENT_BEGIN + 12,
	GE_LOGINOK_GUEST2NORMAL             = GLOBALEVENT_BEGIN + 13,
	GE_LOGINERROR                       = GLOBALEVENT_BEGIN + 14,
	
	GE_GUIDETASK_ACTION					= GLOBALEVENT_BEGIN + 15,
	
	
	
	GE_UPDATE_GAME                      = GLOBALEVENT_BEGIN + 90,
    
    
    
};