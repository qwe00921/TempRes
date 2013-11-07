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
p.m_nLeftCurrentHp = 0;
p.m_nRightCurrentHp = 0;
p.m_nLeftTotalHp = 0;
p.m_nRightTotalHp = 0;

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
	
	p.m_nLeftCurrentHp = 100;
	p.m_nRightCurrentHp = 100;
	p.m_nLeftTotalHp = 100;
	p.m_nRightTotalHp = 100;

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
	p.m_kRightHp:SetPicture(picFg,picBg);
	
	p.m_kLeftHp:SetTotal(p.m_nLeftTotalHp);
	p.m_kLeftHp:SetProcess(p.m_nLeftTotalHp - p.m_nLeftCurrentHp);
	
	p.m_kRightHp:SetTotal(p.m_nRightCurrentHp);
	p.m_kRightHp:SetProcess(p.m_nRightTotalHp);
	
	kLayer:AddChildZ(p.m_kLeftHp,100);
	kLayer:AddChildZ(p.m_kRightHp,100);
	
	p.m_kLeftHp:SetFrameRect(CCRectMake(640 / 2 - 200 - 10,400,200,80));
	p.m_kRightHp:SetFrameRect(CCRectMake(640 / 2 + 10,400,200,80));
	
	SetTimer( p.HpAdd, 0.02f );
	
	return true;
end

function p.HpAdd()
	p.m_nLeftCurrentHp = p.m_nLeftCurrentHp - 0.2;
	p.m_nRightCurrentHp = p.m_nLeftCurrentHp - 0.11;

	p.m_kLeftHp:SetProcess(p.m_nLeftTotalHp - p.m_nLeftCurrentHp);
	p.m_kRightHp:SetProcess(p.m_nLeftCurrentHp);
end