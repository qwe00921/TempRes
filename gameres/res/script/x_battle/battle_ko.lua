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
p.m_nLeftCurrentMp = 0;
p.m_nRightCurrentMp = 0;
p.m_nLeftTotalMp = 0;
p.m_nRightTotalMp = 0;
p.m_kLayer = nil;
p.m_nHpTimer = 0;
p.m_nMpTimer = 0;
p.m_bIsOver = false;

function p.ShowUI()
	if nil == p.m_kLayer then
		local kLayer = createNDUIDialog();
		if kLayer == nil then
			return false;
		end
		
		kLayer:Init();
		kLayer:SetSwallowTouch(false);
		kLayer:SetFrameRectFull();
		GetRunningScene():AddChild(kLayer);
		
	    LoadUI("x_battle_ko.xui",kLayer, nil);
		
		p.m_kLayer = kLayer;
	end
	
	if false == p.InitHpBar() then
		return false;
	end
	
	if false == p.InitMpBar() then
		return false;
	end
	
	return true;
end

function p.CloseUI()
	
end

function p.HideUI()
	
end

function p.InitMpBar()
	p.m_nLeftCurrentMp = 100;
	p.m_nRightCurrentMp = 100;
	p.m_nLeftTotalMp = 100;
	p.m_nRightTotalMp = 100;
	
	p.m_kLeftMp = createNDUIExp();
	p.m_kRightMp = createNDUIExp();
	
	p.m_kLeftMp:Init("","");
	p.m_kRightMp:Init("","");
	
	local picBg = GetPictureByAni( "lancer.hpbar", 2 );
	local picFg = GetPictureByAni( "lancer.hpbar", 1 );
	
	if nil == picBg or nil == picFg then
		WriteCon("Can't found hp bar picture!");
	end
	
	p.m_kLeftMp:SetPicture(picBg,picFg);
	p.m_kRightMp:SetPicture(picFg,picBg);
	
	p.m_kLeftMp:SetTotal(p.m_nLeftTotalMp);
	p.m_kLeftMp:SetProcess(p.m_nLeftTotalMp - p.m_nLeftCurrentMp);
	
	p.m_kRightMp:SetTotal(p.m_nRightCurrentMp);
	p.m_kRightMp:SetProcess(p.m_nRightTotalMp);
	
	p.m_kLayer:AddChildZ(p.m_kLeftMp,100);
	p.m_kLayer:AddChildZ(p.m_kRightMp,100);
	
	p.m_kLeftMp:SetFrameRect(CCRectMake(640 / 2 - 200 - 10,480,200,80));
	p.m_kRightMp:SetFrameRect(CCRectMake(640 / 2 + 10,480,200,80));
	
	p.m_kLeftMp:SetNoText();
	p.m_kRightMp:SetNoText();
	
	p.m_nMpTimer = SetTimer( p.MpAdd, 0.02f );
	
	return true;
end

function p.InitHpBar()
    if p.m_kLayer == nil then
        return false;
    end
	
	p.m_nLeftCurrentHp = 100;
	p.m_nRightCurrentHp = 100;
	p.m_nLeftTotalHp = 100;
	p.m_nRightTotalHp = 100;
	
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
	
	p.m_kLayer:AddChildZ(p.m_kLeftHp,100);
	p.m_kLayer:AddChildZ(p.m_kRightHp,100);
	
	p.m_kLeftHp:SetFrameRect(CCRectMake(640 / 2 - 200 - 10,400,200,80));
	p.m_kRightHp:SetFrameRect(CCRectMake(640 / 2 + 10,400,200,80));
	
	p.m_kLeftHp:SetNoText();
	p.m_kRightHp:SetNoText();
	
	p.m_nHpTimer = SetTimer( p.HpAdd, 0.02f );
	
	return true;
end

function p.HpAdd()
	p.m_nLeftCurrentHp = p.m_nLeftCurrentHp - 2.2;
	p.m_nRightCurrentHp = p.m_nRightCurrentHp - 3.11;
	
	if 0 > p.m_nLeftCurrentHp then
		p.m_nLeftCurrentHp = 0;
		p.m_kLeftHp:SetProcess(p.m_nLeftTotalHp);
		KillTimer(p.m_nHpTimer);
		return;
	end
	
	if 0 > p.m_nRightCurrentHp then
		p.m_nRightCurrentHp = 0;
		p.m_kRightHp:SetProcess(0);
		KillTimer(p.m_nHpTimer);
		return;
	end
	
	p.m_kLeftHp:SetProcess(p.m_nLeftTotalHp - p.m_nLeftCurrentHp);
	p.m_kRightHp:SetProcess(p.m_nRightCurrentHp);
end

function p.MpAdd()
	p.m_nLeftCurrentMp = p.m_nLeftCurrentMp - 4.52;
	p.m_nRightCurrentMp = p.m_nRightCurrentMp - 0.51;
	
	if 0 > p.m_nLeftCurrentMp then
		p.m_nLeftCurrentMp = 0;
		p.m_kLeftMp:SetProcess(p.m_nLeftTotalMp);
		KillTimer(p.m_nMpTimer);
		return;
	end
	
	if 0 > p.m_nRightCurrentMp then
		p.m_nRightCurrentMp = 0;
		p.m_kRightMp:SetProcess(0);
		KillTimer(p.m_nMpTimer);
		return;
	end
	
	p.m_kLeftMp:SetProcess(p.m_nLeftTotalMp - p.m_nLeftCurrentMp);
	p.m_kRightMp:SetProcess(p.m_nRightCurrentMp);
end

function p.InitFighters()
	
end