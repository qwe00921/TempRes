--------------------------------------------------------------
-- FileName: 	cmd_lua_callback.lua
-- author:		zhangwq, 2013/06/02
-- purpose:		lua命令回调（单例）
--------------------------------------------------------------

cmd_lua_callback = {}
local p = cmd_lua_callback;


---------------------------------------------------
--Lua命令回调
--参数: cmdtype		lua命令类型
--		id			物件id
--		num			数值参数1,
--		str			字串参数2
---------------------------------------------------
function p.CmdLuaHandler( cmdtype, id, num, str )
--	local str = string.format( "p.CmdLuaHandler(): cmdtype=%s, id=%d, num=%f, str=%s", cmdtype, id, num, str );
--	WriteCon( str );

	--查找fighter
	local fighter = nil;
	if E_DEMO_VER == 2 then
		fighter = x_battle_mgr.FindFighter(id);
	elseif E_DEMO_VER == 3 then	
		fighter = card_battle_mgr.FindFighter(id);
	elseif E_DEMO_VER == 1 then	
		fighter = battle_mgr.FindFighter(id);
	elseif E_DEMO_VER == 4 then    
        fighter = n_battle_mgr.FindFighter(id);
	end
	
	
	if fighter == nil and (E_DEMO_VER ~= 4) and (E_DEMO_VER ~= 5) then
		WriteCon( "find fighter failed: id="..id);
		return;
	end
	
	--执行具体命令
	if cmdtype == "fighter_damage" then
		fighter:SetLifeDamage(num);
	elseif cmdtype == "buffEnd"  and E_DEMO_VER == 5 then
		w_battle_mgr.BuffEnd();
	elseif cmdtype == "atk_startsing"  and E_DEMO_VER == 5 then
	    local lstateMachine = w_battle_machinemgr.getAtkStateMachine(num);
		if lstateMachine ~= nil then
			lstateMachine:atk_startsing();
		end;
	elseif cmdtype == "atk_start"  and E_DEMO_VER == 5 then
	    local lstateMachine = w_battle_machinemgr.getAtkStateMachine(num);
		if lstateMachine ~= nil then
			lstateMachine:atk_start();
		end;
	elseif cmdtype == "atk_startAtk"  and E_DEMO_VER == 5 then
	    local lstateMachine = w_battle_machinemgr.getAtkStateMachine(num);
		if lstateMachine ~= nil then
			lstateMachine:atk_startAtk();
		end;
    elseif cmdtype == "atk_end" and E_DEMO_VER == 5 then
		local lstateMachine = w_battle_machinemgr.getAtkStateMachine(num);
		if lstateMachine ~= nil then
			lstateMachine:atk_end();
		end;
	elseif cmdtype == "atk_moveback" and E_DEMO_VER == 5 then
		local lstateMachine = w_battle_machinemgr.getAtkStateMachine(num);
		if lstateMachine ~= nil then
			lstateMachine:atk_moveback();
		end;
    elseif cmdtype == "atk_startBuff" and E_DEMO_VER == 5 then
		local lstateMachine = w_battle_machinemgr.getAtkStateMachine(num);
		if lstateMachine ~= nil then
			lstateMachine:atk_startBuff();
		end;
	elseif cmdtype == "atk_BuffEnd" and E_DEMO_VER == 5 then
		local lstateMachine = w_battle_machinemgr.getAtkStateMachine(num);
		if lstateMachine ~= nil then
			lstateMachine:atk_BuffEnd();
		end;		
	elseif cmdtype == "atk_guidstep3_3" and E_DEMO_VER == 5 then
		local lstateMachine = w_battle_machinemgr.getAtkStateMachine(num);
		if lstateMachine ~= nil then
			lstateMachine:atk_guidstep3_3();
		end;			
	elseif cmdtype == "tar_hurt" and E_DEMO_VER == 5 then
		local lstateMachine = w_battle_machinemgr.getTarStateMachine(str,num);
		if lstateMachine ~= nil then
			lstateMachine:tar_hurt();
		end;
	elseif cmdtype == "tar_hurtEnd" and E_DEMO_VER == 5 then
		local lstateMachine = w_battle_machinemgr.getTarStateMachine(str,num);
		if lstateMachine ~= nil then
			lstateMachine:tar_hurtEnd();
		end;
	elseif cmdtype == "tar_ReviveEnd" and E_DEMO_VER == 5 then
		local lstateMachine = w_battle_machinemgr.getTarStateMachine(str,num);
		if lstateMachine ~= nil then
			lstateMachine:tar_ReviveEnd();
		end;
	elseif cmdtype == "tar_dieEnd" and E_DEMO_VER == 5 then
		local lstateMachine = w_battle_machinemgr.getTarStateMachine(str,num);
		if lstateMachine ~= nil then
			lstateMachine:tar_dieEnd();
		end;
	elseif cmdtype == "nextBuff" then
		local lstateMachine = w_battle_machinemgr.getBuffStateMachine(id);
		if lstateMachine ~= nil then
			lstateMachine:nextBuff();
		end;
	elseif cmdtype == "buff_dieEnd" then
		local lstateMachine = w_battle_machinemgr.getBuffStateMachine(id);
		if lstateMachine ~= nil then
			lstateMachine:buff_dieEnd();
		end;			
	elseif cmdtype == "buff_ReviveEnd" then
		local lstateMachine = w_battle_machinemgr.getBuffStateMachine(id);
		if lstateMachine ~= nil then
			lstateMachine:buff_ReviveEnd();
		end;			
		
	elseif cmdtype == "fighter_addHp" then
        fighter:SetLifeAdd( num );	
	elseif cmdtype == "fighter_strike_damage" then
		fighter:SetLifeStrikeDamage(num);
	elseif cmdtype == "fighter_heal" then
		fighter:SetLifeHeal(num);
	elseif cmdtype == "fighter_showbar" then
		fighter:ShowHpBarMoment();

	elseif cmdtype == "ReSetPetNodePos" and E_DEMO_VER == 4 then
        n_battle_mgr.ReSetPetNodePos(); 
	elseif cmdtype == "ReSetPetNodePos" and E_DEMO_VER == 5 then
		w_battle_mgr.ReSetPetNodePos(); 

    elseif cmdtype == "SetFighterPic" and E_DEMO_VER == 4 then
        n_battle_pvp.SetFighterPic( fighter ); 
    elseif cmdtype == "SetFighterPic" and E_DEMO_VER == 5 then
        w_battle_pvp.SetFighterPic( fighter ); 

    elseif cmdtype == "ClearAllFighterPic" and E_DEMO_VER == 4 then
        n_battle_pvp.ClearAllFighterPic();    
    elseif cmdtype == "UpdatePetRage" and E_DEMO_VER == 4 then
        n_battle_pvp.UpdatePetRage( id , -num );    
	elseif cmdtype == "UpdatePetRage" and E_DEMO_VER == 5 then
        w_battle_pvp.UpdatePetRage( id , -num );
		    		
    elseif cmdtype == "fighter_revive" and E_DEMO_VER == 4 then
        FighterRevive( fighter , num );        
		
	elseif cmdtype == "AddMaskImage" then
		if E_DEMO_VER == 2 then
			x_battle_mgr:AddMaskImage();
		elseif E_DEMO_VER == 3 then	
			card_battle_mgr:AddMaskImage();
		elseif E_DEMO_VER == 4 then   
            n_battle_mgr:AddMaskImage();
		elseif E_DEMO_VER == 5 then   
            w_battle_mgr:AddMaskImage();			
		end
	elseif cmdtype == "HideMaskImage" then
		if E_DEMO_VER == 2 then
			x_battle_mgr:HideMaskImage();
		elseif E_DEMO_VER == 3 then	
			card_battle_mgr:HideMaskImage();
		elseif E_DEMO_VER == 4 then   
            n_battle_mgr:HideMaskImage();	
		elseif E_DEMO_VER == 5 then   
            w_battle_mgr:HideMaskImage();				
		end
	elseif cmdtype == "ReSetSkillNameBarPos" then
		if E_DEMO_VER == 2 then
			x_battle_pvp:ReSetSkillNameBarPos();
		elseif E_DEMO_VER == 3 then	
			card_battle_pvp:ReSetSkillNameBarPos();
		elseif E_DEMO_VER == 4 then   
            n_battle_pvp:ReSetSkillNameBarPos();	
		elseif E_DEMO_VER == 5 then   
            w_battle_pvp:ReSetSkillNameBarPos();				
		end
	elseif cmdtype == "SetSkillNameBarToLeft" then
		if E_DEMO_VER == 2 then
			x_battle_pvp:SetSkillNameBarToLeft();
		elseif E_DEMO_VER == 3 then	
			card_battle_pvp:SetSkillNameBarToLeft();
		elseif E_DEMO_VER == 4 then   
            n_battle_pvp:SetSkillNameBarToLeft();
		elseif E_DEMO_VER == 5 then   
            w_battle_pvp:SetSkillNameBarToLeft();			
		end
	elseif cmdtype == "SetSkillNameBarToRight" then
		if E_DEMO_VER == 2 then
			x_battle_pvp:SetSkillNameBarToRight();	
		elseif E_DEMO_VER == 3 then	
			card_battle_pvp:SetSkillNameBarToRight();	
		elseif E_DEMO_VER == 4 then   
            n_battle_pvp:SetSkillNameBarToRight();  
		elseif E_DEMO_VER == 5 then   
            w_battle_pvp:SetSkillNameBarToRight();  			
		end
	elseif cmdtype == "skillbar_change" then
        fighter.skillbar.life = fighter.skillbar.life + num;
        if fighter.skillbar.life > 100 then
            fighter.skillbar.life = 100;
        end
        fighter.skillbar:SetLife(fighter.skillbar.life);
     elseif cmdtype == "update_team_rage" then
        card_battle_mgr.UpdateTeamRage( fighter.camp, num );
	elseif cmdtype == "equip_rein_effect" then
		equip_rein_result.equip_rein_effect_finish();
	elseif cmdtype == "PickEnd" then
		w_battle_mgr.PickItem( id, num );
	else
		--
	end
end

RegCommandLuaHandler( p.CmdLuaHandler );