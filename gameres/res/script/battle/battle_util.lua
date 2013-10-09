--------------------------------------------------------------
-- FileName: 	battle_util.lua
-- author:		zhangwq, 2013/05/16
-- purpose:		战士常用函数（单实例）
--------------------------------------------------------------

battle_util = {}
local p = battle_util;


--计算fighterA到fighterB的方向
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
