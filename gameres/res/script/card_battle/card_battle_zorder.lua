--------------------------------------------------------------
-- FileName: 	card_battle_zorder.lua
-- author:		zhangwq, 2013/9/9
-- purpose:		卡牌战斗Z序问题
--------------------------------------------------------------

card_battle_zorder = {}
local p = card_battle_zorder;

local idTimer_SortZOrder = 0; --定时更新ZOrder

--定时更新Z序 (every tick)
function p.SortZOrder()
	if idTimer_SortZOrder == 0 then
		idTimer_SortZOrder = SetTimer( p.OnTimer_SortZOrder, 0.04f );
	end	
end

--重置Z序
function p.ResetZOrder()
	--WriteCon( "card_battle_zorder: ResetZOrder" );
	
	--重置Z序
	local layer = card_battle_mgr.GetBattleLayer();
	if layer ~= nil then 
		layer:ResetZOrder();
	end
	
	--删除定时
	if idTimer_SortZOrder > 0 then
		KillTimer( idTimer_SortZOrder );
		idTimer_SortZOrder = 0;	
	end
end

--定时更新Z序
function p.OnTimer_SortZOrder()
	--WriteCon( "card_battle_mainui: OnTimer_SortZOrder" );
	local layer = card_battle_mgr.GetBattleLayer();
	if layer ~= nil then
		layer:SortZOrder();
	end
end