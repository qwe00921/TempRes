--------------------------------------------------------------
-- FileName: 	battle_ko.lua
-- author:		Guo Hao
-- purpose:		剧情管理器（数据）
-------------------------------------------------------------

battle_ko = {}
local p = battle_ko;
p.m_kLeftHp = nil;
p.m_kLeftMp = nil;
p.m_kRightHp = nil;
p.m_kRightMp = nil;

function p.ShowUI()
	if false == p.InitUI() then
		return false;
	end
	
	return true;
end

function p.CloseUI()
	
end

function p.HideUI()
	
end

function p.InitUI()
	local kLayer = createNDUIDialog();
    if kLayer == nil then
        return false;
    end

	kLayer:Init();
	kLayer:SetSwallowTouch(false);
	kLayer:SetFrameRectFull();
	GetRunningScene():AddChild(kLayer);

    LoadUI("x_battle_ko.xui",kLayer, nil);
	
	p.m_kLeftHp = createNDUIExp();
	p.m_kRightHp = createNDUIExp();
	
	p.m_kLeftHp:Init("","");
	p.m_kRightHp:Init("","");
	
	local picBg = GetPictureByAni( "lancer.hpbar", 0 );
	local picFg = GetPictureByAni( "lancer.hpbar", 1 );
	
	if nil == picBg or nil == picFg then
		WriteCon("Can't found hp bar picture!");
	end
	
	p.m_kLeftHp:SetPicture(picBg,picFg);
	p.m_kRightHp:SetPicture(picBg,picFg);
	
	p.m_kLeftHp:SetTotal(1000);
	p.m_kLeftHp:SetProcess(1000);
	
	p.m_kRightHp:SetTotal(1000);
	p.m_kRightHp:SetProcess(1000);
	
	kLayer:AddChildZ(p.m_kLeftHp,100);
	kLayer:AddChildZ(p.m_kRightHp,100);
	
	p.m_kLeftHp:SetFrameRect(CCRectMake(80,400,200,80));
	p.m_kRightHp:SetFrameRect(CCRectMake(640 - 280,400,200,80));
	
	return true;
end