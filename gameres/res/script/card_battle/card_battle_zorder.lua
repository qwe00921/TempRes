--------------------------------------------------------------
-- FileName: 	card_battle_zorder.lua
-- author:		zhangwq, 2013/9/9
-- purpose:		����ս��Z������
--------------------------------------------------------------

card_battle_zorder = {}
local p = card_battle_zorder;

local idTimer_SortZOrder = 0; --��ʱ����ZOrder

--��ʱ����Z�� (every tick)
function p.SortZOrder()
	if idTimer_SortZOrder == 0 then
		idTimer_SortZOrder = SetTimer( p.OnTimer_SortZOrder, 0.04f );
	end	
end

--����Z��
function p.ResetZOrder()
	--WriteCon( "card_battle_zorder: ResetZOrder" );
	
	--����Z��
	local layer = card_battle_mgr.GetBattleLayer();
	if layer ~= nil then 
		layer:ResetZOrder();
	end
	
	--ɾ����ʱ
	if idTimer_SortZOrder > 0 then
		KillTimer( idTimer_SortZOrder );
		idTimer_SortZOrder = 0;	
	end
end

--��ʱ����Z��
function p.OnTimer_SortZOrder()
	--WriteCon( "card_battle_mainui: OnTimer_SortZOrder" );
	local layer = card_battle_mgr.GetBattleLayer();
	if layer ~= nil then
		layer:SortZOrder();
	end
end