--------------------------------------------------------------
-- FileName: 	battle_ko.lua
-- author:		Guo Hao
-- purpose:		��������������ݣ�
-------------------------------------------------------------

battle_ko = {}
local p = battle_ko;

function p.ShowUI()
	local kLayer = createNDUIDialog();
    if kLayer == nil then
        return false;
    end

	kLayer:Init();
	kLayer:SetSwallowTouch(false);
	kLayer:SetFrameRectFull();
	GetRunningScene():AddChild(kLayer);

    LoadUI("x_battle_ko.xui",kLayer, nil);
end