--------------------------------------------------------------
-- FileName: 	battle_util.lua
-- author:		zhangwq, 2013/05/16
-- purpose:		սʿ���ú�������ʵ����
--------------------------------------------------------------

battle_util = {}
local p = battle_util;


--����fighterA��fighterB�ķ���
function p.GetDir( A, B )
	local Ax,Ay = A:GetFighterCenterPos();
	local Bx,By = B:GetFighterCenterPos();
	
	local dir;
	if Bx > Ax then
		if By > Ay then
			dir = E_DIR_RB;
		else
			dir = E_DIR_RT;
		end
	elseif Bx < Ax then
		if By < Ay then
			dir = E_DIR_LT;
		else
			dir = E_DIR_LB;
		end
	else
		if By < Ay then
			dir = E_DIR_TOP;
		else
			dir = E_DIR_DOWN;
		end
	end
	return dir;
end
