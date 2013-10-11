--------------------------------------------------------------
-- FileName: 	cmd_lua_callback.lua
-- author:		zhangwq, 2013/06/02
-- purpose:		lua����ص���������
--------------------------------------------------------------

cmd_lua_callback = {}
local p = cmd_lua_callback;


---------------------------------------------------
--Lua����ص�
--����: cmdtype		lua��������
--		id			���id
--		num			��ֵ����1
--		str			�ִ�����2
---------------------------------------------------
function p.CmdLuaHandler( cmdtype, id, num, str )
	local str = string.format( "p.CmdLuaHandler(): cmdtype=%s, id=%d, num=%f, str=%s", cmdtype, id, num, str );
	WriteCon( str );

	--����fighter
	local fighter = nil;
	if E_DEMO_VER == 2 then
		fighter = x_battle_mgr.FindFighter(id);
	elseif E_DEMO_VER == 3 then	
		fighter = card_battle_mgr.FindFighter(id);
	elseif E_DEMO_VER == 1 then	
		fighter = battle_mgr.FindFighter(id);
	end
	
	if fighter == nil then
		WriteCon( "find fighter failed: id="..id);
		return;
	end
		
	--ִ�о�������
	if cmdtype == "fighter_damage" then
		fighter:SetLifeDamage( num );
	elseif cmdtype == "AddMaskImage" then
		if E_DEMO_VER == 2 then
			x_battle_mgr:AddMaskImage();
		elseif E_DEMO_VER == 3 then	
			card_battle_mgr:AddMaskImage();
		end
	elseif cmdtype == "HideMaskImage" then
		if E_DEMO_VER == 2 then
			x_battle_mgr:HideMaskImage();
		elseif E_DEMO_VER == 3 then	
			card_battle_mgr:HideMaskImage();
		end
	elseif cmdtype == "ReSetSkillNameBarPos" then
		if E_DEMO_VER == 2 then
			x_battle_pvp:ReSetSkillNameBarPos();
		elseif E_DEMO_VER == 3 then	
			card_battle_pvp:ReSetSkillNameBarPos();
		end
	elseif cmdtype == "SetSkillNameBarToLeft" then
		if E_DEMO_VER == 2 then
			x_battle_pvp:SetSkillNameBarToLeft();
		elseif E_DEMO_VER == 3 then	
			card_battle_pvp:SetSkillNameBarToLeft();
		end
	elseif cmdtype == "SetSkillNameBarToRight" then
		if E_DEMO_VER == 2 then
			x_battle_pvp:SetSkillNameBarToRight();	
		elseif E_DEMO_VER == 3 then	
			card_battle_pvp:SetSkillNameBarToRight();	
		end
	elseif cmdtype == "skillbar_change" then
        fighter.skillbar.life = fighter.skillbar.life + num;
        if fighter.skillbar.life > 100 then
            fighter.skillbar.life = 100;
        end
        fighter.skillbar:SetLife(fighter.skillbar.life);
     elseif cmdtype == "update_team_rage" then
        card_battle_mgr.UpdateTeamRage( fighter.camp, num );
        
	else
		--
	end
end

RegCommandLuaHandler( p.CmdLuaHandler );